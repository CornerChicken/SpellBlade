local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matter = require(ReplicatedStorage.Packages.matter)

export type ActiveSpellCastData = {
	spellId: string,          -- e.g., "Fireball", "DashStrike", "StunBolt"
	startedAt: number,        -- os.clock() timestamp when the cast began
	channelTime: number,      -- Duration in seconds before release (0 for instant)
	targetCFrame: CFrame,     -- The aim direction/position passed from the client intent
}

local ActiveSpellCast = Matter.component("ActiveSpellCast", {
	spellId = "Fireball",
	startedAt = 0,
	channelTime = 0.3,
	targetCFrame = CFrame.identity,
}) :: (defaultData: ActiveSpellCastData?) -> ActiveSpellCastData

return ActiveSpellCast