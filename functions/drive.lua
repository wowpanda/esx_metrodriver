drive                           = {}

drive.TrainIsReadyForDrive      = function(train)
    CanDriveTheTrain = false
    if train ~= 0 then
        driver = GetPedInVehicleSeat(train, -1)
        if driver == nil or driver == 0 then
            CanDriveTheTrain = true
        end
    end
    return CanDriveTheTrain
end

drive.SetTrainAsDrivable        = function(PlayerPed, train)
    if drive.TrainIsReadyForDrive(train) then
        SetPedIntoVehicle(PlayerPed, train, -1)
        drive.StartDriving(PlayerPed, train)
    end
end

drive.StartDriving              = function(PlayerPed, train)
    TrainConfig = drive.TrainConfig()
    while true do
        if drive.IsDriveTheTrain(PlayerPed, train) then
            TrainSpeed = GetEntitySpeed(train)
            if TrainConfig.engine then

                if IsControlPressed(1, framework.keys[Config.keys.control.traction]) then
                    drive.SetTrainSpeed(train, true, TrainSpeed)
                end

                if IsControlPressed(1, framework.keys[Config.keys.control.brakes]) then
                    drive.SetTrainSpeed(train, false, TrainSpeed)
                end

                if IsControlJustPressed(1, framework.keys[Config.keys.control.EnginePower]) then
                    TrainConfig.engine = false
                    if TrainSpeed > 0.0 then
                        drive.EmergencyDowngrade(train, TrainSpeed)
                    end
                end

            else
                framework.DisplayHelpText(_U('press-for-start-train'))
                if IsControlJustPressed(1, framework.keys[Config.keys.control.EnginePower]) then
                    TrainConfig.engine = true 
                end
            end
        else
            if train ~= 0 and TrainSpeed ~= nil then
                drive.EmergencyDowngrade(train, TrainSpeed)
            end
            break
        end
        Citizen.Wait(5)
    end
end

drive.IsDriveTheTrain           = function(PlayerPed, train)
    if GetVehicleClass(train) == 21 and GetPedInVehicleSeat(train, -1) == PlayerPed then
        return true
    else
        return false
    end
end

drive.TrainConfig               = function()
    TrainConfig         = {}
    TrainConfig.engine  = false
    TrainConfig.Speed   = 0.0
    return TrainConfig
end

drive.SetTrainSpeed             = function(train, power, CurrentTrainSpeed)
    if power then
        Speed = CurrentTrainSpeed+Config.Torque
    else
        Speed = CurrentTrainSpeed-Config.Torque
    end
    if Speed < 0.040 then
        Speed = 0.0
    end
    SetTrainSpeed(train, Speed)
    SetTrainCruiseSpeed(train, Speed)
    Citizen.Wait(5)
    return Speed
end

drive.EmergencyDowngrade        = function(train, TrainSpeed)
    while true do
		if TrainSpeed <= 0 then
			SetTrainSpeed(train, 0.0)
			SetTrainCruiseSpeed(train, 0.0)
			break
		else
			TrainSpeed = TrainSpeed-(Config.EmergencyTorque+0.045)
			SetTrainSpeed(train, TrainSpeed)
			SetTrainCruiseSpeed(train, TrainSpeed)
		end
		Citizen.Wait(5)
	end
	return nil
end