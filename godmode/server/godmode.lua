class 'GodMode'

local admins = {
	"STEAM_0:0:26199873",
	"STEAM_0:0:28323431",
}

local gods	 = {}

function GodMode:__init()
	Events:Subscribe("PlayerChat", self, self.PlayerChat)
	Events:Subscribe("PreTick", self, self.keepGodsAlive)
end

function isAdmin(player)
	local adminstring = ""

	for i,line in ipairs(admins) do
		adminstring = adminstring .. line .. " "
	end

	if string.match(adminstring, player:GetSteamId().string) then
		return true
	end
	return false
end

function isGod(player)
	local godstring = ""

	for i,line in ipairs(gods) do
		godstring = godstring .. line .. " "
	end

	if string.match(godstring, player:GetSteamId().string) then
		return true
	end
	return false
end

function getPlayerName(steamid)

	for player in Server:GetPlayers() do

		if steamid == player:GetSteamId().string then

			return player:GetName()
		end
	end
end


function GodMode:addGod(player)

	table.insert(gods,player:GetSteamId().string)
	Chat:Broadcast(player:GetName() .. " is ", Color(200, 200, 200))
end

function GodMode:removeGod(player)
	for i,v in ipairs(gods) do

		if player:GetSteamId().string == v then

			table.remove(gods,i)
			Chat:Broadcast(player:GetName() .. " is mortal again!", Color(200, 200, 200))
		end
	end
end

function GodMode:keepGodsAlive()
	for player in Server:GetPlayers() do

		if isGod(player) then

			if player:GetHealth() ~= 1 then

				player:SetHealth(1)
			end
		end
	end
end

function GodMode:PlayerChat(args)
	if isAdmin(args.player) then
		if args.text == "/godmode" then

			if isGod(args.player) then
				self:removeGod(args.player)
			else
				self:addGod(args.player)
			end
			return false
		end

		if args.text == "/gods" then
			godNames = "No one is in Godmode."
			for i,line in ipairs(gods) do
				godNames = "Gods: "
				if(i > 1) then
					godNames = godNames .. ", "
				end

				godNames = godNames .. getPlayerName(line)
			end

			Chat:Broadcast(godNames,Color(200, 200, 200))
			return false
		end
	return true
	end
end

local godmode = GodMode()