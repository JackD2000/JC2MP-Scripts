class 'Garbagecleaner'

function Garbagecleaner:__init()
	Events:Subscribe("ModulesLoad", 	self, self.ModulesLoad)
	Events:Subscribe("ModuleUnload", 	self, self.ModuleUnload)
end

function Garbagecleaner:ModulesLoad()
	Events:FireRegisteredEvent("HelpAddItem",
		{
			name = 	"Garbage Cleaner",
			text = 
					"The Garbage Cleaner script removes all unused vehicles from the server.\n"
					"The script itself uses a timed cycle to perform this cleanup after a specified interval.\n"
					"It also announces the cleanup beforehand, giving players time to get back into their vehicles.\n"
					"If a player-spawned vehicle is unoccupied by the time a cleanup commences - The vehicle will be removed.\n\n"..

					"Admin commands:\n"..
					"/cleanup\n"..
					"Forces a cleanup cycle.\n\n"..

					"/cleanup enable\n"..
					"Enables the cleanup cycle.\n\n"..

					"/cleanup disable\n"..
					"Disables the cleanup cycle.\n\n"..

					"/cleanup time\n"..
					"Prints the time to the next cycle into the chat."
		})
end

function Garbagecleaner:ModuleUnload()
	Events:FireRegisteredEvent("HelpRemoveItem", {name = "Garbage Cleaner"})
end

local garbagecleaner = Garbagecleaner()