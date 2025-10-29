-- PetService.lua
-- Server-side pet management (basic implementation)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local PetTypes = require(ReplicatedStorage.Shared.PetTypes)

local PetService = Knit.CreateService {
    Name = "PetService",
    Client = {
        -- Client methods are declared below as wrappers that call Server methods
        GetPets = Knit.CreateProperty(nil),
        HatchPet = Knit.CreateProperty(nil),
        EvolvePet = Knit.CreateProperty(nil),
        
        -- Signal to notify clients when their pets change
        PetsChanged = Knit.CreateSignal(),
    },
}

-- Lazy reference to DataService
local DataService = nil

function PetService:KnitInit()
    print("[PetService] Initializing...")
end

function PetService:KnitStart()
    print("[PetService] Starting...")
    -- Get DataService reference
    DataService = Knit.GetService("DataService")
end

-- Helper: Get player data and ensure pets array exists
function PetService:_getPlayerPets(userId)
    if not DataService then
        warn("[PetService] DataService not available")
        return nil
    end
    
    local playerData = DataService:GetPlayerData(userId)
    if not playerData then
        warn("[PetService] No player data for userId:", userId)
        return nil
    end
    
    print("[PetService] Player data exists for userId:", userId)
    print("[PetService] Current pets array:", playerData.pets)
    
    -- Ensure pets array exists
    if not playerData.pets then
        print("[PetService] Creating new pets array for userId:", userId)
        playerData.pets = {}
    end
    
    print("[PetService] Pets array length:", #playerData.pets)
    
    return playerData.pets
end

-- Server: Hatch a pet for a user (simple deterministic creation for now)
function PetService:HatchPet(userId, petKey)
    print("[PetService] HatchPet called - userId:", userId, "petKey:", petKey)
    
    local pets = self:_getPlayerPets(userId)
    if not pets then
        warn("[PetService] Failed to get player pets")
        return false, "Player data unavailable"
    end

    print("[PetService] Current pet count before hatching:", #pets)

    local config = PetTypes.GetConfig(petKey)
    if not config then
        warn("[PetService] Invalid pet key:", petKey)
        return false, "Invalid pet key"
    end

    local newPet = {
        id = config.id .. "_" .. tostring(math.random(100000, 999999)),
        type = config.id,
        name = config.name,
        rarity = config.rarity,
        level = 1,
        experience = 0,
        resourceBonus = config.resourceBonus,
        description = config.description,
        createdAt = os.time(),
    }

    print("[PetService] Created new pet:", newPet.name, newPet.id)
    
    table.insert(pets, newPet)
    
    print("[PetService] Pet count after insert:", #pets)
    print("[PetService] Verifying pet was added - first pet:", pets[1] and pets[1].name or "nil")
    
    -- Update stats
    if DataService then
        local playerData = DataService:GetPlayerData(userId)
        if playerData and playerData.stats then
            playerData.stats.petsHatched = (playerData.stats.petsHatched or 0) + 1
        end
    end

    print("[PetService] Hatched pet:", newPet.name, "for userId:", userId)
    
    -- Notify client that pets changed
    local player = Players:GetPlayerByUserId(userId)
    if player then
        self.Client.PetsChanged:Fire(player)
    end
    
    return true, newPet
end

-- Server: Get player's pets (returns shallow copy)
function PetService:GetPets(userId)
    print("[PetService] GetPets called for userId:", userId)
    
    local pets = self:_getPlayerPets(userId)
    if not pets then
        warn("[PetService] No pets found for userId:", userId)
        return {}
    end
    
    print("[PetService] Returning", #pets, "pets for userId:", userId)
    
    local copy = {}
    for i, v in ipairs(pets) do
        copy[i] = v
    end
    return copy
end

-- Server: Simple evolve operation (combine two pets into a stronger one)
function PetService:EvolvePet(userId, petIdA, petIdB)
    local pets = self:_getPlayerPets(userId)
    if not pets then
        return false, "Player data unavailable"
    end
    
    local idxA, idxB
    for i, p in ipairs(pets) do
        if p.id == petIdA then idxA = i end
        if p.id == petIdB then idxB = i end
    end

    if not idxA or not idxB or idxA == idxB then
        return false, "Invalid pets"
    end

    local petA = pets[idxA]
    local petB = pets[idxB]

    -- Simple rule: require same type and rarity for evolution
    if petA.type ~= petB.type or petA.rarity ~= petB.rarity then
        return false, "Pets incompatible for evolution"
    end

    -- Create evolved pet
    local evolved = {
        id = petA.type .. "_" .. tostring(math.random(100000, 999999)),
        type = petA.type,
        name = petA.name,
        rarity = petA.rarity,
        level = math.max(petA.level, petB.level) + 1,
        experience = 0,
        resourceBonus = (petA.resourceBonus + petB.resourceBonus) * 1.1,
        description = petA.description,
        createdAt = os.time(),
    }

    -- Remove higher index first
    if idxA > idxB then
        table.remove(pets, idxA)
        table.remove(pets, idxB)
    else
        table.remove(pets, idxB)
        table.remove(pets, idxA)
    end

    table.insert(pets, evolved)

    print("[PetService] Evolved pet:", evolved.name, "level", evolved.level, "for userId:", userId)
    
    -- Notify client that pets changed
    local player = Players:GetPlayerByUserId(userId)
    if player then
        self.Client.PetsChanged:Fire(player)
    end
    
    return true, evolved
end

--[[ Client wrappers ]]--
function PetService.Client:GetPets(player)
    return self.Server:GetPets(player.UserId)
end

function PetService.Client:HatchPet(player, petKey)
    return self.Server:HatchPet(player.UserId, petKey)
end

function PetService.Client:EvolvePet(player, petIdA, petIdB)
    return self.Server:EvolvePet(player.UserId, petIdA, petIdB)
end

return PetService
