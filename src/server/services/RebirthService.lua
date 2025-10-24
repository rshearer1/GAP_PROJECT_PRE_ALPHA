--[[
    RebirthService.lua
    Server-side rebirth/prestige system
    
    Handles:
    - Calculating 90% completion requirement
    - Executing rebirth (reset progress, keep stars)
    - Awarding rebirth bonuses (+10% permanent multiplier)
    - Tracking rebirth count and rank
]]

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RebirthService = Knit.CreateService {
    Name = "RebirthService",
    Client = {
        GetRebirthInfo = Knit.CreateProperty(nil),
        ExecuteRebirth = Knit.CreateProperty(nil),
    },
    
    -- Rebirth rank thresholds
    _rankThresholds = {
        { name = "Bronze", minRebirths = 0, color = Color3.fromRGB(205, 127, 50) },
        { name = "Silver", minRebirths = 5, color = Color3.fromRGB(192, 192, 192) },
        { name = "Gold", minRebirths = 10, color = Color3.fromRGB(255, 215, 0) },
        { name = "Platinum", minRebirths = 20, color = Color3.fromRGB(229, 228, 226) },
        { name = "Diamond", minRebirths = 50, color = Color3.fromRGB(185, 242, 255) },
    },
}

function RebirthService:KnitInit()
    print("[RebirthService] Initializing...")
end

function RebirthService:KnitStart()
    print("[RebirthService] Starting...")
    print("[RebirthService] Started successfully!")
end

--[[ Helper Methods ]]--

-- Get rebirth rank based on count
function RebirthService:_getRank(rebirthCount: number)
    local rank = self._rankThresholds[1] -- Default to Bronze
    
    for _, threshold in ipairs(self._rankThresholds) do
        if rebirthCount >= threshold.minRebirths then
            rank = threshold
        end
    end
    
    return rank
end

-- Calculate total items available to unlock
function RebirthService:_calculateTotalItems(userId: number)
    local UpgradeService = Knit.GetService("UpgradeService")
    local SolarSystemService = Knit.GetService("SolarSystemService")
    
    -- Count total upgrades (7 currently, but get dynamically)
    local totalUpgrades = 0
    for _ in pairs(UpgradeService._upgradeDefinitions) do
        totalUpgrades = totalUpgrades + 1
    end
    
    -- Count total planets in solar system
    local solarSystem = SolarSystemService:GetSolarSystem(userId)
    local totalPlanets = solarSystem and solarSystem.planetCount or 1
    
    -- Count total biomes per planet (4 biomes × number of planets)
    local totalBiomes = totalPlanets * 4
    
    -- Total items = upgrades + planets + biomes
    -- (Pets will be added later when pet system is implemented)
    return totalUpgrades + totalPlanets + totalBiomes
end

-- Calculate items unlocked by player
function RebirthService:_calculateUnlockedItems(userId: number)
    local UpgradeService = Knit.GetService("UpgradeService")
    local SolarSystemService = Knit.GetService("SolarSystemService")
    local DataService = Knit.GetService("DataService")
    
    local playerData = DataService:GetPlayerData(userId)
    if not playerData then return 0 end
    
    -- Count unlocked upgrades (purchases with level > 0)
    local unlockedUpgrades = 0
    if playerData.upgrades then
        for _, level in pairs(playerData.upgrades) do
            if level and level > 0 then
                unlockedUpgrades = unlockedUpgrades + 1
            end
        end
    end
    
    -- Count unlocked planets
    local solarSystem = SolarSystemService:GetSolarSystem(userId)
    local unlockedPlanets = solarSystem and solarSystem.planetsUnlocked or 1
    
    -- Count biomes completed (count unique biomes achieved across all planets)
    local biomesCompleted = 0
    if solarSystem and solarSystem.planets then
        local uniqueBiomes = {}
        for _, planet in ipairs(solarSystem.planets) do
            if planet.isUnlocked and planet.biome then
                local key = planet.planetId .. "_" .. planet.biome
                if not uniqueBiomes[key] then
                    uniqueBiomes[key] = true
                    biomesCompleted = biomesCompleted + 1
                end
            end
        end
    end
    
    return unlockedUpgrades + unlockedPlanets + biomesCompleted
end

--[[ Public Methods ]]--

-- Get rebirth info for player (eligibility, rewards, etc.)
function RebirthService:GetRebirthInfo(userId: number)
    local DataService = Knit.GetService("DataService")
    local PlanetService = Knit.GetService("PlanetService")
    
    local playerData = DataService:GetPlayerData(userId)
    local planet = PlanetService:GetPlanet(userId)
    
    if not playerData or not planet then
        return {
            canRebirth = false,
            reason = "No player data",
        }
    end
    
    -- Calculate completion
    local totalItems = self:_calculateTotalItems(userId)
    local unlockedItems = self:_calculateUnlockedItems(userId)
    local completionPercent = (unlockedItems / totalItems) * 100
    
    -- Check requirements
    local rebirthCount = playerData.progression.rebirthCount or 0
    local minLevel = 15
    local minCompletion = 90
    
    local meetsLevelRequirement = planet.level >= minLevel
    local meetsCompletionRequirement = completionPercent >= minCompletion
    local canRebirth = meetsLevelRequirement and meetsCompletionRequirement
    
    -- Calculate rewards
    local currentMultiplier = playerData.progression.rebirthMultiplier or 0
    local bonusMultiplier = 0.10 -- +10% per rebirth
    local newMultiplier = currentMultiplier + bonusMultiplier
    
    -- Bonus stars based on progress
    local bonusStars = math.floor(10 + (completionPercent - 90) * 2) -- 10-30 stars
    
    -- Get rank info
    local currentRank = self:_getRank(rebirthCount)
    local nextRank = self:_getRank(rebirthCount + 1)
    
    return {
        canRebirth = canRebirth,
        totalItems = totalItems,
        unlockedItems = unlockedItems,
        completionPercent = math.floor(completionPercent * 10) / 10, -- Round to 1 decimal
        
        -- Requirements
        minLevel = minLevel,
        currentLevel = planet.level,
        meetsLevelRequirement = meetsLevelRequirement,
        minCompletion = minCompletion,
        meetsCompletionRequirement = meetsCompletionRequirement,
        
        -- Current stats
        rebirthCount = rebirthCount,
        currentMultiplier = currentMultiplier,
        currentRank = currentRank.name,
        currentRankColor = currentRank.color,
        
        -- Rewards preview
        bonusMultiplier = bonusMultiplier,
        newMultiplier = newMultiplier,
        bonusStars = bonusStars,
        nextRank = nextRank.name,
        nextRankColor = nextRank.color,
        
        -- What you keep
        keeps = {
            stars = true,
            starUpgrades = true,
            pets = false, -- Will be true when pet system is added
            rebirthMultiplier = true,
        },
        
        -- What resets
        resets = {
            solarSystem = true,
            planets = true,
            resources = true,
            levels = true,
            upgrades = true,
            biomes = true,
        },
    }
end

-- Execute rebirth for player
function RebirthService:ExecuteRebirth(player: Player)
    local userId = player.UserId
    local rebirthInfo = self:GetRebirthInfo(userId)
    
    -- Validate eligibility
    if not rebirthInfo.canRebirth then
        warn("[RebirthService] Player " .. player.Name .. " cannot rebirth - requirements not met")
        return false, "Requirements not met: " .. (rebirthInfo.reason or "Unknown")
    end
    
    local DataService = Knit.GetService("DataService")
    local SolarSystemService = Knit.GetService("SolarSystemService")
    local UpgradeService = Knit.GetService("UpgradeService")
    local PlanetService = Knit.GetService("PlanetService")
    
    local playerData = DataService:GetPlayerData(userId)
    if not playerData then
        return false, "Player data not found"
    end
    
    print("[RebirthService] Executing rebirth for " .. player.Name)
    
    -- Award rebirth rewards BEFORE resetting
    playerData.progression.rebirthCount = (playerData.progression.rebirthCount or 0) + 1
    playerData.progression.rebirthMultiplier = rebirthInfo.newMultiplier
    
    -- Award bonus stars (if star system is implemented)
    -- playerData.inventory.stars = (playerData.inventory.stars or 0) + rebirthInfo.bonusStars
    
    -- Update rebirth rank
    local newRank = self:_getRank(playerData.progression.rebirthCount)
    playerData.progression.rebirthRank = newRank.name
    
    -- Track stats
    if not playerData.stats.totalRebirths then
        playerData.stats.totalRebirths = 0
    end
    playerData.stats.totalRebirths = playerData.stats.totalRebirths + 1
    
    -- Reset: Generate new solar system
    local newSolarSystem = SolarSystemService:_generateSolarSystem(userId)
    playerData.solarSystem = newSolarSystem
    SolarSystemService._solarSystems[userId] = newSolarSystem
    
    -- Reset: Clear all upgrades
    playerData.upgrades = {}
    UpgradeService._playerUpgrades[userId] = {}
    
    -- Reset: Clear progression (except rebirth data and star upgrades)
    local starUpgrades = playerData.progression.starUpgrades or {} -- Keep star upgrades
    local biomesCompleted = {} -- Reset biomes
    local achievements = playerData.progression.achievements or {} -- Keep achievements
    
    playerData.progression.upgradesUnlocked = {}
    playerData.progression.biomesCompleted = biomesCompleted
    playerData.progression.achievements = achievements
    playerData.progression.starUpgrades = starUpgrades -- Restore star upgrades
    
    -- Reset: Load first planet from new solar system
    local firstPlanet = newSolarSystem.planets[1]
    PlanetService._planets[userId] = firstPlanet
    
    -- Save data
    DataService:UpdatePlayerData(userId, playerData)
    DataService:SavePlayerData(player)
    
    print("[RebirthService] Rebirth complete for " .. player.Name)
    print("[RebirthService] New rank: " .. newRank.name .. ", Multiplier: +" .. (rebirthInfo.newMultiplier * 100) .. "%")
    print("[RebirthService] New solar system with " .. newSolarSystem.planetCount .. " planets")
    
    return true, "Rebirth successful! New rank: " .. newRank.name
end

--[[ Client Methods ]]--

function RebirthService.Client:GetRebirthInfo(player: Player)
    return self.Server:GetRebirthInfo(player.UserId)
end

function RebirthService.Client:ExecuteRebirth(player: Player)
    return self.Server:ExecuteRebirth(player)
end

return RebirthService
