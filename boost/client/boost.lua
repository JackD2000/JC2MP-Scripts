class 'Boost'

function Boost:__init()
	Events:Subscribe("KeyDown", self, self.Input)
	Events:Subscribe("ModulesLoad", self, self.ModulesLoad)
	Events:Subscribe("ModuleUnload", self, self.ModuleUnload)
end

function Boost:Input(args)
	if args.key == 16 then

		Network:Send("BoostAccelerate")

		return false

	elseif args.key == 17 then

		Network:Send("BoostBrake")

		return false

	else
		return true
	end
end

function Boost:ModulesLoad()
	Events:FireRegisteredEvent("HelpAddItem",
		{
			name = 	"Boost",
			text = 
					"The Boost script is used to accerlerate a registered players vehicle beyond the normal limit.\n\n" ..

					"Keys:\n"..
					"LSHIFT: Accerlerate your vehicle - Requires you to be registered.\n\n"..

					"Commands:\n"..
					"/boost\n"..
					"Enable or disable your boost key if you are in the list of registered players.\n\n"..

					"Admin commands:\n"..
					"/bost add <player>\n"..
					"Add a player to the list of registered players. Leave the argument empty to add yourself.\n\n"..

					"/boost remove <player>\n"..
					"Remove a player from the list of registered players. Leave the argument empty to remove yourself.\n\n"..

					"/boost players\n"..
					"Prints all registered player's names into the chat."
		})
end

function Boost:ModuleUnload()
	Events:FireRegisteredEvent("HelpRemoveItem", {name = "Boost"})
end

local boost = Boost()