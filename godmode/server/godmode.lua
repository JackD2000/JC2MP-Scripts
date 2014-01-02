class 'Godmode'

function Godmode:__init()
	self.admins = {
		"STEAM_0:0:26199873",
		"STEAM_0:0:28323431",
	}

	self.players = {}
	self.reviveList = {}
	self.reviveCoords = {}

	Events:Subscribe("PlayerChat", 	self, self.PlayerChat)
	Events:Subscribe("PlayerQuit", 	self, self.PlayerQuit)
	Events:Subscribe("PreTick", 	self, self.KeepAlive)
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

--Deprecated since we now directly store the player.
--[[function Godmode:GetPlayerName(steamid)
	for player in Server:GetPlayers() do
		if steamid == player:GetSteamId().string then

			return player:GetName()
		end
	end
end]]

function Godmode:AddPlayer(player)
	self.players[player:GetSteamId().string] = player

	Chat:Send(player, "[Godmode] You are now immortal!", Color(0, 255, 0))
end

function Godmode:RemovePlayer(player)
	for i, godPlayer in pairs(self.players) do
		if player:GetSteamId().string == godPlayer:GetSteamId().string then

			self.players[i] = nil

			if isValid(player) then
				Chat:Send(player, "[Godmode] You are mortal again.", Color(0, 255, 0))
			end
			
			return
		end
	end
end

function Godmode:KeepAlive()
	for i, player in pairs(self.players) do
		if IsValid(player) then
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
			self.players[i] = nil
		end
	end

	for i, player in pairs(self.reviveList) do
		if player:GetHealth() ~= 0 then
			player:Teleport(self.reviveCoords[player:GetSteamId().string], Angle())

			self.reviveList[player:GetSteamId().string] = nil
			self.reviveCoords[player:GetSteamId().string] = nil
		end
	end
end

function Godmode:PlayerChat(args)
	if args.text == "/godmode" then
		if self:isAdmin(args.player) or self:isGod(args.player) then

			if self:isGod(args.player) then
				self:RemovePlayer(args.player)
			else
				self:AddPlayer(args.player)
			end

			return false
		else
			Chat:Send(args.player, "[SERVER] You must be an admin to use this command.", Color(255,  0,  0))
		end
	end

	if args.text == "/gods" then
		if self:isAdmin(args.player) then

			local godNames = "[Godmode]"

			local playerExists = false

			for i, p in pairs(self.players) do
				playerExists = true
			end

			if playerExists then

				for i, player in pairs(self.players) do
					godNames = godNames .." " .. player:GetName() .. "(" .. player:GetSteamId().string .. ")"
				end
			else
				godNames = godNames .." No one is currently in Godmode!"
			end

			Chat:Send(args.player, godNames, Color(0, 255, 0))

			return false
		else
			Chat:Send(args.player, "[SERVER] You must be an admin to use this command.", Color(255,  0,  0))
		end
	end

	return true
end

function Godmode:PlayerQuit(args)
	self:RemovePlayer(args.player)
end

local godmode = Godmode()