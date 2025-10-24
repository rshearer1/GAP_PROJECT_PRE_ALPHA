--[[
    Constants.lua
    Game balance constants and configuration values
    
    All tunable game parameters should be defined here for easy balancing.
]]

local Constants = {}

-- Resource Generation
Constants.RESOURCES = {
    BASE_WATER_RATE = 1,        -- Water per second
    BASE_MINERAL_RATE = 0.8,    -- Minerals per second
    BASE_ENERGY_RATE = 0.5,     -- Energy per second
    BASE_BIOMASS_RATE = 0.3,    -- Biomass per second
    
    DEFAULT_CAP = 1000,         -- Default resource cap
    CAP_MULTIPLIER = 2.5,       -- Cap multiplier per upgrade
}

-- Planet Settings
Constants.PLANET = {
    STARTING_SIZE = 10,         -- Initial planet size
    MAX_SIZE = 100,             -- Maximum planet size
    STARTING_LEVEL = 1,
    XP_PER_LEVEL = 100,         -- Experience needed per level
    XP_SCALE = 1.5,             -- XP scaling per level
}

-- Biome Thresholds
Constants.BIOMES = {
    BARREN = {
        name = "Barren",
        minLevel = 1,
        waterBonus = 0,
        mineralBonus = 0,
        energyBonus = 0,
        biomassBonus = 0,
        color = Color3.fromRGB(120, 100, 80),
    },
    ROCKY = {
        name = "Rocky",
        minLevel = 3,
        waterBonus = 0,
        mineralBonus = 0.5,      -- +50% minerals
        energyBonus = 0,
        biomassBonus = 0,
        color = Color3.fromRGB(150, 120, 90),
    },
    OCEANIC = {
        name = "Oceanic",
        minLevel = 7,
        waterBonus = 1.0,        -- +100% water
        mineralBonus = 0.5,
        energyBonus = 0.3,
        biomassBonus = 0.2,
        color = Color3.fromRGB(50, 120, 200),
    },
    FOREST = {
        name = "Forest",
        minLevel = 12,
        waterBonus = 0.5,
        mineralBonus = 0.3,
        energyBonus = 0.8,
        biomassBonus = 1.5,      -- +150% biomass
        color = Color3.fromRGB(80, 160, 80),
    },
}

-- Gameplay Settings
Constants.GAMEPLAY = {
    AUTO_SAVE_INTERVAL = 60,    -- Save every 60 seconds
    UPDATE_TICK_RATE = 1,       -- Update resources every second
    OFFLINE_EARNINGS_CAP = 28800, -- 8 hours in seconds
    MAX_PETS_EQUIPPED = 3,
}

-- VIP Multipliers
Constants.VIP = {
    RESOURCE_MULTIPLIER = 2,    -- 2x resource generation
    OFFLINE_CAP_HOURS = 24,     -- 24 hours offline earnings
}

-- Pet Settings
Constants.PETS = {
    HATCH_COST = 100,           -- Cost to hatch an egg
    MAX_LEVEL = 50,
    XP_PER_LEVEL = 50,
    
    RARITY_MULTIPLIERS = {
        Common = 1.0,
        Rare = 1.25,
        Epic = 1.5,
        Legendary = 2.0,
        Mythical = 3.0,
    },
}

-- UI Settings
Constants.UI = {
    UPDATE_INTERVAL = 0.5,      -- Update UI every 0.5 seconds
    NOTIFICATION_DURATION = 3,  -- Notifications last 3 seconds
    
    -- Planet UI Frame Settings
    PLANET_UI = {
        MAIN_FRAME_SIZE = UDim2.new(0, 220, 0, 280),
        MAIN_FRAME_SIZE_MINIMIZED = UDim2.new(0, 220, 0, 40),
        MAIN_FRAME_POSITION = UDim2.new(0, 10, 0, 10),
        MAIN_FRAME_BG_COLOR = Color3.fromRGB(30, 30, 40),
        MAIN_FRAME_TRANSPARENCY = 0.1,
        
        CORNER_RADIUS = UDim.new(0, 8),
        PADDING = UDim.new(0, 10),
        
        MINIMIZE_BTN_SIZE = UDim2.new(0, 25, 0, 25),
        MINIMIZE_BTN_POS = UDim2.new(1, -30, 0, 5),
        MINIMIZE_BTN_COLOR = Color3.fromRGB(52, 73, 94),
        
        TITLE_SIZE = UDim2.new(1, -35, 0, 30),
        TITLE_TEXT_SIZE = 18,
        TITLE_TEXT = "My Planet",
        
        INFO_FRAME_SIZE = UDim2.new(1, 0, 0, 60),
        INFO_FRAME_COLOR = Color3.fromRGB(40, 40, 50),
        
        RESOURCES_FRAME_SIZE = UDim2.new(1, 0, 0, 120),
        RESOURCES_FRAME_POS = UDim2.new(0, 0, 0, 70),
        
        XP_BUTTON_SIZE = UDim2.new(1, 0, 0, 35),
        XP_BUTTON_POS = UDim2.new(0, 0, 0, 200),
        XP_BUTTON_COLOR = Color3.fromRGB(100, 100, 200),
        XP_BUTTON_TEXT = "⭐ Gain XP",
        
        -- Resource Colors
        WATER_COLOR = Color3.fromRGB(100, 150, 255),
        MINERAL_COLOR = Color3.fromRGB(150, 150, 150),
        ENERGY_COLOR = Color3.fromRGB(255, 200, 100),
        BIOMASS_COLOR = Color3.fromRGB(100, 200, 100),
        
        -- Text Sizes
        LEVEL_TEXT_SIZE = 18,
        BIOME_TEXT_SIZE = 12,
        XP_TEXT_SIZE = 10,
        RESOURCE_TEXT_SIZE = 13,
        BUTTON_TEXT_SIZE = 14,
    },
}

return Constants
