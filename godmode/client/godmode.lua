class 'Godmode'

function Godmode:__init()
	self.enabled = false

	Events:Subscribe("LocalPlayerBulletHit", self, self.Handle)
	Events:Subscribe("LocalPlayerExplosionHit", self, self.Handle)
	Events:Subscribe("LocalPlayerForcePulseHit", self, self.Handle)

	Network:Subscribe("GodmodeToggle", self, self.GodmodeToggle)
end

function Godmode:GodmodeToggle(client, args)
	self.enabled = args
end

function Godmode:Handle(args)
	return not self.enabled
end

local godMode = Godmode()