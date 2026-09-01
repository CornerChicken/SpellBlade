local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Health = require(ReplicatedStorage.Shared.components.Health)
local Owner = require(ReplicatedStorage.Shared.components.Owner)

local function HealthSyncSystem(world)
    for id, record in world:queryChanged(Health) do --queryChanged returns entities whose health component has been changed since the last tick
        if record.new then
            local owner = world:get(id, Owner)
            if owner and owner.player and owner.player.Character then
                local humanoid = owner.player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.MaxHealth = record.new.max
                    humanoid.Health = math.max(record.new.current, 1)
                end
            end
        end
    end
end

return HealthSyncSystem