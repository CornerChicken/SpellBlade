local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matter = require(ReplicatedStorage.Packages.matter)

export type AttackWindup = {
    startedAt: number,
    range: number,
    damage: number,
}

local AttackWindup = Matter.component("AttackWindup", {
	startedAt = 0,
    range = 6, --in studs
    damage = 20,
}) :: (defaultData: AttackWindup?) -> AttackWindup

return AttackWindup
