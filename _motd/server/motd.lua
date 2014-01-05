
class 'MOTD'

function MOTD:ReadFile(filename)
    local file = io.open(filename, "rb")

    if file == nil then
    	print("[MOTD] " ..filename .." was not found!")

    	return nil
    end

    local lines = {}

    for line in file:lines() do
        if string.sub(line, 1, 2) ~= "--" then
            table.insert(lines, line)
        end
    end

    return lines
end

function MOTD:BroadcastMOTD()
    if self.message ~= nil then
        for i, line in pairs(self.message) do
            Chat:Broadcast(self.prefix ..line, self.color)
        end
    end
end

function MOTD:DisplayMOTD(player)
    if self.message ~= nil then
        for i, line in pairs(self.message) do
            Chat:Send(player, self.prefix ..line, self.color)
        end
    end
end

function MOTD:DisplayHelp(player)
    if self.help ~= nil then
        for i, line in pairs(self.help) do
            Chat:Send(player, self.prefix ..line, self.color)
        end
    end
end

function MOTD:__init()
    --Displayed infront of the MOTD and help lines.
    self.prefix = "[SERVER] "

    --The color of the messages.
    self.color = Color(25, 225, 125)

    --This file should contain some short information about the server.
	self.message = self:ReadFile("server/message.txt") 

    --The help file should lists the players available commands and keys.
    self.help = self:ReadFile("server/help.txt")   

	Events:Subscribe("PlayerJoin", self, self.PlayerJoin)
	Events:Subscribe("PlayerChat", self, self.PlayerChat)
    Events:Subscribe("ModuleLoad",    self, self.ModuleLoad)
    Events:Subscribe("ModuleUnload",    self, self.ModuleUnload)
end

function MOTD:PlayerJoin(args)
	self:DisplayMOTD(args.player)
end

function MOTD:PlayerChat(args)
	if args.text == "/motd" then
        self:DisplayMOTD(args.player)

        return false

	elseif args.text == "/help" then
        self:DisplayHelp(args.player)

        return false
    end

    return true
end

function MOTD:ModuleLoad(args)
    self:BroadcastMOTD()
end

function MOTD:ModuleUnload(args)
    Chat:Broadcast(self.prefix .."Reloading plugins!", self.color)
end

local motd = MOTD()