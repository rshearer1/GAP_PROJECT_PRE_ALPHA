--[[
    SpawnService.lua
    Server-side spawn area management
    
    Creates basic spawn area centered on player plots
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Janitor = require(ReplicatedStorage.Packages.Janitor)

local SpawnService = Knit.CreateService({
    Name = "SpawnService",
    Client = {},
})

SpawnService._janitor = Janitor.new()
SpawnService._spawnCenter = nil
SpawnService._spawnReady = false

function SpawnService:KnitInit()
    print("[SpawnService] Initializing...")
end

function SpawnService:KnitStart()
    print("[SpawnService] Starting...")
    
    -- Set up player teleport handler FIRST
    self._janitor:Add(Players.PlayerAdded:Connect(function(player)
        self:_handlePlayerSpawn(player)
    end), "Disconnect")
    
    -- Handle existing players
    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(function()
            self:_handlePlayerSpawn(player)
        end)
    end
    
    -- Now build spawn area
    print("[SpawnService] Waiting for plots to load...")
    task.wait(2)
    
    local spawnCenter = self:_calculatePlotCenter()
    print("[SpawnService] Spawn center:", spawnCenter)
    
    self._spawnCenter = spawnCenter
    self:_buildSpawnArea(spawnCenter)
    self._spawnReady = true
    
    print("[SpawnService] Basic spawn area created!")
end

function SpawnService:_calculatePlotCenter()
    local plotsFolder = Workspace:FindFirstChild("PlayerPlots")
    
    if not plotsFolder then
        warn("[SpawnService] PlayerPlots folder not found")
        return Vector3.new(0, 0, 0)
    end
    
    local totalX, totalZ = 0, 0
    local plotCount = 0
    
    for _, plot in ipairs(plotsFolder:GetChildren()) do
        local basePart = plot:FindFirstChildWhichIsA("BasePart", true)
        if basePart then
            totalX = totalX + basePart.Position.X
            totalZ = totalZ + basePart.Position.Z
            plotCount = plotCount + 1
        end
    end
    
    if plotCount == 0 then
        warn("[SpawnService] No plots found")
        return Vector3.new(0, 0, 0)
    end
    
    local centerX = totalX / plotCount
    local centerZ = totalZ / plotCount
    
    print("[SpawnService] Calculated center from", plotCount, "plots")
    return Vector3.new(centerX, 0, centerZ)
end

---
-- Handle player spawn - teleport to correct location
-- @param player Player - The player joining
--
function SpawnService:_handlePlayerSpawn(player: Player)
    -- Wait for character to load
    local character = player.Character or player.CharacterAdded:Wait()
    
    -- Wait for spawn area to be ready
    local timeout = 0
    while not self._spawnReady and timeout < 50 do
        task.wait(0.1)
        timeout = timeout + 1
    end
    
    if not self._spawnCenter then
        warn("[SpawnService] Spawn center not ready for", player.Name)
        return
    end
    
    -- Wait for HumanoidRootPart to exist
    local hrp = character:WaitForChild("HumanoidRootPart", 5)
    if not hrp then
        warn("[SpawnService] No HumanoidRootPart for", player.Name)
        return
    end
    
    -- Teleport player to spawn center
    local spawnPosition = self._spawnCenter + Vector3.new(0, 5, 0)
    hrp.CFrame = CFrame.new(spawnPosition)
    
    print("[SpawnService] Teleported", player.Name, "to spawn center")
end

function SpawnService:_buildSpawnArea(centerPosition)
    -- Remove any existing spawn locations from workspace
    for _, child in ipairs(Workspace:GetChildren()) do
        if child:IsA("SpawnLocation") then
            print("[SpawnService] Removing default spawn:", child.Name)
            child:Destroy()
        end
    end
    
    local spawnFolder = Instance.new("Folder")
    spawnFolder.Name = "SpawnArea"
    spawnFolder.Parent = Workspace
    
    local platform = Instance.new("Part")
    platform.Name = "SpawnPlatform"
    platform.Size = Vector3.new(40, 1, 40)
    platform.Position = centerPosition
    platform.Anchored = true
    platform.Material = Enum.Material.SmoothPlastic
    platform.Color = Color3.fromRGB(50, 50, 50)
    platform.Parent = spawnFolder
    
    local spawnRadius = 15
    local numSpawns = 8
    
    for i = 1, numSpawns do
        local angle = (math.pi * 2 / numSpawns) * i
        local x = math.cos(angle) * spawnRadius
        local z = math.sin(angle) * spawnRadius
        
        local spawn = Instance.new("SpawnLocation")
        spawn.Name = "Spawn" .. i
        spawn.Size = Vector3.new(4, 1, 4)
        spawn.Position = centerPosition + Vector3.new(x, 1, z)
        spawn.Anchored = true
        spawn.CanCollide = false
        spawn.Material = Enum.Material.Neon
        spawn.Color = Color3.fromRGB(80, 180, 255)
        spawn.Transparency = 0.3
        spawn.Duration = 0
        spawn.Parent = spawnFolder
    end
    
    print("[SpawnService] Created platform at", centerPosition)
end

return SpawnService
