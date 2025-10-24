--[[
    StarMapService
    
    Manages the Star Map prestige system where players earn and spend Stars
    for permanent upgrades that persist through rebirths.
    
    Features:
    - Award stars for biome mastery (4 per planet)
    - Track purchased star upgrades
    - Apply permanent bonuses (offline earnings, rate multipliers, etc.)
    - Calculate offline earnings
    
    API:
    - GetPlayerStars(player) -> number
    - GetStarUpgrades(player) -> {string}
    - PurchaseStarUpgrade(player, upgradeId) -> boolean
    - CalculateOfflineEarnings(player, timeOffline) -> resources
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local StarMapService = Knit.CreateService({
    Name = "StarMapService",
    Client = {
        GetStarData = Knit.CreateProperty({}),
        PurchaseUpgrade = Knit.CreateSignal(),
    },
})

-- Star Upgrade Definitions
local STAR_UPGRADES = {
    -- Offline Earnings Time
    {
        id = "offline_time_1",
        name = "Extended Offline Time I",
        description = "+2 hours offline earnings",
        cost = 1,
        category = "offline",
        effect = { offlineTimeBonus = 2 * 3600 } -- 2 hours in seconds
    },
    {
        id = "offline_time_2",
        name = "Extended Offline Time II",
        description = "+4 hours offline earnings",
        cost = 2,
        category = "offline",
        requires = "offline_time_1",
        effect = { offlineTimeBonus = 4 * 3600 }
    },
    {
        id = "offline_time_3",
        name = "Extended Offline Time III",
        description = "+8 hours offline earnings",
        cost = 3,
        category = "offline",
        requires = "offline_time_2",
        effect = { offlineTimeBonus = 8 * 3600 }
    },
    {
        id = "offline_time_4",
        name = "Extended Offline Time IV",
        description = "+24 hours offline earnings",
        cost = 5,
        category = "offline",
        requires = "offline_time_3",
        effect = { offlineTimeBonus = 24 * 3600 }
    },
    
    -- Offline Rate Multiplier
    {
        id = "offline_rate_1",
        name = "Offline Production I",
        description = "50% resource rate while offline",
        cost = 1,
        category = "offline",
        effect = { offlineRateMultiplier = 0.5 }
    },
    {
        id = "offline_rate_2",
        name = "Offline Production II",
        description = "75% resource rate while offline",
        cost = 2,
        category = "offline",
        requires = "offline_rate_1",
        effect = { offlineRateMultiplier = 0.75 }
    },
    {
        id = "offline_rate_3",
        name = "Offline Production III",
        description = "100% resource rate while offline",
        cost = 3,
        category = "offline",
        requires = "offline_rate_2",
        effect = { offlineRateMultiplier = 1.0 }
    },
    
    -- Global Bonuses
    {
        id = "global_resources",
        name = "Resource Abundance",
        description = "+10% to all resource generation",
        cost = 2,
        category = "global",
        effect = { globalResourceBonus = 0.1 }
    },
    {
        id = "global_caps",
        name = "Expanded Reserves",
        description = "+50% to all resource caps",
        cost = 2,
        category = "global",
        effect = { globalCapBonus = 0.5 }
    },
    {
        id = "global_xp",
        name = "Accelerated Growth",
        description = "+25% XP gain",
        cost = 3,
        category = "global",
        effect = { globalXPBonus = 0.25 }
    },
    {
        id = "global_discount",
        name = "Economic Efficiency",
        description = "-10% upgrade costs",
        cost = 3,
        category = "global",
        effect = { globalCostReduction = 0.1 }
    },
    
    -- Special Unlocks
    {
        id = "auto_collect",
        name = "Automated Harvesting",
        description = "Resources auto-collect every 10 seconds",
        cost = 4,
        category = "special",
        effect = { autoCollect = true }
    },
    {
        id = "fifth_biome",
        name = "Apex Ecosystem",
        description = "Unlock 5th biome tier (Coming Soon)",
        cost = 5,
        category = "special",
        effect = { maxBiomeLevel = 5 }
    },
    {
        id = "pet_storage",
        name = "Extended Habitat",
        description = "+10 pet storage slots (Coming Soon)",
        cost = 2,
        category = "special",
        effect = { petStorageBonus = 10 }
    },
}

function StarMapService:KnitInit()
    print("[StarMapService] Initializing...")
    
    -- Store upgrade definitions for quick lookup
    self._upgradesByID = {}
    for _, upgrade in ipairs(STAR_UPGRADES) do
        self._upgradesByID[upgrade.id] = upgrade
    end
    
    -- Player star data cache
    self._playerStarData = {}
end

function StarMapService:KnitStart()
    print("[StarMapService] Starting...")
    
    -- Listen for player added/removing
    game.Players.PlayerAdded:Connect(function(player)
        self:_loadPlayerStarData(player)
    end)
    
    game.Players.PlayerRemoving:Connect(function(player)
        self._playerStarData[player.UserId] = nil
    end)
    
    print("[StarMapService] Started successfully!")
end

--[[ Private Methods ]]--

function StarMapService:_loadPlayerStarData(player: Player)
    local DataService = Knit.GetService("DataService")
    
    -- Load from DataService
    local success, data = pcall(function()
        return DataService:GetData(player, "starData")
    end)
    
    if success and data then
        self._playerStarData[player.UserId] = data
    else
        -- Initialize default star data
        self._playerStarData[player.UserId] = {
            stars = 0,
            totalStarsEarned = 0,
            starUpgrades = {},
            biomesCompleted = {} -- Track which planet biomes have been mastered
        }
        
        -- Save default data
        DataService:SetData(player, "starData", self._playerStarData[player.UserId])
    end
    
    print("[StarMapService] Loaded star data for", player.Name, "- Stars:", self._playerStarData[player.UserId].stars)
end

function StarMapService:_savePlayerStarData(player: Player)
    local DataService = Knit.GetService("DataService")
    local starData = self._playerStarData[player.UserId]
    
    if starData then
        DataService:SetData(player, "starData", starData)
    end
end

--[[ Public Methods ]]--

-- Get player's current star count
function StarMapService:GetPlayerStars(player: Player): number
    local data = self._playerStarData[player.UserId]
    return data and data.stars or 0
end

-- Get player's purchased star upgrades
function StarMapService:GetStarUpgrades(player: Player): {string}
    local data = self._playerStarData[player.UserId]
    return data and data.starUpgrades or {}
end

-- Award stars to player (from biome completion, achievements, etc.)
function StarMapService:AwardStars(player: Player, amount: number, reason: string?)
    local data = self._playerStarData[player.UserId]
    if not data then
        warn("[StarMapService] No star data for", player.Name)
        return false
    end
    
    data.stars += amount
    data.totalStarsEarned += amount
    
    print("[StarMapService]", player.Name, "earned", amount, "stars", reason and ("(" .. reason .. ")") or "")
    
    self:_savePlayerStarData(player)
    self.Client.GetStarData:SetFor(player, data)
    
    return true
end

-- Mark a biome as completed for a specific planet
function StarMapService:MarkBiomeCompleted(player: Player, planetId: string, biome: string): boolean
    local data = self._playerStarData[player.UserId]
    if not data then return false end
    
    local key = planetId .. "_" .. biome
    
    -- Check if already completed
    if data.biomesCompleted[key] then
        return false -- Already got stars for this
    end
    
    -- Mark as completed
    data.biomesCompleted[key] = true
    
    -- Award 1 star per biome mastered
    self:AwardStars(player, 1, "Mastered " .. biome .. " biome")
    
    return true
end

-- Purchase a star upgrade
function StarMapService:PurchaseStarUpgrade(player: Player, upgradeId: string): boolean
    local data = self._playerStarData[player.UserId]
    if not data then
        warn("[StarMapService] No star data for", player.Name)
        return false
    end
    
    local upgrade = self._upgradesByID[upgradeId]
    if not upgrade then
        warn("[StarMapService] Invalid upgrade ID:", upgradeId)
        return false
    end
    
    -- Check if already purchased
    if table.find(data.starUpgrades, upgradeId) then
        warn("[StarMapService] Upgrade already purchased:", upgradeId)
        return false
    end
    
    -- Check requirements
    if upgrade.requires then
        if not table.find(data.starUpgrades, upgrade.requires) then
            warn("[StarMapService] Missing requirement:", upgrade.requires)
            return false
        end
    end
    
    -- Check if enough stars
    if data.stars < upgrade.cost then
        warn("[StarMapService] Not enough stars. Need:", upgrade.cost, "Have:", data.stars)
        return false
    end
    
    -- Deduct stars
    data.stars -= upgrade.cost
    
    -- Add upgrade
    table.insert(data.starUpgrades, upgradeId)
    
    print("[StarMapService]", player.Name, "purchased star upgrade:", upgrade.name)
    
    self:_savePlayerStarData(player)
    self.Client.GetStarData:SetFor(player, data)
    
    return true
end

-- Get all upgrade effects for a player
function StarMapService:GetPlayerUpgradeEffects(player: Player): {[string]: any}
    local data = self._playerStarData[player.UserId]
    if not data then return {} end
    
    local effects = {
        offlineTimeBonus = 0,
        offlineRateMultiplier = 0,
        globalResourceBonus = 0,
        globalCapBonus = 0,
        globalXPBonus = 0,
        globalCostReduction = 0,
        autoCollect = false,
        maxBiomeLevel = 4, -- Default
        petStorageBonus = 0,
    }
    
    -- Accumulate effects from all purchased upgrades
    for _, upgradeId in ipairs(data.starUpgrades) do
        local upgrade = self._upgradesByID[upgradeId]
        if upgrade then
            for effectKey, effectValue in pairs(upgrade.effect) do
                if type(effectValue) == "boolean" then
                    effects[effectKey] = effectValue
                elseif type(effectValue) == "number" then
                    -- For time/multiplier upgrades, use highest tier
                    if effectKey == "offlineTimeBonus" or effectKey == "offlineRateMultiplier" then
                        effects[effectKey] = math.max(effects[effectKey], effectValue)
                    else
                        -- For bonuses, stack additively
                        effects[effectKey] = effects[effectKey] + effectValue
                    end
                else
                    effects[effectKey] = effectValue
                end
            end
        end
    end
    
    return effects
end

-- Calculate offline earnings
function StarMapService:CalculateOfflineEarnings(player: Player, timeOffline: number): {[string]: number}
    local effects = self:GetPlayerUpgradeEffects(player)
    
    -- Base offline time is 1 hour
    local maxOfflineTime = 3600 + effects.offlineTimeBonus
    local cappedTime = math.min(timeOffline, maxOfflineTime)
    
    -- If no offline rate multiplier purchased, return empty
    if effects.offlineRateMultiplier == 0 then
        return {}
    end
    
    -- Get current planet's resource rates
    local PlanetService = Knit.GetService("PlanetService")
    local planetState = PlanetService:GetPlayerPlanet(player)
    
    if not planetState then
        return {}
    end
    
    -- Calculate offline resources (simplified - would use actual rate calculation)
    local Constants = require(ReplicatedStorage.Shared.Constants)
    local biomeData = Constants.BIOMES[planetState.biome]
    
    local offlineResources = {
        water = Constants.RESOURCES.BASE_WATER_RATE * (1 + biomeData.waterBonus) * effects.offlineRateMultiplier * cappedTime,
        minerals = Constants.RESOURCES.BASE_MINERALS_RATE * (1 + biomeData.mineralsBonus) * effects.offlineRateMultiplier * cappedTime,
        energy = Constants.RESOURCES.BASE_ENERGY_RATE * (1 + biomeData.energyBonus) * effects.offlineRateMultiplier * cappedTime,
        biomass = Constants.RESOURCES.BASE_BIOMASS_RATE * (1 + biomeData.biomassBonus) * effects.offlineRateMultiplier * cappedTime,
    }
    
    print("[StarMapService]", player.Name, "earned offline resources for", cappedTime, "seconds")
    
    return offlineResources
end

-- Get all available upgrades
function StarMapService:GetAllUpgrades(): {{}}
    return STAR_UPGRADES
end

--[[ Client Methods ]]--

function StarMapService.Client:GetStarData(player: Player)
    return self.Server:GetPlayerStars(player), self.Server:GetStarUpgrades(player)
end

function StarMapService.Client:PurchaseUpgrade(player: Player, upgradeId: string)
    return self.Server:PurchaseStarUpgrade(player, upgradeId)
end

function StarMapService.Client:GetAllUpgrades(player: Player)
    return self.Server:GetAllUpgrades()
end

return StarMapService
