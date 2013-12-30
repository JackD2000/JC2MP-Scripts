PlayerChat = function(args)
	-- Spawn a tank and put them inside it.
	if args.text == "/metatank" then
		spawnArgs = {}
		spawnArgs.model_id = 56 -- Razorback
		spawnArgs.position = args.player:GetPosition()
		spawnArgs.angle = args.player:GetAngle()
 
		local vehicle = Vehicle.Create(spawnArgs)
		args.player:EnterVehicle(vehicle, VehicleSeat.Driver)
 
		return false
	end
 
	return true
end
Events:Subscribe("PlayerChat", PlayerChat)
 
SpawnTankBullet = function(args, player)
	-- Make sure their vehicle still exists.
	local vehicle = player:GetVehicle()
	if not IsValid(vehicle) then
		return
	end
 
	spawnArgs = {}
	spawnArgs.model_id = 50
	spawnArgs.position = vehicle:GetPosition() + Vector3(0, 2, 0) + args.direction * 15
	spawnArgs.angle = args.angle
	spawnArgs.linear_velocity = args.direction * 100
 
	Vehicle.Create(spawnArgs)
end
Network:Subscribe("FireTank", SpawnTankBullet)