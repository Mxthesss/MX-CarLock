local isRunningWorkaround = false

Citizen.CreateThread(function()
	while ESX == nil do
		ESX = exports["es_extended"]:getSharedObject()
		Citizen.Wait(0)
	end
end)

function StartWorkaroundTask()
	if isRunningWorkaround then
		return
	end

	local timer = 0
	local playerPed = PlayerPedId()
	isRunningWorkaround = true

	while timer < 100 do
		Citizen.Wait(0)
		timer = timer + 1

		local vehicle = GetVehiclePedIsTryingToEnter(playerPed)

		if DoesEntityExist(vehicle) then
			local lockStatus = GetVehicleDoorLockStatus(vehicle)

			if lockStatus == 4 then
				ClearPedTasks(playerPed)
			end
		end
	end

	isRunningWorkaround = false
end

function ToggleVehicleLock()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)
	local vehicle

	Citizen.CreateThread(function()
		StartWorkaroundTask()
	end)

	if IsPedInAnyVehicle(playerPed, false) then
		vehicle = GetVehiclePedIsIn(playerPed, false)
	else
		vehicle = GetClosestVehicle(coords, 8.0, 0, 71)
	end

	if not DoesEntityExist(vehicle) then
		return
	end

	ESX.TriggerServerCallback('MX-CarLock:requestPlayerCars', function(isOwnedVehicle)

		if isOwnedVehicle then
			local lockStatus = GetVehicleDoorLockStatus(vehicle)

			if lockStatus == 1 then -- unlocked
				SetVehicleDoorsLocked(vehicle, 2)
				PlayVehicleDoorCloseSound(vehicle, 1)
				if lib.progressCircle({
					duration = 500,
					label = _U('locking'), -- Here you need to change text to your language
					position = 'bottom',
					useWhileDead = false,
					canCancel = true,
					disable = {
						car = false,
					},
					anim = {
						dict = 'anim@mp_player_intmenu@key_fob@',
						clip = 'fob_click'
					},
				}) then print('Do stuff when complete') else print('Do stuff when cancelled') end

				lib.notify({
					title = _U('car'), -- Here you need to change text to your language
					description = _U('message_locked'),
					type = 'success'
				})
			elseif lockStatus == 2 then -- locked
				SetVehicleDoorsLocked(vehicle, 1)
				PlayVehicleDoorOpenSound(vehicle, 0)
				if lib.progressCircle({
					duration = 500,
					label = _U('unlocking'), -- Here you need to change text to your language
					position = 'bottom',
					useWhileDead = false,
					canCancel = true,
					disable = {
						car = false,
					},
					anim = {
						dict = 'anim@mp_player_intmenu@key_fob@',
						clip = 'fob_click'
					},
				}) then print('Do stuff when complete') else print('Do stuff when cancelled') end
				lib.notify({
					title = _U('car'), -- Here you need to change text to your language
					description = _U('message_unlocked'),
					type = 'success'
				})
			end
		end

	end, ESX.Math.Trim(GetVehicleNumberPlateText(vehicle)))
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if IsControlJustReleased(0, 57) and IsInputDisabled(0) then -- Default F10
			ToggleVehicleLock()
			Citizen.Wait(300)
	
		-- D-pad down on controllers works, too!
		elseif IsControlJustReleased(0, 173) and not IsInputDisabled(0) then
			ToggleVehicleLock()
			Citizen.Wait(300)
		end
	end
end)



print('^5Made By Mxthess^7: ^1'..GetCurrentResourceName()..'^7 started ^2successfully^7...')

