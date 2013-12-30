class 'Environment'

function Environment:__init()
	self.admins = {}
	self:AddAdmin("STEAM_0:0:26199873")
	seld:AddAdmin("STEAM_0:0:28323431")

	Events:Subscribe("PlayerChat", self, self.PlayerChat)
end

function Environment:AddAdmin(steamId)
	self.admins[steamId] = true
end

function Environment:IsAdmin(player)
	return self.admins[player:GetSteamId().string] ~= nil
end

function Environment:PlayerChat(args)
	local player = args.player
	local message = args.text
	
	local commands = {}
	for command in string.gmatch(message, "[^%s]+") do
		table.insert(commands, command)
	end
	
	if commands[1] == "/time" then
		if not self:IsAdmin(player) then
			Chat:Send(player, "You are not an admin!", Color(255, 0, 0))
			return true
		end
	
		if commands[2] == nil then
			Chat:Send(player, "No time specified. Correct usage: /time <0.0 - 24.0>", Color(255, 0, 0))
			return true
		end
		
		local setTime = tonumber(commands[2])
		if setTime == nil then
			Chat:Send(player, "The specified time is not a number!", Color(255, 0, 0))
			return true
		end
		
		DefaultWorld:SetTime(setTime)
		
		Chat:Send(player, "Time set.", Color(255, 0, 0))
	elseif commands[1] == "/timestep" then
		if not self:IsAdmin(player) then
			Chat:Send(player, "You are not an admin!", Color(255, 0, 0))
			return true
		end
	
		if commands[2] == nil then
			Chat:Send(player, "No time step specified. Correct usage: /timestep <0 - *>", Color(255, 0, 0))
			return true
		end
		
		local timeStep = tonumber(commands[2])
		if timeStep == nil then
			Chat:Send(player, "The specified time step is not a number!", Color(255, 0, 0))
			return true
		end
		
		DefaultWorld:SetTimeStep(timeStep)
		
		Chat:Send(player, "Time step set.", Color(255, 0, 0))
	elseif commands[1] == "/weather" then
		if not self:IsAdmin(player) then
			Chat:Send(player, "You are not an admin!", Color(255, 0, 0))
			return true
		end
	
		if commands[2] == nil then
			Chat:Send(player, "No weather severity specified. Correct usage: /weather <0 - 2>", Color(255, 0, 0))
			return true
		end
		
		local weatherSeverity = tonumber(commands[2])
		if weatherSeverity == nil then
			Chat:Send(player, "The specified weather severity is not a number!", Color(255, 0, 0))
			return true
		elseif weatherSeverity < 0 or weatherSeverity > 2 then
			Chat:Send(player, "The specified weather severity is not in the range 0 to 2!", Color(255, 0, 0))
			return true
		end
		
		DefaultWorld:SetWeatherSeverity(weatherSeverity)
		
		Chat:Send(player, "Weather set.", Color(255, 0, 0))
	end
	
	return true
end

local environment = Environment()