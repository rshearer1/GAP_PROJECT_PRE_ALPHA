--[[
    PlanetProximityService.lua
    Server-side proximity detection and landing mechanics
    
    Handles:
    - Detecting when players are near their planets
    - Validating landing requests
    - Managing landing/takeoff transitions
    - Providing landing positions
    
    GAP Compliance:
    - Uses Janitor for cleanup
    - References Constants for all values
    - JSDoc comments on all methods
    - Server-authoritative validation
]]

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Janitor = require(game:GetService("ReplicatedStorage").Packages.Janitor)
local Promise = require(game:GetService("ReplicatedStorage").Packages.Promise)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Constants = require(ReplicatedStorage.Shared.Constants)

local PlanetProximityService = Knit.CreateService {
    Name = "PlanetProximityService",
    Client = {
        -- Get planets within proximity range
        GetNearbyPlanets = Knit.CreateProperty({}),
        
        -- Request to land on a planet
        RequestLanding = Knit.CreateProperty(nil),
        
        -- Request to takeoff from planet
        RequestTakeoff = Knit.CreateProperty(nil),
    },
    
    -- Internal state
    _planetService = nil,
    _solarSystemService = nil,
    _spaceArenaService = nil,
    _playerLandedState = {}, -- [userId] = planetId or nil
    _janitor = nil,
}

---
-- Initialize PlanetProximityService
--
function PlanetProximityService:KnitInit()
    print("[PlanetProximityService] Initializing...")
    self._janitor = Janitor.new()
    self._playerLandedState = {}
end

---
-- Start PlanetProximityService
--
function PlanetProximityService:KnitStart()
    print("[PlanetProximityService] Starting...")
    
    -- Get required services
    self._planetService = Knit.GetService("PlanetService")
    self._solarSystemService = Knit.GetService("SolarSystemService")
    self._spaceArenaService = Knit.GetService("SpaceArenaService")
    
    -- Set up client methods
    self:_setupClientMethods()
    
    print("[PlanetProximityService] Started successfully!")
end

---
-- Set up client-callable methods
-- @private
--
function PlanetProximityService:_setupClientMethods()
    -- Get nearby planets (called frequently by client)
    self.Client.GetNearbyPlanets = function(self, player)
        return self.Server:GetNearbyPlanets(player)
    end
    
    -- Request landing on a planet
    self.Client.RequestLanding = function(self, player, planetId)
        return self.Server:RequestLanding(player, planetId)
    end
    
    -- Request takeoff from planet
    self.Client.RequestTakeoff = function(self, player)
        return self.Server:RequestTakeoff(player)
    end
end

---
-- Get planets within proximity range of the player's ship
-- @param player Player - The player to check
-- @return Promise<{ProximityData}> - Array of nearby planet data
--
function PlanetProximityService:GetNearbyPlanets(player)
    return Promise.new(function(resolve, reject)
        if not player or not player.Character then
            reject("Invalid player or no character")
            return
        end
        
        local userId = player.UserId
        local character = player.Character
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        
        if not rootPart then
            reject("No HumanoidRootPart found")
            return
        end
        
        -- Get player's planets
        local solarSystemData = self._solarSystemService:GetSolarSystemData(userId)
        if not solarSystemData then
            resolve({}) -- No planets yet
            return
        end
        
        local playerPosition = rootPart.Position
        local nearbyPlanets = {}
        local planetsFolder = Workspace:FindFirstChild("Planets")
        
        if not planetsFolder then
            resolve({})
            return
        end
        
        -- Check each planet for proximity
        for _, planetData in ipairs(solarSystemData.planets) do
            local planetModel = planetsFolder:FindFirstChild(`{player.Name}_Planet_{planetData.planetId}`)
            
            if planetModel and planetModel.PrimaryPart then
                local planetPosition = planetModel.PrimaryPart.Position
                local distance = (playerPosition - planetPosition).Magnitude
                
                if distance <= Constants.PLANET_EXPLORATION.PROXIMITY_RADIUS then
                    table.insert(nearbyPlanets, {
                        planetId = planetData.planetId,
                        planetName = planetData.name or "Planet",
                        distance = distance,
                        canLand = distance <= Constants.PLANET_EXPLORATION.MAX_LANDING_DISTANCE,
                        position = planetPosition,
                        biome = planetData.biome or "Barren",
                    })
                end
            end
        end
        
        -- Sort by distance (closest first)
        table.sort(nearbyPlanets, function(a, b)
            return a.distance < b.distance
        end)
        
        resolve(nearbyPlanets)
    end)
end

---
-- Handle landing request from player
-- @param player Player - The player requesting landing
-- @param planetId string - The planet to land on
-- @return Promise<LandingData> - Landing position and settings
--
function PlanetProximityService:RequestLanding(player, planetId)
    return Promise.new(function(resolve, reject)
        if not player or not player.Character then
            reject("Invalid player or no character")
            return
        end
        
        local userId = player.UserId
        
        -- Check if player already landed
        if self._playerLandedState[userId] then
            reject("Already landed on a planet")
            return
        end
        
        -- Verify planet ownership
        local solarSystemData = self._solarSystemService:GetSolarSystemData(userId)
        if not solarSystemData then
            reject("No solar system found")
            return
        end
        
        local ownsPlanet = false
        local planetData = nil
        for _, planet in ipairs(solarSystemData.planets) do
            if planet.planetId == planetId then
                ownsPlanet = true
                planetData = planet
                break
            end
        end
        
        if not ownsPlanet then
            reject("You don't own this planet")
            return
        end
        
        -- Get planet model
        local planetsFolder = Workspace:FindFirstChild("Planets")
        if not planetsFolder then
            reject("Planets folder not found")
            return
        end
        
        local planetModel = planetsFolder:FindFirstChild(`{player.Name}_Planet_{planetId}`)
        if not planetModel or not planetModel.PrimaryPart then
            reject("Planet model not found")
            return
        end
        
        -- Check distance
        local character = player.Character
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then
            reject("No HumanoidRootPart found")
            return
        end
        
        local distance = (rootPart.Position - planetModel.PrimaryPart.Position).Magnitude
        if distance > Constants.PLANET_EXPLORATION.MAX_LANDING_DISTANCE then
            reject("Too far from planet to land")
            return
        end
        
        -- Calculate landing position (on top of planet sphere)
        local planetPosition = planetModel.PrimaryPart.Position
        local planetSize = planetModel.PrimaryPart.Size.Y
        local landingPosition = planetPosition + Vector3.new(0, planetSize / 2 + Constants.PLANET_EXPLORATION.LANDING_HEIGHT, 0)
        
        -- Mark player as landed
        self._playerLandedState[userId] = planetId
        
        print(`[PlanetProximityService] Player {player.Name} landing on planet {planetId}`)
        
        resolve({
            success = true,
            planetId = planetId,
            planetName = planetData.name or "Planet",
            spawnCFrame = CFrame.new(landingPosition),
            surfaceGravity = Constants.PLANET_EXPLORATION.SURFACE_GRAVITY,
            biome = planetData.biome or "Barren",
        })
    end)
end

---
-- Handle takeoff request from player
-- @param player Player - The player requesting takeoff
-- @return Promise<boolean> - Success status
--
function PlanetProximityService:RequestTakeoff(player)
    return Promise.new(function(resolve, reject)
        if not player then
            reject("Invalid player")
            return
        end
        
        local userId = player.UserId
        
        -- Check if player is actually landed
        if not self._playerLandedState[userId] then
            reject("Not currently landed on a planet")
            return
        end
        
        -- Clear landed state
        local planetId = self._playerLandedState[userId]
        self._playerLandedState[userId] = nil
        
        print(`[PlanetProximityService] Player {player.Name} taking off from planet {planetId}`)
        
        resolve(true)
    end)
end

---
-- Check if player is currently landed
-- @param userId number - The user ID to check
-- @return boolean - True if landed on a planet
--
function PlanetProximityService:IsPlayerLanded(userId)
    return self._playerLandedState[userId] ~= nil
end

---
-- Get the planet a player is currently on
-- @param userId number - The user ID to check
-- @return string|nil - Planet ID or nil if not landed
--
function PlanetProximityService:GetLandedPlanet(userId)
    return self._playerLandedState[userId]
end

return PlanetProximityService
