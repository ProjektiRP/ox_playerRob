Citizen.CreateThread(function()
    local resourceName = 'P_playerRob'

    while true do
        local currentResource = GetCurrentResourceName()
        if currentResource ~= resourceName then
            print('Change resource name to ' .. resourceName)
        end
        Citizen.Wait(60000) -- Check every minute
    end
end)
