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

print('^5Made By Mxthess^7: ^1'..GetCurrentResourceName()..'^7 started ^2successfully^7...')

