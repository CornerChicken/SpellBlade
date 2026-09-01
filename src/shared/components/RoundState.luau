local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matter = require(ReplicatedStorage.Packages.matter)

export type RoundStateData = {
    scoreA: number,
    scoreB: number,
    currentRound: number,
    phase: "Fighting" | "RoundOver" | "MatchOver",
}

local RoundState = Matter.component("RoundState", {
	scoreA = 0,
    scoreB = 0,
    currentRound = 1,
    phase = "Fighting", --Fighting, RoundOver, MatchOver
}) :: (defaultData: RoundStateData?) -> RoundStateData

return RoundState

