ESX = exports["es_extended"]:getSharedObject()


ESX.RegisterServerCallback('MX-CarLock:requestPlayerCars', function(source, cb, plate)
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.fetchAll('SELECT 1 FROM owned_vehicles WHERE owner = @owner AND plate = @plate', {
		['@owner'] = xPlayer.identifier,
		['@plate'] = plate
	}, function(result)
		cb(result[1] ~= nil)
	end)
end)


ESX.RegisterServerCallback('MX-CarLock:isVehicleOwned', function(playerId, cb, vehiclePlate)
    local xPlayer = ESX.GetPlayerFromId(playerId);

    if (not xPlayer) then return end;

    MySQL.Async.fetchScalar('SELECT `owner` FROM `owned_vehicles` WHERE @plate = `plate`;', {
        ['@plate'] = vehiclePlate;
    }, function(Owner)
        cb(Owner ~= nil)
    end)
end)

local vehiclesCache = {}

exports('resetPlate', function(plate)

    vehiclesCache[plate] = nil

end)

exports('giveTempKeys', function(plate, identifier, timeout)

    if not vehiclesCache[plate] then
        vehiclesCache[plate] = {}
    end

    vehiclesCache[plate][identifier] = true

    if timeout then
        Citizen.SetTimeout(timeout, function()
            if vehiclesCache[plate] and vehiclesCache[plate][identifier] then
                vehiclesCache[plate][identifier] = nil
            end
        end)
    end
end)

RegisterNetEvent('MX-CarLock:GiveKeyToPerson', function(plate, target)
    local xPlayer = ESX.GetPlayerFromId(source)
    local owner = MySQL.Sync.fetchScalar('SELECT owner FROM owned_vehicles WHERE plate = "'..plate..'"')
    if owner == xPlayer.identifier then
        local xTarget = ESX.GetPlayerFromId(target)
        local peopleWithKeys = MySQL.Sync.fetchScalar('SELECT peopleWithKeys FROM owned_vehicles WHERE plate = "'..plate..'"')
        local keysTable = json.decode(peopleWithKeys) or {}
        keysTable[xTarget.identifier] = true

        MySQL.Async.execute('UPDATE owned_vehicles SET peopleWithKeys = @peopleWithKeys WHERE plate = @plate', {
            ['@peopleWithKeys'] = json.encode(keysTable),
            ['@plate'] = plate
        }, function(rowsUpdated)
            if rowsUpdated > 0 then
                xTarget.showNotification(_U('received_keys', plate))
                xPlayer.showNotification(_U('gave_keys', plate))
            end
        end)

        if vehiclesCache[plate] then
            vehiclesCache[plate][xTarget.identifier] = true
        end

    else
        xPlayer.showNotification(_U('not_yours_vehicle'))
    end
end)



print('^5Made By Mxthess^7: ^1'..GetCurrentResourceName()..'^7 started ^2successfully^7...')

