timer = nil
fireInterval = 1
 
Fire = function()
	local args = {}
	args.angle = Camera:GetAngle()
	args.direction = args.angle * Vector3(0, 0, -1)
 
	Network:Send("FireTank", args)
end
 
TryToFire = function()
	-- Make sure we only fire once every fireInterval. Otherwise, it would try to spam network
	-- messages every frame. That is not good.
	if timer then
		if timer:GetSeconds() >= fireInterval then
			timer = nil
		end
	else
		Fire()
		timer = Timer()
	end
end
 
LocalPlayerInput = function(args)
	-- We only want the Razorback tank.
	local vehicle = LocalPlayer:GetVehicle()
	if vehicle == nil or vehicle:GetModelId() ~= 56 then
		return true
	end
	-- Replace the vehicle fire actions with our own implementation.
	if args.input == Action.VehicleFireRight or args.input == Action.VehicleFireLeft then
		TryToFire()
		return false
	else
		return true
	end
end
Events:Subscribe("LocalPlayerInput", LocalPlayerInput)