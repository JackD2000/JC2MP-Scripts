class 'Godmode'

function Godmode:__init()
	self.enabled = false

	Game:FireEvent("ply.vulnerable")

	Events:Subscribe("LocalPlayerBulletHit", self, self.HandleDamage)
	Events:Subscribe("LocalPlayerExplosionHit", self, self.HandleDamage)
	Events:Subscribe("LocalPlayerForcePulseHit", self, self.HandleDamage)

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

local godMode = Godmode()