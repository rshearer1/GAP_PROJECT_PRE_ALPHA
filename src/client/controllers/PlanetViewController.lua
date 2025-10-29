--[[
    PlanetViewController.lua
    Client-side planet view camera controller
    
    Responsibilities:
    - Toggle planet view mode (close-up camera)
    - Smooth camera transitions
    - Display planet information overlay
    - Handle view controls (rotate, zoom)
    
    GAP Compliance:
    - Uses Janitor for cleanup
    - References Constants.UI.PLANET_VIEW for all UI values
    - JSDoc comments on all public methods
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Constants = require(ReplicatedStorage.Shared.Constants)

local PlanetViewController = Knit.CreateController({
    Name = "PlanetViewController",
})

-- Local state
PlanetViewController._isInPlanetView = false
PlanetViewController._planetModel = nil
PlanetViewController._originalCameraCFrame = nil
PlanetViewController._viewUI = nil
PlanetViewController._janitor = Janitor.new()
PlanetViewController._player = Players.LocalPlayer
PlanetViewController._camera = Workspace.CurrentCamera
PlanetViewController._rotationAngle = 0
PlanetViewController._zoomDistance = 30

--[[ Controller Lifecycle ]]--

---
-- Initialize PlanetViewController
--
function PlanetViewController:KnitInit()
    print("[PlanetViewController] Initializing...")
end

---
-- Start PlanetViewController
-- Creates view toggle button and sets up controls
--
function PlanetViewController:KnitStart()
    print("[PlanetViewController] Starting...")
    
    -- Wait for character
    if not self._player.Character then
        self._player.CharacterAdded:Wait()
    end
    
    -- Create toggle button
    self:_createToggleButton()
    
    print("[PlanetViewController] Started successfully!")
end

--[[ Private Methods ]]--

---
-- Create the "View My Planet" toggle button
--
function PlanetViewController:_createToggleButton()
    local playerGui = self._player:WaitForChild("PlayerGui")
    
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PlanetViewToggle"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui
    
    self._janitor:Add(screenGui)
    
    -- Create toggle button (below the other nav buttons)
    local navConfig = Constants.UI.PLANET_UI.NAV_BUTTONS
    local buttonIndex = 4 -- After Settings button
    
    local viewButton = Instance.new("TextButton")
    viewButton.Name = "ViewPlanetButton"
    viewButton.Size = UDim2.new(0, 120, 0, 40)
    viewButton.Position = UDim2.new(1, -(navConfig.RIGHT_OFFSET + 120), 0, navConfig.START_Y + ((buttonIndex + 1) * (navConfig.BUTTON_SIZE.Y.Offset + navConfig.BUTTON_SPACING)))
    viewButton.AnchorPoint = Vector2.new(0, 0)
    viewButton.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
    viewButton.Text = "🌍 View Planet"
    viewButton.TextColor3 = Color3.new(1, 1, 1)
    viewButton.TextSize = 16
    viewButton.Font = Enum.Font.GothamBold
    viewButton.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = viewButton
    
    -- Button click handler
    self._janitor:Add(viewButton.MouseButton1Click:Connect(function()
        self:_togglePlanetView()
    end), "Disconnect")
end

---
-- Toggle between planet view and normal view
--
function PlanetViewController:_togglePlanetView()
    if self._isInPlanetView then
        self:_exitPlanetView()
    else
        self:_enterPlanetView()
    end
end

---
-- Enter planet view mode
--
function PlanetViewController:_enterPlanetView()
    print("[PlanetViewController] Entering planet view...")
    
    -- Find the player's planet in workspace
    local planetsFolder = Workspace:FindFirstChild("Planets")
    if not planetsFolder then
        warn("[PlanetViewController] Planets folder not found")
        return
    end
    
    local planetModel = planetsFolder:FindFirstChild(`{self._player.Name}_Planet`)
    if not planetModel then
        warn("[PlanetViewController] Planet model not found")
        return
    end
    
    self._planetModel = planetModel
    local planetCore = planetModel:FindFirstChild("PlanetCore")
    if not planetCore then
        warn("[PlanetViewController] PlanetCore not found")
        return
    end
    
    -- Save original camera state
    self._originalCameraCFrame = self._camera.CFrame
    self._camera.CameraType = Enum.CameraType.Scriptable
    
    -- Calculate camera position (in front of planet)
    local planetPosition = planetCore.Position
    local cameraOffset = Vector3.new(0, 5, self._zoomDistance)
    local targetCFrame = CFrame.new(planetPosition + cameraOffset, planetPosition)
    
    -- Smooth camera transition
    local tween = TweenService:Create(
        self._camera,
        TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {CFrame = targetCFrame}
    )
    tween:Play()
    
    -- Create planet view UI
    task.wait(1)
    self:_createPlanetViewUI()
    
    -- Start rotation update
    self:_startCameraRotation()
    
    self._isInPlanetView = true
    print("[PlanetViewController] Entered planet view")
end

---
-- Exit planet view mode
--
function PlanetViewController:_exitPlanetView()
    print("[PlanetViewController] Exiting planet view...")
    
    -- Stop camera rotation
    if self._rotationConnection then
        self._rotationConnection:Disconnect()
        self._rotationConnection = nil
    end
    
    -- Restore camera
    if self._originalCameraCFrame then
        local tween = TweenService:Create(
            self._camera,
            TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {CFrame = self._originalCameraCFrame}
        )
        tween:Play()
        
        task.wait(1)
        self._camera.CameraType = Enum.CameraType.Custom
    end
    
    -- Remove planet view UI
    if self._viewUI then
        self._viewUI:Destroy()
        self._viewUI = nil
    end
    
    self._isInPlanetView = false
    print("[PlanetViewController] Exited planet view")
end

---
-- Create the planet view UI overlay (like in the screenshot)
--
function PlanetViewController:_createPlanetViewUI()
    local playerGui = self._player:WaitForChild("PlayerGui")
    
    -- Get planet data
    local PlanetController = Knit.GetController("PlanetController")
    local planetState = PlanetController:getPlanetState()
    if not planetState then
        warn("[PlanetViewController] No planet state available")
        return
    end
    
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PlanetViewUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui
    
    -- Title at top (like "My Planet" in screenshot)
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(0, 300, 0, 60)
    titleLabel.Position = UDim2.new(0.5, -150, 0, 20)
    titleLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    titleLabel.BackgroundTransparency = 0.5
    titleLabel.BorderSizePixel = 0
    titleLabel.Text = "My Planet"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextSize = 32
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = screenGui
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = titleLabel
    
    -- Planet name (username like "Fewice" in screenshot)
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(0, 300, 0, 40)
    nameLabel.Position = UDim2.new(0.5, -150, 0, 90)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = self._player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 24
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.Parent = screenGui
    
    -- Info panel at bottom (like in screenshot)
    local infoPanel = Instance.new("Frame")
    infoPanel.Name = "InfoPanel"
    infoPanel.Size = UDim2.new(0, 380, 0, 190) -- Increased width and height
    infoPanel.Position = UDim2.new(0.5, -190, 1, -210)
    infoPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    infoPanel.BackgroundTransparency = 0.2
    infoPanel.BorderSizePixel = 0
    infoPanel.Parent = screenGui
    
    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 12)
    panelCorner.Parent = infoPanel
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 15)
    padding.PaddingRight = UDim.new(0, 15)
    padding.PaddingTop = UDim.new(0, 15)
    padding.PaddingBottom = UDim.new(0, 15)
    padding.Parent = infoPanel
    
    -- Panel title
    local panelTitle = Instance.new("TextLabel")
    panelTitle.Name = "PanelTitle"
    panelTitle.Size = UDim2.new(1, 0, 0, 25)
    panelTitle.Position = UDim2.new(0, 0, 0, 0)
    panelTitle.BackgroundTransparency = 1
    panelTitle.Text = "My Planet"
    panelTitle.TextColor3 = Color3.new(1, 1, 1)
    panelTitle.TextSize = 18
    panelTitle.Font = Enum.Font.GothamBold
    panelTitle.TextXAlignment = Enum.TextXAlignment.Left
    panelTitle.Parent = infoPanel
    
    -- Level info
    local levelLabel = Instance.new("TextLabel")
    levelLabel.Name = "LevelLabel"
    levelLabel.Size = UDim2.new(1, 0, 0, 20)
    levelLabel.Position = UDim2.new(0, 0, 0, 30)
    levelLabel.BackgroundTransparency = 1
    levelLabel.Text = `Level {planetState.level}`
    levelLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    levelLabel.TextSize = 16
    levelLabel.Font = Enum.Font.GothamBold
    levelLabel.TextXAlignment = Enum.TextXAlignment.Left
    levelLabel.Parent = infoPanel
    
    -- Biome info
    local biomeLabel = Instance.new("TextLabel")
    biomeLabel.Name = "BiomeLabel"
    biomeLabel.Size = UDim2.new(1, 0, 0, 18)
    biomeLabel.Position = UDim2.new(0, 0, 0, 52)
    biomeLabel.BackgroundTransparency = 1
    biomeLabel.Text = `Biome: {planetState.biome}`
    biomeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    biomeLabel.TextSize = 14
    biomeLabel.Font = Enum.Font.Gotham
    biomeLabel.TextXAlignment = Enum.TextXAlignment.Left
    biomeLabel.Parent = infoPanel
    
    -- Resources container frame
    local resourcesFrame = Instance.new("Frame")
    resourcesFrame.Name = "ResourcesFrame"
    resourcesFrame.Size = UDim2.new(1, 0, 0, 60)
    resourcesFrame.Position = UDim2.new(0, 0, 0, 75)
    resourcesFrame.BackgroundTransparency = 1
    resourcesFrame.Parent = infoPanel
    
    -- Resources (using vertical list for clean layout)
    local resources = {
        {icon = "💧", name = "Water", value = planetState.resources.water, color = Constants.UI.PLANET_UI.WATER_COLOR},
        {icon = "⛏️", name = "Minerals", value = planetState.resources.minerals, color = Constants.UI.PLANET_UI.MINERAL_COLOR},
        {icon = "⚡", name = "Energy", value = planetState.resources.energy, color = Constants.UI.PLANET_UI.ENERGY_COLOR},
        {icon = "🌱", name = "Biomass", value = planetState.resources.biomass, color = Constants.UI.PLANET_UI.BIOMASS_COLOR},
    }
    
    -- Create two columns manually with better spacing
    for i, resource in ipairs(resources) do
        local resourceLabel = Instance.new("TextLabel")
        resourceLabel.Name = resource.name .. "Label"
        resourceLabel.Size = UDim2.new(0.5, -8, 0, 24)
        
        -- Calculate position: left column (Water, Energy) or right column (Minerals, Biomass)
        local isLeftColumn = (i == 1 or i == 3)
        local row = isLeftColumn and (i == 1 and 0 or 1) or (i == 2 and 0 or 1)
        
        if isLeftColumn then
            -- Left column
            resourceLabel.Position = UDim2.new(0, 0, 0, row * 28)
        else
            -- Right column
            resourceLabel.Position = UDim2.new(0.5, 8, 0, row * 28)
        end
        
        resourceLabel.BackgroundTransparency = 1
        resourceLabel.Text = `{resource.icon} {resource.name}: {math.floor(resource.value)}`
        resourceLabel.TextColor3 = resource.color
        resourceLabel.TextSize = 14
        resourceLabel.Font = Enum.Font.GothamMedium
        resourceLabel.TextXAlignment = Enum.TextXAlignment.Left
        resourceLabel.TextTruncate = Enum.TextTruncate.AtEnd
        resourceLabel.ClipsDescendants = true
        resourceLabel.Parent = resourcesFrame
    end
    
    -- Gain XP button (like in screenshot)
    local xpButton = Instance.new("TextButton")
    xpButton.Name = "XPButton"
    xpButton.Size = UDim2.new(1, 0, 0, 30)
    xpButton.Position = UDim2.new(0, 0, 1, -35)
    xpButton.BackgroundColor3 = Color3.fromRGB(142, 68, 173)
    xpButton.Text = "⭐ Gain XP"
    xpButton.TextColor3 = Color3.new(1, 1, 1)
    xpButton.TextSize = 14
    xpButton.Font = Enum.Font.GothamBold
    xpButton.Parent = infoPanel
    
    local xpCorner = Instance.new("UICorner")
    xpCorner.CornerRadius = UDim.new(0, 6)
    xpCorner.Parent = xpButton
    
    -- XP button click handler (collect resources)
    xpButton.MouseButton1Click:Connect(function()
        local PlanetService = Knit.GetService("PlanetService")
        PlanetService:CollectResources():andThen(function(result)
            print(`[PlanetViewController] Collected XP: {result.xpGained}`)
            -- Refresh display
            task.wait(0.5)
            self:_refreshPlanetViewUI()
        end):catch(function(err)
            warn("[PlanetViewController] Failed to collect resources:", err)
        end)
    end)
    
    -- Exit button (positioned to bottom-right to avoid overlap with info panel)
    local exitButton = Instance.new("TextButton")
    exitButton.Name = "ExitButton"
    exitButton.Size = UDim2.new(0, 120, 0, 40)
    exitButton.Position = UDim2.new(1, -140, 1, -60) -- Bottom-right corner with margin
    exitButton.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
    exitButton.Text = "✕ Exit View"
    exitButton.TextColor3 = Color3.new(1, 1, 1)
    exitButton.TextSize = 16
    exitButton.Font = Enum.Font.GothamBold
    exitButton.Parent = screenGui
    
    local exitCorner = Instance.new("UICorner")
    exitCorner.CornerRadius = UDim.new(0, 8)
    exitCorner.Parent = exitButton
    
    exitButton.MouseButton1Click:Connect(function()
        self:_exitPlanetView()
    end)
    
    self._viewUI = screenGui
end

---
-- Refresh planet view UI with updated data
--
function PlanetViewController:_refreshPlanetViewUI()
    if not self._viewUI then return end
    
    local PlanetController = Knit.GetController("PlanetController")
    local planetState = PlanetController:getPlanetState()
    if not planetState then return end
    
    local infoPanel = self._viewUI:FindFirstChild("InfoPanel")
    if not infoPanel then return end
    
    -- Update level
    local levelLabel = infoPanel:FindFirstChild("LevelLabel")
    if levelLabel then
        levelLabel.Text = `Level {planetState.level}`
    end
    
    -- Update biome
    local biomeLabel = infoPanel:FindFirstChild("BiomeLabel")
    if biomeLabel then
        biomeLabel.Text = `Biome: {planetState.biome}`
    end
    
    -- Update resources
    local resourcesFrame = infoPanel:FindFirstChild("ResourcesFrame")
    if resourcesFrame then
        local resources = {
            {icon = "💧", name = "Water", value = planetState.resources.water},
            {icon = "⛏️", name = "Minerals", value = planetState.resources.minerals},
            {icon = "⚡", name = "Energy", value = planetState.resources.energy},
            {icon = "🌱", name = "Biomass", value = planetState.resources.biomass},
        }
        
        for i, resource in ipairs(resources) do
            local resourceLabel = resourcesFrame:FindFirstChild(resource.name .. "Label")
            if resourceLabel then
                resourceLabel.Text = `{resource.icon} {resource.name}: {math.floor(resource.value)}`
            end
        end
    end
end

---
-- Start automatic camera rotation around planet
--
function PlanetViewController:_startCameraRotation()
    if not self._planetModel then return end
    
    local planetCore = self._planetModel:FindFirstChild("PlanetCore")
    if not planetCore then return end
    
    self._rotationAngle = 0
    
    self._rotationConnection = RunService.RenderStepped:Connect(function(dt)
        if not self._isInPlanetView or not planetCore then
            return
        end
        
        -- Slowly rotate camera around planet
        self._rotationAngle = self._rotationAngle + (dt * 0.2) -- Slow rotation
        
        local planetPosition = planetCore.Position
        local distance = self._zoomDistance
        
        -- Calculate camera position in a circle around planet
        local offsetX = math.sin(self._rotationAngle) * distance
        local offsetZ = math.cos(self._rotationAngle) * distance
        local cameraPosition = planetPosition + Vector3.new(offsetX, 5, offsetZ)
        
        self._camera.CFrame = CFrame.new(cameraPosition, planetPosition)
    end)
end

--[[ Public Methods ]]--

---
-- Check if currently in planet view
-- @return boolean - True if in planet view mode
--
function PlanetViewController:isInPlanetView()
    return self._isInPlanetView
end

return PlanetViewController
