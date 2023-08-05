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

-- Funkce pro přepsání majitele auta
function TransferVehicleOwnership(source)
    -- Získání hráče
    local player = GetPlayerPed(source)

    -- Získání hráče stojícího vedle hráče
    local nearbyPlayer = nil
    for _, otherPlayer in ipairs(GetActivePlayers()) do
        if otherPlayer ~= source then
            local otherPlayerPed = GetPlayerPed(otherPlayer)
            local distance = GetDistanceBetweenCoords(GetEntityCoords(player), GetEntityCoords(otherPlayerPed), true)
            if distance <= 2.0 then
                nearbyPlayer = otherPlayer
                break
            end
        end
    end

    -- Kontrola, zda byl nalezen hráč stojící vedle
    if nearbyPlayer ~= nil then
        -- Získání informací o vozidle hráče
        local vehicle = GetVehiclePedIsIn(player, false)
        local vehiclePlate = GetVehicleNumberPlateText(vehicle)

        -- Získání identifikátorů hráčů
        local currentOwner = GetPlayerIdentifier(source)
        local newOwner = GetPlayerIdentifier(nearbyPlayer)

        -- Aktualizace majitele vozidla v databázi
        MySQL.Async.execute('UPDATE owned_vehicles SET owner = @newOwner WHERE plate = @plate AND owner = @currentOwner', {
            ['@newOwner'] = newOwner,
            ['@plate'] = vehiclePlate,
            ['@currentOwner'] = currentOwner
        }, function(rowsUpdated)
            if rowsUpdated > 0 then
                TriggerClientEvent('esx:showNotification', source, '^2Majitelství vozidla bylo úspěšně přepsáno na ' .. GetPlayerName(nearbyPlayer))
                TriggerClientEvent('esx:showNotification', nearbyPlayer, '^2Majitelství vozidla bylo přepsáno na tebe.')
            else
                TriggerClientEvent('esx:showNotification', source, '^1Chyba: Nemůžeš přepsat majitele vozidla.')
            end
        end)
    else
        TriggerClientEvent('esx:showNotification', source, '^1Chyba: Vedle tebe není žádný hráč.')
    end
end

RegisterCommand(Config.GiveKeyCommand, function(source, args)
    TransferVehicleOwnership(source)
end, false)

print('^5Made By Mxthess^7: ^1'..GetCurrentResourceName()..'^7 started ^2successfully^7...')