-- Server entry point
-- Initializes Knit framework and starts all services

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

print("[Server] Loading Knit services...")
print("[Server] Script location:", script:GetFullName())

-- The services folder is a sibling in ServerScriptService
local servicesFolder = script.Parent:FindFirstChild("services")
print("[Server] Services folder:", servicesFolder)

if servicesFolder then
    local children = servicesFolder:GetChildren()
    print("[Server] Found", #children, "modules in services folder")
    
    for _, module in ipairs(children) do
        if module:IsA("ModuleScript") then
            print("[Server] Loading service:", module.Name)
            local success, err = pcall(function()
                require(module)
            end)
            if success then
                print("[Server] ✓ Loaded service:", module.Name)
            else
                warn("[Server] ✗ Failed to load service:", module.Name, err)
            end
        end
    end
else
    warn("[Server] ⚠️ Services folder not found!")
    warn("[Server] script.Parent children:")
    for _, child in ipairs(script.Parent:GetChildren()) do
        warn("  -", child.Name, child.ClassName)
    end
end

-- Start Knit
print("[Server] Starting Knit...")
Knit.Start():andThen(function()
    print("[Server] Knit started successfully!")
    
    -- Set up player join/leave handling
    local Players = game:GetService("Players")
    local DataService = Knit.GetService("DataService")
    local PlanetService = Knit.GetService("PlanetService")
    local SolarSystemService = Knit.GetService("SolarSystemService")
    
    ---
    -- Handle player joining
    --
    local function onPlayerAdded(player)
        print("[Server] Player joined:", player.Name)
        
        -- Load player data (ProfileService handles session-locking)
        local data = DataService:LoadPlayerData(player)
        
        if data then
            -- Initialize planet if needed
            if not data.planet or data.planet.level == 0 then
                print("[Server] Initializing new planet for", player.Name)
                PlanetService:CreatePlanet(player.UserId)
            end
            
            -- Initialize solar system if needed
            if not data.solarSystem then
                print("[Server] Initializing solar system for", player.Name)
                SolarSystemService:CreateSolarSystem(player.UserId)
            end
            
            print("[Server] Player setup complete:", player.Name)
        else
            warn("[Server] Failed to load data for", player.Name)
        end
    end
    
    ---
    -- Handle player leaving
    --
    local function onPlayerRemoving(player)
        print("[Server] Player leaving:", player.Name)
        
        -- Release profile (saves and unlocks session)
        DataService:UnloadPlayerData(player)
    end
    
    -- Connect event handlers
    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(onPlayerRemoving)
    
    -- Handle players who joined before this script ran
    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(onPlayerAdded, player)
    end
    
    print("[Server] Player management initialized")
    
end):catch(function(err)
    warn("[Server] Knit failed to start:", err)
end)
