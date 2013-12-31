
function BoostInput(args)
	if args.key == 16 then

		Network:Send("BoostAccelerate")

		return false

	elseif args.key == 17 then

		Network:Send("BoostBrake")

		return false

	else
		return true
	end
end

Events:Subscribe("KeyDown", BoostInput)