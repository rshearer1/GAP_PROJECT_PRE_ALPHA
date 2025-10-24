--[[
    UpgradeController.lua
    Client-side upgrade shop UI and interaction
    
    Shows available upgrades with costs and allows purchasing.
]]

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local UpgradeController = Knit.CreateController {
    Name = "UpgradeController",
    
    _upgradeService = nil,
    _planetController = nil,
    _shopUI = nil,
    _isOpen = false,
}

function UpgradeController:KnitStart()
    print("[UpgradeController] Starting...")
    
    self._upgradeService = Knit.GetService("UpgradeService")
    self._planetController = Knit.GetController("PlanetController")
    
    -- Create shop UI
    self:_createShopUI()
    
    -- Update shop every 2 seconds
    task.spawn(function()
        while true do
            if self._isOpen then
                self:_updateShop()
            end
            task.wait(2)
        end
    end)
    
    print("[UpgradeController] Started!")
end

function UpgradeController:_createShopUI()
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UpgradeShopUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui
    
    -- Toggle Button (top-right, smaller)
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0, 80, 0, 35) -- Reduced from 120x40
    toggleButton.Position = UDim2.new(1, -90, 0, 10) -- Closer to corner
    toggleButton.BackgroundColor3 = Color3.fromRGB(60, 140, 60)
    toggleButton.Text = "🛒 Shop"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.TextSize = 14 -- Reduced from 18
    toggleButton.Parent = screenGui
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 6)
    toggleCorner.Parent = toggleButton
    
    -- Shop Frame (initially hidden)
    local shopFrame = Instance.new("Frame")
    shopFrame.Name = "ShopFrame"
    shopFrame.Size = UDim2.new(0, 600, 0, 500)
    shopFrame.Position = UDim2.new(0.5, -300, 0.5, -250)
    shopFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    shopFrame.BackgroundTransparency = 0.05 -- Slightly transparent
    shopFrame.Visible = false
    shopFrame.Parent = screenGui
    
    local shopCorner = Instance.new("UICorner")
    shopCorner.CornerRadius = UDim.new(0, 12)
    shopCorner.Parent = shopFrame
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -80, 0, 40)
    titleLabel.Position = UDim2.new(0, 10, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🛒 Upgrade Shop"
    titleLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 24
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = shopFrame
    
    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(1, -50, 0, 10)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 24
    closeButton.Parent = shopFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton
    
    -- Scrolling Frame for upgrades
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "UpgradeList"
    scrollFrame.Size = UDim2.new(1, -20, 1, -70)
    scrollFrame.Position = UDim2.new(0, 10, 0, 60)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.Parent = shopFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 10)
    listLayout.Parent = scrollFrame
    
    -- Auto-resize canvas
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Toggle button functionality
    toggleButton.MouseButton1Click:Connect(function()
        self._isOpen = not self._isOpen
        shopFrame.Visible = self._isOpen
        
        if self._isOpen then
            self:_updateShop()
        end
    end)
    
    -- Close button functionality
    closeButton.MouseButton1Click:Connect(function()
        self._isOpen = false
        shopFrame.Visible = false
    end)
    
    self._shopUI = screenGui
end

function UpgradeController:_updateShop()
    if not self._shopUI then return end
    
    local shopFrame = self._shopUI:FindFirstChild("ShopFrame")
    if not shopFrame then return end
    
    local scrollFrame = shopFrame:FindFirstChild("UpgradeList")
    if not scrollFrame then return end
    
    -- Get planet state to check resources
    local planetState = self._planetController:getPlanetState()
    if not planetState then return end
    
    -- Get available upgrades from server
    self._upgradeService:GetAvailableUpgrades():andThen(function(upgrades)
        -- Clear existing upgrade cards
        for _, child in pairs(scrollFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        -- Create upgrade cards
        for _, upgrade in ipairs(upgrades) do
            self:_createUpgradeCard(scrollFrame, upgrade, planetState.resources)
        end
    end):catch(function(err)
        warn("[UpgradeController] Failed to get upgrades:", err)
    end)
end

function UpgradeController:_createUpgradeCard(parent: ScrollingFrame, upgrade, playerResources)
    local card = Instance.new("Frame")
    card.Name = upgrade.id
    card.Size = UDim2.new(1, -10, 0, 100)
    card.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    card.Parent = parent
    
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = card
    
    -- Upgrade Name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Size = UDim2.new(1, -120, 0, 25)
    nameLabel.Position = UDim2.new(0, 10, 0, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = upgrade.name
    nameLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 16
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = card
    
    -- Current Level
    local levelLabel = Instance.new("TextLabel")
    levelLabel.Name = "Level"
    levelLabel.Size = UDim2.new(0, 100, 0, 25)
    levelLabel.Position = UDim2.new(1, -110, 0, 5)
    levelLabel.BackgroundTransparency = 1
    levelLabel.Text = string.format("Lvl %d/%d", upgrade.currentLevel, upgrade.maxLevel)
    levelLabel.TextColor3 = upgrade.isMaxed and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(200, 200, 200)
    levelLabel.Font = Enum.Font.Gotham
    levelLabel.TextSize = 14
    levelLabel.TextXAlignment = Enum.TextXAlignment.Right
    levelLabel.Parent = card
    
    -- Description
    local descLabel = Instance.new("TextLabel")
    descLabel.Name = "Description"
    descLabel.Size = UDim2.new(1, -20, 0, 20)
    descLabel.Position = UDim2.new(0, 10, 0, 30)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = upgrade.description
    descLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 12
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = card
    
    -- Cost Display
    local costFrame = Instance.new("Frame")
    costFrame.Name = "CostFrame"
    costFrame.Size = UDim2.new(1, -130, 0, 20)
    costFrame.Position = UDim2.new(0, 10, 0, 55)
    costFrame.BackgroundTransparency = 1
    costFrame.Parent = card
    
    local costLayout = Instance.new("UIListLayout")
    costLayout.FillDirection = Enum.FillDirection.Horizontal
    costLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    costLayout.Padding = UDim.new(0, 15)
    costLayout.Parent = costFrame
    
    -- Create cost labels for each resource
    local resourceIcons = {water = "💧", minerals = "⛏️", energy = "⚡", biomass = "🌱"}
    for resourceName, amount in pairs(upgrade.cost) do
        if amount > 0 then
            local hasEnough = playerResources[resourceName] >= amount
            
            local costLabel = Instance.new("TextLabel")
            costLabel.Name = resourceName
            costLabel.Size = UDim2.new(0, 80, 1, 0)
            costLabel.BackgroundTransparency = 1
            costLabel.Text = string.format("%s %d", resourceIcons[resourceName], amount)
            costLabel.TextColor3 = hasEnough and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
            costLabel.Font = Enum.Font.Gotham
            costLabel.TextSize = 12
            costLabel.TextXAlignment = Enum.TextXAlignment.Left
            costLabel.Parent = costFrame
        end
    end
    
    -- Purchase Button
    local canAfford = playerResources.water >= upgrade.cost.water and
                      playerResources.minerals >= upgrade.cost.minerals and
                      playerResources.energy >= upgrade.cost.energy and
                      playerResources.biomass >= upgrade.cost.biomass
    
    local buyButton = Instance.new("TextButton")
    buyButton.Name = "BuyButton"
    buyButton.Size = UDim2.new(0, 110, 0, 30)
    buyButton.Position = UDim2.new(1, -120, 1, -40)
    buyButton.Text = upgrade.isMaxed and "MAX" or "Purchase"
    buyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    buyButton.Font = Enum.Font.GothamBold
    buyButton.TextSize = 14
    buyButton.Parent = card
    
    if upgrade.isMaxed then
        buyButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        buyButton.AutoButtonColor = false
    elseif canAfford then
        buyButton.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
    else
        buyButton.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
        buyButton.AutoButtonColor = false
    end
    
    local buyCorner = Instance.new("UICorner")
    buyCorner.CornerRadius = UDim.new(0, 6)
    buyCorner.Parent = buyButton
    
    -- Purchase functionality
    if not upgrade.isMaxed and canAfford then
        buyButton.MouseButton1Click:Connect(function()
            self:purchaseUpgrade(upgrade.id)
        end)
    end
end

function UpgradeController:purchaseUpgrade(upgradeId: string)
    print("[UpgradeController] Attempting to purchase:", upgradeId)
    
    self._upgradeService:PurchaseUpgrade(upgradeId):andThen(function(success, errorMsg)
        if success then
            print("[UpgradeController] Purchase successful!")
            -- Refresh shop UI
            self:_updateShop()
            -- Refresh planet state
            if self._planetController then
                self._planetController:refreshPlanetState()
            end
        else
            warn("[UpgradeController] Purchase failed:", errorMsg)
        end
    end):catch(function(err)
        warn("[UpgradeController] Purchase error:", err)
    end)
end

return UpgradeController
