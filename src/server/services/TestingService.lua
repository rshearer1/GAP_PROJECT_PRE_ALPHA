--[[
    ⚠️ TESTING SERVICE - DELETE BEFORE PRODUCTION ⚠️
    
    TestingService.lua
    Server-side testing utilities
    
    Provides:
    - Quick level-up commands
    - Instant resource generation
    - Force rebirth eligibility
    - Planet unlocking shortcuts
    
    🔴 REMOVE THIS FILE BEFORE FINAL RELEASE 🔴
]]

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local TestingService = Knit.CreateService {
    Name = "TestingService",
    Client = {
        AddResources = Knit.CreateProperty(nil),
        AddLevel = Knit.CreateProperty(nil),
        UnlockAllPlanets = Knit.CreateProperty(nil),
        BuyAllUpgrades = Knit.CreateProperty(nil),
        ForceRebirthEligibility = Knit.CreateProperty(nil),
        AddStars = Knit.CreateProperty(nil),
    },
}

function TestingService:KnitInit()
    print("[TestingService] ⚠️ TESTING MODE ACTIVE ⚠️")
end

function TestingService:KnitStart()
    print("[TestingService] Started - Debug commands available")
end

--[[ Testing Commands ]]--

-- Add resources to player
function TestingService:AddResources(player: Player, amount: number)
    local PlanetService = Knit.GetService("PlanetService")
    local planet = PlanetService:GetPlanet(player.UserId)
    
    if planet then
        planet.resources.water = planet.resources.water + amount
        planet.resources.minerals = planet.resources.minerals + amount
        planet.resources.energy = planet.resources.energy + amount
        planet.resources.biomass = planet.resources.biomass + amount
        
        print("[TestingService] Added " .. amount .. " of each resource to " .. player.Name)
        return true
    end
    
    return false
end

-- Add levels to player
function TestingService:AddLevel(player: Player, levels: number)
    local PlanetService = Knit.GetService("PlanetService")
    local planet = PlanetService:GetPlanet(player.UserId)
    
    if planet then
        planet.level = planet.level + levels
        planet.experience = 0 -- Reset XP
        
        -- Update biome
        if planet.level >= 12 then
            planet.biome = "Forest"
        elseif planet.level >= 7 then
            planet.biome = "Oceanic"
        elseif planet.level >= 3 then
            planet.biome = "Rocky"
        end
        
        print("[TestingService] Added " .. levels .. " levels to " .. player.Name .. " (now Level " .. planet.level .. ", " .. planet.biome .. ")")
        return true
    end
    
    return false
end

-- Unlock all planets in solar system
function TestingService:UnlockAllPlanets(player: Player)
    local SolarSystemService = Knit.GetService("SolarSystemService")
    local solarSystem = SolarSystemService:GetSolarSystem(player.UserId)
    
    if solarSystem then
        for _, planet in ipairs(solarSystem.planets) do
            planet.isUnlocked = true
        end
        solarSystem.planetsUnlocked = #solarSystem.planets
        
        print("[TestingService] Unlocked all " .. #solarSystem.planets .. " planets for " .. player.Name)
        return true
    end
    
    return false
end

-- Buy all upgrades
function TestingService:BuyAllUpgrades(player: Player)
    local UpgradeService = Knit.GetService("UpgradeService")
    local userId = player.UserId
    
    if not UpgradeService._playerUpgrades[userId] then
        UpgradeService._playerUpgrades[userId] = {}
    end
    
    local count = 0
    for upgradeId, upgrade in pairs(UpgradeService._upgradeDefinitions) do
        UpgradeService._playerUpgrades[userId][upgradeId] = upgrade.maxLevel
        count = count + 1
    end
    
    print("[TestingService] Maxed out all " .. count .. " upgrades for " .. player.Name)
    return true
end

-- Force rebirth eligibility (set to 95% completion)
function TestingService:ForceRebirthEligibility(player: Player)
    -- Add resources
    self:AddResources(player, 10000)
    
    -- Add levels
    self:AddLevel(player, 15)
    
    -- Unlock most planets (leave 1-2 locked for 90%+)
    local SolarSystemService = Knit.GetService("SolarSystemService")
    local solarSystem = SolarSystemService:GetSolarSystem(player.UserId)
    
    if solarSystem and #solarSystem.planets > 2 then
        for i = 1, #solarSystem.planets - 1 do
            solarSystem.planets[i].isUnlocked = true
        end
        solarSystem.planetsUnlocked = #solarSystem.planets - 1
    end
    
    -- Buy most upgrades (leave 1 not maxed for 90%+)
    local UpgradeService = Knit.GetService("UpgradeService")
    local userId = player.UserId
    
    if not UpgradeService._playerUpgrades[userId] then
        UpgradeService._playerUpgrades[userId] = {}
    end
    
    local count = 0
    for upgradeId, upgrade in pairs(UpgradeService._upgradeDefinitions) do
        if count == 0 then
            -- Leave first upgrade at low level
            UpgradeService._playerUpgrades[userId][upgradeId] = 1
        else
            UpgradeService._playerUpgrades[userId][upgradeId] = upgrade.maxLevel
        end
        count = count + 1
    end
    
    print("[TestingService] ⭐ Set " .. player.Name .. " to ~95% completion (ready for rebirth)")
    return true
end

-- Add stars (for Star Map system)
function TestingService:AddStars(player: Player, amount: number)
    local StarMapService = Knit.GetService("StarMapService")
    
    if StarMapService then
        local success = StarMapService:AwardStars(player, amount, "Debug Command")
        
        if success then
            print("[TestingService] Added " .. amount .. " stars to " .. player.Name)
            return true
        end
    end
    
    return false
end

--[[ Client Methods ]]--

function TestingService.Client:AddResources(player: Player, amount: number)
    return self.Server:AddResources(player, amount)
end

function TestingService.Client:AddLevel(player: Player, levels: number)
    return self.Server:AddLevel(player, levels)
end

function TestingService.Client:UnlockAllPlanets(player: Player)
    return self.Server:UnlockAllPlanets(player)
end

function TestingService.Client:BuyAllUpgrades(player: Player)
    return self.Server:BuyAllUpgrades(player)
end

function TestingService.Client:ForceRebirthEligibility(player: Player)
    return self.Server:ForceRebirthEligibility(player)
end

function TestingService.Client:AddStars(player: Player, amount: number)
    return self.Server:AddStars(player, amount)
end

return TestingService
