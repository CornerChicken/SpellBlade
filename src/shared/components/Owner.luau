local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matter = require(ReplicatedStorage.Packages.matter)

export type OwnerData = {
    player: Player
}

local Owner = Matter.component("Owner", {
	player = nil :: any,
}) :: (defaultData: OwnerData?) -> OwnerData

return Owner
