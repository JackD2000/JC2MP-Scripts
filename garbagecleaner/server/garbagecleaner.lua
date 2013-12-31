--[[	
		Garbage cleaner - Created by Catlinman (https://twitter.com/Catlinman_)

		This script makes sure that no vehicles spawned through other plugins like the metatank
		plugin remain for too long cluttering the server. It uses a timer to remove vehicles
		after a certain interval if they are not being occupied. The default interval is 20 minutes.
		I have also modified the freeroam plugin to only reload vehicles if the event 'ReloadVehicles'
		is fired. This way, vehicles are removed and then reloaded in the freeroam plugin after they have
		been removed here.

		The freeroam plugin has also been modified to use a fixed spawns.txt file location for easier management.
]]


class 'Garbagecleaner'

local admins = {
	"STEAM_0:0:26199873",
	"STEAM_0:0:28323431",
}

local interval = 30 --MINUTES

local timer = nil

function Garbagecleaner:__init()
	Events:Subscribe("PlayerChat", self, self.PlayerChat)
	Events:Subscribe("PreTick", self, self.Cycle)
end

function Garbagecleaner:isAdmin(player)
	local adminstring = ""

	for i,line in ipairs(admins) do
		adminstring = adminstring .. line .. " "
	end

	if(string.match(adminstring, tostring(player:GetSteamId()))) then
		return true
	end
	
	return false
end

function Garbagecleaner:Cycle(args)
	if not timer then
		timer = Timer()
	else
		if timer:GetSeconds() > interval * 60 then
			self:Cleanup()
		end
	end
end

function Garbagecleaner:PlayerChat(args)
	if args.text == "/cleanup" then
		if self:isAdmin(args.player) then
			self:Cleanup()

			return false
		else
			Chat:Send(args.player, "[SERVER] You must be an admin to use this command.")
		end
	end
 
	return true
end

function Garbagecleaner:Cleanup()
	Chat:Broadcast("[SERVER] Commencing garbage cleanup!", Color(255,  0,  0))

	for v in Server:GetVehicles() do
		if v:GetWorld():GetId() == 0 then
			if #v:GetOccupants() < 1 then
				v:Remove()
			end
		end
	end

	Events:Fire("ReloadFreeroam")

	Chat:Broadcast("[SERVER] Successfully reloaded all vehicles!", Color(255,  0,  0))

	timer = nil
end

local cleaner = Garbagecleaner()