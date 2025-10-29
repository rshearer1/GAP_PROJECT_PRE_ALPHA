-- PetTypes.lua
-- Shared pet configuration and helpers

local PetTypes = {}

PetTypes.Configs = {
    ["space_dragon"] = {
        id = "space_dragon",
        name = "Space Dragon",
        rarity = "Legendary",
        resourceBonus = 0.40,
        description = "A mighty dragon that boosts all resources.",
    },
    ["star_whale"] = {
        id = "star_whale",
        name = "Star Whale",
        rarity = "Epic",
        resourceBonus = 0.25,
        description = "A gentle giant that increases water generation.",
    },
    ["nebula_fox"] = {
        id = "nebula_fox",
        name = "Nebula Fox",
        rarity = "Rare",
        resourceBonus = 0.15,
        description = "A clever companion that boosts energy.",
    },
    ["water_wisp"] = {
        id = "water_wisp",
        name = "Water Wisp",
        rarity = "Rare",
        resourceBonus = 0.20,
        description = "Helps with water generation.",
    },
    ["flame_spirit"] = {
        id = "flame_spirit",
        name = "Flame Spirit",
        rarity = "Epic",
        resourceBonus = 0.30,
        description = "Improves temperature control and biomass.",
    },
}

PetTypes.RarityChances = {
    Common = 0.50,
    Rare = 0.30,
    Epic = 0.15,
    Legendary = 0.045,
    Mythical = 0.005,
}

-- Utility: get a config by id
function PetTypes.GetConfig(id)
    return PetTypes.Configs[id]
end

-- Utility: list all available pet configs
function PetTypes.GetAllConfigs()
    local list = {}
    for k, v in pairs(PetTypes.Configs) do
        table.insert(list, v)
    end
    return list
end

return PetTypes
