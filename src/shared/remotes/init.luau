local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not remotesFolder then
    remotesFolder = Instance.new("Folder")
    remotesFolder.Name = "Remotes"
    remotesFolder.Parent = ReplicatedStorage
end

local function getOrCreateRemote(name)
    local remote = remotesFolder:FindFirstChild(name)
    if not remote then
        remote = Instance.new("RemoteEvent")
        remote.Name = name
        remote.Parent = remotesFolder
    end
    return remote
end

return {
    Attack = getOrCreateRemote("Attack"),
    Dodge = getOrCreateRemote("Dodge"),
    Parry = getOrCreateRemote("Parry"),
    CastSpell = getOrCreateRemote("CastSpell"),
}