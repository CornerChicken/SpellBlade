local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matter = require(ReplicatedStorage.Packages.matter)

export type ProjectileData = {
	casterEntity: number,
	spellId: string,
	damage: number,
	speed: number,
	direction: Vector3,
	spawnedAt: number,
	lifetime: number,
	stunDuration: number?,
}

local Projectile = Matter.component("Projectile", {
	casterEntity = -1,
	spellId = "",
	damage = 0,
	speed = 0,
	direction = Vector3.zero,
	spawnedAt = 0,
	lifetime = 3,
	stunDuration = 0,
}) :: (defaultData: ProjectileData?) -> ProjectileData

return Projectile