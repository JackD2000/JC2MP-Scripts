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

--Utility function - Rounds a number to the given amount of digits after the comma
local function round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

--We use this function to load the admins SteamIds into the admins table
function Garbagecleaner:LoadAdmins(filename)
	local file = io.open(filename, "r")
	local i = 0
	local admins = {}

	if file == nil then
		print("[GarbageCleaner] The supplied file was not found!")
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

function Garbagecleaner:__init()
	--We start off by loading the admins from the 'admins.txt' file
	self.admins = self:LoadAdmins("server/admins.txt")

	--Vehicles that should not be removed are added here
	self.managedList = {}

	--The time between cycles
	self.interval = 30 --MINUTES

	self.timer = nil

	self.enabled = true

	self.WarningA = false
	self.WarningB = false

	Events:Subscribe("PlayerChat", self, self.PlayerChat)
	Events:Subscribe("PreTick", self, self.Cycle)
	
	--Other plugins can fire this event and supply a vehicle object to notify the garbage cleaner
	--that the said plugin is managing the vehicle by itself.

	Events:Subscribe("RegisterManagedVehicle", self, self.AddToManagedList)

	--We reload the freeroam plugin and make it add its vehicles to the managed list
	Events:Fire("ReloadFreeroam")
end

function Garbagecleaner:isAdmin(player)
	local adminstring = ""

	for i,line in ipairs(self.admins) do
		adminstring = adminstring .. line .. " "
	end

	if(string.match(adminstring, player:GetSteamId().string)) then
		return true
	end
	
	return false
end

function Garbagecleaner:Cycle(args)
	if self.enabled == true then
		if not self.timer then
			self.timer = Timer()
		else
			if self.timer:GetSeconds() > (self.interval - 5) * 60 and self.WarningA == false then
				Chat:Broadcast("[SERVER] Performing routine garbage cleanup in 5 minutes!", Color(255,  155,  55))
				self.WarningA = true

			elseif self.timer:GetSeconds() > (self.interval - 0.167) * 60 and self.WarningB == false then
				Chat:Broadcast("[SERVER] Performing routine garbage cleanup in 10 seconds!", Color(255,  155,  55))
				self.WarningB = true

			elseif self.timer:GetSeconds() > self.interval * 60 then
				self:Cleanup()
			end
		end
	end
end

function Garbagecleaner:PlayerChat(args)
	local cmd_args = args.text:split(" ")

	if cmd_args[1] == "/cleanup" then
		if self:isAdmin(args.player) then
			if cmd_args[2] then
				if cmd_args[2] == "reset" then
					if self.enabled == true then
						self.timer = nil

						Chat:Send(args.player, "[SERVER] Garbage Cleaner cycle has been reset - Interval = " ..self.interval .." Minutes", Color(0,  255,  0))

						return false
					else
						Chat:Send(args.player, "[SERVER] The garbage cycle is currently deactivated - Enable it by typing '/cleanup enable'", Color(255,  0,  0))

						return false
					end

				elseif cmd_args[2] == "time" then
					if self.enabled == true then
						Chat:Send(args.player, "[SERVER] Time until next cleanup cycle: " ..(self.interval - round(self.timer:GetSeconds() / 60, 2)) .." Minutes", Color(255,  155,  55))

						return false
					else
						Chat:Send(args.player, "[SERVER] The garbage cycle is currently deactivated!", Color(255,  0,  0))

						return false
					end
				
				elseif cmd_args[2] == "enable" then
					if self.enabled == false then
						self.enabled = true

						Chat:Send(args.player, "[SERVER] The garbage cycle has been enabled!", Color(0,  255,  0))

						return false
					else
						Chat:Send(args.player, "[SERVER] The garbage cycle is already enabled!", Color(255,  0,  0))

						return false
					end

				elseif cmd_args[2] == "disable" then
					if self.enabled == true then

						self.enabled = false
						self.timer = nil

						Chat:Send(args.player, "[SERVER] The garbage cycle has been disabled!", Color(0,  255,  0))

						return false
					else
						Chat:Send(args.player, "[SERVER] The garbage cycle is already disabled!", Color(255,  0,  0))

						return false
					end
				end
			else
				self:Cleanup()

				return false
			end
		else
			return false
		end
	end
 
	return true
end

function Garbagecleaner:AddToManagedList(vehicle)
	self.managedList[vehicle:GetId()] = vehicle
end

function Garbagecleaner:Cleanup()
	Chat:Broadcast("[SERVER] Commencing garbage cleanup!", Color(255,  155,  55))

	--We check if managed vehicles are still in the game. If not, remove them from the list.
	for i, v in pairs(self.managedList) do
		if not IsValid(v) then
			self.managedList[i] = nil
		end
	end

	local count = 0
	
	for v in Server:GetVehicles() do
		if not self.managedList[v:GetId()] then
			if v:GetWorld():GetId() == 0 then
				if #v:GetOccupants() == 0 then
					count = count + 1

					v:Remove()
				end
			end
		end
	end

	if count > 0 then
		Chat:Broadcast("[SERVER] Successfully cleaned up all unmanaged vehicles! (Count: " ..count ..")", Color(255,  155,  55))
	else
		Chat:Broadcast("[SERVER] No vehicles needed to be removed!", Color(255,  155,  55))
	end

	self.timer = nil
	self.WarningA = false
	self.WarningB = false
end

local cleaner = Garbagecleaner()