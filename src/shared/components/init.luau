local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Matter = require(ReplicatedStorage.Packages.matter)

local components = {}

components.CharacterTag = Matter.component("CharacterTag")

return components