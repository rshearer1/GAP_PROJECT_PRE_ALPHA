--[[
    StarMapController
    
    Client-side controller for Star Map UI
    Displays constellation-themed UI for purchasing permanent star upgrades
    
    Features:
    - Star button to open Star Map
    - Constellation-themed UI
    - Display available upgrades by category
    - Show owned vs locked upgrades
    - Purchase star upgrades
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local StarMapController = Knit.CreateController({
    Name = "StarMapController",
})

function StarMapController:KnitInit()
    print("[StarMapController] Initializing...")
    self._player = Players.LocalPlayer
    self._starMapService = nil
    self._ui = nil
    self._currentStars = 0
    self._purchasedUpgrades = {}
    self._allUpgrades = {}
end

function StarMapController:KnitStart()
    print("[StarMapController] Starting...")
    
    -- Get StarMapService
    self._starMapService = Knit.GetService("StarMapService")
    
    -- Create UI
    self:_createUI()
    
    -- Load initial data
    self:_loadStarData()
    
    -- Listen for star data updates
    self._starMapService.GetStarData:Observe(function(starData)
        if starData then
            self._currentStars = starData.stars
            self._purchasedUpgrades = starData.starUpgrades or {}
            self:_updateUI()
        end
    end)
    
    print("[StarMapController] Started!")
end

--[[ Private Methods ]]--

function StarMapController:_createUI()
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "StarMapUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = self._player.PlayerGui
    
    -- Star Map button (right side, vertical layout) - ImageButton
    local Constants = require(game:GetService("ReplicatedStorage").Shared.Constants)
    local navConfig = Constants.UI.PLANET_UI.NAV_BUTTONS
    local buttonIndex = 0 -- First button in vertical stack
    
    local starButton = Instance.new("ImageButton")
    starButton.Name = "StarButton"
    starButton.Size = navConfig.BUTTON_SIZE
    starButton.Position = UDim2.new(1, -(navConfig.RIGHT_OFFSET + navConfig.BUTTON_SIZE.X.Offset), 0, navConfig.START_Y + (buttonIndex * (navConfig.BUTTON_SIZE.Y.Offset + navConfig.BUTTON_SPACING)))
    starButton.AnchorPoint = Vector2.new(0, 0)
    starButton.BackgroundTransparency = 1
    starButton.Image = "rbxassetid://109076471250268"
    starButton.ScaleType = Enum.ScaleType.Fit
    starButton.Parent = screenGui
    
    -- Star Map panel (hidden by default)
    local mapPanel = Instance.new("Frame")
    mapPanel.Name = "MapPanel"
    mapPanel.Size = UDim2.new(0, 700, 0, 500)
    mapPanel.Position = UDim2.new(0.5, -350, 0.5, -250)
    mapPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 25) -- Dark space theme
    mapPanel.BorderSizePixel = 0
    mapPanel.Visible = false
    mapPanel.Parent = screenGui
    
    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 12)
    panelCorner.Parent = mapPanel
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -60, 0, 50)
    title.Position = UDim2.new(0, 20, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "⭐ Star Map"
    title.TextColor3 = Color3.fromRGB(255, 215, 0)
    title.TextSize = 28
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = mapPanel
    
    -- Star counter
    local starCounter = Instance.new("TextLabel")
    starCounter.Name = "StarCounter"
    starCounter.Size = UDim2.new(0, 150, 0, 40)
    starCounter.Position = UDim2.new(1, -170, 0, 15)
    starCounter.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    starCounter.Text = "⭐ 0 Stars"
    starCounter.TextColor3 = Color3.fromRGB(255, 215, 0)
    starCounter.TextSize = 18
    starCounter.Font = Enum.Font.GothamBold
    starCounter.Parent = mapPanel
    
    local counterCorner = Instance.new("UICorner")
    counterCorner.CornerRadius = UDim.new(0, 8)
    counterCorner.Parent = starCounter
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(1, -50, 0, 10)
    closeButton.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextSize = 24
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = mapPanel
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton
    
    -- Subtitle
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(1, -40, 0, 30)
    subtitle.Position = UDim2.new(0, 20, 0, 50)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Permanent upgrades that persist through rebirths"
    subtitle.TextColor3 = Color3.fromRGB(150, 150, 180)
    subtitle.TextSize = 14
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = mapPanel
    
    -- Scrolling frame for upgrades
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "UpgradeScroll"
    scrollFrame.Size = UDim2.new(1, -40, 1, -100)
    scrollFrame.Position = UDim2.new(0, 20, 0, 80)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.Parent = mapPanel
    
    -- Grid layout for upgrade cards
    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.new(0, 200, 0, 140)
    grid.CellPadding = UDim2.new(0, 10, 0, 10)
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    grid.Parent = scrollFrame
    
    -- Button click handlers
    starButton.MouseButton1Click:Connect(function()
        mapPanel.Visible = not mapPanel.Visible
        if mapPanel.Visible then
            self:_loadStarData()
        end
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        mapPanel.Visible = false
    end)
    
    self._ui = screenGui
    self._mapPanel = mapPanel
    self._starCounter = starCounter
    self._scrollFrame = scrollFrame
end

function StarMapController:_loadStarData()
    -- Load current stars and upgrades
    self._starMapService:GetStarData():andThen(function(stars, upgrades)
        self._currentStars = stars
        self._purchasedUpgrades = upgrades
        
        -- Load all upgrade definitions
        return self._starMapService:GetAllUpgrades()
    end):andThen(function(allUpgrades)
        self._allUpgrades = allUpgrades
        self:_updateUI()
    end):catch(function(err)
        warn("[StarMapController] Failed to load star data:", err)
    end)
end

function StarMapController:_updateUI()
    if not self._ui then return end
    
    -- Update star counter
    self._starCounter.Text = "⭐ " .. self._currentStars .. " Stars"
    
    -- Clear existing upgrade cards
    for _, child in ipairs(self._scrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Create upgrade cards
    for i, upgrade in ipairs(self._allUpgrades) do
        self:_createUpgradeCard(upgrade, i)
    end
    
    -- Update canvas size
    local grid = self._scrollFrame:FindFirstChildOfClass("UIGridLayout")
    if grid then
        self._scrollFrame.CanvasSize = UDim2.new(0, 0, 0, grid.AbsoluteContentSize.Y + 10)
    end
end

function StarMapController:_createUpgradeCard(upgrade: {}, order: number)
    local isPurchased = table.find(self._purchasedUpgrades, upgrade.id) ~= nil
    local canAfford = self._currentStars >= upgrade.cost
    local meetsRequirements = true
    
    -- Check requirements
    if upgrade.requires then
        meetsRequirements = table.find(self._purchasedUpgrades, upgrade.requires) ~= nil
    end
    
    local card = Instance.new("Frame")
    card.Name = upgrade.id
    card.BackgroundColor3 = isPurchased and Color3.fromRGB(30, 60, 30) or Color3.fromRGB(30, 30, 45)
    card.BorderSizePixel = 0
    card.LayoutOrder = order
    card.Parent = self._scrollFrame
    
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 10)
    cardCorner.Parent = card
    
    -- Stroke for visual flair
    local stroke = Instance.new("UIStroke")
    stroke.Color = isPurchased and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(255, 215, 0)
    stroke.Thickness = isPurchased and 3 or 1
    stroke.Transparency = isPurchased and 0 or 0.7
    stroke.Parent = card
    
    -- Name label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -10, 0, 30)
    nameLabel.Position = UDim2.new(0, 5, 0, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = upgrade.name
    nameLabel.TextColor3 = isPurchased and Color3.fromRGB(150, 255, 150) or Color3.fromRGB(255, 215, 0)
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextWrapped = true
    nameLabel.TextYAlignment = Enum.TextYAlignment.Top
    nameLabel.Parent = card
    
    -- Description
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -10, 0, 40)
    descLabel.Position = UDim2.new(0, 5, 0, 35)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = upgrade.description
    descLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    descLabel.TextSize = 11
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextWrapped = true
    descLabel.TextYAlignment = Enum.TextYAlignment.Top
    descLabel.Parent = card
    
    -- Cost / Status
    if isPurchased then
        local ownedLabel = Instance.new("TextLabel")
        ownedLabel.Size = UDim2.new(1, -10, 0, 30)
        ownedLabel.Position = UDim2.new(0, 5, 1, -35)
        ownedLabel.BackgroundTransparency = 1
        ownedLabel.Text = "✓ OWNED"
        ownedLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        ownedLabel.TextSize = 16
        ownedLabel.Font = Enum.Font.GothamBold
        ownedLabel.Parent = card
    else
        local buyButton = Instance.new("TextButton")
        buyButton.Size = UDim2.new(1, -10, 0, 30)
        buyButton.Position = UDim2.new(0, 5, 1, -35)
        buyButton.BackgroundColor3 = (canAfford and meetsRequirements) and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(80, 80, 80)
        buyButton.Text = "⭐ " .. upgrade.cost .. " Star" .. (upgrade.cost > 1 and "s" or "")
        buyButton.TextColor3 = Color3.new(1, 1, 1)
        buyButton.TextSize = 14
        buyButton.Font = Enum.Font.GothamBold
        buyButton.Active = canAfford and meetsRequirements
        buyButton.Parent = card
        
        local buyCorner = Instance.new("UICorner")
        buyCorner.CornerRadius = UDim.new(0, 6)
        buyCorner.Parent = buyButton
        
        -- Purchase handler
        buyButton.MouseButton1Click:Connect(function()
            if canAfford and meetsRequirements then
                self:_purchaseUpgrade(upgrade.id)
            end
        end)
        
        -- Show requirement tooltip if not met
        if not meetsRequirements then
            local reqLabel = Instance.new("TextLabel")
            reqLabel.Size = UDim2.new(1, -10, 0, 15)
            reqLabel.Position = UDim2.new(0, 5, 0, 75)
            reqLabel.BackgroundTransparency = 1
            reqLabel.Text = "⚠ Requires previous tier"
            reqLabel.TextColor3 = Color3.fromRGB(255, 150, 150)
            reqLabel.TextSize = 9
            reqLabel.Font = Enum.Font.Gotham
            reqLabel.Parent = card
        end
    end
end

function StarMapController:_purchaseUpgrade(upgradeId: string)
    print("[StarMapController] Attempting to purchase:", upgradeId)
    
    self._starMapService:PurchaseUpgrade(upgradeId):andThen(function(success)
        if success then
            print("[StarMapController] Purchase successful!")
            -- Reload data to update UI
            self:_loadStarData()
        else
            warn("[StarMapController] Purchase failed")
        end
    end):catch(function(err)
        warn("[StarMapController] Purchase error:", err)
    end)
end

return StarMapController
