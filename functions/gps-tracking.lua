GPS                     = {}


GPS.Initialization      = function(PlayerPed, train)
    PlayerPed = GetPlayerPed(-1)
    PlayerCoords = GetEntityCoords(PlayerPed)
    for i,stop in pairs(Config.TrainStops) do
        if GetDistanceBetweenCoords(stop.x, stop.y, stop.z, PlayerCoords.x, PlayerCoords.y, PlayerCoords.z, false) < 6.5 then
            GPS.StartNavigation(i)
        end
    end
end

GPS.StartNavigation     = function(i)
    Citizen.Wait(100)
    Stops = Config.TrainStops
    NextStop = i+1
    if Stops[NextStop] ~= nil then
        while true do
            PlayerPed = GetPlayerPed(-1)
            PlayerCoords = GetEntityCoords(PlayerPed)
            if drive.IsDriveTheTrain(PlayerPed, GetVehiclePedIsIn(PlayerPed, false)) then
                NextStopDistance = GetDistanceBetweenCoords(Stops[NextStop].x, Stops[NextStop].y, Stops[NextStop].z, PlayerCoords.x, PlayerCoords.y, PlayerCoords.z, true)
                framework.drawTxt(_U('next-stop', Stops[NextStop].name), 0, 1, 0.8, 0.905, 0.4, 255, 255, 255, 255)
                framework.drawTxt(_U('next-stop-distance', framework.round(NextStopDistance)), 0, 1, 0.82, 0.940, 0.4, 255, 255, 255, 255)
                if NextStopDistance < 4.5 then
                    GPS.AskToMarkStop(Stops[NextStop])
                    NextStop = NextStop+1
                    if Stops[NextStop] == nil then
                        NextStop    = nil
                        Stops       = nil
                        ESX.ShowNotification(_U('gps-stopped'))
                        break
                    end
                end
            end
            if IsControlJustPressed(1, framework.keys[Config.keys.gps]) then
                NextStop    = nil
                Stops       = nil
                ESX.ShowNotification(_U('gps-stopped'))
                break
            end
            Citizen.Wait(10)
        end
    else
        ESX.ShowNotification(_U('no-gps'))
    end
end

GPS.AskToMarkStop       = function(stop)
    timer = 0
    ESX.ShowNotification(_U('wait-passagers'))
    while timer < Config.BreakTime do
        timer = timer+1
        Citizen.Wait(25)
    end
    ESX.ShowNotification(_U('you-can-start'))
    return nil
end