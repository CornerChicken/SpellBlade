local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Components = require(ReplicatedStorage.Shared.components)

local function StunSystem(world)
    for id, timer, state in world:query(Components.StunTimer, Components.CombatState) do
        if os.clock() >= timer.endsAt then
            world:remove(id, Components.StunTimer)
            if state.state == "Stunned" then
                world:insert(id, state:patch({ state = "Idle" }))
            end
        end
    end
end

return StunSystem