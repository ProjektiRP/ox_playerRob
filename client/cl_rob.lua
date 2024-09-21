local QBCore = nil
local ESX = nil
local PlayingAnim = false
local Notify = function(message) end

-- Localization texts --
local Project = {}

Citizen.CreateThread(function()
    -- Check for QBCore first
    if exports['qb-core'] then
        QBCore = exports['qb-core']:GetCoreObject()
        Notify = function(message)
            QBCore.Functions.Notify(message, "info")
        end
    -- Check for ESX if QBCore is not found
    elseif exports['es_extended'] then
        ESX = exports['es_extended']:getSharedObject()
        Notify = function(message)
            TriggerEvent('esx:showNotification', message)
        end
    else
        Notify = function(message)
            exports.ox_lib:notify({
                title = "Notification",
                description = message,
                type = "info"
            })
        end
    end
end)

function LoadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(1)
    end
end

function IsPlayerArmed()
    return IsPedArmed(PlayerPedId(), 4)
end

function IsPlayersNearby()
    local closestPlayer, distance = -1, math.huge
    if QBCore then
        closestPlayer, distance = QBCore.Functions.GetClosestPlayer()
    elseif ESX then
        closestPlayer, distance = ESX.Game.GetClosestPlayer()
    end
    return closestPlayer ~= -1 and distance <= 1.5
end

function IsArmedWithWeapon()
    local weaponHashes = {
        "WEAPON_KNIFE", "WEAPON_KNIFE_BOTTLE", "WEAPON_KNIFE_CERAMIC", "WEAPON_KNIFE_DAGGER", 
        "WEAPON_ASSAULTRIFLE", "WEAPON_SNIPERRIFLE"
    }

    local weapon = GetSelectedPedWeapon(PlayerPedId())
    for _, hash in ipairs(weaponHashes) do
        if weapon == GetHashKey(hash) then
            return true
        end
    end
    return false
end

function HasPoliceJob()
    local playerData = QBCore and QBCore.Functions.GetPlayerData() or ESX.GetPlayerData()
    return playerData.job and playerData.job.name == "police"
end

function RobPlayer()
    if not (IsPlayerArmed() or IsArmedWithWeapon()) and not HasPoliceJob() then
        Notify(Project.locales["need"])
        return
    end

    if IsPlayersNearby() then
        local closestPlayer, distance = QBCore and QBCore.Functions.GetClosestPlayer() or ESX.Game.GetClosestPlayer()

        if distance <= 1.5 then
            local closestPlayerPed = GetPlayerPed(closestPlayer)
            local closestPlayerHasHandsUp = IsEntityPlayingAnim(closestPlayerPed, 'missminuteman_1ig_2', 'handsup_base', 3)

            if closestPlayerHasHandsUp or IsPlayerDead(closestPlayer) or HasPoliceJob() then
                if exports.ox_inventory:openInventory('player', GetPlayerServerId(closestPlayer)) then
                    PlayingAnim = true
                    LoadAnimDict('mini@repair')
                    TaskPlayAnim(PlayerPedId(), 'mini@repair', 'fixing_a_ped', 8.0, -8, -1, 49, 0, 0, 0, 0)

                    -- Notify the player being robbed
                    NotifyPlayerBeingRobbed(closestPlayer)

                    Citizen.Wait(8500)
                    ClearPedTasks(PlayerPedId())
                    PlayingAnim = false
                end
            else
                Notify(Project.locales["hands"])
            end
        else
            Notify(Project.locales["noplayers"])
        end
    end
end

function NotifyPlayerBeingRobbed(targetPlayer)
    local message = Project.locales["being_robbed"]
    Notify(message)
end

-- Command --
RegisterCommand('rob', function()
    if not PlayingAnim then
        RobPlayer()
    else
        Notify(Project.locales["performing_action"])
    end
end)

-- Localization texts --
Project.locales = {
    ["need"] = "You need a gun to rob someone!",
    ["noplayers"] = "No players nearby!",
    ["hands"] = "The player doesn't have hands up!",
    ["performing_action"] = "You are already performing an action",
    ["being_robbed"] = "Someone is checking your pockets!"
}
