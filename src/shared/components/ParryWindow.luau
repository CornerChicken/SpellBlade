local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matter = require(ReplicatedStorage.Packages.matter)

export type ParryWindow = {
    startedAt: number,
    duration: number,
}

local ParryWindow = Matter.component("ParryWindow", {
	startedAt = 0,
    duration = 0.3,
}) :: (defaultData: ParryWindow?) -> ParryWindow

return ParryWindow
