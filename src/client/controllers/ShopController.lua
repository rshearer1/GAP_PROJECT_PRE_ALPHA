--[[
    ShopController
    
    Client-side controller for the Premium Shop UI
    Displays game passes and handles purchases
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local ShopController = Knit.CreateController({
    Name = "ShopController",
})

function ShopController:KnitInit()
    print("[ShopController] Initializing...")
    self._player = Players.LocalPlayer
    self._gamePassService = nil
    self._ui = nil
    self._shopInteraction = nil
end

function ShopController:KnitStart()
    print("[ShopController] Starting...")
    
    -- Get GamePassService
    self._gamePassService = Knit.GetService("GamePassService")
    
    -- Wait for shop interaction point to exist
    task.spawn(function()
        local workspace = game:GetService("Workspace")
        repeat task.wait(1) until workspace:FindFirstChild("SpawnArea")
        
        local spawnArea = workspace.SpawnArea
        local shopInteraction = spawnArea:FindFirstChild("ShopInteraction")
        
        if shopInteraction then
            self._shopInteraction = shopInteraction
            
            -- Create UI
            self:_createShopUI()
            
            -- Listen for click on shop NPC
            local clickDetector = shopInteraction:FindFirstChildOfClass("ClickDetector")
            if clickDetector then
                clickDetector.MouseClick:Connect(function(player)
                    if player == self._player then
                        self:_openShop()
                    end
                end)
            end
        end
    end)
    
    print("[ShopController] Started!")
end

--[[ Private Methods ]]--

function ShopController:_createShopUI()
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PremiumShopUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = self._player.PlayerGui
    
    -- Shop toggle button (right side, vertical layout) - ImageButton
    local Constants = require(game:GetService("ReplicatedStorage").Shared.Constants)
    local navConfig = Constants.UI.PLANET_UI.NAV_BUTTONS
    local buttonIndex = 2 -- Third button in vertical stack
    
    local shopButton = Instance.new("ImageButton")
    shopButton.Name = "ShopButton"
    shopButton.Size = navConfig.BUTTON_SIZE
    shopButton.Position = UDim2.new(1, -(navConfig.RIGHT_OFFSET + navConfig.BUTTON_SIZE.X.Offset), 0, navConfig.START_Y + (buttonIndex * (navConfig.BUTTON_SIZE.Y.Offset + navConfig.BUTTON_SPACING)))
    shopButton.AnchorPoint = Vector2.new(0, 0)
    shopButton.BackgroundTransparency = 1
    shopButton.Image = "rbxassetid://140353244803526"
    shopButton.ScaleType = Enum.ScaleType.Fit
    shopButton.Parent = screenGui
    
    -- Shop panel (hidden by default)
    local shopPanel = Instance.new("Frame")
    shopPanel.Name = "ShopPanel"
    shopPanel.Size = UDim2.new(0, 800, 0, 600)
    shopPanel.Position = UDim2.new(0.5, -400, 0.5, -300)
    shopPanel.BackgroundColor3 = Color3.fromRGB(20, 15, 30)
    shopPanel.BorderSizePixel = 0
    shopPanel.Visible = false
    shopPanel.Parent = screenGui
    
    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 12)
    panelCorner.Parent = shopPanel
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -60, 0, 60)
    title.Position = UDim2.new(0, 20, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "⭐ PREMIUM SHOP ⭐"
    title.TextColor3 = Color3.fromRGB(255, 215, 0)
    title.TextSize = 32
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = shopPanel
    
    -- Subtitle
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(1, -60, 0, 30)
    subtitle.Position = UDim2.new(0, 20, 0, 55)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Enhance your planet-growing experience with premium perks!"
    subtitle.TextColor3 = Color3.fromRGB(180, 180, 200)
    subtitle.TextSize = 14
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = shopPanel
    
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
    closeButton.Parent = shopPanel
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        shopPanel.Visible = false
    end)
    
    -- Shop button click handler
    shopButton.MouseButton1Click:Connect(function()
        shopPanel.Visible = not shopPanel.Visible
        if shopPanel.Visible then
            self:_loadGamePasses()
        end
    end)
    
    -- Scrolling frame for game passes
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "GamePassScroll"
    scrollFrame.Size = UDim2.new(1, -40, 1, -110)
    scrollFrame.Position = UDim2.new(0, 20, 0, 90)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 10
    scrollFrame.Parent = shopPanel
    
    -- Grid layout
    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.new(0, 240, 0, 200)
    grid.CellPadding = UDim2.new(0, 15, 0, 15)
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    grid.Parent = scrollFrame
    
    self._ui = screenGui
    self._shopPanel = shopPanel
    self._scrollFrame = scrollFrame
end

function ShopController:_openShop()
    if not self._shopPanel then return end
    
    self._shopPanel.Visible = true
    
    -- Load game passes
    self:_loadGamePasses()
end

function ShopController:_loadGamePasses()
    -- Get all game passes
    self._gamePassService:GetAllGamePasses():andThen(function(gamePasses)
        return self._gamePassService:GetOwnedGamePasses(), gamePasses
    end):andThen(function(ownedPasses, allPasses)
        self:_displayGamePasses(allPasses, ownedPasses)
    end):catch(function(err)
        warn("[ShopController] Failed to load game passes:", err)
    end)
end

function ShopController:_displayGamePasses(gamePasses: {{}}, ownedPasses: {string})
    -- Clear existing cards
    for _, child in ipairs(self._scrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Create cards for each game pass
    for i, pass in ipairs(gamePasses) do
        self:_createGamePassCard(pass, table.find(ownedPasses, pass.internalId) ~= nil, i)
    end
    
    -- Update canvas size
    local grid = self._scrollFrame:FindFirstChildOfClass("UIGridLayout")
    if grid then
        self._scrollFrame.CanvasSize = UDim2.new(0, 0, 0, grid.AbsoluteContentSize.Y + 20)
    end
end

function ShopController:_createGamePassCard(pass: {}, isOwned: boolean, order: number)
    local card = Instance.new("Frame")
    card.Name = pass.internalId
    card.BackgroundColor3 = isOwned and Color3.fromRGB(30, 60, 30) or Color3.fromRGB(40, 35, 50)
    card.BorderSizePixel = 0
    card.LayoutOrder = order
    card.Parent = self._scrollFrame
    
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 10)
    cardCorner.Parent = card
    
    -- Stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = isOwned and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(255, 215, 0)
    stroke.Thickness = isOwned and 3 or 2
    stroke.Transparency = isOwned and 0 or 0.5
    stroke.Parent = card
    
    -- Icon
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(1, 0, 0, 50)
    icon.Position = UDim2.new(0, 0, 0, 10)
    icon.BackgroundTransparency = 1
    icon.Text = pass.icon
    icon.TextSize = 40
    icon.Parent = card
    
    -- Name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -10, 0, 30)
    nameLabel.Position = UDim2.new(0, 5, 0, 60)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = pass.name
    nameLabel.TextColor3 = isOwned and Color3.fromRGB(150, 255, 150) or Color3.fromRGB(255, 215, 0)
    nameLabel.TextSize = 16
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextWrapped = true
    nameLabel.Parent = card
    
    -- Description
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -10, 0, 50)
    descLabel.Position = UDim2.new(0, 5, 0, 90)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = pass.description
    descLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    descLabel.TextSize = 12
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextWrapped = true
    descLabel.Parent = card
    
    -- Purchase button or owned label
    if isOwned then
        local ownedLabel = Instance.new("TextLabel")
        ownedLabel.Size = UDim2.new(1, -10, 0, 35)
        ownedLabel.Position = UDim2.new(0, 5, 1, -45)
        ownedLabel.BackgroundTransparency = 1
        ownedLabel.Text = "✓ OWNED"
        ownedLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        ownedLabel.TextSize = 18
        ownedLabel.Font = Enum.Font.GothamBold
        ownedLabel.Parent = card
    else
        local buyButton = Instance.new("TextButton")
        buyButton.Size = UDim2.new(1, -10, 0, 35)
        buyButton.Position = UDim2.new(0, 5, 1, -45)
        buyButton.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
        buyButton.Text = "BUY - " .. pass.price .. " R$"
        buyButton.TextColor3 = Color3.new(0, 0, 0)
        buyButton.TextSize = 16
        buyButton.Font = Enum.Font.GothamBold
        buyButton.Parent = card
        
        local buyCorner = Instance.new("UICorner")
        buyCorner.CornerRadius = UDim.new(0, 6)
        buyCorner.Parent = buyButton
        
        -- Purchase handler
        buyButton.MouseButton1Click:Connect(function()
            self:_purchaseGamePass(pass.internalId)
        end)
    end
end

function ShopController:_purchaseGamePass(internalId: string)
    print("[ShopController] Purchasing game pass:", internalId)
    
    self._gamePassService:PurchaseGamePass(internalId):catch(function(err)
        warn("[ShopController] Purchase error:", err)
    end)
end

return ShopController
