--[[
    GamePassService
    
    Manages game passes and premium purchases
    
    Game Passes:
    - 2x Resources (permanent resource generation multiplier)
    - VIP Planet Slot (+1 extra planet in solar system)
    - Auto-Collector (automatically collect resources)
    - Premium Pet Slots (+10 pet storage)
    - XP Boost (2x XP gain permanently)
    - Instant Rebirth (skip rebirth cooldown)
    
    Note: Game pass IDs must be created in Roblox Studio/Creator Dashboard
]]

local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local GamePassService = Knit.CreateService({
    Name = "GamePassService",
    Client = {
        PurchaseGamePass = Knit.CreateSignal(),
        GamePassOwned = Knit.CreateSignal(),
    },
})

-- Game Pass Definitions (IDs must be set after creating in Roblox)
local GAME_PASSES = {
    {
        id = 0, -- REPLACE WITH ACTUAL GAME PASS ID
        internalId = "double_resources",
        name = "2x Resources",
        description = "Double all resource generation permanently!",
        icon = "💎",
        price = 199, -- Robux (for display only, actual price set in Roblox)
        benefits = {
            resourceMultiplier = 2.0
        }
    },
    {
        id = 0, -- REPLACE WITH ACTUAL GAME PASS ID
        internalId = "vip_planet",
        name = "VIP Planet Slot",
        description = "Unlock 1 extra planet in your solar system!",
        icon = "🌍",
        price = 299,
        benefits = {
            extraPlanetSlot = 1
        }
    },
    {
        id = 0, -- REPLACE WITH ACTUAL GAME PASS ID
        internalId = "auto_collector",
        name = "Auto-Collector",
        description = "Resources automatically collect every 10 seconds!",
        icon = "⚡",
        price = 399,
        benefits = {
            autoCollect = true
        }
    },
    {
        id = 0, -- REPLACE WITH ACTUAL GAME PASS ID
        internalId = "premium_pets",
        name = "Premium Pet Slots",
        description = "+10 pet storage slots (Coming Soon)",
        icon = "🐾",
        price = 249,
        benefits = {
            petSlots = 10
        }
    },
    {
        id = 0, -- REPLACE WITH ACTUAL GAME PASS ID
        internalId = "xp_boost",
        name = "XP Boost",
        description = "Gain 2x XP from all sources permanently!",
        icon = "⚡",
        price = 349,
        benefits = {
            xpMultiplier = 2.0
        }
    },
    {
        id = 0, -- REPLACE WITH ACTUAL GAME PASS ID
        internalId = "instant_rebirth",
        name = "Instant Rebirth",
        description = "Skip rebirth cooldowns and rebirth instantly!",
        icon = "🔄",
        price = 499,
        benefits = {
            instantRebirth = true
        }
    },
}

function GamePassService:KnitInit()
    print("[GamePassService] Initializing...")
    
    -- Cache player game pass ownership
    self._playerGamePasses = {}
    
    -- Create lookup by internal ID
    self._gamePassesByID = {}
    for _, pass in ipairs(GAME_PASSES) do
        self._gamePassesByID[pass.internalId] = pass
    end
end

function GamePassService:KnitStart()
    print("[GamePassService] Starting...")
    
    -- Listen for players joining
    game.Players.PlayerAdded:Connect(function(player)
        self:_loadPlayerGamePasses(player)
    end)
    
    -- Listen for game pass purchases
    MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
        if wasPurchased then
            print("[GamePassService]", player.Name, "purchased game pass", gamePassId)
            self:_onGamePassPurchased(player, gamePassId)
        end
    end)
    
    print("[GamePassService] Started!")
end

--[[ Private Methods ]]--

function GamePassService:_loadPlayerGamePasses(player: Player)
    local userId = player.UserId
    self._playerGamePasses[userId] = {}
    
    -- Check ownership of all game passes
    for _, pass in ipairs(GAME_PASSES) do
        if pass.id > 0 then -- Only check if ID is set
            local success, ownsPass = pcall(function()
                return MarketplaceService:UserOwnsGamePassAsync(userId, pass.id)
            end)
            
            if success and ownsPass then
                self._playerGamePasses[userId][pass.internalId] = true
                print("[GamePassService]", player.Name, "owns", pass.name)
            end
        end
    end
end

function GamePassService:_onGamePassPurchased(player: Player, gamePassId: number)
    -- Find which game pass was purchased
    for _, pass in ipairs(GAME_PASSES) do
        if pass.id == gamePassId then
            self._playerGamePasses[player.UserId][pass.internalId] = true
            
            -- Notify client
            self.Client.GamePassOwned:Fire(player, pass.internalId)
            
            print("[GamePassService]", player.Name, "now owns", pass.name)
            break
        end
    end
end

--[[ Public Methods ]]--

-- Check if player owns a specific game pass
function GamePassService:PlayerOwnsGamePass(player: Player, internalId: string): boolean
    local userId = player.UserId
    if not self._playerGamePasses[userId] then
        return false
    end
    
    return self._playerGamePasses[userId][internalId] == true
end

-- Get all game passes owned by player
function GamePassService:GetPlayerGamePasses(player: Player): {string}
    local userId = player.UserId
    if not self._playerGamePasses[userId] then
        return {}
    end
    
    local owned = {}
    for passId, isOwned in pairs(self._playerGamePasses[userId]) do
        if isOwned then
            table.insert(owned, passId)
        end
    end
    
    return owned
end

-- Get multiplier benefits for a player
function GamePassService:GetPlayerBenefits(player: Player): {[string]: any}
    local benefits = {
        resourceMultiplier = 1.0,
        xpMultiplier = 1.0,
        extraPlanetSlot = 0,
        petSlots = 0,
        autoCollect = false,
        instantRebirth = false,
    }
    
    -- Apply benefits from owned game passes
    for _, pass in ipairs(GAME_PASSES) do
        if self:PlayerOwnsGamePass(player, pass.internalId) then
            for key, value in pairs(pass.benefits) do
                if type(value) == "number" then
                    -- Multiply for multipliers, add for slots
                    if key:find("Multiplier") then
                        benefits[key] = benefits[key] * value
                    else
                        benefits[key] = benefits[key] + value
                    end
                elseif type(value) == "boolean" then
                    benefits[key] = value
                end
            end
        end
    end
    
    return benefits
end

-- Get all available game passes
function GamePassService:GetAllGamePasses(): {{}}
    return GAME_PASSES
end

-- Prompt purchase (called from client)
function GamePassService:PromptPurchase(player: Player, internalId: string)
    local pass = self._gamePassesByID[internalId]
    if not pass then
        warn("[GamePassService] Invalid game pass ID:", internalId)
        return
    end
    
    if pass.id == 0 then
        warn("[GamePassService] Game pass ID not set for:", pass.name)
        -- TODO: Show error to player
        return
    end
    
    -- Check if already owned
    if self:PlayerOwnsGamePass(player, internalId) then
        print("[GamePassService]", player.Name, "already owns", pass.name)
        return
    end
    
    -- Prompt purchase
    MarketplaceService:PromptGamePassPurchase(player, pass.id)
end

--[[ Client Methods ]]--

function GamePassService.Client:GetAllGamePasses(player: Player)
    return self.Server:GetAllGamePasses()
end

function GamePassService.Client:GetOwnedGamePasses(player: Player)
    return self.Server:GetPlayerGamePasses(player)
end

function GamePassService.Client:PurchaseGamePass(player: Player, internalId: string)
    self.Server:PromptPurchase(player, internalId)
end

return GamePassService
