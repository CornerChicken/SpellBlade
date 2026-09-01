local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matter = require(ReplicatedStorage.Packages.matter)

export type CombatStateData = {
    state: "Idle" | "Attacking" | "Dodging" | "Parrying" | "CastingSpell" | "Stunned",
}

local CombatState = Matter.component("CombatState", {
	state = "Idle",
}) :: (defaultData: CombatStateData?) -> CombatStateData

return CombatState

