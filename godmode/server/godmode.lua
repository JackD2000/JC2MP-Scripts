
class 'Godmode'

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
function Godmode:LoadAdmins(filename)
	local file = io.open(filename, "r")
	local i = 0
	local admins = {}

	if file == nil then
		print("[Godmode] The supplied file was not found!")
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
function Godmode:LoadPlayers(filename)
	local file = io.open(filename, "r")
	local i = 0
	local players = {}
	local playerStates = {}

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
			players[playerString[1]] = {}
			playerStates[playerString[1]] = StringToBool(playerString[2])

			--We make sure that if a player from the loaded list is on the server we complete his template
			for player in Server:GetPlayers() do
				if player:GetSteamId().string == playerString[1] then
					players[player:GetSteamId().string] = player

					Chat:Send(player, "[Godmode] You were detected - Godmode set to: " ..tostring(playerStates[player:GetSteamId().string]), Color(55, 155, 255))
				end
			end
		end
	end

	file:close()

	return players, playerStates
end

function Godmode:SavePlayers(filename)
	local file = io.open(filename, "w")

	--If there is no user file we can just ignore loading
	if file == nil then
		return
	end
	
	for i, player in pairs(self.players) do
		file:write(player:GetSteamId().string, " ", tostring(self.playerStates[player:GetSteamId().string]), "\n")
	end

	file:close()

	return true
end

function Godmode:__init()
	--The time between ticks in milliseconds (Default 1000)
	self.interval = 1000

	--All you admins are belong to us!
	self.admins = self:LoadAdmins("server/admins.txt")

	self.timer = Timer()

	self.players, self.playerStates = self:LoadPlayers("server/players.txt")

	Events:Subscribe("PreTick",			self, self.Tick)
	Events:Subscribe("PlayerChat", 		self, self.PlayerChat)
	Events:Subscribe("PlayerJoin",		self, self.PlayerJoin)
	Events:Subscribe("PlayerQuit", 		self, self.PlayerQuit)
	Events:Subscribe("ModuleUnload", 	self, self.ModuleUnload)
end

function Godmode:isAdmin(player)
	local adminstring = ""

	for i, line in pairs(self.admins) do
		adminstring = adminstring .. line .. " "
	end

	if string.match(adminstring, player:GetSteamId().string) then
		return true
	end

	return false
end

function Godmode:AddPlayer(player)
	self.players[player:GetSteamId().string] = player
	self.playerStates[player:GetSteamId().string] = true

	Network:Send(player, "GodmodeToggle", true)

	Chat:Send(player, "[Godmode] You have been added to the list of Godmode players - You are now immortal!", Color(0, 255, 0))
end

function Godmode:RemovePlayer(player)
	if self.players[player:GetSteamId().string] ~= nil then
		local godstring = " - You are now mortal again"

		if self.playerStates[player:GetSteamId().string] == false then
			godstring = ""
		end

		self.players[player:GetSteamId().string] = nil
		self.playerStates[player:GetSteamId().string] = nil

		Network:Send(player, "GodmodeToggle", false)

		Chat:Send(player, "[Godmode] You have been removed from the list of Godmode players" ..godstring .."!", Color(0, 255, 0))
	end
end

function Godmode:EnablePlayer(player)
	if self.players[player:GetSteamId().string] ~= nil then
		self.playerStates[player:GetSteamId().string] = true
		
		Network:Send(player, "GodmodeToggle", true)

		Chat:Send(player, "[Godmode] You are now immortal!", Color(0, 255, 0))
	end
end

function Godmode:DisablePlayer(player)
	if self.players[player:GetSteamId().string] ~= nil then
		self.playerStates[player:GetSteamId().string] = false
		
		Network:Send(player, "GodmodeToggle", false)

		Chat:Send(player, "[Godmode] You are now mortal again!", Color(0, 255, 0))
	end
end

function Godmode:Tick(args)
	if self.timer:GetMilliseconds() > self.interval then
		for i, player in pairs(self.players) do
			if IsValid(player) then
				if self.playerStates[player:GetSteamId().string] == true then
					if player:GetWorld():GetId() == 0 then

						player:SetHealth(1)

						local vehicle = player:GetVehicle()

						if vehicle then
							vehicle:SetHealth(1)
						end
					else
						self.playerStates[player:GetSteamId().string] = false

						Chat:Send(player, "[Godmode] You are not in the main world - You are now mortal again.", Color(55, 155, 255))
					end
				end
			end
		end

		self.timer:Restart()
	end
end

function Godmode:PlayerChat(args)
	local cmd_args = args.text:split(" ")

	if cmd_args[1] == "/godmode" then
		if self:isAdmin(args.player) then
			if cmd_args[2] then
				if cmd_args[2] == "add" then

					local p = nil
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
							Chat:Send(args.player, "[Godmode] '" ..referenceName .."' was not found on the server and will be ignored!", Color( 255, 0, 0))

							return false
						end
					else
						p = args.player
						id = args.player:GetSteamId().string
						name = args.player:GetName()
					end

					if not self.players[id] then
						self:AddPlayer(p)

						if args.player ~= p then
							Chat:Send(args.player, "[Godmode] '" ..name .."' has been added to the Godmode list!", Color( 0, 255, 0))
						end
					else
						Chat:Send(args.player, "[Godmode] '" ..name .."' is already in the Godmode list!", Color( 255, 0, 0))
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
							Chat:Send(args.player, "[Godmode] '" ..referenceName .."' was not found on the server and will be ignored!", Color( 255, 0, 0))

							return false
						end
					else
						p = args.player
						id = args.player:GetSteamId().string
						name = args.player:GetName()
					end

					if self.players[id] then
						self:RemovePlayer(p)

						if args.player ~= p then
							Chat:Send(args.player, "[Godmode] '" ..name .."' has been removed from the Godmode list!", Color( 0, 255, 0))
						end
					else
						Chat:Send(args.player, "[Godmode] '" ..name .."' is not in the Godmode list!", Color( 255, 0, 0))
					end

				elseif cmd_args[2] == "players" then
					local playerNames = "[Godmode]"

					local playerExists = false

					for i, p in pairs(self.players) do
						if IsValid(p) then
							playerExists = true
						end
					end

					if playerExists == true then
						for i, player in pairs(self.players) do
							if IsValid(player) then
								playerNames = playerNames .." '" .. player:GetName() .. "' [" ..string.upper(tostring(self.playerStates[player:GetSteamId().string])) .."]"
							end
						end
					else
						playerNames = playerNames .." There are no players in the list of Godmode players!"
					end

					Chat:Send(args.player, playerNames, Color(0, 255, 0))

					return false
				else
					Chat:Send(args.player, "[Godmode] Invalid parameters - Options: '/godmode (add/remove/players) <name>'", Color( 255, 0, 0))
				end

				return false
			end
		end

		if args.player:GetWorld():GetId() == 0 then
			local id = args.player:GetSteamId().string

			if self.players[id] == nil then
				if self:isAdmin(args.player) then
					Chat:Send(args.player, "[Godmode] You are not in the Godmode list - Add yourself by typing '/godmode add .'", Color( 0, 255, 0))
				end

				return false
			else
				if self.playerStates[id] == true then
					self:DisablePlayer(args.player)
				else
					self:EnablePlayer(args.player)
				end

				return false
			end
		else
			if self:isAdmin(args.player) or self.players[id] ~= nil then
				Chat:Send(args.player, "[Godmode] You must be in the main world to use this command.", Color( 255, 0, 0))

				return false
			end
		end
	end
 
	return true
end

function Godmode:PlayerJoin(args)
	if self.players[args.player:GetSteamId().string] ~= nil then
		self.players[args.player:GetSteamId().string] = args.player

		Chat:Send(args.player, "[Godmode] You were detected - Godmode set to: " ..tostring(self.playerStates[args.player:GetSteamId().string]), Color(55, 155, 255))
	end
end

function Godmode:PlayerQuit(args)
	if self.players[args.player:GetSteamId().string] then
		Network:Send(args.player, "GodmodeToggle", false)
	end
end

function Godmode:ModuleUnload(args)
	self:SavePlayers("server/players.txt")

	for i, player in pairs(self.players) do
		if IsValid(player) then
			if self.playerStates[player:GetSteamId().string] == true then
				self.playerStates[player:GetSteamId().string] = false
				
				Network:Send(player, "GodmodeToggle", false)

				Chat:Send(player, "[Godmode] Module unloaded - You are now mortal again!", Color(255, 155, 55))
			end
		end
	end
end

local godmode = Godmode()