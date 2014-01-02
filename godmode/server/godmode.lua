class 'Godmode'

function Godmode:__init()
	self.admins = {
		"STEAM_0:0:26199873",
		"STEAM_0:0:28323431",
	}

	self.players = {}
	self.playerStates = {}
	self.reviveList = {}
	self.reviveCoords = {}

	Events:Subscribe("PlayerChat", 	self, self.PlayerChat)
	Events:Subscribe("PlayerQuit", 	self, self.PlayerQuit)
	Events:Subscribe("PostTick", 	self, self.KeepAlive)
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

function Godmode:isGod(player)
	local godstring = ""

	for i, godPlayer in pairs(self.players) do
		godstring = godstring .. godPlayer:GetSteamId().string .. " "
	end

	if string.match(godstring, player:GetSteamId().string) then
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
	if IsValid(player) then
		if self.players[player:GetSteamId().string] ~= nil then
			self.players[player:GetSteamId().string] = nil
			self.playerStates[player:GetSteamId().string] = nil

			Network:Send(player, "GodmodeToggle", false)
		end

		Chat:Send(player, "[Godmode] You have been removed from the list of Godmode players - You are now mortal again!", Color(0, 255, 0))
	end
end

function Godmode:EnablePlayer(player)
	if IsValid(player) then
		if self.players[player:GetSteamId().string] ~= nil then
			self.playerStates[player:GetSteamId().string] = true
			
			Network:Send(player, "GodmodeToggle", true)

			Chat:Send(player, "[Godmode] You are now immortal!", Color(0, 255, 0))
		end
	end
end

function Godmode:DisablePlayer(player)
	if IsValid(player) then
		if self.players[player:GetSteamId().string] ~= nil then
			self.playerStates[player:GetSteamId().string] = false
			
			Network:Send(player, "GodmodeToggle", false)

			Chat:Send(player, "[Godmode] You are now mortal again!", Color(0, 255, 0))
		end
	end
end

function Godmode:KeepAlive()
	for i, player in pairs(self.players) do
		if IsValid(player) then
			if self.playerStates[player:GetSteamId().string] == true then
				if player:GetWorld():GetId() == 0 then
					if self:isGod(player) then
						if player:GetHealth() ~= 1 then
							if player:GetHealth() ~= 0 then

								player:SetHealth(1)

							elseif not self.reviveList[player:GetSteamId().string] then
								self.reviveList[player:GetSteamId().string] = player

								self.reviveCoords[player:GetSteamId().string] = player:GetPosition()
							end
						end

						local vehicle = player:GetVehicle()

						if vehicle ~= nil then
							if vehicle:GetHealth() ~= 1 then
								vehicle:SetHealth(1)
							end
						end
					end
				else
					if self:isGod(player) then
						self.players[player:GetSteamId().string] = nil

						Chat:Send(player, "[Godmode] You are not in the main world - You are now mortal again!", Color(50, 155, 255))
					end
				end
			end
		else
			self.players[i] = nil
		end
	end

	for i, player in pairs(self.reviveList) do

		if player:GetHealth() ~= 0 then
			player:Teleport(self.reviveCoords[player:GetSteamId().string], Angle())

			self.reviveList[player:GetSteamId().string] = nil
			self.reviveCoords[player:GetSteamId().string] = nil

			Chat:Send(player, "[Godmode] You have been teleported to your death position!", Color(0, 255, 0))
		end
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
								if player:GetWorld():GetId() == 0 then

									p = player
									id = player:GetSteamId().string
									name = player:GetName()

									break
								else
									Chat:Send(args.player, "[Godmode] '" ..referenceName .."' is currently not in the main world and will be ignored!", Color( 255, 0, 0))

									return false
								end
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
								if player:GetWorld():GetId() == 0 then

									p = player
									id = player:GetSteamId().string
									name = player:GetName()

									break
								else
									Chat:Send(args.player, "[Godmode] '" ..referenceName .."' is currently not in the main world and will be ignored!", Color( 255, 0, 0))

									return false
								end
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
						playerExists = true
					end

					if playerExists == true then
						for i, player in pairs(self.players) do
							playerNames = playerNames .." '" .. player:GetName() .. "' (" ..string.upper(tostring(self.playerStates[player:GetSteamId().string])) ..")" --.. player:GetSteamId().string .. ")"
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
			else
				if args.player:GetWorld():GetId() == 0 then
					local id = args.player:GetSteamId().string

					if self.players[id] == nil then
						Chat:Send(args.player, "[Godmode] You are not in the Godmode list - Add yourself by typing '/godmode add .'", Color( 0, 255, 0))

					else
						if self.playerStates[id] == true then
							self:DisablePlayer(args.player)

						else
							self:EnablePlayer(args.player)
						end
					end

					return false
				else
					Chat:Send(args.player, "[Godmode] You must be in the main world to use this command.", Color( 255, 0, 0))
				end
			end
		else
			Chat:Send(args.player, "[SERVER] You must be an admin to use this command.", Color( 255, 0, 0))
		end
	end
 
	return true
end

function Godmode:PlayerQuit(args)
	self:RemovePlayer(args.player)
end

local godmode = Godmode()