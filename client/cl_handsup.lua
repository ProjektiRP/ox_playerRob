-- Hands up
local canHandsUp = true
local handsup = false
local TIME = { Time = 0 }
local animDict = "random@mugging3"

AddEventHandler("handsup:toggle", function(param)
    canHandsUp = param
end)

function loadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(100)
    end
end

Citizen.CreateThread(function()
    while true do
        Wait(0)
        local playerPed = PlayerPedId()

        if canHandsUp then
            if IsControlJustPressed(1, 20) and (GetGameTimer() - TIME.Time) > 150 then -- Default button "Z"
                if handsup then
                    handsup = false
                    ClearPedSecondaryTask(playerPed)
                else
                    loadAnimDict(animDict)
                    handsup = true
                    TaskPlayAnim(playerPed, animDict, "handsup_standing_base", 1.2, 1.2, -1, 49, 0, 0, 0, 0)
                end
                
                TIME.Time = GetGameTimer()
            end
        end
    end
end)

-- Surrender
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(handsup and 1 or 500)
        if handsup then
            ESX.ShowHelpNotification('[~r~X~w~] Surrender') -- When hands up, press "X" to surrender
            if IsControlJustReleased(0, 73) then -- Default button "X"
                ExecuteCommand("e surrender")
            end

            -- Disable controls while hands are up
            for _, control in ipairs({24, 257, 25, 263, 80, 288, 289, 167, 59, 71, 72, 47, 264, 140, 141, 142, 143, 75}) do
                DisableControlAction(0, control, true)
            end
        end
    end
end)
