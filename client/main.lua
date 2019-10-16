ESX										= nil
local PlayerData						= {}
local PlayerIsInTain                    = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

Citizen.CreateThread(function()
    while true do
        PlayerPed = GetPlayerPed(-1)
        if PlayerPed ~= nil and (not IsPlayerIsReady(PlayerPed)) then
            train = framework.GetClosestTrain(PlayerPed)
            if train ~= false and train ~= nil and train ~= 0 and GetEntitySpeed(train) == 0.0 then
                if IsControlJustPressed(1, framework.keys['F']) then
                    if (not PlayerIsInTain) then
                        x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(train, 0.0, 0.0, 0.44))
                        PlayerIsInTain = true
                    else
                        x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(train, -1.85, -1.85, 0.55))
                        PlayerIsInTain = false
                    end
                    SetEntityCoords(PlayerPed, x, y, z, 0.0, 0.0, 0.0, false)
                end
            else
                Citizen.Wait(850)
            end
        end
        Citizen.Wait(5)
    end
end)

Citizen.CreateThread(function()
    while true do
        PlayerPed = GetPlayerPed(-1) 
        if PlayerPed ~= nil then
            for i,train in pairs(Config.LoadThisModel) do
                train = GetHashKey(train)
                RequestModel(train)
                while not HasModelLoaded(train) do
                    RequestModel(train)
                    Citizen.Wait(25)
                end
            end
            if PlayerData.job ~= nil then
                if IsPlayerIsReady(PlayerPed) then
                    blip = AddBlipForCoord(Config.SpawnTrain.menu.x, Config.SpawnTrain.menu.y, Config.SpawnTrain.menu.z)
                    SetBlipCategory(blip, 1)
                    SetBlipRoute(blip, false)
                    SetBlipColour(blip, 0)
                    SetBlipSprite(blip, 36)
                    SetBlipScale(blip, 0.8)
                    SetBlipAsShortRange(blip, true)
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString(_U('job-name'))
                    EndTextCommandSetBlipName(blip)
                end
                break
            end
        end
        Citizen.Wait(200)
    end
end)

Citizen.CreateThread(function()
    while true do
        PlayerPed = GetPlayerPed(-1)
        if  IsPlayerIsReady(PlayerPed) then
            if IsControlJustPressed(1, framework.keys[Config.keys.gps]) then
                train = GetVehiclePedIsIn(PlayerPed, false)
                if drive.IsDriveTheTrain(PlayerPed, train) then
                    GPS.Initialization(PlayerPed, train)
                    Citizen.Wait(800)
                end
            end
        end
        Citizen.Wait(5)
    end
end)

Citizen.CreateThread(function()
    while true do
        PlayerPed = GetPlayerPed(-1)
        if IsPlayerIsReady(PlayerPed) then
            PlayerCoords = GetEntityCoords(PlayerPed)
            if GetDistanceBetweenCoords(Config.SpawnTrain.menu.x, Config.SpawnTrain.menu.y, Config.SpawnTrain.menu.z, PlayerCoords.x, PlayerCoords.y, PlayerCoords.z, true) < 0.95 then
                if IsControlJustPressed(1, framework.keys['E']) then
                    OpenSpawnTrainMenu()
                    Citizen.Wait(100)
                end
            end
        end
        Citizen.Wait(5)
    end
end)

Citizen.CreateThread(function()
    while true do
        PlayerPed = GetPlayerPed(-1)
        if IsPlayerIsReady(PlayerPed) then
            if IsControlJustPressed(1, framework.keys[Config.keys.EnterTrain]) then
                train = framework.GetClosestTrain(PlayerPed)
                if train ~= nil and train ~= 0 then
                    if (drive.TrainIsReadyForDrive(train)) then
                        drive.SetTrainAsDrivable(PlayerPed, train)
                    else
                        ESX.ShowNotification(_U('cant-drive-train'))
                    end
                end
                Citizen.Wait(25)
            end
        end
        Citizen.Wait(5)
    end
end)

function OpenSpawnTrainMenu()
    PlayerPed = GetPlayerPed(-1)
    elements = {
        { label = _U('spawn-train'), value = 'spawn' },
        { label = _U('delete-train'), value = 'delete' }
    }
    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'gunshop', {
            title    = 'state.png',
            align    = 'top-left',
            elements = elements,
        },
        function(data, menu)
            menu.close()
            if data.current.value == 'spawn' then
                train = CreateMissionTrain(24, Config.SpawnTrain.point.x, Config.SpawnTrain.point.y , Config.SpawnTrain.point.z, true)
                while not DoesEntityExist(train) do
                    Citizen.Wait(500)
                end
                SetTrainSpeed(train, 0.0)
                SetTrainCruiseSpeed(train, 0.0)
                SetEntityAsMissionEntity(train, true, false)
            end
            if data.current.value == 'delete' then
                train = framework.GetClosestTrain(PlayerPed)
                if train ~= false and train ~= nil and train ~= 0 then
                    DeleteMissionTrain(train)
                else
                    ESX.ShowNotification(_U('no-train-near'))
                end
            end
        end,
        function(data, menu)
            menu.close()
            GunshopMenu = false
        end
    )
end

function IsPlayerIsReady(PlayerPed)
    if PlayerPed ~= nil and PlayerData.job ~= nil and PlayerData.job.name == 'police' then
        return true
    else
        return false    
    end
end