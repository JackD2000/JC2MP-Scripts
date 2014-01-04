class 'Godmode'

function Godmode:__init()
	self.enabled = false

	Events:Subscribe("LocalPlayerBulletHit", self, self.HandleDamage)
	Events:Subscribe("LocalPlayerExplosionHit", self, self.HandleDamage)
	Events:Subscribe("LocalPlayerForcePulseHit", self, self.HandleDamage)

	Events:Subscribe("PlayerQuit", self, self.LeaveServer)

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

function Godmode:LeaveServer(args)
	self:GodmodeToggle(false)
end

function Godmode:HandleDamage(args)
	return not self.enabled
end

local godMode = Godmode()