local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matter = require(ReplicatedStorage.Packages.matter)

export type DodgeVelocity = {
    direction: Vector3, -- unit vector (length 1), which way to dash
    speed: number,      -- studs per second
    endsAt: number,
}

local DodgeVelocity = Matter.component("DodgeVelocity", {
	direction = Vector3.new(0, 0, 0), -- unit vector (length 1), which way to dash
    speed = 0,                         -- studs per second
    endsAt = 0,
}) :: (defaultData: DodgeVelocity?) -> DodgeVelocity

return DodgeVelocity
