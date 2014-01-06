
class 'MOTD'

function MOTD:__init()
	Events:Subscribe("ModulesLoad", 	self, self.ModulesLoad)
	Events:Subscribe("ModuleUnload", 	self, self.ModuleUnload)
end

function MOTD:ModulesLoad()
	Events:FireRegisteredEvent( "HelpAddItem",
		{
			name = 	"MOTD",
			text = 
					"The Message of the day script is used to present players with a join message.\n\n" ..

					"Commands:.\n"..
					"/motd\n"..
					"Displays the message of the day.\n\n"..

					"/help\n"..
					"Gives a quick overview of the servers custom commands and keys."
		} )
end

function MOTD:ModuleUnload()
	Events:FireRegisteredEvent("HelpRemoveItem", {name = "MOTD"})
end

local motd = MOTD()