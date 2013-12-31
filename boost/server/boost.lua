--[[
		Vehicle boost - Created by Catlinman (https://twitter.com/Catlinman_)

		As an Admin use shift to multiply your speed and ctrl to brake.

		TODO:	-> Add different modes
				-> Allow Admins to approve players for use
				-> Use chat commands for easy customisation
				-> Possible GUI for configuration
]]

class 'Boost'

local admins = {
	"STEAM_0:0:26199873",
	"STEAM_0:0:28323431",
}

local players = {}
local boostAmount = 0.001

function Boost:__init()
	Network:Subscribe("BoostAccelerate", self, self.Accelerate)
	Network:Subscribe("BoostBrake", self, self.Brake)

	Events:Subscribe("PostTick", self, self.Cooldown)
end

function Boost:isAdmin(player)
	local adminstring = ""

	for i,line in ipairs(admins) do
		adminstring = adminstring .. line .. " "
	end

	if(string.match(adminstring, tostring(player:GetSteamId()))) then
		return true
	end
	
	return false
end

function Boost:Cooldown()
	for i, p in pairs(players) do
		if players[i] - (boostAmount / 100) <= 0.9 then
			players[i] = nil
		else
			players[i] = players[i] - boostAmount / 100
		end
	end
end

function Boost:Accelerate(args, client)
	if self:isAdmin(client) then
		local vehicle = client:GetVehicle()

		if not IsValid(vehicle) then
			players[tostring(client:GetSteamId())] = nil

			return
		end

		if players[tostring(client:GetSteamId())] then
			players[tostring(client:GetSteamId())] = math.clamp(players[tostring(client:GetSteamId())] + boostAmount, 0, 1000)
		else
			players[tostring(client:GetSteamId())] = 1
		end

	 	--local angle = Camera:GetAngle()

	 	client:GetVehicle():SetLinearVelocity(client:GetVehicle():GetLinearVelocity() * players[tostring(client:GetSteamId())])
	end
end

function Boost:Brake(args, client)
	if self:isAdmin(client) then
		local vehicle = client:GetVehicle()

		if not IsValid(vehicle) then
			players[tostring(client:GetSteamId())] = nil

			return
		end

		if players[tostring(client:GetSteamId())] then
			players[tostring(client:GetSteamId())] = math.clamp(players[tostring(client:GetSteamId())] - (boostAmount * 25), 0, 1000)
		else
			players[tostring(client:GetSteamId())] = 1
		end

		client:GetVehicle():SetLinearVelocity(client:GetVehicle():GetLinearVelocity() * math.clamp(players[tostring(client:GetSteamId())], 0, 1000))
	end
end

local boost = Boost()