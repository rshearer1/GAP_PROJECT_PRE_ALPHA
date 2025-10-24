--[[
    PlanetController.lua
    Client-side planet UI and interaction controller
    
    Responsibilities:
    - Display planet state and resources
    - Update UI in real-time
    - Handle player interactions with planet
    - Communicate with PlanetService
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Types = require(ReplicatedStorage.Shared.Types)
local Constants = require(ReplicatedStorage.Shared.Constants)

local PlanetController = Knit.CreateController({
    Name = "PlanetController",
})

-- Local state
PlanetController._planetState = nil
PlanetController._ui = nil
PlanetController._updateConnection = nil

--[[ Controller Lifecycle ]]--

function PlanetController:KnitInit()
    print("[PlanetController] Initializing...")
end

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

function PlanetController:_startUpdateLoop(PlanetService)
    -- Update UI periodically
    self._updateConnection = task.spawn(function()
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
end

function PlanetController:_createUI()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PlanetUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui
    
    -- Create main container (much smaller)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 220, 0, 280) -- Reduced from 300x400
    mainFrame.Position = UDim2.new(0, 10, 0, 10) -- Closer to corner
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BackgroundTransparency = 0.1 -- Slightly transparent
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Add corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    -- Add padding (reduced)
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.Parent = mainFrame
    
    -- Minimize/Maximize button
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "MinimizeButton"
    minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
    minimizeBtn.Position = UDim2.new(1, -30, 0, 5)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(52, 73, 94)
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
    minimizeBtn.TextSize = 20
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = mainFrame
    
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 4)
    minCorner.Parent = minimizeBtn
    
    -- Title (smaller)
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -35, 0, 30) -- Make room for minimize button
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "My Planet"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18 -- Reduced from 24
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
    
    -- Planet Info Frame (smaller)
    local infoFrame = Instance.new("Frame")
    infoFrame.Name = "InfoFrame"
    infoFrame.Size = UDim2.new(1, 0, 0, 60) -- Reduced from 80
    infoFrame.Position = UDim2.new(0, 0, 0, 0)
    infoFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
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
    
    -- Level label (smaller text)
    local levelLabel = Instance.new("TextLabel")
    levelLabel.Name = "LevelLabel"
    levelLabel.Size = UDim2.new(1, 0, 0, 16) -- Reduced height
    levelLabel.Position = UDim2.new(0, 0, 0, 0)
    levelLabel.BackgroundTransparency = 1
    levelLabel.Text = "Level 1"
    levelLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    levelLabel.TextSize = 18
    levelLabel.Font = Enum.Font.GothamBold
    levelLabel.TextXAlignment = Enum.TextXAlignment.Left
    levelLabel.Parent = infoFrame
    
    -- Biome label
    local biomeLabel = Instance.new("TextLabel")
    biomeLabel.Name = "BiomeLabel"
    biomeLabel.Size = UDim2.new(1, 0, 0, 16)
    biomeLabel.Position = UDim2.new(0, 0, 0, 18) -- Adjusted
    biomeLabel.BackgroundTransparency = 1
    biomeLabel.Text = "Biome: Barren"
    biomeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    biomeLabel.TextSize = 12 -- Slightly smaller
    biomeLabel.Font = Enum.Font.Gotham
    biomeLabel.TextXAlignment = Enum.TextXAlignment.Left
    biomeLabel.Parent = infoFrame
    
    -- XP Progress label (smaller)
    local xpLabel = Instance.new("TextLabel")
    xpLabel.Name = "XPLabel"
    xpLabel.Size = UDim2.new(1, 0, 0, 14)
    xpLabel.Position = UDim2.new(0, 0, 0, 36) -- Adjusted
    xpLabel.BackgroundTransparency = 1
    xpLabel.Text = "XP: 0 / 100"
    xpLabel.TextColor3 = Color3.fromRGB(150, 150, 255)
    xpLabel.TextSize = 10 -- Smaller
    xpLabel.Font = Enum.Font.Gotham
    xpLabel.TextXAlignment = Enum.TextXAlignment.Left
    xpLabel.Parent = infoFrame
    
    -- Resources Frame (smaller)
    local resourcesFrame = Instance.new("Frame")
    resourcesFrame.Name = "ResourcesFrame"
    resourcesFrame.Size = UDim2.new(1, 0, 0, 120) -- Reduced from 200
    resourcesFrame.Position = UDim2.new(0, 0, 0, 70) -- Adjusted position
    resourcesFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
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
    
    -- Resource labels (smaller, more compact)
    local resourceTypes = {
        {name = "Water", color = Color3.fromRGB(100, 150, 255), icon = "💧"},
        {name = "Minerals", color = Color3.fromRGB(150, 150, 150), icon = "⛏️"},
        {name = "Energy", color = Color3.fromRGB(255, 200, 100), icon = "⚡"},
        {name = "Biomass", color = Color3.fromRGB(100, 200, 100), icon = "🌱"},
    }
    
    for i, resource in ipairs(resourceTypes) do
        local resourceLabel = Instance.new("TextLabel")
        resourceLabel.Name = resource.name .. "Label"
        resourceLabel.Size = UDim2.new(1, 0, 0, 24) -- Reduced from 35
        resourceLabel.Position = UDim2.new(0, 0, 0, (i - 1) * 26) -- Tighter spacing
        resourceLabel.BackgroundTransparency = 1
        resourceLabel.Text = `{resource.icon} {resource.name}: 0`
        resourceLabel.TextColor3 = resource.color
        resourceLabel.TextSize = 13 -- Reduced from 16
        resourceLabel.Font = Enum.Font.GothamMedium
        resourceLabel.TextXAlignment = Enum.TextXAlignment.Left
        resourceLabel.Parent = resourcesFrame
    end
    
    
    -- XP Collect Button (smaller)
    local xpButton = Instance.new("TextButton")
    xpButton.Name = "XPButton"
    xpButton.Size = UDim2.new(1, 0, 0, 35) -- Reduced from 40
    xpButton.Position = UDim2.new(0, 0, 0, 200) -- Positioned below resources
    xpButton.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
    xpButton.Text = "⭐ Gain XP"
    xpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    xpButton.Font = Enum.Font.GothamBold
    xpButton.TextSize = 14 -- Reduced from 16
    xpButton.Parent = contentFrame
    
    local xpCorner = Instance.new("UICorner")
    xpCorner.CornerRadius = UDim.new(0, 8)
    xpCorner.Parent = xpButton
    
    -- XP Button click handler
    xpButton.MouseButton1Click:Connect(function()
        local PlanetService = Knit.GetService("PlanetService")
        PlanetService:CollectResources():andThen(function(result)
            if result and result.xpGained and result.xpGained > 0 then
                print(`[PlanetController] Gained {result.xpGained} XP!`)
                -- Refresh planet state to see level changes
                self:refreshPlanetState()
            end
        end):catch(function(err)
            warn("[PlanetController] Failed to collect XP:", err)
        end)
    end)
    
    -- Minimize button functionality
    local isMinimized = false
    minimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        contentFrame.Visible = not isMinimized
        minimizeBtn.Text = isMinimized and "+" or "−"
        
        if isMinimized then
            mainFrame.Size = UDim2.new(0, 220, 0, 40) -- Just title bar
        else
            mainFrame.Size = UDim2.new(0, 220, 0, 280) -- Full size
        end
    end)
    
    self._ui = screenGui
    print("[PlanetController] UI created successfully - MainFrame Parent:", mainFrame.Parent.Name)
    self:_updateUI()
end

function PlanetController:_updateUI()
    if not self._ui or not self._planetState then return end
    
    local mainFrame = self._ui:FindFirstChild("MainFrame")
    if not mainFrame then return end
    
    -- Update planet info
    local infoFrame = mainFrame:FindFirstChild("InfoFrame")
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
    local resourcesFrame = mainFrame:FindFirstChild("ResourcesFrame")
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

-- Get current planet state (for other controllers)
function PlanetController:getPlanetState()
    return self._planetState
end

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
