--[[
    SolarSystemService.lua
    Server-side solar system management
    
    Handles:
    - Generating random solar systems (3-8 planets)
    - Managing planet unlocks
    - Switching between planets
    - Planet-specific bonuses
]]

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Shared.Constants)

local SolarSystemService = Knit.CreateService {
    Name = "SolarSystemService",
    Client = {
        -- Client-facing methods
        GetSolarSystem = Knit.CreateProperty({}),
        SwitchPlanet = Knit.CreateProperty(nil),
        UnlockPlanet = Knit.CreateProperty(nil),
    },
    
    -- Solar systems for each player [userId] = solarSystem
    _solarSystems = {},
    
    -- Planet types with unique bonuses
    _planetTypes = {
        {
            name = "Mineral World",
            description = "Rich in minerals and ores",
            bonuses = { minerals = 2.0, water = 0.5, energy = 1.0, biomass = 0.8 },
            color = Color3.fromRGB(139, 90, 43), -- Brown
        },
        {
            name = "Ocean World",
            description = "Vast oceans cover the surface",
            bonuses = { water = 2.5, minerals = 0.6, energy = 1.0, biomass = 1.5 },
            color = Color3.fromRGB(52, 152, 219), -- Blue
        },
        {
            name = "Energy Core",
            description = "Radiates intense energy",
            bonuses = { energy = 3.0, water = 0.8, minerals = 1.0, biomass = 0.5 },
            color = Color3.fromRGB(241, 196, 15), -- Yellow
        },
        {
            name = "Volcanic World",
            description = "Active volcanoes and geothermal energy",
            bonuses = { energy = 2.0, minerals = 1.8, water = 0.3, biomass = 0.6 },
            color = Color3.fromRGB(192, 57, 43), -- Red
        },
        {
            name = "Forest World",
            description = "Lush forests and abundant life",
            bonuses = { biomass = 2.5, water = 1.5, energy = 1.0, minerals = 0.7 },
            color = Color3.fromRGB(39, 174, 96), -- Green
        },
        {
            name = "Ice World",
            description = "Frozen surface with water reserves",
            bonuses = { water = 2.0, minerals = 1.2, energy = 0.6, biomass = 0.4 },
            color = Color3.fromRGB(174, 214, 241), -- Light Blue
        },
        {
            name = "Desert World",
            description = "Harsh desert with rare resources",
            bonuses = { minerals = 1.5, energy = 1.8, water = 0.4, biomass = 0.5 },
            color = Color3.fromRGB(230, 176, 77), -- Sand
        },
        {
            name = "Paradise World",
            description = "Perfectly balanced ecosystem",
            bonuses = { water = 1.5, minerals = 1.5, energy = 1.5, biomass = 1.5 },
            color = Color3.fromRGB(155, 89, 182), -- Purple
        },
    }
}

function SolarSystemService:KnitInit()
    print("[SolarSystemService] Initializing...")
    
    -- Seed random number generator for consistent results
    math.randomseed(os.time())
end

function SolarSystemService:KnitStart()
    print("[SolarSystemService] Starting...")
    
    -- Handle player joining
    game.Players.PlayerAdded:Connect(function(player)
        self:_onPlayerJoined(player)
    end)
    
    -- Handle player leaving
    game.Players.PlayerRemoving:Connect(function(player)
        self:_onPlayerLeaving(player)
    end)
    
    print("[SolarSystemService] Started successfully!")
end

--[[ Private Methods ]]--

function SolarSystemService:_onPlayerJoined(player: Player)
    local DataService = Knit.GetService("DataService")
    local playerData = DataService:LoadPlayerData(player)
    
    -- Check if player has a solar system
    if playerData.solarSystem then
        self._solarSystems[player.UserId] = playerData.solarSystem
        print("[SolarSystemService] Loaded solar system for " .. player.Name .. " with " .. #playerData.solarSystem.planets .. " planets")
    else
        -- Generate new solar system
        local solarSystem = self:_generateSolarSystem(player.UserId)
        self._solarSystems[player.UserId] = solarSystem
        
        -- Save to DataService
        DataService:UpdatePlayerData(player.UserId, {
            solarSystem = solarSystem
        })
        
        print("[SolarSystemService] Generated new solar system for " .. player.Name .. " with " .. solarSystem.planetCount .. " planets")
    end
end

function SolarSystemService:_onPlayerLeaving(player: Player)
    local userId = player.UserId
    local solarSystem = self._solarSystems[userId]
    
    if solarSystem then
        -- Save to DataService
        local DataService = Knit.GetService("DataService")
        DataService:UpdatePlayerData(userId, {
            solarSystem = solarSystem
        })
        DataService:SavePlayerData(player)
        
        print("[SolarSystemService] Saved solar system for " .. player.Name)
    end
    
    -- Clean up from memory
    self._solarSystems[userId] = nil
end

-- Generate a random solar system with 3-8 planets
function SolarSystemService:_generateSolarSystem(userId: number)
    local planetCount = math.random(3, 8)
    local seed = os.time() + userId
    
    local solarSystem = {
        id = "solarsystem_" .. userId .. "_" .. os.time(),
        planetCount = planetCount,
        planets = {},
        activePlanetIndex = 1, -- Start on first planet
        planetsUnlocked = 1, -- First planet is free
        seed = seed,
    }
    
    -- Generate planets
    for i = 1, planetCount do
        local planet = self:_generatePlanet(userId, i, solarSystem.id)
        
        -- First planet is always unlocked
        if i == 1 then
            planet.isUnlocked = true
            planet.unlockCost = { water = 0, minerals = 0, energy = 0, biomass = 0 }
        else
            planet.isUnlocked = false
            -- Unlock cost scales with planet index
            local costMultiplier = i * 100
            planet.unlockCost = {
                water = costMultiplier * 2,
                minerals = costMultiplier * 3,
                energy = costMultiplier * 2,
                biomass = costMultiplier * 1.5,
            }
        end
        
        table.insert(solarSystem.planets, planet)
    end
    
    return solarSystem
end

-- Generate a single planet with random type and bonuses
function SolarSystemService:_generatePlanet(userId: number, planetIndex: number, systemId: string)
    -- Pick random planet type
    local planetTypeIndex = math.random(1, #self._planetTypes)
    local planetType = self._planetTypes[planetTypeIndex]
    
    local planet = {
        userId = userId,
        planetId = systemId .. "_planet_" .. planetIndex,
        planetIndex = planetIndex,
        planetType = planetType.name,
        planetDescription = planetType.description,
        level = 1,
        experience = 0,
        biome = "Barren", -- All planets start Barren
        size = Constants.PLANET.SIZE,
        temperature = math.random(200, 400),
        atmosphere = math.random(0, 100),
        resources = {
            water = 0,
            minerals = 0,
            energy = 0,
            biomass = 0,
        },
        lastUpdated = os.time(),
        bonuses = planetType.bonuses,
        baseColor = planetType.color,
        isUnlocked = false,
        unlockCost = { water = 0, minerals = 0, energy = 0, biomass = 0 },
    }
    
    return planet
end

--[[ Public Methods ]]--

-- Get player's solar system
function SolarSystemService:GetSolarSystem(userId: number)
    return self._solarSystems[userId]
end

-- Get active planet for player
function SolarSystemService:GetActivePlanet(userId: number)
    local solarSystem = self._solarSystems[userId]
    if not solarSystem then
        warn("[SolarSystemService] No solar system for user", userId)
        return nil
    end
    
    local activeIndex = solarSystem.activePlanetIndex or 1
    return solarSystem.planets[activeIndex]
end

-- Switch to a different planet
function SolarSystemService:SwitchPlanet(player: Player, planetIndex: number)
    local userId = player.UserId
    local solarSystem = self._solarSystems[userId]
    
    if not solarSystem then
        warn("[SolarSystemService] No solar system for user", userId)
        return false
    end
    
    -- Validate planet index
    if planetIndex < 1 or planetIndex > #solarSystem.planets then
        warn("[SolarSystemService] Invalid planet index", planetIndex)
        return false
    end
    
    -- Check if planet is unlocked
    local targetPlanet = solarSystem.planets[planetIndex]
    if not targetPlanet.isUnlocked then
        warn("[SolarSystemService] Planet " .. planetIndex .. " is locked for " .. player.Name)
        return false
    end
    
    -- Save current planet resources before switching
    local PlanetService = Knit.GetService("PlanetService")
    local currentPlanet = self:GetActivePlanet(userId)
    if currentPlanet then
        local serverPlanet = PlanetService:GetPlanet(userId)
        if serverPlanet then
            currentPlanet.resources = serverPlanet.resources
            currentPlanet.level = serverPlanet.level
            currentPlanet.experience = serverPlanet.experience
            currentPlanet.biome = serverPlanet.biome
        end
    end
    
    -- Switch planet
    solarSystem.activePlanetIndex = planetIndex
    
    -- Load new planet into PlanetService
    PlanetService:SetPlanet(userId, targetPlanet)
    
    print("[SolarSystemService] Player " .. player.Name .. " switched to planet " .. planetIndex .. " (" .. targetPlanet.planetType .. ")")
    
    return true
end

-- Unlock a planet
function SolarSystemService:UnlockPlanet(player: Player, planetIndex: number)
    local userId = player.UserId
    local solarSystem = self._solarSystems[userId]
    
    if not solarSystem then
        warn("[SolarSystemService] No solar system for user", userId)
        return false
    end
    
    -- Validate planet index
    if planetIndex < 1 or planetIndex > #solarSystem.planets then
        warn("[SolarSystemService] Invalid planet index", planetIndex)
        return false
    end
    
    local planet = solarSystem.planets[planetIndex]
    
    -- Check if already unlocked
    if planet.isUnlocked then
        warn("[SolarSystemService] Planet " .. planetIndex .. " already unlocked")
        return false
    end
    
    -- Check if player has resources
    local PlanetService = Knit.GetService("PlanetService")
    local currentPlanet = PlanetService:GetPlanet(userId)
    
    if not currentPlanet then
        warn("[SolarSystemService] No active planet for user", userId)
        return false
    end
    
    -- Validate resources
    if currentPlanet.resources.water < planet.unlockCost.water or
       currentPlanet.resources.minerals < planet.unlockCost.minerals or
       currentPlanet.resources.energy < planet.unlockCost.energy or
       currentPlanet.resources.biomass < planet.unlockCost.biomass then
        warn("[SolarSystemService] Insufficient resources to unlock planet " .. planetIndex)
        return false
    end
    
    -- Deduct resources
    currentPlanet.resources.water = currentPlanet.resources.water - planet.unlockCost.water
    currentPlanet.resources.minerals = currentPlanet.resources.minerals - planet.unlockCost.minerals
    currentPlanet.resources.energy = currentPlanet.resources.energy - planet.unlockCost.energy
    currentPlanet.resources.biomass = currentPlanet.resources.biomass - planet.unlockCost.biomass
    
    -- Unlock planet
    planet.isUnlocked = true
    solarSystem.planetsUnlocked = solarSystem.planetsUnlocked + 1
    
    print("[SolarSystemService] Player " .. player.Name .. " unlocked planet " .. planetIndex .. " (" .. planet.planetType .. ")")
    
    return true
end

-- Client methods
function SolarSystemService.Client:GetSolarSystem(player: Player)
    return self.Server:GetSolarSystem(player.UserId)
end

function SolarSystemService.Client:SwitchPlanet(player: Player, planetIndex: number)
    return self.Server:SwitchPlanet(player, planetIndex)
end

function SolarSystemService.Client:UnlockPlanet(player: Player, planetIndex: number)
    return self.Server:UnlockPlanet(player, planetIndex)
end

return SolarSystemService
