local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matter = require(ReplicatedStorage.Packages.matter)

export type RenderModelData = {
	model: Instance?,
}

local RenderModel = Matter.component("RenderModel", {
	model = nil :: Instance?,
})

return RenderModel