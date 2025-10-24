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
end):catch(function(err)
    warn("[Server] Knit failed to start:", err)
end)
