class 'Godmode'

function Godmode:__init()
	self.enabled = false

	Game:FireEvent("ply.vulnerable")

	Events:Subscribe("LocalPlayerBulletHit", self, self.HandleDamage)
	Events:Subscribe("LocalPlayerExplosionHit", self, self.HandleDamage)
	Events:Subscribe("LocalPlayerForcePulseHit", self, self.HandleDamage)
	Events:Subscribe("ModulesLoad", self, self.ModulesLoad)
	Events:Subscribe("ModuleUnload", self, self.ModuleUnload)

	Network:Subscribe("GodmodeToggle", self, self.GodmodeToggle)
end

function Godmode:GodmodeToggle(args)
	self.enabled = args

	if self.enabled == true then
		Game:FireEvent("ply.predator.awesomeness")

		Game:FireEvent("ply.makeinvulnerable")
	else
		Game:FireEvent("ply.vulnerable")
	end
end

function Godmode:HandleDamage(args)
	return not self.enabled
end

function Godmode:ModulesLoad()
	Events:FireRegisteredEvent("HelpAddItem",
		{
			name = 	"Godmode",
			text = 
					"The Godmode script makes every player who has been registered by an admin invincible.\n\n" ..

					"Commands:\n"..
					"/godmode\n"..
					"Enable or disable your godmode if you are in the list of registered players.\n\n"..

					"Admin commands:\n"..
					"/godmode add <player>\n"..
					"Add a player to the list of registered players. Leave the argument empty to add yourself.\n\n"..

					"/godmode remove <player>\n"..
					"Remove a player from the list of registered players. Leave the argument empty to remove yourself.\n\n"..

					"/godmode players\n"..
					"Prints all registered player's names into the chat."
		})
end

function Godmode:ModuleUnload()
	Events:FireRegisteredEvent("HelpRemoveItem", {name = "Godmode"})
end

local godMode = Godmode()