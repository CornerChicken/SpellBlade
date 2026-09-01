local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matter = require(ReplicatedStorage.Packages.matter)

export type RenderModelData = {
	instance: Instance,
}

local RenderModel = Matter.component("RenderModel", {
	instance = nil :: any,
}) :: (defaultData: RenderModelData?) -> RenderModelData

return RenderModel