--[[	
		Garbage cleaner - Created by Catlinman (https://twitter.com/Catlinman_)

		This script makes sure that no vehicles spawned through other plugins like the metatank
		plugin remain for too long cluttering the server. It uses a timer to remove vehicles
		after a certain interval if they are not being occupied. The default interval is 30 minutes.
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

--Vehicles that should not be removed are added here
local managedList = {}

local interval = 30 --MINUTES

local timer = nil
local triggeredWarning = false

function Garbagecleaner:__init()
	Events:Subscribe("PlayerChat", self, self.PlayerChat)
	Events:Subscribe("PreTick", self, self.Cycle)
	
	Events:Subscribe("RegisterManagedVehicle", self, self.AddToManagedList)

	Events:Fire("ReloadFreeroam")
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
		if timer:GetSeconds() > (interval - 5) * 60 and triggeredWarning == false then
			Chat:Broadcast("[SERVER] Performing routine garbage cleanup in 5 minutes!", Color(255,  0,  0))
			triggeredWarning = true

		elseif timer:GetSeconds() > interval * 60 then
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

function Garbagecleaner:AddToManagedList(vehicle)
	managedList[vehicle:GetId()] = vehicle
end

function Garbagecleaner:Cleanup()
	Chat:Broadcast("[SERVER] Commencing garbage cleanup!", Color(255,  0,  0))

	--We check if managed vehicles are still in the game. If not, remove them from the list.
	for i, v in pairs(managedList) do
		for v2 in v:GetWorld():GetVehicles() do
			if v == v2 then return end
		end

		v = nil
	end

	for v in Server:GetVehicles() do
		if not managedList[v:GetId()] or v:GetUnoccupiedRemove() == true then
			if v:GetWorld():GetId() == 0 then
				if #v:GetOccupants() < 1 then
					v:Remove()
				end
			end
		end
	end

	Chat:Broadcast("[SERVER] Successfully cleaned up all unmanaged vehicles!", Color(255,  0,  0))

	timer = nil
	triggeredWarning = false
end

local cleaner = Garbagecleaner()