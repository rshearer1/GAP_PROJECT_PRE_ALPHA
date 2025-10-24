--[[
    UpgradeService.lua
    Server-side upgrade management
    
    Handles:
    - Upgrade definitions and costs
    - Purchase validation
    - Applying upgrade effects
    - Tracking player upgrades
]]

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Types = require(game:GetService("ReplicatedStorage").Shared.Types)
local Constants = require(game:GetService("ReplicatedStorage").Shared.Constants)

local UpgradeService = Knit.CreateService {
    Name = "UpgradeService",
    Client = {},
    
    -- Store player upgrades: [userId] = { [upgradeId] = level }
    _playerUpgrades = {},
    
    -- Define available upgrades
    _upgradeDefinitions = {},
}

-- Initialize upgrade definitions
function UpgradeService:KnitInit()
    print("[UpgradeService] Initializing...")
    
    -- Resource Rate Upgrades
    self._upgradeDefinitions["water_rate_1"] = {
        id = "water_rate_1",
        name = "Water Pump I",
        description = "Increase water generation by 25%",
        cost = { water = 50, minerals = 30, energy = 20, biomass = 0 },
        unlockLevel = 1,
        maxLevel = 5,
        effectType = "ResourceRate",
        effectResource = "water",
        effectValue = 0.25,  -- +25% per level
    }
    
    self._upgradeDefinitions["mineral_rate_1"] = {
        id = "mineral_rate_1",
        name = "Mining Drill I",
        description = "Increase mineral generation by 25%",
        cost = { water = 30, minerals = 50, energy = 20, biomass = 0 },
        unlockLevel = 1,
        maxLevel = 5,
        effectType = "ResourceRate",
        effectResource = "minerals",
        effectValue = 0.25,
    }
    
    self._upgradeDefinitions["energy_rate_1"] = {
        id = "energy_rate_1",
        name = "Solar Panel I",
        description = "Increase energy generation by 25%",
        cost = { water = 20, minerals = 30, energy = 50, biomass = 0 },
        unlockLevel = 2,
        maxLevel = 5,
        effectType = "ResourceRate",
        effectResource = "energy",
        effectValue = 0.25,
    }
    
    self._upgradeDefinitions["biomass_rate_1"] = {
        id = "biomass_rate_1",
        name = "Bio-Reactor I",
        description = "Increase biomass generation by 25%",
        cost = { water = 40, minerals = 20, energy = 30, biomass = 50 },
        unlockLevel = 3,
        maxLevel = 5,
        effectType = "ResourceRate",
        effectResource = "biomass",
        effectValue = 0.25,
    }
    
    -- Resource Cap Upgrades
    self._upgradeDefinitions["water_cap_1"] = {
        id = "water_cap_1",
        name = "Water Tank I",
        description = "Increase water storage by 500",
        cost = { water = 100, minerals = 50, energy = 30, biomass = 0 },
        unlockLevel = 2,
        maxLevel = 10,
        effectType = "ResourceCap",
        effectResource = "water",
        effectValue = 500,  -- +500 per level
    }
    
    self._upgradeDefinitions["mineral_cap_1"] = {
        id = "mineral_cap_1",
        name = "Mineral Vault I",
        description = "Increase mineral storage by 500",
        cost = { water = 50, minerals = 100, energy = 30, biomass = 0 },
        unlockLevel = 2,
        maxLevel = 10,
        effectType = "ResourceCap",
        effectResource = "minerals",
        effectValue = 500,
    }
    
    -- Planet Size Upgrade
    self._upgradeDefinitions["planet_size_1"] = {
        id = "planet_size_1",
        name = "Planetary Growth",
        description = "Increase planet size by 5 units",
        cost = { water = 200, minerals = 200, energy = 100, biomass = 100 },
        unlockLevel = 5,
        maxLevel = 10,
        effectType = "Size",
        effectResource = nil,
        effectValue = 5,
    }
    
    print("[UpgradeService] Loaded " .. self:_countUpgrades() .. " upgrade definitions")
end

function UpgradeService:KnitStart()
    print("[UpgradeService] Started!")
    
    -- Load player upgrades from DataService when they join
    game.Players.PlayerAdded:Connect(function(player)
        self:_onPlayerJoined(player)
    end)
    
    -- Save player upgrades when they leave
    game.Players.PlayerRemoving:Connect(function(player)
        self:_onPlayerLeaving(player)
    end)
end

-- Handle player joining - load their upgrade data
function UpgradeService:_onPlayerJoined(player: Player)
    local DataService = Knit.GetService("DataService")
    local playerData = DataService:LoadPlayerData(player)
    
    if playerData and playerData.upgrades then
        self._playerUpgrades[player.UserId] = playerData.upgrades
        
        -- Count upgrades
        local upgradeCount = 0
        for _ in pairs(playerData.upgrades) do
            upgradeCount = upgradeCount + 1
        end
        
        print("[UpgradeService] Loaded " .. upgradeCount .. " upgrades for " .. player.Name)
    else
        -- Initialize empty upgrades table
        self._playerUpgrades[player.UserId] = {}
        print("[UpgradeService] Initialized empty upgrades for " .. player.Name)
    end
end

-- Handle player leaving - save their upgrade data
function UpgradeService:_onPlayerLeaving(player: Player)
    local userId = player.UserId
    local playerUpgrades = self._playerUpgrades[userId]
    
    if playerUpgrades then
        -- Update DataService with upgrade data
        local DataService = Knit.GetService("DataService")
        DataService:UpdatePlayerData(userId, {
            upgrades = playerUpgrades
        })
        
        -- Save to DataStore
        DataService:SavePlayerData(player)
        
        print("[UpgradeService] Saved upgrades for " .. player.Name)
    end
    
    -- Clean up from memory
    self._playerUpgrades[userId] = nil
end

-- Count upgrade definitions
function UpgradeService:_countUpgrades()
    local count = 0
    for _ in pairs(self._upgradeDefinitions) do
        count = count + 1
    end
    return count
end

-- Get upgrade definitions for a player (filtered by unlock level)
function UpgradeService:GetAvailableUpgrades(userId: number, playerLevel: number)
    local available = {}
    
    for id, upgrade in pairs(self._upgradeDefinitions) do
        if playerLevel >= upgrade.unlockLevel then
            local currentLevel = self:GetUpgradeLevel(userId, id)
            
            -- Add upgrade info with current level
            table.insert(available, {
                id = upgrade.id,
                name = upgrade.name,
                description = upgrade.description,
                cost = upgrade.cost,
                unlockLevel = upgrade.unlockLevel,
                maxLevel = upgrade.maxLevel,
                currentLevel = currentLevel,
                effectType = upgrade.effectType,
                effectResource = upgrade.effectResource,
                effectValue = upgrade.effectValue,
                canAfford = false,  -- Will be set by client
                isMaxed = currentLevel >= upgrade.maxLevel,
            })
        end
    end
    
    return available
end

-- Get current level of an upgrade for a player
function UpgradeService:GetUpgradeLevel(userId: number, upgradeId: string): number
    if not self._playerUpgrades[userId] then
        return 0
    end
    return self._playerUpgrades[userId][upgradeId] or 0
end

-- Purchase an upgrade
function UpgradeService:PurchaseUpgrade(userId: number, upgradeId: string): (boolean, string?)
    local upgrade = self._upgradeDefinitions[upgradeId]
    if not upgrade then
        return false, "Upgrade not found"
    end
    
    -- Check current level
    local currentLevel = self:GetUpgradeLevel(userId, upgradeId)
    if currentLevel >= upgrade.maxLevel then
        return false, "Upgrade already at max level"
    end
    
    -- Get PlanetService to check/deduct resources
    local PlanetService = Knit.GetService("PlanetService")
    local planet = PlanetService:GetPlanet(userId)
    if not planet then
        return false, "Planet not found"
    end
    
    -- Check player level requirement
    if planet.level < upgrade.unlockLevel then
        return false, "Player level too low"
    end
    
    -- Check if player has enough resources
    if planet.resources.water < upgrade.cost.water or
       planet.resources.minerals < upgrade.cost.minerals or
       planet.resources.energy < upgrade.cost.energy or
       planet.resources.biomass < upgrade.cost.biomass then
        return false, "Not enough resources"
    end
    
    -- Deduct resources
    planet.resources.water -= upgrade.cost.water
    planet.resources.minerals -= upgrade.cost.minerals
    planet.resources.energy -= upgrade.cost.energy
    planet.resources.biomass -= upgrade.cost.biomass
    
    -- Increase upgrade level
    if not self._playerUpgrades[userId] then
        self._playerUpgrades[userId] = {}
    end
    self._playerUpgrades[userId][upgradeId] = currentLevel + 1
    
    -- Apply upgrade effect
    self:_applyUpgradeEffect(userId, upgrade, currentLevel + 1)
    
    print(string.format("[UpgradeService] Player %d purchased %s (Level %d)", userId, upgradeId, currentLevel + 1))
    
    return true, nil
end

-- Apply upgrade effect to planet
function UpgradeService:_applyUpgradeEffect(userId: number, upgrade, newLevel: number)
    local PlanetService = Knit.GetService("PlanetService")
    local planet = PlanetService:GetPlanet(userId)
    if not planet then return end
    
    if upgrade.effectType == "Size" then
        -- Increase planet size
        planet.size += upgrade.effectValue
        
        -- Update visuals
        local PlanetVisualsService = Knit.GetService("PlanetVisualsService")
        if PlanetVisualsService then
            PlanetVisualsService:UpdatePlanetVisual(userId, planet)
        end
    end
    
    -- Note: Rate and Cap upgrades are applied via GetUpgradeMultipliers() during resource calculation
end

-- Get all upgrade multipliers for a player (used by PlanetService)
function UpgradeService:GetUpgradeMultipliers(userId: number)
    local multipliers = {
        water_rate = 1,
        minerals_rate = 1,
        energy_rate = 1,
        biomass_rate = 1,
        water_cap = 0,
        minerals_cap = 0,
        energy_cap = 0,
        biomass_cap = 0,
    }
    
    if not self._playerUpgrades[userId] then
        return multipliers
    end
    
    -- Calculate multipliers from all purchased upgrades
    for upgradeId, level in pairs(self._playerUpgrades[userId]) do
        local upgrade = self._upgradeDefinitions[upgradeId]
        if upgrade then
            if upgrade.effectType == "ResourceRate" then
                local key = upgrade.effectResource .. "_rate"
                multipliers[key] = multipliers[key] + (upgrade.effectValue * level)
            elseif upgrade.effectType == "ResourceCap" then
                local key = upgrade.effectResource .. "_cap"
                multipliers[key] = multipliers[key] + (upgrade.effectValue * level)
            end
        end
    end
    
    return multipliers
end

-- Client methods
function UpgradeService.Client:GetAvailableUpgrades(player: Player)
    local PlanetService = Knit.GetService("PlanetService")
    local planet = PlanetService:GetPlanet(player.UserId)
    if not planet then
        return {}
    end
    
    return self.Server:GetAvailableUpgrades(player.UserId, planet.level)
end

function UpgradeService.Client:PurchaseUpgrade(player: Player, upgradeId: string)
    return self.Server:PurchaseUpgrade(player.UserId, upgradeId)
end

return UpgradeService
