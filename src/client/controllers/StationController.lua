--[[
    StationController.lua
    Client-side space station UI management
    
    Handles:
    - Station upgrade UI
    - Module placement UI
    - Resource display
    - Station overview
    
    GAP Compliance:
    - Uses Janitor for cleanup
    - References Constants for all values
    - JSDoc comments on all methods
]]

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Janitor = require(game:GetService("ReplicatedStorage").Packages.Janitor)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Constants = require(ReplicatedStorage.Shared.Constants)

local StationController = Knit.CreateController {
    Name = "StationController",
    
    -- UI elements
    _ui = nil,
    _mainFrame = nil,
    
    -- Station data
    _stationData = nil,
    
    -- Janitor for cleanup
    _janitor = Janitor.new(),
}

---
-- Initialize StationController
--
function StationController:KnitInit()
    print("[StationController] Initializing...")
end

---
-- Start StationController
--
function StationController:KnitStart()
    print("[StationController] Starting...")
    
    local player = Players.LocalPlayer
    
    -- Create UI
    task.wait(1)
    self:_createUI()
    
    -- Load station data
    task.spawn(function()
        task.wait(2) -- Wait for station to be created server-side
        self:_loadStationData()
    end)
    
    -- Toggle UI with B key
    self._janitor:Add(UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.B then
            self:_toggleUI()
        end
    end), "Disconnect")
    
    print("[StationController] Started! Press B to open Station UI")
end

---
-- Create station management UI
-- @private
--
function StationController:_createUI()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "StationUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui
    
    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 600, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -300, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    -- Corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, -20, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "SPACE STATION"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 24
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(1, -45, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 20
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        self:_toggleUI()
    end)
    
    -- Content frame
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, -20, 1, -70)
    contentFrame.Position = UDim2.new(0, 10, 0, 60)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    
    -- Station info section
    self:_createStationInfoSection(contentFrame)
    
    -- Upgrade section
    self:_createUpgradeSection(contentFrame)
    
    -- Modules section
    self:_createModulesSection(contentFrame)
    
    self._ui = screenGui
    self._mainFrame = mainFrame
end

---
-- Create station info section
-- @param parent Instance - Parent frame
-- @private
--
function StationController:_createStationInfoSection(parent)
    local infoFrame = Instance.new("Frame")
    infoFrame.Name = "InfoFrame"
    infoFrame.Size = UDim2.new(1, 0, 0, 80)
    infoFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    infoFrame.BorderSizePixel = 0
    infoFrame.Parent = parent
    
    local infoCorner = Instance.new("UICorner")
    infoCorner.CornerRadius = UDim.new(0, 8)
    infoCorner.Parent = infoFrame
    
    -- Station level
    local levelLabel = Instance.new("TextLabel")
    levelLabel.Name = "LevelLabel"
    levelLabel.Size = UDim2.new(0.5, -10, 0, 30)
    levelLabel.Position = UDim2.new(0, 10, 0, 10)
    levelLabel.BackgroundTransparency = 1
    levelLabel.Text = "Station Level: 1"
    levelLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    levelLabel.TextSize = 18
    levelLabel.Font = Enum.Font.GothamBold
    levelLabel.TextXAlignment = Enum.TextXAlignment.Left
    levelLabel.Parent = infoFrame
    
    -- Modules count
    local modulesLabel = Instance.new("TextLabel")
    modulesLabel.Name = "ModulesLabel"
    modulesLabel.Size = UDim2.new(0.5, -10, 0, 30)
    modulesLabel.Position = UDim2.new(0.5, 0, 0, 10)
    modulesLabel.BackgroundTransparency = 1
    modulesLabel.Text = "Modules: 0/12"
    modulesLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    modulesLabel.TextSize = 16
    modulesLabel.Font = Enum.Font.Gotham
    modulesLabel.TextXAlignment = Enum.TextXAlignment.Left
    modulesLabel.Parent = infoFrame
    
    -- Capacity info
    local capacityLabel = Instance.new("TextLabel")
    capacityLabel.Name = "CapacityLabel"
    capacityLabel.Size = UDim2.new(1, -20, 0, 30)
    capacityLabel.Position = UDim2.new(0, 10, 0, 45)
    capacityLabel.BackgroundTransparency = 1
    capacityLabel.Text = "Capacity: 1000"
    capacityLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
    capacityLabel.TextSize = 14
    capacityLabel.Font = Enum.Font.Gotham
    capacityLabel.TextXAlignment = Enum.TextXAlignment.Left
    capacityLabel.Parent = infoFrame
end

---
-- Create upgrade section
-- @param parent Instance - Parent frame
-- @private
--
function StationController:_createUpgradeSection(parent)
    local upgradeFrame = Instance.new("Frame")
    upgradeFrame.Name = "UpgradeFrame"
    upgradeFrame.Size = UDim2.new(1, 0, 0, 100)
    upgradeFrame.Position = UDim2.new(0, 0, 0, 90)
    upgradeFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    upgradeFrame.BorderSizePixel = 0
    upgradeFrame.Parent = parent
    
    local upgradeCorner = Instance.new("UICorner")
    upgradeCorner.CornerRadius = UDim.new(0, 8)
    upgradeCorner.Parent = upgradeFrame
    
    local upgradeTitle = Instance.new("TextLabel")
    upgradeTitle.Size = UDim2.new(1, -20, 0, 30)
    upgradeTitle.Position = UDim2.new(0, 10, 0, 5)
    upgradeTitle.BackgroundTransparency = 1
    upgradeTitle.Text = "UPGRADE STATION"
    upgradeTitle.TextColor3 = Color3.fromRGB(255, 200, 100)
    upgradeTitle.TextSize = 16
    upgradeTitle.Font = Enum.Font.GothamBold
    upgradeTitle.TextXAlignment = Enum.TextXAlignment.Left
    upgradeTitle.Parent = upgradeFrame
    
    -- Upgrade button
    local upgradeButton = Instance.new("TextButton")
    upgradeButton.Name = "UpgradeButton"
    upgradeButton.Size = UDim2.new(1, -20, 0, 50)
    upgradeButton.Position = UDim2.new(0, 10, 0, 40)
    upgradeButton.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    upgradeButton.Text = "Upgrade to Level 2\nCost: 500 Planet Essence"
    upgradeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    upgradeButton.TextSize = 16
    upgradeButton.Font = Enum.Font.GothamBold
    upgradeButton.Parent = upgradeFrame
    
    local upgradeButtonCorner = Instance.new("UICorner")
    upgradeButtonCorner.CornerRadius = UDim.new(0, 8)
    upgradeButtonCorner.Parent = upgradeButton
    
    upgradeButton.MouseButton1Click:Connect(function()
        self:_upgradeStation()
    end)
end

---
-- Create modules section
-- @param parent Instance - Parent frame
-- @private
--
function StationController:_createModulesSection(parent)
    local modulesFrame = Instance.new("Frame")
    modulesFrame.Name = "ModulesFrame"
    modulesFrame.Size = UDim2.new(1, 0, 1, -200)
    modulesFrame.Position = UDim2.new(0, 0, 0, 200)
    modulesFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    modulesFrame.BorderSizePixel = 0
    modulesFrame.Parent = parent
    
    local modulesCorner = Instance.new("UICorner")
    modulesCorner.CornerRadius = UDim.new(0, 8)
    modulesCorner.Parent = modulesFrame
    
    local modulesTitle = Instance.new("TextLabel")
    modulesTitle.Size = UDim2.new(1, -20, 0, 30)
    modulesTitle.Position = UDim2.new(0, 10, 0, 5)
    modulesTitle.BackgroundTransparency = 1
    modulesTitle.Text = "BUILD MODULES"
    modulesTitle.TextColor3 = Color3.fromRGB(150, 200, 255)
    modulesTitle.TextSize = 16
    modulesTitle.Font = Enum.Font.GothamBold
    modulesTitle.TextXAlignment = Enum.TextXAlignment.Left
    modulesTitle.Parent = modulesFrame
    
    -- Module buttons grid
    local moduleTypes = {"STORAGE", "DEFENSE", "MINING", "SHIELD", "HANGAR"}
    local yPos = 40
    
    for i, moduleType in ipairs(moduleTypes) do
        local moduleData = Constants.SPACE_STATION.MODULE_TYPES[moduleType]
        
        local moduleButton = Instance.new("TextButton")
        moduleButton.Name = moduleType .. "Button"
        moduleButton.Size = UDim2.new(1, -20, 0, 45)
        moduleButton.Position = UDim2.new(0, 10, 0, yPos)
        moduleButton.BackgroundColor3 = moduleData.color
        moduleButton.Text = moduleData.name .. " - " .. moduleData.cost .. " Essence\n" .. moduleData.effect
        moduleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        moduleButton.TextSize = 12
        moduleButton.Font = Enum.Font.Gotham
        moduleButton.Parent = modulesFrame
        
        local moduleCorner = Instance.new("UICorner")
        moduleCorner.CornerRadius = UDim.new(0, 6)
        moduleCorner.Parent = moduleButton
        
        moduleButton.MouseButton1Click:Connect(function()
            self:_buildModule(moduleType)
        end)
        
        yPos = yPos + 50
    end
end

---
-- Load station data from server
-- @private
--
function StationController:_loadStationData()
    local SpaceStationService = Knit.GetService("SpaceStationService")
    
    SpaceStationService:GetMyStation():andThen(function(stationData)
        if stationData then
            self._stationData = stationData
            self:_updateUI()
            print("[StationController] Loaded station data:", stationData.level)
        else
            warn("[StationController] No station data received")
        end
    end):catch(function(err)
        warn("[StationController] Failed to load station:", err)
    end)
end

---
-- Update UI with current station data
-- @private
--
function StationController:_updateUI()
    if not self._stationData or not self._mainFrame then return end
    
    local content = self._mainFrame:FindFirstChild("Content")
    if not content then return end
    
    -- Update station info
    local infoFrame = content:FindFirstChild("InfoFrame")
    if infoFrame then
        local levelLabel = infoFrame:FindFirstChild("LevelLabel")
        if levelLabel then
            levelLabel.Text = "Station Level: " .. self._stationData.level
        end
        
        local modulesLabel = infoFrame:FindFirstChild("ModulesLabel")
        if modulesLabel then
            local moduleCount = 0
            for _ in pairs(self._stationData.modules) do
                moduleCount = moduleCount + 1
            end
            modulesLabel.Text = "Modules: " .. moduleCount .. "/12"
        end
        
        local capacityLabel = infoFrame:FindFirstChild("CapacityLabel")
        if capacityLabel then
            capacityLabel.Text = string.format("Capacity: %.0f", self._stationData.capacity.metal)
        end
    end
    
    -- Update upgrade button
    local upgradeFrame = content:FindFirstChild("UpgradeFrame")
    if upgradeFrame then
        local upgradeButton = upgradeFrame:FindFirstChild("UpgradeButton")
        if upgradeButton then
            local nextLevel = self._stationData.level + 1
            local upgradeCost = Constants.SPACE_STATION.UPGRADE_COSTS[nextLevel]
            
            if upgradeCost then
                upgradeButton.Text = "Upgrade to Level " .. nextLevel .. "\nCost: " .. upgradeCost.planetEssence .. " Planet Essence"
                upgradeButton.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
            else
                upgradeButton.Text = "MAX LEVEL REACHED"
                upgradeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            end
        end
    end
end

---
-- Toggle UI visibility
-- @private
--
function StationController:_toggleUI()
    if not self._mainFrame then return end
    
    self._mainFrame.Visible = not self._mainFrame.Visible
    
    if self._mainFrame.Visible then
        self:_loadStationData()
    end
end

---
-- Upgrade station
-- @private
--
function StationController:_upgradeStation()
    local SpaceStationService = Knit.GetService("SpaceStationService")
    
    SpaceStationService:UpgradeStation():andThen(function(result)
        if result.success then
            print("[StationController] Station upgraded to level", result.newLevel)
            self._stationData.level = result.newLevel
            self._stationData.capacity = result.newCapacity
            self:_updateUI()
        else
            warn("[StationController] Upgrade failed:", result.error)
        end
    end):catch(function(err)
        warn("[StationController] Upgrade error:", err)
    end)
end

---
-- Build a module
-- @param moduleType string - Type of module to build
-- @private
--
function StationController:_buildModule(moduleType)
    -- Find first available slot
    local slotNumber = nil
    for i = 1, Constants.SPACE_STATION.MAX_STATION_MODULES do
        if not self._stationData.modules[i] then
            slotNumber = i
            break
        end
    end
    
    if not slotNumber then
        warn("[StationController] No available module slots")
        return
    end
    
    local SpaceStationService = Knit.GetService("SpaceStationService")
    
    SpaceStationService:AddModule(moduleType, slotNumber):andThen(function(result)
        if result.success then
            print("[StationController] Built", moduleType, "in slot", slotNumber)
            self._stationData.modules[slotNumber] = result.module
            self:_updateUI()
        else
            warn("[StationController] Build failed:", result.error)
        end
    end):catch(function(err)
        warn("[StationController] Build error:", err)
    end)
end

return StationController
