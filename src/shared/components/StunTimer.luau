local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matter = require(ReplicatedStorage.Packages.matter)

export type StunTimer = {
endsAt: number
}

local StunTimer = Matter.component("StunTimer", {
	endsAt = 0,
}) :: (defaultData: StunTimer?) -> StunTimer

return StunTimer
