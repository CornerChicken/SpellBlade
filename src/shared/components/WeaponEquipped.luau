local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matter = require(ReplicatedStorage.Packages.matter)

export type WeaponEquippedData = {
    weaponId: string
}

local WeaponEquipped = Matter.component("WeaponEquipped", {
	weaponId = "basicSword",
}) :: (defaultData: WeaponEquippedData?) -> WeaponEquippedData

return WeaponEquipped



