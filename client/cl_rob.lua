ESX = nil
local PlayingAnim = false

-- Localization texts --
local Project = {}

Citizen.CreateThread(function()
    while not ESX do
        ESX = exports['es_extended']:getSharedObject()
        Citizen.Wait(0)
    end

    ESX.PlayerData = ESX.GetPlayerData()
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
    local closestPlayer, distance = ESX.Game.GetClosestPlayer()
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
        ESX.ShowNotification(Project.locales["need"])
        return
    end

    if IsPlayersNearby() then
        local closestPlayer, distance = ESX.Game.GetClosestPlayer()

        if distance <= 1.5 then
            local closestPlayerPed = GetPlayerPed(closestPlayer)
            local closestPlayerHasHandsUp = IsEntityPlayingAnim(closestPlayerPed, "random@mugging3", "handsup_standing_base", 3)

            if closestPlayerHasHandsUp or IsPlayerDead(closestPlayer) then
                if lib.progressBar({
                    duration = 8500,
                    label = Project.locales["progressbar"],
                    useWhileDead = false,
                    canCancel = true,
                    disable = { move = true, car = true, combat = true },
                    anim = { dict = 'mini@repair', clip = 'fixing_a_ped' },
                    prop = {}
                }) then
                    exports.ox_inventory:openInventory('player', GetPlayerServerId(closestPlayer))
                end
            else
                -- Notification if the player doesn't have hands up
                ESX.ShowNotification(Project.locales["hands"])
            end
        else
            -- Notification if no players are nearby
            ESX.ShowNotification(Project.locales["noplayers"])
        end
    end
end

-- Command --
RegisterCommand('rob', function()
    RobPlayer()
end)

-- Register key mapping --
RegisterKeyMapping('rob', 'Rob a player', 'keyboard', 'G')

-- Localization texts --
Project.locales = {
    ["need"] = "You need something longer than your arm!",
    ["noplayers"] = "No players nearby!",
    ["progressbar"] = "Checking pockets...",
    ["hands"] = "The player doesn't have hands up!"
}
