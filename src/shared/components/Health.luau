local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matter = require(ReplicatedStorage.Packages.matter)

export type HealthData = {
    current: number,
    max: number
}

local Health = Matter.component("Health", {
	current = 100,
	max = 100,
}) :: (defaultData: HealthData?) -> HealthData

return Health
