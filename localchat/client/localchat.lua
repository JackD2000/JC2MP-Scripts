class 'LocalChat'

function LocalChat:__init()
    self.block_all = false

    Events:Subscribe( "LocalPlayerChat", self, self.LocalPlayerChat )
    Events:Subscribe( "PlayerChat", self, self.PlayerChat )
    Events:Subscribe( "ModuleLoad", self, self.ModulesLoad )
    Events:Subscribe( "ModulesLoad", self, self.ModulesLoad )
    Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )
end

function LocalChat:LocalPlayerChat( args )
    if args.text == "/localchat" then
        self.block_all = not self.block_all

        if self.block_all then
            Chat:Print( "You are now in local chat only mode.", 
                Color( 255, 255, 255 ) )
        else
            Chat:Print( "You can now see global chat.",
                Color( 255, 255, 255 ) )
        end
    end
end

function LocalChat:PlayerChat( args )
    if IsValid( args.player ) and args.player ~= LocalPlayer then
        local col = math.lerp( 
                        args.player:GetColor(), Color( 255, 255, 255 ), 0.2 )

        Chat:Print( "[Nearby] " .. args.player:GetName() .. ": " .. args.text, col )

        return false
    end

    -- Let it through if it's not our problem
    if self.block_all and args.player ~= LocalPlayer then
        return false
    else
        return true
    end
end

function LocalChat:ModulesLoad()
    Events:FireRegisteredEvent( "HelpAddItem",
        {
            name = "Local Chat",
            text = 
                "Chat messages sent by players near you will be highlighted " ..
                "as local chat, so you can clearly pick out messages of importance.\n \n" ..
                "If you would like to hide global chat completely, and only see " ..
                "local chat, then type /localchat to toggle local chat only mode."
        } )
end

function LocalChat:ModuleUnload()
    Events:FireRegisteredEvent( "HelpRemoveItem",
        {
            name = "Local Chat"
        } )
end

local_chat = LocalChat()