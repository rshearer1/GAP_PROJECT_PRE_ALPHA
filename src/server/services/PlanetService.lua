--[[
    PlanetService.lua
    Server-side planet management using Knit framework
    
    Responsibilities:
    - Create planets for new players
    - Store and update planet state
    - Calculate resource generation
    - Handle planet upgrades and evolution
    - Manage save/load (will integrate ProfileService later)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(ReplicatedStorage.Packages.Promise)

local Types = require(ReplicatedStorage.Shared.Types)
local Constants = require(ReplicatedStorage.Shared.Constants)

local PlanetService = Knit.CreateService({
    Name = "PlanetService",
    Client = {},
})

-- Store all active planets (userId -> PlanetState)
PlanetService._planets = {}

--[[ Service Lifecycle ]]--

function PlanetService:KnitInit()
    print("[PlanetService] Initializing...")
end

function PlanetService:KnitStart()
    print("[PlanetService] Starting...")
    
    -- Get PlanetVisualsService (optional, only if it exists)
    task.spawn(function()
        task.wait(1) -- Wait for other services to load
        local success, visualsService = pcall(function()
            return Knit.GetService("PlanetVisualsService")
        end)
        if success then
            self._visualsService = visualsService
            print("[PlanetService] Connected to PlanetVisualsService")
        end
        
        -- Get StarMapService (optional)
        local starSuccess, starMapService = pcall(function()
            return Knit.GetService("StarMapService")
        end)
        if starSuccess then
            self._starMapService = starMapService
            print("[PlanetService] Connected to StarMapService")
        end
    end)
    
    -- Handle player joining
    Players.PlayerAdded:Connect(function(player)
        self:_onPlayerJoined(player)
    end)
    
    -- Handle player leaving
    Players.PlayerRemoving:Connect(function(player)
        self:_onPlayerLeaving(player)
    end)
    
    -- Start resource update loop
    task.spawn(function()
        self:_resourceUpdateLoop()
    end)
    
    print("[PlanetService] Started successfully!")
end

--[[ Private Methods ]]--

function PlanetService:_onPlayerJoined(player: Player)
    print(`[PlanetService] Player {player.Name} joined`)
    
    -- Get active planet from SolarSystemService
    local SolarSystemService = Knit.GetService("SolarSystemService")
    local activePlanet = SolarSystemService:GetActivePlanet(player.UserId)
    
    if activePlanet then
        -- Use the active planet from the solar system
        self._planets[player.UserId] = activePlanet
        print(`[PlanetService] Loaded active planet for {player.Name} - {activePlanet.planetType}, Level {activePlanet.level}, Biome: {activePlanet.biome}`)
    else
        -- Fallback: load from legacy DataService (for backwards compatibility)
        local DataService = Knit.GetService("DataService")
        local playerData = DataService:LoadPlayerData(player)
        local planet = playerData.planet or self:_createPlanet(player.UserId)
        self._planets[player.UserId] = planet
        print(`[PlanetService] Planet loaded for {player.Name} - Level {planet.level}, Biome: {planet.biome}`)
    end
end

function PlanetService:_onPlayerLeaving(player: Player)
    print(`[PlanetService] Player {player.Name} leaving`)
    
    -- Planet is saved by SolarSystemService, no need to save here
    -- Just clean up from memory
    self._planets[player.UserId] = nil
end

function PlanetService:_createPlanet(userId: number): Types.PlanetState
    -- Create a new planet with default values
    local planet: Types.PlanetState = {
        userId = userId,
        level = Constants.PLANET.STARTING_LEVEL,
        experience = 0,
        biome = "Barren",
        size = Constants.PLANET.STARTING_SIZE,
        temperature = 20,
        atmosphere = 0,
        resources = {
            water = 0,
            minerals = 0,
            energy = 0,
            biomass = 0,
        },
        lastUpdated = os.time(),
    }
    
    return planet
end

function PlanetService:_resourceUpdateLoop()
    while true do
        task.wait(Constants.GAMEPLAY.UPDATE_TICK_RATE)
        
        local deltaTime = Constants.GAMEPLAY.UPDATE_TICK_RATE
        
        -- Update all active planets
        for userId, planet in pairs(self._planets) do
            self:_updatePlanetResources(planet, deltaTime)
        end
    end
end

function PlanetService:_updatePlanetResources(planet: Types.PlanetState, deltaTime: number)
    -- Calculate base rates
    local waterRate = Constants.RESOURCES.BASE_WATER_RATE
    local mineralRate = Constants.RESOURCES.BASE_MINERAL_RATE
    local energyRate = Constants.RESOURCES.BASE_ENERGY_RATE
    local biomassRate = Constants.RESOURCES.BASE_BIOMASS_RATE
    
    -- Apply biome bonuses
    local biomeConfig = Constants.BIOMES[string.upper(planet.biome)]
    if biomeConfig then
        waterRate = waterRate * (1 + biomeConfig.waterBonus)
        mineralRate = mineralRate * (1 + biomeConfig.mineralBonus)
        energyRate = energyRate * (1 + biomeConfig.energyBonus)
        biomassRate = biomassRate * (1 + biomeConfig.biomassBonus)
    end
    
    -- Apply upgrade multipliers
    local UpgradeService = Knit.GetService("UpgradeService")
    if UpgradeService then
        local multipliers = UpgradeService:GetUpgradeMultipliers(planet.userId)
        waterRate = waterRate * (1 + multipliers.water_rate)
        mineralRate = mineralRate * (1 + multipliers.minerals_rate)
        energyRate = energyRate * (1 + multipliers.energy_rate)
        biomassRate = biomassRate * (1 + multipliers.biomass_rate)
        
        -- Calculate resource caps
        local waterCap = Constants.RESOURCES.DEFAULT_CAP + multipliers.water_cap
        local mineralCap = Constants.RESOURCES.DEFAULT_CAP + multipliers.minerals_cap
        local energyCap = Constants.RESOURCES.DEFAULT_CAP + multipliers.energy_cap
        local biomassCap = Constants.RESOURCES.DEFAULT_CAP + multipliers.biomass_cap
        
        -- Update resources with caps
        planet.resources.water = math.min(planet.resources.water + (waterRate * deltaTime), waterCap)
        planet.resources.minerals = math.min(planet.resources.minerals + (mineralRate * deltaTime), mineralCap)
        planet.resources.energy = math.min(planet.resources.energy + (energyRate * deltaTime), energyCap)
        planet.resources.biomass = math.min(planet.resources.biomass + (biomassRate * deltaTime), biomassCap)
    else
        -- Fallback if UpgradeService not available (no caps)
        planet.resources.water = planet.resources.water + (waterRate * deltaTime)
        planet.resources.minerals = planet.resources.minerals + (mineralRate * deltaTime)
        planet.resources.energy = planet.resources.energy + (energyRate * deltaTime)
        planet.resources.biomass = planet.resources.biomass + (biomassRate * deltaTime)
    end
    
    planet.lastUpdated = os.time()
end

function PlanetService:_calculateBiome(level: number): Types.BiomeType
    -- Determine biome based on level
    if level >= Constants.BIOMES.FOREST.minLevel then
        return "Forest"
    elseif level >= Constants.BIOMES.OCEANIC.minLevel then
        return "Oceanic"
    elseif level >= Constants.BIOMES.ROCKY.minLevel then
        return "Rocky"
    else
        return "Barren"
    end
end

--[[ Public Server Methods ]]--

function PlanetService:GetPlanetData(userId: number): Types.PlanetState?
    return self._planets[userId]
end

function PlanetService:AddExperience(userId: number, amount: number): boolean
    local planet = self._planets[userId]
    if not planet then return false end
    
    planet.experience = planet.experience + amount
    
    -- Check for level up
    local xpNeeded = Constants.PLANET.XP_PER_LEVEL * (Constants.PLANET.XP_SCALE ^ (planet.level - 1))
    
    if planet.experience >= xpNeeded then
        planet.experience = planet.experience - xpNeeded
        planet.level = planet.level + 1
        
        -- Update biome
        local oldBiome = planet.biome
        planet.biome = self:_calculateBiome(planet.level)
        
        -- Update planet size based on level
        planet.size = Constants.PLANET.STARTING_SIZE + (planet.level * 2)
        
        -- Update visuals if biome changed
        if planet.biome ~= oldBiome and self._visualsService then
            self._visualsService:UpdatePlanetVisual(userId, planet)
            
            -- Award star for biome completion (when progressing to NEXT biome)
            if self._starMapService then
                local player = game.Players:GetPlayerByUserId(userId)
                if player then
                    -- Award star for completing the OLD biome
                    self._starMapService:MarkBiomeCompleted(player, planet.id, oldBiome)
                end
            end
        end
        
        print(`[PlanetService] Planet {userId} leveled up to {planet.level}! Biome: {planet.biome}`)
        return true
    end
    
    return false
end

-- Get planet data (for other services)
function PlanetService:GetPlanet(userId: number): Types.PlanetState?
    return self._planets[userId]
end

-- Set planet data (used by SolarSystemService when switching planets)
function PlanetService:SetPlanet(userId: number, planet: Types.PlanetState)
    self._planets[userId] = planet
    print("[PlanetService] Set planet for user", userId, "- Type:", planet.planetType or "Legacy")
end

--[[ Client-Callable Methods ]]--

function PlanetService.Client:GetPlanetState(player: Player)
    return self.Server:GetPlanetData(player.UserId)
end

function PlanetService.Client:CollectResources(player: Player)
    local planet = self.Server:GetPlanetData(player.UserId)
    
    if planet then
        -- Calculate total resources collected
        local totalCollected = planet.resources.water + planet.resources.minerals + 
                               planet.resources.energy + planet.resources.biomass
        
        -- Award XP based on resources collected (1 XP per 10 resources)
        local xpGained = math.floor(totalCollected / 10)
        
        if xpGained > 0 then
            self.Server:AddExperience(player.UserId, xpGained)
            print(string.format("[PlanetService] Player %s gained %d XP from collecting resources", player.Name, xpGained))
        end
        
        -- Return current resources (in real game, this would reset them)
        return {
            water = planet.resources.water,
            minerals = planet.resources.minerals,
            energy = planet.resources.energy,
            biomass = planet.resources.biomass,
            xpGained = xpGained,
        }
    end
    
    return nil
end

return PlanetService
