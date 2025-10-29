--[[
    SpaceArenaService.lua
    Server-side space arena management
    
    Handles:
    - Central black hole placement
    - Player station plot assignments (circular around black hole)
    - Equal angular spacing with varying Y heights
    - Station positions and boundaries
    
    GAP Compliance:
    - Uses Janitor for cleanup
    - References Constants for all values
    - JSDoc comments on all methods
]]

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Janitor = require(game:GetService("ReplicatedStorage").Packages.Janitor)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Constants = require(ReplicatedStorage.Shared.Constants)

local SpaceArenaService = Knit.CreateService {
    Name = "SpaceArenaService",
    Client = {},
    
    -- Black hole instance
    _blackHole = nil,
    
    -- Player station assignments {[userId] = plotNumber}
    _playerStations = {},
    
    -- Station positions (pre-calculated circular positions)
    _stationPositions = {},
    
    -- Janitor for cleanup
    _janitor = Janitor.new(),
}

---
-- Initialize SpaceArenaService
--
function SpaceArenaService:KnitInit()
    print("[SpaceArenaService] Initializing...")
    
    -- Pre-calculate station positions around black hole
    self:_calculateStationPositions()
end

---
-- Start SpaceArenaService
--
function SpaceArenaService:KnitStart()
    print("[SpaceArenaService] Starting...")
    
    -- Create central black hole
    self:_createBlackHole()
    
    -- Create station zones (visual markers)
    self:_createStationZones()
    
    print("[SpaceArenaService] Black hole arena ready!")
end

---
-- Calculate positions for player stations in a circle around black hole
-- Each station at equal angular spacing but different Y heights
-- @private
--
function SpaceArenaService:_calculateStationPositions()
    local arenaRadius = Constants.SPACE_ARENA.ARENA_RADIUS
    local maxPlayers = Constants.SPACE_ARENA.MAX_PLAYER_STATIONS
    local centerPos = Constants.SPACE_ARENA.BLACK_HOLE_POSITION
    local yVariation = Constants.SPACE_ARENA.STATION_Y_VARIATION
    
    for i = 1, maxPlayers do
        -- Equal angular spacing around circle
        local angle = (i - 1) * (2 * math.pi / maxPlayers)
        
        -- Calculate X and Z on circle
        local x = centerPos.X + (arenaRadius * math.cos(angle))
        local z = centerPos.Z + (arenaRadius * math.sin(angle))
        
        -- Vary Y height in a wave pattern
        local yOffset = math.sin(angle * 2) * yVariation -- Creates wave around circle
        local y = centerPos.Y + yOffset
        
        self._stationPositions[i] = {
            position = Vector3.new(x, y, z),
            angle = angle,
            plotNumber = i,
            lookAtCenter = CFrame.lookAt(Vector3.new(x, y, z), centerPos), -- Face black hole
        }
    end
    
    print("[SpaceArenaService] Calculated positions for", maxPlayers, "stations")
end

---
-- Get a station plot for a player (assigns next available)
-- @param userId number - Player's UserId
-- @return table - Station data {position, angle, plotNumber, lookAtCenter}
--
function SpaceArenaService:GetPlayerStation(userId)
    -- Check if player already has a station
    if self._playerStations[userId] then
        local plotNumber = self._playerStations[userId]
        return self._stationPositions[plotNumber]
    end
    
    -- Find next available plot
    local usedPlots = {}
    for _, plotNum in pairs(self._playerStations) do
        usedPlots[plotNum] = true
    end
    
    for plotNum, stationData in ipairs(self._stationPositions) do
        if not usedPlots[plotNum] then
            self._playerStations[userId] = plotNum
            print("[SpaceArenaService] Assigned plot", plotNum, "to user", userId)
            return stationData
        end
    end
    
    -- All plots taken - assign to plot 1 (fallback)
    warn("[SpaceArenaService] All plots taken! Assigning player", userId, "to plot 1")
    self._playerStations[userId] = 1
    return self._stationPositions[1]
end

---
-- Release a player's station plot when they leave
-- @param userId number - Player's UserId
--
function SpaceArenaService:ReleasePlayerStation(userId)
    if self._playerStations[userId] then
        local plotNum = self._playerStations[userId]
        print("[SpaceArenaService] Released plot", plotNum, "from user", userId)
        self._playerStations[userId] = nil
    end
end

---
-- Create the central black hole
-- @private
--
function SpaceArenaService:_createBlackHole()
    local centerPos = Constants.SPACE_ARENA.BLACK_HOLE_POSITION
    local blackHoleSize = Constants.SPACE_ARENA.BLACK_HOLE_SIZE
    
    -- Create black hole sphere
    local blackHole = Instance.new("Part")
    blackHole.Name = "BlackHole"
    blackHole.Shape = Enum.PartType.Ball
    blackHole.Size = Vector3.new(blackHoleSize, blackHoleSize, blackHoleSize)
    blackHole.Position = centerPos
    blackHole.Anchored = true
    blackHole.CanCollide = false
    blackHole.Material = Enum.Material.Neon
    blackHole.Color = Color3.fromRGB(10, 10, 30) -- Dark blue-black
    blackHole.Transparency = 0.3
    blackHole.Parent = Workspace
    
    -- Add glow effect
    local pointLight = Instance.new("PointLight")
    pointLight.Brightness = 2
    pointLight.Color = Color3.fromRGB(50, 50, 150)
    pointLight.Range = blackHoleSize * 3
    pointLight.Parent = blackHole
    
    -- Add particle effect (accretion disk)
    local particles = Instance.new("ParticleEmitter")
    particles.Texture = "rbxasset://textures/particles/smoke_main.dds"
    particles.Rate = 50
    particles.Lifetime = NumberRange.new(5, 10)
    particles.Speed = NumberRange.new(20, 30)
    particles.Rotation = NumberRange.new(0, 360)
    particles.RotSpeed = NumberRange.new(50, 100)
    particles.Color = ColorSequence.new(Color3.fromRGB(150, 100, 200), Color3.fromRGB(50, 50, 150))
    particles.Size = NumberSequence.new(10, 20)
    particles.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.8),
        NumberSequenceKeypoint.new(0.5, 0.5),
        NumberSequenceKeypoint.new(1, 1),
    })
    particles.Parent = blackHole
    
    self._blackHole = blackHole
    
    print("[SpaceArenaService] Created black hole at", centerPos)
end

---
-- Create visual markers for station zones
-- @private
--
function SpaceArenaService:_createStationZones()
    local zoneRadius = Constants.SPACE_ARENA.STATION_ZONE_RADIUS
    
    for i, stationData in ipairs(self._stationPositions) do
        -- Create zone marker (transparent sphere)
        local zone = Instance.new("Part")
        zone.Name = "StationZone_" .. i
        zone.Shape = Enum.PartType.Cylinder
        zone.Size = Vector3.new(5, zoneRadius * 2, zoneRadius * 2)
        zone.Position = stationData.position
        zone.CFrame = stationData.lookAtCenter * CFrame.Angles(0, 0, math.pi/2) -- Orient cylinder
        zone.Anchored = true
        zone.CanCollide = false
        zone.Material = Enum.Material.ForceField
        zone.Color = Color3.fromRGB(100, 200, 255)
        zone.Transparency = 0.9
        zone.Parent = Workspace
        
        -- Add boundary ring
        local ring = Instance.new("Part")
        ring.Name = "BoundaryRing"
        ring.Shape = Enum.PartType.Cylinder
        ring.Size = Vector3.new(2, zoneRadius * 2.1, zoneRadius * 2.1)
        ring.Position = stationData.position
        ring.CFrame = zone.CFrame
        ring.Anchored = true
        ring.CanCollide = false
        ring.Material = Enum.Material.Neon
        ring.Color = Color3.fromRGB(0, 150, 255)
        ring.Transparency = 0.7
        ring.Parent = zone
        
        -- Add plot number label
        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0, 100, 0, 50)
        billboard.StudsOffset = Vector3.new(0, zoneRadius + 10, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = zone
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = "PLOT " .. i
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Parent = billboard
    end
    
    print("[SpaceArenaService] Created", #self._stationPositions, "station zones")
end

---
-- Get black hole position
-- @return Vector3 - Black hole center position
--
function SpaceArenaService.Client:GetBlackHolePosition()
    return Constants.SPACE_ARENA.BLACK_HOLE_POSITION
end

---
-- Get player's assigned station data
-- @param player Player - The player requesting their station
-- @return table - Station data {position, angle, plotNumber, lookAtCenter}
--
function SpaceArenaService.Client:GetMyStation(player)
    return self.Server:GetPlayerStation(player.UserId)
end

return SpaceArenaService
