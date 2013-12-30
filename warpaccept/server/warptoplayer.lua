class 'WarpToPlayer'

function WarpToPlayer:__init()
	self.warpRequests = {}
	self.textColor = Color(200, 50, 200)
	
	Events:Subscribe("PlayerChat", self, self.PlayerChat)
end

function WarpToPlayer:PlayerChat(args)
	local message = args.text
	local player = args.player
	
	local words = {}
	for word in string.gmatch(message, "[^%s]+") do
		table.insert(words, word)
		break
	end
	
	if (words[1] == "/gtp") then
		local targetPlayerName = message:gsub("/gtp ", "") -- Get target player name from command
		local targetPlayer = nil
		
		for playerSearch in Server:GetPlayers() do
			if string.find(playerSearch:GetName():lower(), targetPlayerName:lower()) then -- Find player with matching name
				targetPlayer = playerSearch
				break
			end
		end
		
		if targetPlayer == nil then
			Chat:Send(player, "Could not find a player with the nane \"" .. targetPlayerName .. "\"", self.textColor)
			return false
		end
		
		self.warpRequests[targetPlayer] = player
		Chat:Send(player, targetPlayer:GetName() .. " must accept your teleport.", self.textColor)
		Chat:Send(targetPlayer, player:GetName() .. " has requested to teleport to you. Type /gta to accept.", self.textColor)
		return false
	elseif (words[1] == "/gta") then
		local teleportingPlayer = nil
		for target, requester in pairs(self.warpRequests) do
			if (target == player) then
				teleportingPlayer = requester
				self.warpRequests[target] = nil
				break
			end
		end
	
		if (teleportingPlayer == nil) then
			Chat:Send(player, "There are no teleport requests pending.", self.textColor)
			return false
		end
		
		Chat:Send(player, teleportingPlayer:GetName() .. " has warped to you.", self.textColor)
		Chat:Send(teleportingPlayer, "You have warped to " .. player:GetName() .. ".", self.textColor)
		
		local vector = player:GetPosition()
		vector.x = vector.x + 2
		teleportingPlayer:SetPosition(vector)
	end
end

local warpToPlayer = WarpToPlayer()