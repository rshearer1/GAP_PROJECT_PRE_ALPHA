--[[
    SolarSystemController.lua
    Client-side solar system UI and management
    
    Displays:
    - Solar system map with all planets
    - Planet unlock UI
    - Planet switching interface
]]

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local SolarSystemController = Knit.CreateController {
    Name = "SolarSystemController",
    
    -- UI Elements
    _mapGui = nil,
    _mapFrame = nil,
    _planetButtons = {},
    
    -- State
    _solarSystem = nil,
    _selectedPlanet = nil,
}

function SolarSystemController:KnitInit()
    print("[SolarSystemController] Initializing...")
end

function SolarSystemController:KnitStart()
    print("[SolarSystemController] Starting...")
    
    -- Get services
    self._solarSystemService = Knit.GetService("SolarSystemService")
    self._planetController = Knit.GetController("PlanetController")
    
    -- Create UI
    self:_createUI()
    
    -- Load solar system data
    task.spawn(function()
        self:_loadSolarSystem()
    end)
    
    print("[SolarSystemController] Started successfully!")
end

--[[ UI Creation ]]--

function SolarSystemController:_createUI()
    -- Create ScreenGui
    self._mapGui = Instance.new("ScreenGui")
    self._mapGui.Name = "SolarSystemMap"
    self._mapGui.ResetOnSpawn = false
    self._mapGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self._mapGui.Parent = playerGui
    
    -- Map button (right side, vertical layout) - ImageButton
    local Constants = require(game:GetService("ReplicatedStorage").Shared.Constants)
    local navConfig = Constants.UI.PLANET_UI.NAV_BUTTONS
    local buttonIndex = 1 -- Second button in vertical stack
    
    local mapButton = Instance.new("ImageButton")
    mapButton.Name = "MapButton"
    mapButton.Size = navConfig.BUTTON_SIZE
    mapButton.Position = UDim2.new(1, -(navConfig.RIGHT_OFFSET + navConfig.BUTTON_SIZE.X.Offset), 0, navConfig.START_Y + (buttonIndex * (navConfig.BUTTON_SIZE.Y.Offset + navConfig.BUTTON_SPACING)))
    mapButton.AnchorPoint = Vector2.new(0, 0)
    mapButton.BackgroundTransparency = 1
    mapButton.Image = "rbxassetid://90313785520046"
    mapButton.ScaleType = Enum.ScaleType.Fit
    mapButton.Parent = self._mapGui
    
    -- Map panel (hidden by default)
    self._mapFrame = Instance.new("Frame")
    self._mapFrame.Name = "MapPanel"
    self._mapFrame.Size = UDim2.new(0, 800, 0, 500)
    self._mapFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    self._mapFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    self._mapFrame.BackgroundColor3 = Color3.fromRGB(44, 62, 80)
    self._mapFrame.Visible = false
    self._mapFrame.Parent = self._mapGui
    
    local mapCorner = Instance.new("UICorner")
    mapCorner.CornerRadius = UDim.new(0, 12)
    mapCorner.Parent = self._mapFrame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -40, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Solar System Map"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = self._mapFrame
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(1, -40, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextSize = 20
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = self._mapFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton
    
    -- Planets container (scrolling)
    local planetsScroll = Instance.new("ScrollingFrame")
    planetsScroll.Name = "PlanetsScroll"
    planetsScroll.Size = UDim2.new(1, -40, 1, -80)
    planetsScroll.Position = UDim2.new(0, 20, 0, 60)
    planetsScroll.BackgroundTransparency = 1
    planetsScroll.BorderSizePixel = 0
    planetsScroll.ScrollBarThickness = 8
    planetsScroll.Parent = self._mapFrame
    
    -- Grid layout for planets
    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.new(0, 180, 0, 200)
    grid.CellPadding = UDim2.new(0, 15, 0, 15)
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    grid.Parent = planetsScroll
    
    -- Button click handlers
    mapButton.MouseButton1Click:Connect(function()
        self:_toggleMap()
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        self:_toggleMap()
    end)
end

function SolarSystemController:_toggleMap()
    self._mapFrame.Visible = not self._mapFrame.Visible
    
    if self._mapFrame.Visible then
        -- Refresh solar system data when opening
        self:_loadSolarSystem()
    end
end

--[[ Data Loading ]]--

function SolarSystemController:_loadSolarSystem()
    self._solarSystemService:GetSolarSystem():andThen(function(solarSystem)
        if solarSystem then
            self._solarSystem = solarSystem
            self:_updatePlanetDisplay()
            print("[SolarSystemController] Loaded solar system with", #solarSystem.planets, "planets")
        end
    end):catch(function(err)
        warn("[SolarSystemController] Failed to load solar system:", err)
    end)
end

function SolarSystemController:_updatePlanetDisplay()
    if not self._solarSystem then return end
    
    local planetsScroll = self._mapFrame:FindFirstChild("PlanetsScroll")
    if not planetsScroll then return end
    
    -- Clear existing planet buttons
    for _, child in ipairs(planetsScroll:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    self._planetButtons = {}
    
    -- Create planet cards
    for i, planet in ipairs(self._solarSystem.planets) do
        local card = self:_createPlanetCard(planet, i)
        card.Parent = planetsScroll
        table.insert(self._planetButtons, card)
    end
    
    -- Update scroll canvas size
    local grid = planetsScroll:FindFirstChild("UIGridLayout")
    if grid then
        planetsScroll.CanvasSize = UDim2.new(0, 0, 0, grid.AbsoluteContentSize.Y + 20)
    end
end

function SolarSystemController:_createPlanetCard(planet, index)
    local isActive = (self._solarSystem.activePlanetIndex == index)
    local isUnlocked = planet.isUnlocked
    
    local card = Instance.new("Frame")
    card.Name = "Planet" .. index
    card.BackgroundColor3 = isActive and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(52, 73, 94)
    card.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = card
    
    -- Planet type label
    local typeLabel = Instance.new("TextLabel")
    typeLabel.Size = UDim2.new(1, -10, 0, 30)
    typeLabel.Position = UDim2.new(0, 5, 0, 5)
    typeLabel.BackgroundTransparency = 1
    typeLabel.Text = planet.planetType
    typeLabel.TextColor3 = Color3.new(1, 1, 1)
    typeLabel.TextSize = 16
    typeLabel.Font = Enum.Font.GothamBold
    typeLabel.TextTruncate = Enum.TextTruncate.AtEnd
    typeLabel.Parent = card
    
    -- Level label
    local levelLabel = Instance.new("TextLabel")
    levelLabel.Size = UDim2.new(1, -10, 0, 20)
    levelLabel.Position = UDim2.new(0, 5, 0, 35)
    levelLabel.BackgroundTransparency = 1
    levelLabel.Text = "Level " .. planet.level .. " • " .. planet.biome
    levelLabel.TextColor3 = Color3.fromRGB(189, 195, 199)
    levelLabel.TextSize = 12
    levelLabel.Font = Enum.Font.Gotham
    levelLabel.Parent = card
    
    if isUnlocked then
        -- Active indicator (if this is the current planet)
        if isActive then
            local activeLabel = Instance.new("TextLabel")
            activeLabel.Size = UDim2.new(1, -10, 0, 20)
            activeLabel.Position = UDim2.new(0, 5, 0, 55)
            activeLabel.BackgroundTransparency = 1
            activeLabel.Text = "★ ACTIVE ★"
            activeLabel.TextColor3 = Color3.fromRGB(241, 196, 15)
            activeLabel.TextSize = 14
            activeLabel.Font = Enum.Font.GothamBold
            activeLabel.Parent = card
        end
        
        -- Switch button
        local switchButton = Instance.new("TextButton")
        switchButton.Size = UDim2.new(1, -20, 0, 40)
        switchButton.Position = UDim2.new(0, 10, 1, -50)
        switchButton.BackgroundColor3 = isActive and Color3.fromRGB(149, 165, 166) or Color3.fromRGB(52, 152, 219)
        switchButton.Text = isActive and "Current Planet" or "Switch"
        switchButton.TextColor3 = Color3.new(1, 1, 1)
        switchButton.TextSize = 16
        switchButton.Font = Enum.Font.GothamBold
        switchButton.Active = not isActive
        switchButton.Parent = card
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = switchButton
        
        if not isActive then
            switchButton.MouseButton1Click:Connect(function()
                self:_switchToPlanet(index)
            end)
        end
    else
        -- Locked indicator
        local lockLabel = Instance.new("TextLabel")
        lockLabel.Size = UDim2.new(1, -10, 0, 30)
        lockLabel.Position = UDim2.new(0, 5, 0, 60)
        lockLabel.BackgroundTransparency = 1
        lockLabel.Text = "🔒 LOCKED"
        lockLabel.TextColor3 = Color3.fromRGB(231, 76, 60)
        lockLabel.TextSize = 18
        lockLabel.Font = Enum.Font.GothamBold
        lockLabel.Parent = card
        
        -- Unlock cost
        local costLabel = Instance.new("TextLabel")
        costLabel.Size = UDim2.new(1, -10, 0, 60)
        costLabel.Position = UDim2.new(0, 5, 0, 90)
        costLabel.BackgroundTransparency = 1
        costLabel.Text = string.format("💧 %d  ⛰️ %d\n⚡ %d  🌿 %d",
            planet.unlockCost.water,
            planet.unlockCost.minerals,
            planet.unlockCost.energy,
            planet.unlockCost.biomass)
        costLabel.TextColor3 = Color3.fromRGB(189, 195, 199)
        costLabel.TextSize = 11
        costLabel.Font = Enum.Font.Gotham
        costLabel.Parent = card
        
        -- Unlock button
        local unlockButton = Instance.new("TextButton")
        unlockButton.Size = UDim2.new(1, -20, 0, 40)
        unlockButton.Position = UDim2.new(0, 10, 1, -50)
        unlockButton.BackgroundColor3 = Color3.fromRGB(230, 126, 34)
        unlockButton.Text = "Unlock Planet"
        unlockButton.TextColor3 = Color3.new(1, 1, 1)
        unlockButton.TextSize = 16
        unlockButton.Font = Enum.Font.GothamBold
        unlockButton.Parent = card
        
        local unlockCorner = Instance.new("UICorner")
        unlockCorner.CornerRadius = UDim.new(0, 8)
        unlockCorner.Parent = unlockButton
        
        unlockButton.MouseButton1Click:Connect(function()
            self:_unlockPlanet(index)
        end)
    end
    
    return card
end

--[[ Actions ]]--

function SolarSystemController:_switchToPlanet(planetIndex: number)
    print("[SolarSystemController] Switching to planet", planetIndex)
    
    self._solarSystemService:SwitchPlanet(planetIndex):andThen(function(success)
        if success then
            -- Refresh UI
            self:_loadSolarSystem()
            
            -- Refresh planet controller to show new planet
            if self._planetController and self._planetController.refreshPlanetState then
                self._planetController:refreshPlanetState()
            end
            
            -- Close map
            self._mapFrame.Visible = false
            
            print("[SolarSystemController] Successfully switched to planet", planetIndex)
        else
            warn("[SolarSystemController] Failed to switch planet")
        end
    end):catch(function(err)
        warn("[SolarSystemController] Error switching planet:", err)
    end)
end

function SolarSystemController:_unlockPlanet(planetIndex: number)
    print("[SolarSystemController] Unlocking planet", planetIndex)
    
    self._solarSystemService:UnlockPlanet(planetIndex):andThen(function(success)
        if success then
            -- Refresh UI
            self:_loadSolarSystem()
            
            -- Refresh planet controller to update resources
            if self._planetController and self._planetController.refreshPlanetState then
                self._planetController:refreshPlanetState()
            end
            
            print("[SolarSystemController] Successfully unlocked planet", planetIndex)
        else
            warn("[SolarSystemController] Failed to unlock planet - insufficient resources")
        end
    end):catch(function(err)
        warn("[SolarSystemController] Error unlocking planet:", err)
    end)
end

return SolarSystemController
