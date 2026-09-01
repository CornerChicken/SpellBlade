local Workspace = game:GetService("Workspace")

local projectileVisuals = {}

function projectileVisuals.createFireballPart(cframe: CFrame): BasePart
	local part = Instance.new("Part")
	part.Name = "FireballVisual"
	part.Shape = Enum.PartType.Ball
	part.Size = Vector3.new(2.5, 2.5, 2.5)
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(255, 85, 0)
	part.CanCollide = false
	part.Anchored = true
	part.CFrame = cframe
	part.Parent = Workspace

	-- Fire effect
	local attachment = Instance.new("Attachment")
    attachment.Parent = part
	local fire = Instance.new("Fire")
    fire.Parent = part
	fire.Size = 4
	fire.Heat = 10

	return part
end

function projectileVisuals.createStunBoltPart(cframe: CFrame): BasePart
	local part = Instance.new("Part")
	part.Name = "StunBoltVisual"
	part.Shape = Enum.PartType.Cylinder
	part.Size = Vector3.new(3.0, 1.2, 1.2)
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(0, 220, 255)
	part.CanCollide = false
	part.Anchored = true
	part.CFrame = cframe * CFrame.Angles(0, math.rad(90), 0) -- Align cylinder orientation
	part.Parent = Workspace

	return part
end

return projectileVisuals