--[[
		Vehicle boost - Created by Catlinman (https://twitter.com/Catlinman_)

		As an Admin use shift to multiply your speed and ctrl to brake.

		TODO:	-> Add different modes
				-> Allow Admins to approve self.players for use
				-> Use chat commands for easy customisation
				-> Possible GUI for configuration
]]

class 'Boost'

function Boost:__init()
	self.admins = {
		"STEAM_0:0:26199873",
		"STEAM_0:0:28323431",
	}

	self.players = {}
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
	if #self.players > 0 then
		for i, p in pairs(self.players) do
			if self.players[i].speed > 1 then
				self.players[i].speed = self.players[i].speed - self.boostAmount / 100
			else
				self.players[i].speed = 1
			end
		end
	end
end

function Boost:PlayerChat(args)
	if args.text == "/boost" then
		if self:isAdmin(args.player) then
			local id = args.player:GetSteamId()

			if self.players[tostring(id)] == nil then

				self.players[tostring(id)] = {enabled = true, speed = 1}

				Chat:Send(args.player, "Boost: You have been added to the boost list.", Color( 0, 255, 0))
			else
				if self.players[tostring(id)].enabled == true then
					self.players[tostring(id)].enabled = false

					Chat:Send(args.player, "Boost: Your boost has been disabled.", Color( 0, 255, 0))

				else
					self.players[tostring(id)].enabled = true

					Chat:Send(args.player, "Boost: Your boost has been enabled.", Color( 0, 255, 0))
				end
			end

			return false
		else
			Chat:Send(args.player, "[SERVER] You must be an admin to use this command.", Color( 255, 0, 0))
		end
	end
 
	return true
end

function Boost:Accelerate(args, client)
	if client:GetWorld():GetId() == 0 then
		if self:isAdmin(client) then
			if self.players[tostring(client:GetSteamId())] then
				if self.players[tostring(client:GetSteamId())].enabled == true then
					local vehicle = client:GetVehicle()

					if not IsValid(vehicle) then
						return
					end

					self.players[tostring(client:GetSteamId())].speed = math.clamp(self.players[tostring(client:GetSteamId())].speed + self.boostAmount, 1, 1000)

				 	client:GetVehicle():SetLinearVelocity(client:GetVehicle():GetLinearVelocity() * self.players[tostring(client:GetSteamId())].speed)
				 end
			 end
		end
	end
end

function Boost:Brake(args, client)
	if client:GetWorld():GetId() == 0 then
		if self:isAdmin(client) then
			if self.players[tostring(client:GetSteamId())] then
				if self.players[tostring(client:GetSteamId())].enabled == true then
					local vehicle = client:GetVehicle()

					if not IsValid(vehicle) then
						return
					end

					self.players[tostring(client:GetSteamId())].speed = math.clamp(self.players[tostring(client:GetSteamId())].speed - (self.boostAmount * 25), 1, 1000)

					client:GetVehicle():SetLinearVelocity(client:GetVehicle():GetLinearVelocity() * math.clamp(self.players[tostring(client:GetSteamId())].speed, 0, 1000))
				end
			end
		end
	end
end

local boost = Boost()