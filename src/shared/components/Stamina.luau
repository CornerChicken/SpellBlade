local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matter = require(ReplicatedStorage.Packages.matter)

export type StaminaData = {
    current: number,
    max: number
}

local Stamina = Matter.component("Stamina", {
	current = 100,
	max = 100,
}) :: (defaultData: StaminaData?) -> StaminaData

return Stamina
