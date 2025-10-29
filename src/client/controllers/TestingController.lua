--[[
    ⚠️ TESTING CONTROLLER - DELETE BEFORE PRODUCTION ⚠️
    
    TestingController.lua
    Client-side testing UI with debug buttons
    
    Provides quick access to testing commands:
    - Add Resources (+1000 each)
    - Add Levels (+5 levels)
    - Unlock All Planets
    - Buy All Upgrades
    - Force Rebirth Ready (95% completion)
    - Add Stars (+50 stars)
    
    🔴 REMOVE THIS FILE BEFORE FINAL RELEASE 🔴
]]

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local TestingController = Knit.CreateController {
    Name = "TestingController",
    
    -- UI Elements
    _testingGui = nil,
    _testPanel = nil,
}

function TestingController:KnitInit()
    print("[TestingController] ⚠️ TESTING MODE ACTIVE ⚠️")
end

function TestingController:KnitStart()
    print("[TestingController] Starting...")
    
    -- Get services
    self._testingService = Knit.GetService("TestingService")
    self._planetController = Knit.GetController("PlanetController")
    self._solarSystemController = Knit.GetController("SolarSystemController")
    
    -- Create testing UI
    self:_createTestingUI()
    
    print("[TestingController] Started - Press T to toggle debug panel")
end

--[[ UI Creation ]]--

function TestingController:_createTestingUI()
    -- Create ScreenGui
    self._testingGui = Instance.new("ScreenGui")
    self._testingGui.Name = "TestingUI"
    self._testingGui.ResetOnSpawn = false
    self._testingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self._testingGui.Parent = playerGui
    
    -- Test panel (left side, much smaller)
    self._testPanel = Instance.new("Frame")
    self._testPanel.Name = "TestPanel"
    self._testPanel.Size = UDim2.new(0, 200, 0, 350) -- Reduced from 250x500
    self._testPanel.Position = UDim2.new(0, 10, 0.5, -175)
    self._testPanel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    self._testPanel.BackgroundTransparency = 0.2 -- More transparent
    self._testPanel.BorderSizePixel = 0
    self._testPanel.Visible = false -- Start HIDDEN - press T to show
    self._testPanel.Parent = self._testingGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = self._testPanel
    
    -- Title (smaller)
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 30) -- Reduced from 40
    title.Position = UDim2.new(0, 10, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "⚠️ DEBUG ⚠️"
    title.TextColor3 = Color3.fromRGB(241, 196, 15) -- Gold
    title.TextSize = 14 -- Reduced from 18
    title.Font = Enum.Font.GothamBold
    title.Parent = self._testPanel
    
    -- Instructions (smaller)
    local instructions = Instance.new("TextLabel")
    instructions.Size = UDim2.new(1, -20, 0, 20) -- Reduced from 30
    instructions.Position = UDim2.new(0, 10, 0, 35)
    instructions.BackgroundTransparency = 1
    instructions.Text = "Press 'T' to toggle"
    instructions.TextColor3 = Color3.fromRGB(189, 195, 199)
    instructions.TextSize = 10 -- Reduced from 12
    instructions.Font = Enum.Font.Gotham
    instructions.Parent = self._testPanel
    
    -- Button container (smaller)
    local buttonContainer = Instance.new("ScrollingFrame")
    buttonContainer.Name = "ButtonContainer"
    buttonContainer.Size = UDim2.new(1, -20, 1, -65) -- Adjusted for smaller header
    buttonContainer.Position = UDim2.new(0, 10, 0, 55)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.BorderSizePixel = 0
    buttonContainer.ScrollBarThickness = 4 -- Thinner scrollbar
    buttonContainer.Parent = self._testPanel
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = buttonContainer
    
    -- Create debug buttons
    self:_createDebugButton(buttonContainer, "💰 Add Resources (+1000)", function()
        self:_addResources()
    end, 1)
    
    self:_createDebugButton(buttonContainer, "📈 Add Levels (+5)", function()
        self:_addLevels()
    end, 2)
    
    self:_createDebugButton(buttonContainer, "🌍 Unlock All Planets", function()
        self:_unlockAllPlanets()
    end, 3)
    
    self:_createDebugButton(buttonContainer, "🛒 Buy All Upgrades", function()
        self:_buyAllUpgrades()
    end, 4)
    
    self:_createDebugButton(buttonContainer, "⭐ Force Rebirth Ready", function()
        self:_forceRebirthReady()
    end, 5)
    
    self:_createDebugButton(buttonContainer, "🌟 Add Stars (+50)", function()
        self:_addStars()
    end, 6)
    
    self:_createDebugButton(buttonContainer, "� Hatch Random Pet", function()
        self:_hatchRandomPet()
    end, 7)
    
    self:_createDebugButton(buttonContainer, "�🔄 Refresh All UI", function()
        self:_refreshAllUI()
    end, 8)
    
    -- Update canvas size
    buttonContainer.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    
    -- Toggle with T key
    local UserInputService = game:GetService("UserInputService")
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.T then
            self._testPanel.Visible = not self._testPanel.Visible
            print("[TestingController] Testing panel toggled to:", self._testPanel.Visible)
        end
    end)
    
    print("[TestingController] Debug panel created - Press T to toggle")
end

function TestingController:_createDebugButton(parent, text: string, callback, order: number)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 38) -- Reduced from 50
    button.BackgroundColor3 = Color3.fromRGB(52, 73, 94)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 12 -- Reduced from 14
    button.Font = Enum.Font.GothamBold
    button.LayoutOrder = order
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    -- Hover effect
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(52, 73, 94)
    end)
    
    button.MouseButton1Click:Connect(callback)
    
    return button
end

--[[ Testing Commands ]]--

function TestingController:_addResources()
    print("[TestingController] Adding resources...")
    
    self._testingService:AddResources(1000):andThen(function(success)
        if success then
            print("[TestingController] ✅ Added 1000 of each resource")
            self:_refreshAllUI()
        end
    end):catch(function(err)
        warn("[TestingController] ❌ Failed to add resources:", err)
    end)
end

function TestingController:_addLevels()
    print("[TestingController] Adding levels...")
    
    self._testingService:AddLevel(5):andThen(function(success)
        if success then
            print("[TestingController] ✅ Added 5 levels")
            self:_refreshAllUI()
        end
    end):catch(function(err)
        warn("[TestingController] ❌ Failed to add levels:", err)
    end)
end

function TestingController:_unlockAllPlanets()
    print("[TestingController] Unlocking all planets...")
    
    self._testingService:UnlockAllPlanets():andThen(function(success)
        if success then
            print("[TestingController] ✅ Unlocked all planets")
            self:_refreshAllUI()
        end
    end):catch(function(err)
        warn("[TestingController] ❌ Failed to unlock planets:", err)
    end)
end

function TestingController:_buyAllUpgrades()
    print("[TestingController] Buying all upgrades...")
    
    self._testingService:BuyAllUpgrades():andThen(function(success)
        if success then
            print("[TestingController] ✅ Maxed all upgrades")
            self:_refreshAllUI()
        end
    end):catch(function(err)
        warn("[TestingController] ❌ Failed to buy upgrades:", err)
    end)
end

function TestingController:_forceRebirthReady()
    print("[TestingController] Setting rebirth eligibility...")
    
    self._testingService:ForceRebirthEligibility():andThen(function(success)
        if success then
            print("[TestingController] ✅ Set to ~95% completion - Rebirth button should appear!")
            self:_refreshAllUI()
        end
    end):catch(function(err)
        warn("[TestingController] ❌ Failed to force rebirth:", err)
    end)
end

function TestingController:_addStars()
    print("[TestingController] Adding stars...")
    
    self._testingService:AddStars(50):andThen(function(success)
        if success then
            print("[TestingController] ✅ Added 50 stars")
            self:_refreshAllUI()
        end
    end):catch(function(err)
        warn("[TestingController] ❌ Failed to add stars:", err)
    end)
end

function TestingController:_hatchRandomPet()
    print("[TestingController] Hatching random pet...")
    
    -- Get PetService
    local PetService = Knit.GetService("PetService")
    if not PetService then
        warn("[TestingController] ❌ PetService not found")
        return
    end
    
    -- Random pet types
    local petTypes = {"space_dragon", "star_whale", "star_whale", "nebula_fox", "water_wisp", "flame_spirit"}
    local randomPet = petTypes[math.random(1, #petTypes)]
    
    -- Call service (Knit returns a Promise)
    PetService:HatchPet(randomPet):andThen(function(success, pet)
        if success and pet then
            print("[TestingController] ✅ Hatched:", pet.name, "(" .. pet.rarity .. ")")
        else
            warn("[TestingController] ❌ Failed to hatch pet:", tostring(pet))
        end
    end):catch(function(err)
        warn("[TestingController] ❌ Error hatching pet:", err)
    end)
end

function TestingController:_refreshAllUI()
    -- Refresh planet UI
    if self._planetController and self._planetController.refreshPlanetState then
        task.wait(0.2) -- Wait for server to process
        self._planetController:refreshPlanetState()
    end
    
    -- Refresh solar system UI
    if self._solarSystemController and self._solarSystemController._loadSolarSystem then
        task.wait(0.1)
        self._solarSystemController:_loadSolarSystem()
    end
    
    print("[TestingController] ✅ Refreshed all UI")
end

return TestingController
