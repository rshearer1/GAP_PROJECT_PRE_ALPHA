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

-- Plot Settings
Constants.PLOT = {
    SIZE = 120,                 -- Size of each plot in studs
    PLOTS_PER_ROW = 5,          -- Number of plots per row
    SPACING = 20,               -- Spacing between plots
    PLANET_HEIGHT = 20,         -- Height of planet above plot
}

-- UI Settings
Constants.UI = {
    UPDATE_INTERVAL = 0.5,      -- Update UI every 0.5 seconds
    NOTIFICATION_DURATION = 3,  -- Notifications last 3 seconds
    
    -- Planet UI Frame Settings
    PLANET_UI = {
        MAIN_FRAME_SIZE = UDim2.new(0, 220, 0, 270), -- Adjusted to fit nav buttons
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
        
        -- Removed old XP_BUTTON settings (replaced with nav buttons)
        
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
        
        -- Navigation Buttons (image buttons - vertical layout on right side)
        NAV_BUTTONS = {
            BUTTON_SIZE = UDim2.new(0, 50, 0, 50),
            BUTTON_SPACING = 30, -- Vertical spacing between buttons (increased for no overlap)
            RIGHT_OFFSET = 10, -- Distance from right edge
            START_Y = 10, -- Starting Y position from top
            
            -- Button definitions with Roblox asset IDs
            BUTTONS = {
                {name = "Stars", assetId = "rbxassetid://109076471250268", tooltip = "Star Map", action = "starmap"},
                {name = "Galaxy", assetId = "rbxassetid://90313785520046", tooltip = "Solar System", action = "solarsystem"},
                {name = "Shop", assetId = "rbxassetid://140353244803526", tooltip = "Shop", action = "shop"},
                {name = "Settings", assetId = "rbxassetid://80743411284468", tooltip = "Settings", action = "settings"},
            },
        },
    },
}

-- Space Combat Settings
Constants.SPACE_COMBAT = {
    -- Asteroid Settings
    ASTEROID_SPAWN_RADIUS = 200,        -- How far from spawn center to spawn asteroids
    ASTEROID_MIN_DISTANCE = 50,         -- Minimum distance from player
    ASTEROID_MAX_COUNT = 20,            -- Max asteroids in world at once
    ASTEROID_SPAWN_INTERVAL = 2,        -- Seconds between spawn attempts
    ASTEROID_SIZES = {
        SMALL = { size = 5, health = 30, resources = 10 },
        MEDIUM = { size = 10, health = 100, resources = 50 },
        LARGE = { size = 20, health = 300, resources = 150 },
    },
    
    -- Ship Settings
    SHIP_SPEED = 35,                    -- Ship movement speed (reduced for better control)
    SHIP_ROTATION_SPEED = 2,            -- Ship rotation speed
    SHIP_MAX_HEALTH = 100,              -- Starting ship health
    SHIP_RESPAWN_TIME = 5,              -- Seconds to respawn after death
    
    -- Weapon Settings
    WEAPON_DAMAGE = 10,                 -- Base weapon damage
    WEAPON_COOLDOWN = 0.5,              -- Seconds between shots
    WEAPON_RANGE = 200,                 -- Max weapon range
    PROJECTILE_SPEED = 100,             -- Projectile travel speed
    
    -- Resource Drops
    PLANET_ESSENCE_PER_ASTEROID = 5,    -- Base essence dropped
    BIOME_ENERGY_PER_ASTEROID = 2,      -- Base energy dropped
    DROP_PICKUP_RADIUS = 10,            -- How close to auto-collect
    
    -- Territory Settings
    STARTING_TERRITORY_RADIUS = 50,     -- Initial territory size
    TERRITORY_EXPANSION_RATE = 1,       -- Radius increase per asteroid destroyed
    MAX_TERRITORY_RADIUS = 500,         -- Maximum territory size
}

-- Space Arena Settings (Black Hole + Player Stations)
Constants.SPACE_ARENA = {
    -- Black Hole Settings
    BLACK_HOLE_POSITION = Vector3.new(0, 100, 0),   -- Center of arena
    BLACK_HOLE_SIZE = 80,                            -- Diameter of black hole
    
    -- Player Station Settings
    ARENA_RADIUS = 300,                  -- Distance from black hole to stations
    MAX_PLAYER_STATIONS = 8,             -- Max players in arena
    STATION_ZONE_RADIUS = 60,            -- Size of each player's zone
    STATION_Y_VARIATION = 30,            -- Height variation between stations
    
    -- Station Upgrades
    STARTING_STATION_SIZE = 20,          -- Initial station core size
    MAX_STATION_MODULES = 12,            -- Max modules per station
    
    -- Spawn Settings
    STATION_SPAWN_OFFSET = Vector3.new(0, 0, 30), -- Where player spawns relative to station
}

-- Space Station Settings (Station Building & Upgrades)
Constants.SPACE_STATION = {
    -- Core Station Settings
    STARTING_STATION_SIZE = 20,          -- Initial core size
    MAX_STATION_MODULES = 12,            -- Maximum module slots
    STARTING_CAPACITY = 1000,            -- Starting resource storage
    
    -- Station Upgrade Costs (by level)
    UPGRADE_COSTS = {
        [2] = {planetEssence = 500},
        [3] = {planetEssence = 1000},
        [4] = {planetEssence = 2000},
        [5] = {planetEssence = 4000},
        [6] = {planetEssence = 8000},
        [7] = {planetEssence = 16000},
        [8] = {planetEssence = 32000},
        [9] = {planetEssence = 64000},
        [10] = {planetEssence = 128000},
    },
    
    -- Module Types
    MODULE_TYPES = {
        STORAGE = {
            name = "Storage Bay",
            cost = 250,
            color = Color3.fromRGB(100, 100, 100),
            effect = "Increases resource capacity by 50%",
        },
        DEFENSE = {
            name = "Defense Turret",
            cost = 500,
            color = Color3.fromRGB(200, 50, 50),
            effect = "Auto-attacks nearby threats",
        },
        MINING = {
            name = "Mining Laser",
            cost = 750,
            color = Color3.fromRGB(255, 200, 0),
            effect = "Passively generates resources",
        },
        SHIELD = {
            name = "Shield Generator",
            cost = 1000,
            color = Color3.fromRGB(0, 150, 255),
            effect = "Protects station from damage",
        },
        HANGAR = {
            name = "Hangar Bay",
            cost = 1500,
            color = Color3.fromRGB(150, 150, 255),
            effect = "Unlocks ship upgrades",
        },
    },
}

return Constants
