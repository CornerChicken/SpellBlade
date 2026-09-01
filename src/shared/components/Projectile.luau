local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matter = require(ReplicatedStorage.Packages.matter)

export type ProjectileData = {
	speed: number,
	direction: Vector3,
	spawnedAt: number,
	lifetime: number,
}

local Projectile = Matter.component("Projectile", {
	speed = 60,
	direction = Vector3.zero,
	spawnedAt = 0,
	lifetime = 3,
}) :: (defaultData: ProjectileData?) -> ProjectileData

return Projectile