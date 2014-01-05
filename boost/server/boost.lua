
class 'Boost'

--Quick string to boolean function - There is obviously a better way to do this...
local function StringToBool(s)
	if s == "true" then
		return true
	elseif s == "false" then
		return false
	else
		return false
	end
end

--We use this function to load the admins SteamIds into the admins table
function Boost:LoadAdmins(filename)
	local file = io.open(filename, "r")
	local i = 0
	local admins = {}

	if file == nil then
		print("[Boost] The supplied file was not found!")
		return admins
	end
	
	for line in file:lines() do
		i = i + 1
		
		--We check if the admin line was commented out
		if string.sub(line, 1, 2) ~= "--" then
			admins[i] = line
		end
	end

	file:close()

	return admins
end

--We use this function to load each registered players stored data 
function Boost:LoadPlayers(filename)
	local file = io.open(filename, "r")
	local i = 0
	local players = {}

	--If there is no user file we can just ignore loading
	if file == nil then
		return
	end
	
	for line in file:lines() do
		i = i + 1

		--Check if the line was commented out
		if string.sub(line, 1, 2) ~= "--" then
			local playerString = line:split(" ")

			--We create a template which will be completed once a player joins
			players[playerString[1]] = {name = nil, id = playerString[1], localid = nil, enabled = StringToBool(playerString[2]), speed = 1}

			--We make sure that if a player from the loaded list is on the server we complete his template
			for player in Server:GetPlayers() do
				if player:GetSteamId().string == playerString[1] then
					players[player:GetSteamId().string] = {name = player:GetName(), id = player:GetSteamId().string, localid = player:GetId(), enabled = StringToBool(playerString[2]), speed = 1}
				
					Chat:Send(player, "[Boost] You were detected - Boost set to: " ..tostring(players[player:GetSteamId().string].enabled), Color(55, 155, 255))
				end
			end
		end
	end

	file:close()

	return players
end

function Boost:SavePlayers(filename)
	local file = io.open(filename, "w")

	--If there is no user file we can just ignore loading
	if file == nil then
		return
	end
	
	for i, player in pairs(self.playerValues) do
		file:write(player.id, " ", tostring(player.enabled), "\n")
	end

	file:close()

	return true
end

function Boost:__init()
	--Load all the admins!
	self.admins = self:LoadAdmins("server/admins.txt")

	--Instead of storing full sets of players we only store their associated values
	self.playerValues = self:LoadPlayers("server/players.txt")

	--The amount of boost added each tick
	self.boostAmount = 0.001

	Network:Subscribe("BoostAccelerate", self, self.Accelerate)

	Events:Subscribe("PostTick", 		self, self.Cooldown)
	Events:Subscribe("PlayerChat", 		self, self.PlayerChat)
	Events:Subscribe("PlayerJoin",		self, self.PlayerJoin)
	Events:Subscribe("ModuleUnload", 	self, self.ModuleUnload)
end

function Boost:isAdmin(player)
	local adminstring = ""

	for i,line in ipairs(self.admins) do
		adminstring = adminstring .. line .. " "
	end

	if(string.match(adminstring, tostring(player:GetSteamId()))) then
		return true
	end
	
	return false
end

function Boost:AddPlayer(player)
	self.playerValues[player:GetSteamId().string] = {name = player:GetName(), id = player:GetSteamId().string, localid = player:GetId(), enabled = true, speed = 1}

	Chat:Send(player, "[Boost] You have been added to the list of registered players!", Color(0, 255, 0))
end

function Boost:RemovePlayer(player)
	if IsValid(player) then
		if self.playerValues[player:GetSteamId().string] ~= nil then
			self.playerValues[player:GetSteamId().string] = nil
		end

		Chat:Send(player, "[Boost] You have been removed from the list of registered players!", Color(0, 255, 0))
	end
end

function Boost:Cooldown()
	if #self.playerValues > 0 then
		for i, p in pairs(self.playerValues) do
			if self.playerValues[i].speed > 1 then
				self.playerValues[i].speed = self.playerValues[i].speed - self.boostAmount / 100
			else
				self.playerValues[i].speed = 1
			end
		end
	end
end

function Boost:PlayerChat(args)
	local cmd_args = args.text:split(" ")

	if cmd_args[1] == "/boost" then
		if self:isAdmin(args.player) then
			if cmd_args[2] then
				if cmd_args[2] == "add" then

					local p = {}
					local id = 0
					local name = ""

					if cmd_args[3] ~= "." and cmd_args[3] ~= nil then

						local referenceName = ""

						--If a players name has spaces we decide to merge these to a full string
						for i, namepart in pairs(cmd_args) do
							if i < 3 then

							elseif i == 3 then
								referenceName = (referenceName ..namepart)
							else
								referenceName = (referenceName .." " ..namepart)
							end
						end

						for player in Server:GetPlayers() do
							if player:GetName() == referenceName then
								p = player
								id = player:GetSteamId().string
								name = player:GetName()

								break
							end
						end

						if name == "" and id == 0 then
							Chat:Send(args.player, "[Boost] '" ..referenceName .."' was not found on the server and will be ignored!", Color( 255, 0, 0))

							return false
						end
					else
						p = args.player
						id = args.player:GetSteamId().string
						name = args.player:GetName()
					end

					if not self.playerValues[id] then
						self:AddPlayer(p)

						if args.player ~= p then
							Chat:Send(args.player, "[Boost] '" ..name .."' has been added to the list of registered players!", Color( 0, 255, 0))
						end
					else
						Chat:Send(args.player, "[Boost] '" ..name .."' is already in the list of registered players!", Color( 255, 0, 0))
					end

				elseif cmd_args[2] == "remove" then

					local p = {}
					local id = 0
					local name = ""

					if cmd_args[3] ~= "." and cmd_args[3] ~= nil then
						
						local referenceName = ""

						--If a players name has spaces we decide to merge these to a full string
						for i, namepart in pairs(cmd_args) do
							if i < 3 then

							elseif i == 3 then
								referenceName = (referenceName ..namepart)
							else
								referenceName = (referenceName .." " ..namepart)
							end
						end

						for player in Server:GetPlayers() do
							if player:GetName() == referenceName then
								p = player
								id = player:GetSteamId().string
								name = player:GetName()

								break
							end
						end

						if name == "" and id == 0 then
							Chat:Send(args.player, "[Boost] '" ..referenceName .."' was not found on the server and will be ignored!", Color( 255, 0, 0))

							return false
						end
					else
						p = args.player
						id = args.player:GetSteamId().string
						name = args.player:GetName()
					end

					if self.playerValues[id] then
						self:RemovePlayer(p)

						if args.player ~= p then
							Chat:Send(args.player, "[Boost] '" ..name .."' has been removed to the list of registered players!", Color( 0, 255, 0))
						end
					else
						Chat:Send(args.player, "[Boost] '" ..name .."' is not in the list of registered players!", Color( 255, 0, 0))
					end

				elseif cmd_args[2] == "players" then
					local playerNames = "[Boost]"

					local playerExists = false

					for i, p in pairs(self.playerValues) do
						if IsValid(Player.GetById(p.localid)) then
							playerExists = true
						end
					end

					if playerExists == true then
						for i, player in pairs(self.playerValues) do
							if IsValid(Player.GetById(player.localid)) then
								playerNames = playerNames .." '" .. player.name .. "' [" ..string.upper(tostring(player.enabled)) .."]"
							end
						end
					else
						playerNames = playerNames .." There are no players in the list of registered players!"
					end

					Chat:Send(args.player, playerNames, Color(0, 255, 0))

					return false
				else
					Chat:Send(args.player, "[Boost] Invalid parameters - Options: '/boost (add/remove/players) <name>'", Color( 255, 0, 0))
				end

				return false
			end
		end

		if args.player:GetWorld():GetId() == 0 then
			local id = args.player:GetSteamId().string

			if self.playerValues[id] == nil then
				if self:isAdmin(args.player) then
					Chat:Send(args.player, "[Boost] You are not in the list of registered players - Add yourself by typing '/boost add .'", Color( 0, 255, 0))
				end

				return false
			else
				if self.playerValues[id].enabled == true then
					self.playerValues[id].enabled = false

					Chat:Send(args.player, "[Boost] Your boost has been disabled.", Color( 0, 255, 0))

					return false
				else
					self.playerValues[id].enabled = true

					Chat:Send(args.player, "[Boost] Your boost has been enabled.", Color( 0, 255, 0))

					return false
				end
			end
		else
			if self:isAdmin(args.player) or self.playerValues[id] ~= nil then
				Chat:Send(args.player, "[Boost] You must be in the main world to use this command.", Color( 255, 0, 0))

				return false
			end
		end
	end
 
	return true
end

function Boost:Accelerate(args, client)
	if client:GetWorld():GetId() == 0 then
		if self.playerValues[client:GetSteamId().string] then
			if self.playerValues[client:GetSteamId().string].enabled == true then
				local vehicle = client:GetVehicle()

				if not IsValid(vehicle) then
					return
				end

				self.playerValues[client:GetSteamId().string].speed = math.clamp(self.playerValues[client:GetSteamId().string].speed + self.boostAmount, 1, 1000)

				client:GetVehicle():SetLinearVelocity(client:GetVehicle():GetLinearVelocity() * self.playerValues[client:GetSteamId().string].speed)
			 end
		 end
	else
		if self.playerValues[client:GetSteamId().string] then
			if self.playerValues[client:GetSteamId().string].enabled == true then
				Chat:Send(client, "[Boost] You are not in the main world - Your boost has been disabled.", Color(55, 155, 255))
			end

			self.playerValues[client:GetSteamId().string].enabled = false
		end
	end
end

function Boost:PlayerJoin(args)
	if self.playerValues[args.player:GetSteamId().string] ~= nil then
		self.playerValues[args.player:GetSteamId().string].name = args.player:GetName()
		self.playerValues[args.player:GetSteamId().string].localid = args.player:GetId()

		Chat:Send(args.player, "[Boost] You were detected - Boost set to: " ..tostring(self.playerValues[args.player:GetSteamId().string].enabled), Color(55, 155, 255))
	end
end

function Boost:ModuleUnload(args)
	self:SavePlayers("server/players.txt")

	for i, player in pairs(self.playerValues) do
		Chat:Send(Player.GetById(player.localid), "[Boost] Module unloaded - Your boost has been disabled.", Color(255, 155, 55))
	end
end

local boost = Boost()