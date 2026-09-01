local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Projectile = require(script.Parent.Parent.Parent.components.Projectile)
local RenderModel = require(script.Parent.Parent.Parent.components.RenderModel)

local function renderSystem(world)
	-- Listen for new projectile entities replicated from the server
    
	for entityId, record in world:queryChanged(Projectile) do
		if record.new and not record.old then
			-- Spawn physical visual part locally
			local part = Instance.new("Part")
			part.Shape = Enum.PartType.Ball
			part.Size = Vector3.new(2, 2, 2)
			part.Material = Enum.Material.Neon
			part.Color = if record.new.spellId == "Fireball" 
				then Color3.fromRGB(255, 85, 0) 
				else Color3.fromRGB(85, 255, 255)
			part.Anchored = true
			part.CanCollide = false
			part.Parent = workspace

			world:insert(entityId, RenderModel({ instance = part }))

		elseif not record.new and record.old then
			-- Despawn visual part when server despawns projectile entity
			local renderData = world:get(entityId, RenderModel)
			if renderData and renderData.instance then
				renderData.instance:Destroy()
			end
		end
	end
end

return renderSystem