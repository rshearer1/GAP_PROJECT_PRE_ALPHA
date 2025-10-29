--[[
    PlanetVisualsService.lua
    Manages 3D planet visualization in Workspace
    
    Responsibilities:
    - Create planet sphere for each player
    - Position planets in player-specific areas
    - Update planet appearance based on state (biome, level, size)
    - Handle visual effects (atmosphere, particles, rotation)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)

local PlanetVisualsService = Knit.CreateService({
    Name = "PlanetVisualsService",
    Client = {},
})

-- Store planet models and rotation connections
PlanetVisualsService._planetModels = {}
PlanetVisualsService._rotationConnections = {}

-- Spacing between planets
local PLANET_SPACING = 100

--[[ Service Lifecycle ]]--

function PlanetVisualsService:KnitInit()
    print("[PlanetVisualsService] Initializing...")
    
    -- Create planets folder in Workspace
    local planetsFolder = Instance.new("Folder")
    planetsFolder.Name = "Planets"
    planetsFolder.Parent = Workspace
    
    self._planetsFolder = planetsFolder
end

function PlanetVisualsService:KnitStart()
    print("[PlanetVisualsService] Starting...")
    
    -- Get PlanetService and SpaceArenaService
    self._planetService = Knit.GetService("PlanetService")
    self._spaceArenaService = Knit.GetService("SpaceArenaService")
    
    -- Handle player joining
    Players.PlayerAdded:Connect(function(player)
        task.wait(2) -- Wait for planet data and station to be assigned
        self:_createPlanetVisual(player)
    end)
    
    -- Handle player leaving
    Players.PlayerRemoving:Connect(function(player)
        self:_removePlanetVisual(player.UserId)
    end)
    
    print("[PlanetVisualsService] Started successfully!")
end

--[[ Private Methods ]]--

function PlanetVisualsService:_createPlanetVisual(player: Player)
    local userId = player.UserId
    
    -- Get planet data
    local planetData = self._planetService:GetPlanetData(userId)
    if not planetData then
        warn("[PlanetVisualsService] No planet data for", player.Name)
        return
    end
    
    print(`[PlanetVisualsService] Creating planet for {player.Name}`)
    
    -- Get position from space station
    local position = Vector3.new(0, 520, 0) -- Default position at space station height
    
    if self._spaceArenaService then
        local stationData = self._spaceArenaService:GetPlayerStation(userId)
        if stationData then
            -- Place planet above the station platform
            position = stationData.position + Vector3.new(0, 100, 0)
            print(`[PlanetVisualsService] Using station position for {player.Name} at {position}`)
        else
            warn(`[PlanetVisualsService] No station assigned for {player.Name}, using default`)
        end
    else
        warn("[PlanetVisualsService] SpaceArenaService not available")
    end
    
    -- Create planet model
    local planetModel = Instance.new("Model")
    planetModel.Name = `{player.Name}_Planet`
    
    -- Create main sphere
    local sphere = Instance.new("Part")
    sphere.Name = "PlanetCore"
    sphere.Shape = Enum.PartType.Ball
    sphere.Size = Vector3.new(planetData.size, planetData.size, planetData.size)
    sphere.Position = position
    sphere.Anchored = true
    sphere.CanCollide = false
    sphere.Material = Enum.Material.Rock
    sphere.TopSurface = Enum.SurfaceType.Smooth
    sphere.BottomSurface = Enum.SurfaceType.Smooth
    
    -- Apply biome color
    local biomeConfig = Constants.BIOMES[string.upper(planetData.biome)]
    if biomeConfig then
        sphere.Color = biomeConfig.color
    end
    
    sphere.Parent = planetModel
    
    -- Start rotation using RunService (no script needed)
    local rotationConnection
    rotationConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not sphere or not sphere.Parent then
            if rotationConnection then
                rotationConnection:Disconnect()
            end
            return
        end
        sphere.CFrame = sphere.CFrame * CFrame.Angles(0, math.rad(0.5), 0)
    end)
    
    -- Add player name label
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PlayerLabel"
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, planetData.size/2 + 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = sphere
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = player.Name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.TextStrokeTransparency = 0.5
    label.Parent = billboard
    
    -- Add atmosphere glow (if planet has atmosphere)
    if planetData.atmosphere > 0 then
        local pointLight = Instance.new("PointLight")
        pointLight.Brightness = 1
        pointLight.Range = planetData.size * 2
        pointLight.Color = biomeConfig and biomeConfig.color or Color3.fromRGB(255, 255, 255)
        pointLight.Parent = sphere
    end
    
    planetModel.Parent = self._planetsFolder
    
    -- Store references
    self._planetModels[userId] = planetModel
    self._rotationConnections[userId] = rotationConnection
    
    print(`[PlanetVisualsService] Created planet for {player.Name} at {position}`)
end

function PlanetVisualsService:_removePlanetVisual(userId: number)
    -- Disconnect rotation
    local rotationConnection = self._rotationConnections[userId]
    if rotationConnection then
        rotationConnection:Disconnect()
        self._rotationConnections[userId] = nil
    end
    
    -- Remove model
    local planetModel = self._planetModels[userId]
    if planetModel then
        planetModel:Destroy()
        self._planetModels[userId] = nil
        print(`[PlanetVisualsService] Removed planet for user {userId}`)
    end
end

--[[ Public Methods ]]--

function PlanetVisualsService:UpdatePlanetVisual(userId: number, planetData: Types.PlanetState)
    local planetModel = self._planetModels[userId]
    if not planetModel then return end
    
    local sphere = planetModel:FindFirstChild("PlanetCore")
    if not sphere then return end
    
    -- Update size
    sphere.Size = Vector3.new(planetData.size, planetData.size, planetData.size)
    
    -- Update biome color and material
    local biomeConfig = Constants.BIOMES[string.upper(planetData.biome)]
    if biomeConfig then
        sphere.Color = biomeConfig.color
        
        -- Change material based on biome
        if planetData.biome == "Barren" then
            sphere.Material = Enum.Material.Rock
        elseif planetData.biome == "Rocky" then
            sphere.Material = Enum.Material.Slate
        elseif planetData.biome == "Oceanic" then
            sphere.Material = Enum.Material.Water
        elseif planetData.biome == "Forest" then
            sphere.Material = Enum.Material.Grass
        end
    end
    
    -- Update atmosphere glow
    local pointLight = sphere:FindFirstChild("PointLight")
    if planetData.atmosphere > 0 then
        if not pointLight then
            pointLight = Instance.new("PointLight")
            pointLight.Parent = sphere
        end
        pointLight.Brightness = planetData.atmosphere / 100
        pointLight.Range = planetData.size * 2
        pointLight.Color = biomeConfig and biomeConfig.color or Color3.fromRGB(255, 255, 255)
    elseif pointLight then
        pointLight:Destroy()
    end
    
    -- Update billboard position
    local billboard = sphere:FindFirstChild("PlayerLabel")
    if billboard then
        billboard.StudsOffset = Vector3.new(0, planetData.size/2 + 3, 0)
    end
end

---
-- Update planet position (called by PlotService)
-- @param userId number - Player's UserId
-- @param position Vector3 - New position for the planet
--
function PlanetVisualsService:UpdatePlanetPosition(userId: number, position: Vector3)
    local planetModel = self._planetModels[userId]
    if not planetModel then
        warn(`[PlanetVisualsService] No planet model found for user {userId}`)
        return
    end
    
    local planetCore = planetModel:FindFirstChild("PlanetCore")
    if planetCore then
        planetCore.Position = position
        print(`[PlanetVisualsService] Updated planet position for user {userId}`)
    end
end

return PlanetVisualsService
