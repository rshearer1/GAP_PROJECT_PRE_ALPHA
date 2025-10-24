-- Client entry point
-- Initializes Knit framework and starts all controllers

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

print("[Client] Loading Knit controllers...")
print("[Client] Script location:", script:GetFullName())

-- The controllers folder is a sibling in StarterPlayerScripts
local controllersFolder = script.Parent:FindFirstChild("controllers")
print("[Client] Controllers folder:", controllersFolder)

if controllersFolder then
    local children = controllersFolder:GetChildren()
    print("[Client] Found", #children, "modules in controllers folder")
    
    for _, module in ipairs(children) do
        if module:IsA("ModuleScript") then
            print("[Client] Loading controller:", module.Name)
            local success, err = pcall(function()
                require(module)
            end)
            if success then
                print("[Client] ✓ Loaded controller:", module.Name)
            else
                warn("[Client] ✗ Failed to load controller:", module.Name, err)
            end
        end
    end
else
    warn("[Client] ⚠️ Controllers folder not found!")
    warn("[Client] script.Parent children:")
    for _, child in ipairs(script.Parent:GetChildren()) do
        warn("  -", child.Name, child.ClassName)
    end
end

-- Start Knit
print("[Client] Starting Knit...")
Knit.Start():andThen(function()
    print("[Client] Knit started successfully!")
end):catch(function(err)
    warn("[Client] Knit failed to start:", err)
end)
