local QBCore = exports['qb-core']:GetCoreObject()
local ESX = nil
local PlayingAnim = false

-- Localization texts --
local Project = {}

Citizen.CreateThread(function()
    while not ESX do
        ESX = QBCore.Functions.GetPlayerData()
        Citizen.Wait(0)
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
    local closestPlayer, distance = QBCore.Functions.GetClosestPlayer()
    return closestPlayer ~= -1 and distance <= 1.5
end

function IsArmedWithWeapon()
    local weaponHashes = {
        "WEAPON_KNIFE", "WEAPON_KNIFE_BOTTLE", "WEAPON_KNIFE_CERAMIC", "WEAPON_KNIFE_DAGGER", "WEAPON_KNIFE_HATCHET",
        "WEAPON_KNIFE_NIGHTSTICK", "WEAPON_KNIFE_SWITCHBLADE", "WEAPON_KNIFE_TACTICAL", "WEAPON_KNIFE_TRENCH",
        "WEAPON_KNIFE_WRENCH", "WEAPON_KNUCKLE", "WEAPON_MACHETE", "WEAPON_PISTOL", "WEAPON_PISTOL_MK2",
        "WEAPON_COMBATPISTOL", "WEAPON_APPISTOL", "WEAPON_PISTOL50", "WEAPON_SNSPISTOL", "WEAPON_HEAVYPISTOL",
        "WEAPON_VINTAGEPISTOL", "WEAPON_MARKSMANPISTOL", "WEAPON_STUNGUN", "WEAPON_REVOLVER", "WEAPON_REVOLVER_MK2",
        "WEAPON_DOUBLEACTION", "WEAPON_RAYPISTOL", "WEAPON_CERAMICPISTOL", "WEAPON_NAVYREVOLVER", "WEAPON_MICROSMG",
        "WEAPON_SMG", "WEAPON_SMG_MK2", "WEAPON_ASSAULTSMG", "WEAPON_COMBATPDW", "WEAPON_MACHINEPISTOL",
        "WEAPON_MINISMG", "WEAPON_RAYCARBINE", "WEAPON_PUMPSHOTGUN", "WEAPON_PUMPSHOTGUN_MK2", "WEAPON_SAWNOFFSHOTGUN",
        "WEAPON_ASSAULTSHOTGUN", "WEAPON_BULLPUPSHOTGUN", "WEAPON_MUSKET", "WEAPON_HEAVYSHOTGUN", "WEAPON_DBSHOTGUN",
        "WEAPON_AUTOSHOTGUN", "WEAPON_COMBATSHOTGUN", "WEAPON_ASSAULTRIFLE", "WEAPON_ASSAULTRIFLE_MK2", "WEAPON_CARBINERIFLE",
        "WEAPON_CARBINERIFLE_MK2", "WEAPON_ADVANCEDRIFLE", "WEAPON_SPECIALCARBINE", "WEAPON_SPECIALCARBINE_MK2",
        "WEAPON_BULLPUPRIFLE", "WEAPON_BULLPUPRIFLE_MK2", "WEAPON_COMPACTRIFLE", "WEAPON_MG", "WEAPON_COMBATMG",
        "WEAPON_COMBATMG_MK2", "WEAPON_GUSENBERG", "WEAPON_SNIPERRIFLE", "WEAPON_HEAVYSNIPER", "WEAPON_HEAVYSNIPER_MK2",
        "WEAPON_MARKSMANRIFLE", "WEAPON_MARKSMANRIFLE_MK2"
    }

    local weapon = GetSelectedPedWeapon(PlayerPedId())
    for _, hash in ipairs(weaponHashes) do
        if weapon == GetHashKey(hash) then
            return true
        end
    end

    return false
end

function RobPlayer()
    if not (IsPlayerArmed() or IsArmedWithWeapon()) then
        -- Notification if the player is unarmed
        local notificationMessage = Project.locales["need"]
        exports['okokNotify']:Alert('TSLA', notificationMessage, 5000, 'info', false)
        return
    end

    if IsPlayersNearby() then
        local closestPlayer, distance = QBCore.Functions.GetClosestPlayer()

        if distance <= 1.5 then
            local closestPlayerPed = GetPlayerPed(closestPlayer)
            local closestPlayerHasHandsUp = IsEntityPlayingAnim(closestPlayerPed, 'missminuteman_1ig_2', 'handsup_base', 3)

            if closestPlayerHasHandsUp or IsPlayerDead(closestPlayer) then
                if exports.ox_inventory:openInventory('player', GetPlayerServerId(closestPlayer)) then
                    -- Animation and interaction
                    PlayingAnim = true
                    LoadAnimDict('mini@repair')
                    TaskPlayAnim(PlayerPedId(), 'mini@repair', 'fixing_a_ped', 8.0, -8, -1, 49, 0, 0, 0, 0)
                    Citizen.Wait(8500)
                    ClearPedTasks(PlayerPedId())
                    PlayingAnim = false
                end
            else
                -- Notification if the player doesn't have hands up
                local notificationMessage = Project.locales["hands"]
                exports['okokNotify']:Alert('TSLA', notificationMessage, 5000, 'info', false)
            end
        else
            -- Notification if no players are nearby
            local notificationMessage = Project.locales["noplayers"]
            exports['okokNotify']:Alert('TSLA', notificationMessage, 5000, 'info', false)
        end
    end
end

-- Command --
RegisterCommand('rob', function()
    if not PlayingAnim then
        RobPlayer()
    else
        exports['okokNotify']:Alert('TSLA', 'You are already performing an action', 5000, 'info', false)
    end
end)


-- Localization texts --
Project.locales = {
    ["need"] = "You need a gun to rob someone!",
    ["noplayers"] = "No players nearby!",
    ["progressbar"] = "Checking pockets...",
    ["hands"] = "The player doesn't have hands up!"
}
