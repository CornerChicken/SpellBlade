local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StunTimer = require(ReplicatedStorage.Shared.components.StunTimer)
local CombatState = require(ReplicatedStorage.Shared.components.CombatState)

local function StunSystem(world)
    for id, timer, state in world:query(StunTimer, CombatState) do
        if os.clock() >= timer.endsAt then
            world:remove(id, StunTimer)
            if state.state == "Stunned" then
                world:insert(id, state:patch({ state = "Idle" }))
            end
        end
    end
end

return StunSystem