
class 'Boost'

function Boost:__init()
	self.admins = {
		"STEAM_0:0:26199873",
		"STEAM_0:0:28323431",
	}

	--Instead of storing full sets of players we only store their associated values
	self.playerValues = {}

	--The amount of boost added each tick
	self.boostAmount = 0.001

	Network:Subscribe("BoostAccelerate", self, self.Accelerate)
	Network:Subscribe("BoostBrake", self, self.Brake)

	Events:Subscribe("PostTick", self, self.Cooldown)
	Events:Subscribe("PlayerChat", self, self.PlayerChat)
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
				if cmd_args[2] == "add" and cmd_args[3] then
					local id = 0
					local name = ""

					if cmd_args[3] ~= "." then
						for player in Server:GetPlayers() do
							if player:GetName() == cmd_args[3] then
								if player:GetWorld():GetId() == 0 then

									id = player:GetSteamId().string
									name = player:GetName()

									break
								else
									Chat:Send(args.player, "[Boost] " ..cmd_args[3] .." is currently not in the main world and will be ignored!", Color( 255, 0, 0))

									return false
								end
							end
						end

						if name == "" and id == 0 then
							Chat:Send(args.player, "[Boost] " ..cmd_args[3] .." was not found on the server and will be ignored!", Color( 255, 0, 0))

							return false
						end
					else
						id = args.player:GetSteamId().string
						name = args.player:GetName()
					end

					if not self.playerValues[id] then
						self.playerValues[id] = {name = name, id = id, enabled = true, speed = 1}

						Chat:Send(args.player, "[Boost] " ..name .." has been added to the list of registered players!", Color( 0, 255, 0))
					else
						Chat:Send(args.player, "[Boost] " ..name .." is already in the list of registered players!", Color( 255, 0, 0))
					end

				elseif cmd_args[2] == "remove" and cmd_args[3] then

					local id = 0
					local name = ""

					if cmd_args[3] ~= "." then
						for player in Server:GetPlayers() do
							if player:GetName() == cmd_args[3] then
								if player:GetWorld():GetId() == 0 then

									id = player:GetSteamId().string
									name = player:GetName()

									break
								else
									Chat:Send(args.player, "[Boost] " ..cmd_args[3] .." is currently not in the main world and will be ignored!", Color( 255, 0, 0))

									return false
								end
							end
						end

						if name == "" and id == 0 then
							Chat:Send(args.player, "[Boost] " ..cmd_args[3] .." was not found on the server and will be ignored!", Color( 255, 0, 0))

							return false
						end
					else
						id = args.player:GetSteamId().string
						name = args.player:GetName()
					end

					if self.playerValues[id] then
						self.playerValues[id] = nil

						Chat:Send(args.player, "[Boost] " ..name .." has been removed to the list of registered players!", Color( 0, 255, 0))
					else
						Chat:Send(args.player, "[Boost] " ..name .." is not in the list of registered players!", Color( 255, 0, 0))
					end

				elseif cmd_args[2] == "players" then
					local playerNames = "[Boost]"

					local playerExists = false

					for i, p in pairs(self.playerValues) do
						playerExists = true
					end

					if playerExists == true then
						for i, player in pairs(self.playerValues) do
							playerNames = playerNames .." " .. player.name .. "(" .. player.id .. ")"
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
			else
				if args.player:GetWorld():GetId() == 0 then
					local id = args.player:GetSteamId().string

					if self.playerValues[id] == nil then
						Chat:Send(args.player, "[Boost] You are not in the list of registered players - Add yourself by typing '/boost add .'", Color( 0, 255, 0))

					else
						if self.playerValues[id].enabled == true then
							self.playerValues[id].enabled = false

							Chat:Send(args.player, "[Boost] Your boost has been disabled.", Color( 0, 255, 0))

						else
							self.playerValues[id].enabled = true

							Chat:Send(args.player, "[Boost] Your boost has been enabled.", Color( 0, 255, 0))
						end
					end

					return false
				else
					Chat:Send(args.player, "[Boost] You must be in the main world to use this command.", Color( 255, 0, 0))
				end
			end
		else
			Chat:Send(args.player, "[SERVER] You must be an admin to use this command.", Color( 255, 0, 0))
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

function Boost:Brake(args, client)
	if client:GetWorld():GetId() == 0 then
		if self.playerValues[client:GetSteamId().string] then
			if self.playerValues[client:GetSteamId().string].enabled == true then
				local vehicle = client:GetVehicle()

				if not IsValid(vehicle) then
					return
				end

				self.playerValues[client:GetSteamId().string].speed = math.clamp(self.playerValues[client:GetSteamId().string].speed - (self.boostAmount * 25), 1, 1000)

				client:GetVehicle():SetLinearVelocity(client:GetVehicle():GetLinearVelocity() * math.clamp(self.playerValues[client:GetSteamId().string].speed, 0, 1000))
			end
		end
	else
		if self.playerValues[client:GetSteamId().string].enabled == true then
			Chat:Send(client, "[Boost] You are not in the main world - Your boost has been disabled.", Color(255, 155, 55))
		end

		self.playerValues[client:GetSteamId().string].enabled = false
	end
end

local boost = Boost()