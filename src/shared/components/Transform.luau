local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matter = require(ReplicatedStorage.Packages.matter)

export type TransformData = {
    cframe: CFrame,
}

local Transform = Matter.component("Transform", {
	cframe = CFrame.new(),
})

return Transform