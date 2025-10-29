--[[
    SpaceStationService.lua
    Server-side space station management
    
    Handles:
    - Station core creation and upgrades
    - Module placement and management
    - Station resources and capacity
    - Module types: Storage, Defense, Mining, Shield, Hangar
    
    GAP Compliance:
    - Uses Janitor for cleanup
    - References Constants for all values
    - JSDoc comments on all methods
]]

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Janitor = require(game:GetService("ReplicatedStorage").Packages.Janitor)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local Constants = require(ReplicatedStorage.Shared.Constants)

local SpaceStationService = Knit.CreateService {
    Name = "SpaceStationService",
    Client = {},
    
    -- Player stations {[userId] = stationData}
    _playerStations = {},
    
    -- Station models folder
    _stationsFolder = nil,
    
    -- Janitor for cleanup
    _janitor = Janitor.new(),
}

---
-- Initialize SpaceStationService
--
function SpaceStationService:KnitInit()
    print("[SpaceStationService] Initializing...")
    
    -- Create folder for stations
    local stationsFolder = Instance.new("Folder")
    stationsFolder.Name = "PlayerStations"
    stationsFolder.Parent = Workspace
    self._stationsFolder = stationsFolder
end

---
-- Start SpaceStationService
--
function SpaceStationService:KnitStart()
    print("[SpaceStationService] Starting...")
    
    -- Get SpaceArenaService
    local SpaceArenaService = Knit.GetService("SpaceArenaService")
    
    -- Handle player joining
    self._janitor:Add(Players.PlayerAdded:Connect(function(player)
        task.wait(1) -- Wait for SpaceArenaService to assign plot
        
        -- Get player's station position
        local stationData = SpaceArenaService:GetPlayerStation(player.UserId)
        
        -- Create station for player
        self:_createStationForPlayer(player.UserId, stationData)
    end), "Disconnect")
    
    -- Handle player leaving
    self._janitor:Add(Players.PlayerRemoving:Connect(function(player)
        self:_destroyPlayerStation(player.UserId)
    end), "Disconnect")
    
    print("[SpaceStationService] Started!")
end

---
-- Create a station for a player
-- @param userId number - Player's UserId
-- @param plotData table - Station position and orientation data
-- @private
--
function SpaceStationService:_createStationForPlayer(userId, plotData)
    if self._playerStations[userId] then
        warn("[SpaceStationService] Station already exists for user", userId)
        return
    end
    
    -- Create station data
    local stationData = {
        userId = userId,
        level = 1,
        position = plotData.position,
        orientation = plotData.lookAtCenter,
        modules = {},
        resources = {
            metal = 0,
            crystals = 0,
            energy = 0,
        },
        capacity = {
            metal = Constants.SPACE_STATION.STARTING_CAPACITY,
            crystals = Constants.SPACE_STATION.STARTING_CAPACITY,
            energy = Constants.SPACE_STATION.STARTING_CAPACITY,
        },
    }
    
    -- Create station core model
    local stationCore = self:_createStationCore(plotData.position, plotData.lookAtCenter)
    
    -- Store reference
    stationData.coreModel = stationCore
    self._playerStations[userId] = stationData
    
    print("[SpaceStationService] Created station for user", userId, "at plot", plotData.plotNumber)
end

---
-- Create the station core model
-- @param position Vector3 - Station position
-- @param orientation CFrame - Station orientation
-- @return Model - Station core model
-- @private
--
function SpaceStationService:_createStationCore(position, orientation)
    local coreSize = Constants.SPACE_STATION.STARTING_STATION_SIZE
    
    -- Create station core
    local core = Instance.new("Part")
    core.Name = "StationCore"
    core.Size = Vector3.new(coreSize, coreSize, coreSize)
    core.Position = position
    core.CFrame = orientation
    core.Anchored = true
    core.CanCollide = true
    core.Material = Enum.Material.Metal
    core.Color = Color3.fromRGB(120, 120, 140)
    core.Parent = self._stationsFolder
    
    -- Add core details
    local topPart = Instance.new("Part")
    topPart.Name = "CoreTop"
    topPart.Size = Vector3.new(coreSize * 0.8, coreSize * 0.2, coreSize * 0.8)
    topPart.Position = position + Vector3.new(0, coreSize * 0.6, 0)
    topPart.Anchored = true
    topPart.CanCollide = false
    topPart.Material = Enum.Material.Neon
    topPart.Color = Color3.fromRGB(0, 200, 255)
    topPart.Transparency = 0.3
    topPart.Parent = core
    
    -- Add antenna
    local antenna = Instance.new("Part")
    antenna.Name = "Antenna"
    antenna.Size = Vector3.new(1, coreSize * 1.5, 1)
    antenna.Position = position + Vector3.new(0, coreSize * 1.5, 0)
    antenna.Anchored = true
    antenna.CanCollide = false
    antenna.Material = Enum.Material.Metal
    antenna.Color = Color3.fromRGB(200, 200, 210)
    antenna.Parent = core
    
    -- Add antenna light
    local antennaLight = Instance.new("Part")
    antennaLight.Name = "AntennaLight"
    antennaLight.Shape = Enum.PartType.Ball
    antennaLight.Size = Vector3.new(2, 2, 2)
    antennaLight.Position = antenna.Position + Vector3.new(0, coreSize * 0.8, 0)
    antennaLight.Anchored = true
    antennaLight.CanCollide = false
    antennaLight.Material = Enum.Material.Neon
    antennaLight.Color = Color3.fromRGB(0, 255, 100)
    antennaLight.Parent = antenna
    
    -- Add point light
    local pointLight = Instance.new("PointLight")
    pointLight.Brightness = 3
    pointLight.Color = Color3.fromRGB(0, 255, 100)
    pointLight.Range = 50
    pointLight.Parent = antennaLight
    
    return core
end

---
-- Destroy player's station when they leave
-- @param userId number - Player's UserId
-- @private
--
function SpaceStationService:_destroyPlayerStation(userId)
    local stationData = self._playerStations[userId]
    if not stationData then return end
    
    -- Destroy station model
    if stationData.coreModel and stationData.coreModel.Parent then
        stationData.coreModel:Destroy()
    end
    
    -- Remove from tracking
    self._playerStations[userId] = nil
    
    print("[SpaceStationService] Destroyed station for user", userId)
end

---
-- Get player's station data
-- @param userId number - Player's UserId
-- @return table|nil - Station data or nil if not found
--
function SpaceStationService:GetStationData(userId)
    return self._playerStations[userId]
end

---
-- Upgrade station core (increase level, unlock module slots)
-- @param userId number - Player's UserId
-- @return table - Result {success: boolean, error: string|nil}
--
function SpaceStationService:UpgradeStation(userId)
    local stationData = self._playerStations[userId]
    if not stationData then
        return {success = false, error = "No station found"}
    end
    
    local currentLevel = stationData.level
    local upgradeCost = Constants.SPACE_STATION.UPGRADE_COSTS[currentLevel + 1]
    
    if not upgradeCost then
        return {success = false, error = "Max level reached"}
    end
    
    -- Check if player has enough resources
    local DataService = Knit.GetService("DataService")
    local playerData = DataService:GetPlayerData(userId)
    
    if not playerData then
        return {success = false, error = "Player data not found"}
    end
    
    -- Check planetEssence cost
    if playerData.planetEssence < upgradeCost.planetEssence then
        return {success = false, error = "Not enough Planet Essence"}
    end
    
    -- Deduct cost
    playerData.planetEssence = playerData.planetEssence - upgradeCost.planetEssence
    
    -- Upgrade station
    stationData.level = stationData.level + 1
    
    -- Increase capacity
    stationData.capacity.metal = stationData.capacity.metal * 1.5
    stationData.capacity.crystals = stationData.capacity.crystals * 1.5
    stationData.capacity.energy = stationData.capacity.energy * 1.5
    
    print("[SpaceStationService] Upgraded station for user", userId, "to level", stationData.level)
    
    return {
        success = true,
        newLevel = stationData.level,
        newCapacity = stationData.capacity,
    }
end

---
-- Add a module to station
-- @param userId number - Player's UserId
-- @param moduleType string - Type of module (STORAGE, DEFENSE, MINING, SHIELD, HANGAR)
-- @param slotNumber number - Which slot to place module in
-- @return table - Result {success: boolean, error: string|nil}
--
function SpaceStationService:AddModule(userId, moduleType, slotNumber)
    local stationData = self._playerStations[userId]
    if not stationData then
        return {success = false, error = "No station found"}
    end
    
    -- Check if slot is available
    local maxSlots = Constants.SPACE_STATION.MAX_STATION_MODULES
    if slotNumber > maxSlots then
        return {success = false, error = "Invalid slot number"}
    end
    
    -- Check if slot is occupied
    if stationData.modules[slotNumber] then
        return {success = false, error = "Slot already occupied"}
    end
    
    -- Get module data
    local moduleData = Constants.SPACE_STATION.MODULE_TYPES[moduleType]
    if not moduleData then
        return {success = false, error = "Invalid module type"}
    end
    
    -- Check cost
    local DataService = Knit.GetService("DataService")
    local playerData = DataService:GetPlayerData(userId)
    
    if playerData.planetEssence < moduleData.cost then
        return {success = false, error = "Not enough Planet Essence"}
    end
    
    -- Deduct cost
    playerData.planetEssence = playerData.planetEssence - moduleData.cost
    
    -- Create module
    local module = {
        type = moduleType,
        level = 1,
        slotNumber = slotNumber,
        active = true,
    }
    
    stationData.modules[slotNumber] = module
    
    -- Create module visual
    self:_createModuleVisual(stationData, module)
    
    print("[SpaceStationService] Added", moduleType, "module to slot", slotNumber, "for user", userId)
    
    return {success = true, module = module}
end

---
-- Create visual representation of a module
-- @param stationData table - Station data
-- @param module table - Module data
-- @private
--
function SpaceStationService:_createModuleVisual(stationData, module)
    local moduleType = Constants.SPACE_STATION.MODULE_TYPES[module.type]
    if not moduleType then return end
    
    -- Calculate position around station core
    local coreSize = Constants.SPACE_STATION.STARTING_STATION_SIZE
    local angle = (module.slotNumber - 1) * (2 * math.pi / Constants.SPACE_STATION.MAX_STATION_MODULES)
    local distance = coreSize * 1.5
    
    local offsetX = math.cos(angle) * distance
    local offsetZ = math.sin(angle) * distance
    local modulePos = stationData.position + Vector3.new(offsetX, 0, offsetZ)
    
    -- Create module part
    local modulePart = Instance.new("Part")
    modulePart.Name = module.type .. "_Module_" .. module.slotNumber
    modulePart.Size = Vector3.new(8, 8, 8)
    modulePart.Position = modulePos
    modulePart.Anchored = true
    modulePart.CanCollide = true
    modulePart.Material = Enum.Material.Metal
    modulePart.Color = moduleType.color
    modulePart.Parent = stationData.coreModel
    
    -- Add module glow
    local glow = Instance.new("Part")
    glow.Name = "ModuleGlow"
    glow.Size = Vector3.new(6, 6, 6)
    glow.Position = modulePos
    glow.Anchored = true
    glow.CanCollide = false
    glow.Material = Enum.Material.Neon
    glow.Color = moduleType.color
    glow.Transparency = 0.5
    glow.Parent = modulePart
end

---
-- Client: Get player's station data
-- @param player Player - The requesting player
-- @return table|nil - Station data
--
function SpaceStationService.Client:GetMyStation(player)
    return self.Server:GetStationData(player.UserId)
end

---
-- Client: Upgrade station
-- @param player Player - The requesting player
-- @return table - Result
--
function SpaceStationService.Client:UpgradeStation(player)
    return self.Server:UpgradeStation(player.UserId)
end

---
-- Client: Add module
-- @param player Player - The requesting player
-- @param moduleType string - Module type
-- @param slotNumber number - Slot position
-- @return table - Result
--
function SpaceStationService.Client:AddModule(player, moduleType, slotNumber)
    return self.Server:AddModule(player.UserId, moduleType, slotNumber)
end

return SpaceStationService
