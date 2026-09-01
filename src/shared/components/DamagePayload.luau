local Matter = require(game:GetService("ReplicatedStorage").Packages.matter)

export type DamagePayload = {
    casterEntity: number,
    damage: number,
    stunDuration: number,
}

return Matter.component("DamagePayload", {
	casterEntity = 0,
	damage = 25,
	stunDuration = 0, -- Set > 0 for StunBolt
})