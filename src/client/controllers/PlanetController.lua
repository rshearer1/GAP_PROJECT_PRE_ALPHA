--[[
    PlanetController.lua
    Client-side planet UI and interaction controller
    
    Responsibilities:
    - Display planet state and resources
    - Update UI in real-time
    - Handle player interactions with planet
    - Communicate with PlanetService
    
    GAP Compliance:
    - Uses Janitor for cleanup
    - References Constants.UI.PLANET_UI for all UI values
    - JSDoc comments on all public methods
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Types = require(ReplicatedStorage.Shared.Types)
local Constants = require(ReplicatedStorage.Shared.Constants)

local PlanetController = Knit.CreateController({
    Name = "PlanetController",
})

-- Local state
PlanetController._planetState = nil
PlanetController._ui = nil
PlanetController._janitor = Janitor.new()

--[[ Controller Lifecycle ]]--

---
-- Initialize PlanetController
--
---
-- Initialize PlanetController
--
function PlanetController:KnitInit()
    print("[PlanetController] Initializing...")
end

---
-- Start PlanetController
-- Fetches initial planet state and creates UI
--
function PlanetController:KnitStart()
    print("[PlanetController] Starting...")
    
    -- Get PlanetService
    local PlanetService = Knit.GetService("PlanetService")
    
    -- Fetch initial planet state
    PlanetService:GetPlanetState():andThen(function(planetState)
        print("[PlanetController] Received planet state")
        self._planetState = planetState
        
        -- Create UI
        self:_createUI()
        
        -- Start update loop
        self:_startUpdateLoop(PlanetService)
    end):catch(function(err)
        warn("[PlanetController] Failed to get planet state:", err)
    end)
    
    print("[PlanetController] Started successfully!")
end

--[[ Private Methods ]]--

---
-- Start the UI update loop
-- Uses Janitor to manage the update task
-- @param PlanetService table - The PlanetService to fetch state from
--
function PlanetController:_startUpdateLoop(PlanetService)
    -- Update UI periodically (managed by Janitor)
    local updateThread = task.spawn(function()
        while true do
            task.wait(Constants.UI.UPDATE_INTERVAL)
            
            -- Refresh planet state from server
            PlanetService:GetPlanetState():andThen(function(planetState)
                if planetState then
                    self._planetState = planetState
                    self:_updateUI()
                end
            end):catch(function(err)
                warn("[PlanetController] Update failed:", err)
            end)
        end
    end)
    
    self._janitor:Add(function()
        task.cancel(updateThread)
    end, true)
end

---
-- Create the Planet UI
-- All values sourced from Constants.UI.PLANET_UI
--
function PlanetController:_createUI()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    local UI = Constants.UI.PLANET_UI
    
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PlanetUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui
    
    -- Add ScreenGui to Janitor for cleanup
    self._janitor:Add(screenGui)
    
    -- Create main container
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UI.MAIN_FRAME_SIZE
    mainFrame.Position = UI.MAIN_FRAME_POSITION
    mainFrame.BackgroundColor3 = UI.MAIN_FRAME_BG_COLOR
    mainFrame.BackgroundTransparency = UI.MAIN_FRAME_TRANSPARENCY
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Add corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UI.CORNER_RADIUS
    corner.Parent = mainFrame
    
    -- Add padding
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UI.PADDING
    padding.PaddingRight = UI.PADDING
    padding.PaddingTop = UI.PADDING
    padding.PaddingBottom = UI.PADDING
    padding.Parent = mainFrame
    
    -- Minimize/Maximize button
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "MinimizeButton"
    minimizeBtn.Size = UI.MINIMIZE_BTN_SIZE
    minimizeBtn.Position = UI.MINIMIZE_BTN_POS
    minimizeBtn.BackgroundColor3 = UI.MINIMIZE_BTN_COLOR
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
    minimizeBtn.TextSize = 20
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = mainFrame
    
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 4)
    minCorner.Parent = minimizeBtn
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UI.TITLE_SIZE
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = UI.TITLE_TEXT
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = UI.TITLE_TEXT_SIZE
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = mainFrame
    
    -- Content frame (everything except title)
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, 0, 1, -35)
    contentFrame.Position = UDim2.new(0, 0, 0, 35)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    
    -- Planet Info Frame
    local infoFrame = Instance.new("Frame")
    infoFrame.Name = "InfoFrame"
    infoFrame.Size = UI.INFO_FRAME_SIZE
    infoFrame.Position = UDim2.new(0, 0, 0, 0)
    infoFrame.BackgroundColor3 = UI.INFO_FRAME_COLOR
    infoFrame.BorderSizePixel = 0
    infoFrame.Parent = contentFrame
    
    local infoCorner = Instance.new("UICorner")
    infoCorner.CornerRadius = UDim.new(0, 6)
    infoCorner.Parent = infoFrame
    
    local infoPadding = Instance.new("UIPadding")
    infoPadding.PaddingLeft = UDim.new(0, 8)
    infoPadding.PaddingRight = UDim.new(0, 8)
    infoPadding.PaddingTop = UDim.new(0, 6)
    infoPadding.PaddingBottom = UDim.new(0, 6)
    infoPadding.Parent = infoFrame
    
    -- Level label
    local levelLabel = Instance.new("TextLabel")
    levelLabel.Name = "LevelLabel"
    levelLabel.Size = UDim2.new(1, 0, 0, 16)
    levelLabel.Position = UDim2.new(0, 0, 0, 0)
    levelLabel.BackgroundTransparency = 1
    levelLabel.Text = "Level 1"
    levelLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    levelLabel.TextSize = UI.LEVEL_TEXT_SIZE
    levelLabel.Font = Enum.Font.GothamBold
    levelLabel.TextXAlignment = Enum.TextXAlignment.Left
    levelLabel.Parent = infoFrame
    
    -- Biome label
    local biomeLabel = Instance.new("TextLabel")
    biomeLabel.Name = "BiomeLabel"
    biomeLabel.Size = UDim2.new(1, 0, 0, 16)
    biomeLabel.Position = UDim2.new(0, 0, 0, 18)
    biomeLabel.BackgroundTransparency = 1
    biomeLabel.Text = "Biome: Barren"
    biomeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    biomeLabel.TextSize = UI.BIOME_TEXT_SIZE
    biomeLabel.Font = Enum.Font.Gotham
    biomeLabel.TextXAlignment = Enum.TextXAlignment.Left
    biomeLabel.Parent = infoFrame
    
    -- XP Progress label
    local xpLabel = Instance.new("TextLabel")
    xpLabel.Name = "XPLabel"
    xpLabel.Size = UDim2.new(1, 0, 0, 14)
    xpLabel.Position = UDim2.new(0, 0, 0, 36)
    xpLabel.BackgroundTransparency = 1
    xpLabel.Text = "XP: 0 / 100"
    xpLabel.TextColor3 = Color3.fromRGB(150, 150, 255)
    xpLabel.TextSize = UI.XP_TEXT_SIZE
    xpLabel.Font = Enum.Font.Gotham
    xpLabel.TextXAlignment = Enum.TextXAlignment.Left
    xpLabel.Parent = infoFrame
    
    -- Resources Frame
    local resourcesFrame = Instance.new("Frame")
    resourcesFrame.Name = "ResourcesFrame"
    resourcesFrame.Size = UI.RESOURCES_FRAME_SIZE
    resourcesFrame.Position = UI.RESOURCES_FRAME_POS
    resourcesFrame.BackgroundColor3 = UI.INFO_FRAME_COLOR
    resourcesFrame.BorderSizePixel = 0
    resourcesFrame.Parent = contentFrame
    
    local resourcesCorner = Instance.new("UICorner")
    resourcesCorner.CornerRadius = UDim.new(0, 6)
    resourcesCorner.Parent = resourcesFrame
    
    local resourcesPadding = Instance.new("UIPadding")
    resourcesPadding.PaddingLeft = UDim.new(0, 8)
    resourcesPadding.PaddingRight = UDim.new(0, 8)
    resourcesPadding.PaddingTop = UDim.new(0, 6)
    resourcesPadding.PaddingBottom = UDim.new(0, 6)
    resourcesPadding.Parent = resourcesFrame
    
    -- Resource labels
    local resourceTypes = {
        {name = "Water", color = UI.WATER_COLOR, icon = "💧"},
        {name = "Minerals", color = UI.MINERAL_COLOR, icon = "⛏️"},
        {name = "Energy", color = UI.ENERGY_COLOR, icon = "⚡"},
        {name = "Biomass", color = UI.BIOMASS_COLOR, icon = "🌱"},
    }
    
    for i, resource in ipairs(resourceTypes) do
        local resourceLabel = Instance.new("TextLabel")
        resourceLabel.Name = resource.name .. "Label"
        resourceLabel.Size = UDim2.new(1, 0, 0, 24)
        resourceLabel.Position = UDim2.new(0, 0, 0, (i - 1) * 26)
        resourceLabel.BackgroundTransparency = 1
        resourceLabel.Text = `{resource.icon} {resource.name}: 0`
        resourceLabel.TextColor3 = resource.color
        resourceLabel.TextSize = UI.RESOURCE_TEXT_SIZE
        resourceLabel.Font = Enum.Font.GothamMedium
        resourceLabel.TextXAlignment = Enum.TextXAlignment.Left
        resourceLabel.Parent = resourcesFrame
    end
    
    -- Minimize button functionality
    local isMinimized = false
    self._janitor:Add(minimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        contentFrame.Visible = not isMinimized
        minimizeBtn.Text = isMinimized and "+" or "−"
        
        if isMinimized then
            mainFrame.Size = UI.MAIN_FRAME_SIZE_MINIMIZED
        else
            mainFrame.Size = UI.MAIN_FRAME_SIZE
        end
    end), "Disconnect")
    
    self._ui = screenGui
    print("[PlanetController] UI created successfully - MainFrame Parent:", mainFrame.Parent.Name)
    self:_updateUI()
end

---
-- Update the UI with current planet state
--
function PlanetController:_updateUI()
    if not self._ui or not self._planetState then return end
    
    local mainFrame = self._ui:FindFirstChild("MainFrame")
    if not mainFrame then return end
    
    local contentFrame = mainFrame:FindFirstChild("Content")
    if not contentFrame then return end
    
    -- Update planet info
    local infoFrame = contentFrame:FindFirstChild("InfoFrame")
    if infoFrame then
        local levelLabel = infoFrame:FindFirstChild("LevelLabel")
        if levelLabel then
            levelLabel.Text = `Level {self._planetState.level}`
        end
        
        local biomeLabel = infoFrame:FindFirstChild("BiomeLabel")
        if biomeLabel then
            biomeLabel.Text = `Biome: {self._planetState.biome}`
        end
        
        local xpLabel = infoFrame:FindFirstChild("XPLabel")
        if xpLabel then
            local Constants = require(game:GetService("ReplicatedStorage").Shared.Constants)
            local xpNeeded = Constants.PLANET.XP_PER_LEVEL * (Constants.PLANET.XP_SCALE ^ (self._planetState.level - 1))
            xpLabel.Text = `XP: {math.floor(self._planetState.experience)} / {math.floor(xpNeeded)}`
        end
    end
    
    -- Update resources
    local resourcesFrame = contentFrame:FindFirstChild("ResourcesFrame")
    if resourcesFrame then
        local waterLabel = resourcesFrame:FindFirstChild("WaterLabel")
        if waterLabel then
            waterLabel.Text = `💧 Water: {math.floor(self._planetState.resources.water)}`
        end
        
        local mineralsLabel = resourcesFrame:FindFirstChild("MineralsLabel")
        if mineralsLabel then
            mineralsLabel.Text = `⛏️ Minerals: {math.floor(self._planetState.resources.minerals)}`
        end
        
        local energyLabel = resourcesFrame:FindFirstChild("EnergyLabel")
        if energyLabel then
            energyLabel.Text = `⚡ Energy: {math.floor(self._planetState.resources.energy)}`
        end
        
        local biomassLabel = resourcesFrame:FindFirstChild("BiomassLabel")
        if biomassLabel then
            biomassLabel.Text = `🌱 Biomass: {math.floor(self._planetState.resources.biomass)}`
        end
    end
end

--[[ Public Methods ]]--

---
-- Get current planet state
-- @return PlanetState? - The cached planet state
--
-- Get current planet state (for other controllers)
function PlanetController:getPlanetState()
    return self._planetState
end

---
-- Refresh planet state from server
-- Called after upgrades, collections, etc.
--
-- Refresh planet state from server (called after upgrades, etc.)
function PlanetController:refreshPlanetState()
    local PlanetService = Knit.GetService("PlanetService")
    PlanetService:GetPlanetState():andThen(function(planetState)
        if planetState then
            self._planetState = planetState
            self:_updateUI()
        end
    end):catch(function(err)
        warn("[PlanetController] Refresh failed:", err)
    end)
end

return PlanetController
