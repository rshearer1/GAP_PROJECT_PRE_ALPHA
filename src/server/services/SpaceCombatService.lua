--[[
    SpaceCombatService.lua
    Server-side space combat system
    
    Handles:
    - Asteroid spawning and management
    - Asteroid destruction and loot drops
    - Combat validation
    - Resource collection
    
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

local SpaceCombatService = Knit.CreateService {
    Name = "SpaceCombatService",
    
    -- Active asteroids in the world
    _asteroids = {},
    
    -- Player combat stats
    _playerCombatStats = {},
    
    -- Janitor for cleanup
    _janitor = Janitor.new(),
    
    -- Asteroid folder in workspace
    _asteroidFolder = nil,
    
    -- Spawn center point
    _spawnCenter = Vector3.new(0, 50, 0), -- Above the baseplate
}

---
-- Initialize SpaceCombatService
--
function SpaceCombatService:KnitInit()
    print("[SpaceCombatService] Initializing...")
    
    -- Create asteroid folder in workspace
    self._asteroidFolder = Instance.new("Folder")
    self._asteroidFolder.Name = "Asteroids"
    self._asteroidFolder.Parent = Workspace
    
    print("[SpaceCombatService] Initialized!")
end

---
-- Start SpaceCombatService
--
function SpaceCombatService:KnitStart()
    print("[SpaceCombatService] Starting...")
    
    -- Start asteroid spawning loop
    local spawnThread = task.spawn(function()
        while true do
            task.wait(Constants.SPACE_COMBAT.ASTEROID_SPAWN_INTERVAL)
            self:_spawnAsteroidWave()
        end
    end)
    self._janitor:Add(function() task.cancel(spawnThread) end, true)
    
    print("[SpaceCombatService] Started! Asteroid spawning active.")
end

---
-- Spawn a wave of asteroids
-- @private
--
function SpaceCombatService:_spawnAsteroidWave()
    -- Don't spawn if we're at max capacity
    local currentCount = #self._asteroids
    if currentCount >= Constants.SPACE_COMBAT.ASTEROID_MAX_COUNT then
        return
    end
    
    -- Spawn 1-3 asteroids per wave
    local asteroidsToSpawn = math.random(1, 3)
    for i = 1, asteroidsToSpawn do
        if #self._asteroids < Constants.SPACE_COMBAT.ASTEROID_MAX_COUNT then
            self:_spawnAsteroid()
        end
    end
end

---
-- Spawn a single asteroid
-- @private
--
function SpaceCombatService:_spawnAsteroid()
    -- Random size
    local sizeTypes = {"SMALL", "MEDIUM", "LARGE"}
    local sizeType = sizeTypes[math.random(1, #sizeTypes)]
    local asteroidData = Constants.SPACE_COMBAT.ASTEROID_SIZES[sizeType]
    
    -- Random position in a ring around black hole (between stations)
    local blackHolePos = Constants.SPACE_ARENA.BLACK_HOLE_POSITION
    local minRadius = Constants.SPACE_ARENA.BLACK_HOLE_SIZE + 50 -- Outside black hole
    local maxRadius = Constants.SPACE_ARENA.ARENA_RADIUS - 100 -- Before stations
    
    local angle = math.random() * math.pi * 2
    local distance = math.random(minRadius, maxRadius)
    local position = blackHolePos + Vector3.new(
        math.cos(angle) * distance,
        math.random(-50, 50), -- Vertical variation
        math.sin(angle) * distance
    )
    
    -- Create asteroid model
    local asteroid = Instance.new("Part")
    asteroid.Name = "Asteroid_" .. sizeType
    asteroid.Size = Vector3.new(asteroidData.size, asteroidData.size, asteroidData.size)
    asteroid.Position = position
    asteroid.Shape = Enum.PartType.Ball
    asteroid.Material = Enum.Material.Rock
    asteroid.Color = Color3.fromRGB(100 + math.random(-20, 20), 80 + math.random(-20, 20), 70 + math.random(-20, 20))
    asteroid.Anchored = true
    asteroid.CanCollide = true
    asteroid.Parent = self._asteroidFolder
    
    -- Add health value
    local healthValue = Instance.new("IntValue")
    healthValue.Name = "Health"
    healthValue.Value = asteroidData.health
    healthValue.Parent = asteroid
    
    -- Add max health (for UI)
    local maxHealthValue = Instance.new("IntValue")
    maxHealthValue.Name = "MaxHealth"
    maxHealthValue.Value = asteroidData.health
    maxHealthValue.Parent = asteroid
    
    -- Add resource value
    local resourceValue = Instance.new("IntValue")
    resourceValue.Name = "ResourceValue"
    resourceValue.Value = asteroidData.resources
    resourceValue.Parent = asteroid
    
    -- Add to tracking
    table.insert(self._asteroids, asteroid)
    
    -- Cleanup when destroyed
    asteroid.Destroying:Connect(function()
        for i, a in ipairs(self._asteroids) do
            if a == asteroid then
                table.remove(self._asteroids, i)
                break
            end
        end
    end)
    
    print("[SpaceCombatService] Spawned", sizeType, "asteroid at", position)
end

---
-- Damage an asteroid
-- @param asteroidInstance Instance - The asteroid part
-- @param damage number - Amount of damage to deal
-- @param attackerPlayer Player - The player who dealt damage
-- @return boolean - True if asteroid was destroyed
--
function SpaceCombatService:DamageAsteroid(asteroidInstance, damage, attackerPlayer)
    if not asteroidInstance or not asteroidInstance:FindFirstChild("Health") then
        return false
    end
    
    local healthValue = asteroidInstance:FindFirstChild("Health")
    healthValue.Value = healthValue.Value - damage
    
    print("[SpaceCombatService]", attackerPlayer.Name, "damaged asteroid for", damage, "- Health:", healthValue.Value)
    
    -- Check if destroyed
    if healthValue.Value <= 0 then
        self:_destroyAsteroid(asteroidInstance, attackerPlayer)
        return true
    end
    
    return false
end

---
-- Destroy an asteroid and drop resources
-- @param asteroidInstance Instance - The asteroid to destroy
-- @param killerPlayer Player - The player who destroyed it
-- @private
--
function SpaceCombatService:_destroyAsteroid(asteroidInstance, killerPlayer)
    local resourceValue = asteroidInstance:FindFirstChild("ResourceValue")
    local resources = resourceValue and resourceValue.Value or 0
    
    print("[SpaceCombatService]", killerPlayer.Name, "destroyed asteroid! Resources:", resources)
    
    -- Award resources to player
    local DataService = Knit.GetService("DataService")
    local playerData = DataService:GetPlayerData(killerPlayer.UserId)
    
    if playerData then
        -- Add Planet Essence and Biome Energy
        playerData.spaceResources = playerData.spaceResources or {
            planetEssence = 0,
            biomeEnergy = 0,
        }
        
        playerData.spaceResources.planetEssence = playerData.spaceResources.planetEssence + resources
        playerData.spaceResources.biomeEnergy = playerData.spaceResources.biomeEnergy + (resources / 2)
        
        print("[SpaceCombatService] Awarded", resources, "Planet Essence and", resources/2, "Biome Energy to", killerPlayer.Name)
    end
    
    -- Visual effect (simple explosion)
    local explosion = Instance.new("Explosion")
    explosion.Position = asteroidInstance.Position
    explosion.BlastRadius = asteroidInstance.Size.X * 2
    explosion.BlastPressure = 0 -- Don't push nearby parts
    explosion.Parent = Workspace
    
    -- Destroy the asteroid
    asteroidInstance:Destroy()
end

---
-- Get all active asteroids
-- @return table - Array of asteroid instances
--
function SpaceCombatService:GetActiveAsteroids()
    return self._asteroids
end

---
-- Clear all asteroids (for testing/reset)
--
function SpaceCombatService:ClearAllAsteroids()
    for _, asteroid in ipairs(self._asteroids) do
        if asteroid and asteroid.Parent then
            asteroid:Destroy()
        end
    end
    self._asteroids = {}
    print("[SpaceCombatService] Cleared all asteroids")
end

return SpaceCombatService
