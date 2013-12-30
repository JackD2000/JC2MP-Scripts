PlayerChat = function(args)
	if args.text == "/pos" then
		print(args.player:GetPosition())
		return false
	end
 
	return true
end
 
Events:Subscribe("PlayerChat", PlayerChat)