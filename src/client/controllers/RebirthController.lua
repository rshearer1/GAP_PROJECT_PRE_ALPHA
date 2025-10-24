--[[
    RebirthController.lua
    Client-side rebirth UI and management
    
    Displays:
    - Rebirth button (appears when eligible)
    - Rebirth info panel (requirements, rewards)
    - Confirmation dialog with warning
]]

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local RebirthController = Knit.CreateController {
    Name = "RebirthController",
    
    -- UI Elements
    _rebirthGui = nil,
    _rebirthButton = nil,
    _infoPanel = nil,
    _confirmDialog = nil,
    
    -- State
    _rebirthInfo = nil,
    _checkInterval = 5, -- Check eligibility every 5 seconds
}

function RebirthController:KnitInit()
    print("[RebirthController] Initializing...")
end

function RebirthController:KnitStart()
    print("[RebirthController] Starting...")
    
    -- Get services
    self._rebirthService = Knit.GetService("RebirthService")
    self._planetController = Knit.GetController("PlanetController")
    
    -- Create UI
    self:_createUI()
    
    -- Start checking eligibility
    task.spawn(function()
        self:_checkEligibilityLoop()
    end)
    
    print("[RebirthController] Started successfully!")
end

--[[ UI Creation ]]--

function RebirthController:_createUI()
    -- Create ScreenGui
    self._rebirthGui = Instance.new("ScreenGui")
    self._rebirthGui.Name = "RebirthUI"
    self._rebirthGui.ResetOnSpawn = false
    self._rebirthGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self._rebirthGui.Parent = playerGui
    
    -- Rebirth button (top-right, appears when eligible, smaller)
    self._rebirthButton = Instance.new("TextButton")
    self._rebirthButton.Name = "RebirthButton"
    self._rebirthButton.Size = UDim2.new(0, 90, 0, 35) -- Reduced from 120x50
    self._rebirthButton.Position = UDim2.new(1, -275, 0, 10) -- Adjusted position
    self._rebirthButton.AnchorPoint = Vector2.new(0, 0)
    self._rebirthButton.BackgroundColor3 = Color3.fromRGB(155, 89, 182) -- Purple
    self._rebirthButton.Text = "🔄 Rebirth"
    self._rebirthButton.TextColor3 = Color3.new(1, 1, 1)
    self._rebirthButton.TextSize = 14 -- Reduced from 18
    self._rebirthButton.Font = Enum.Font.GothamBold
    self._rebirthButton.Visible = false -- Hidden until eligible
    self._rebirthButton.Parent = self._rebirthGui
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = self._rebirthButton
    
    -- Pulsing animation for rebirth button
    local pulse = Instance.new("UIScale")
    pulse.Parent = self._rebirthButton
    
    task.spawn(function()
        while true do
            if self._rebirthButton.Visible then
                for i = 1, 10 do
                    pulse.Scale = 1 + (math.sin(i / 10 * math.pi) * 0.05)
                    task.wait(0.1)
                end
            end
            task.wait(0.1)
        end
    end)
    
    -- Info panel (shown when clicking rebirth button)
    self:_createInfoPanel()
    
    -- Confirmation dialog
    self:_createConfirmDialog()
    
    -- Button click handlers
    self._rebirthButton.MouseButton1Click:Connect(function()
        self:_showInfoPanel()
    end)
end

function RebirthController:_createInfoPanel()
    self._infoPanel = Instance.new("Frame")
    self._infoPanel.Name = "InfoPanel"
    self._infoPanel.Size = UDim2.new(0, 600, 0, 500)
    self._infoPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
    self._infoPanel.AnchorPoint = Vector2.new(0.5, 0.5)
    self._infoPanel.BackgroundColor3 = Color3.fromRGB(44, 62, 80)
    self._infoPanel.Visible = false
    self._infoPanel.Parent = self._rebirthGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = self._infoPanel
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -40, 0, 50)
    title.Position = UDim2.new(0, 20, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "🔄 Rebirth System"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 28
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = self._infoPanel
    
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
    closeButton.Parent = self._infoPanel
    
    local closeCorne = Instance.new("UICorner")
    closeCorne.CornerRadius = UDim.new(0, 8)
    closeCorne.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        self._infoPanel.Visible = false
    end)
    
    -- Content scroll frame
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "ContentScroll"
    scroll.Size = UDim2.new(1, -40, 1, -140)
    scroll.Position = UDim2.new(0, 20, 0, 60)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 8
    scroll.Parent = self._infoPanel
    
    -- Layout for content
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll
    
    -- Rebirth button at bottom
    local rebirthBtn = Instance.new("TextButton")
    rebirthBtn.Name = "ConfirmButton"
    rebirthBtn.Size = UDim2.new(1, -40, 0, 50)
    rebirthBtn.Position = UDim2.new(0, 20, 1, -60)
    rebirthBtn.BackgroundColor3 = Color3.fromRGB(155, 89, 182)
    rebirthBtn.Text = "🔄 REBIRTH NOW"
    rebirthBtn.TextColor3 = Color3.new(1, 1, 1)
    rebirthBtn.TextSize = 20
    rebirthBtn.Font = Enum.Font.GothamBold
    rebirthBtn.Parent = self._infoPanel
    
    local rebirthCorner = Instance.new("UICorner")
    rebirthCorner.CornerRadius = UDim.new(0, 8)
    rebirthCorner.Parent = rebirthBtn
    
    rebirthBtn.MouseButton1Click:Connect(function()
        self:_showConfirmDialog()
    end)
end

function RebirthController:_createConfirmDialog()
    self._confirmDialog = Instance.new("Frame")
    self._confirmDialog.Name = "ConfirmDialog"
    self._confirmDialog.Size = UDim2.new(0, 400, 0, 250)
    self._confirmDialog.Position = UDim2.new(0.5, 0, 0.5, 0)
    self._confirmDialog.AnchorPoint = Vector2.new(0.5, 0.5)
    self._confirmDialog.BackgroundColor3 = Color3.fromRGB(231, 76, 60) -- Red warning
    self._confirmDialog.Visible = false
    self._confirmDialog.ZIndex = 10
    self._confirmDialog.Parent = self._rebirthGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = self._confirmDialog
    
    -- Warning text
    local warning = Instance.new("TextLabel")
    warning.Size = UDim2.new(1, -40, 0, 150)
    warning.Position = UDim2.new(0, 20, 0, 20)
    warning.BackgroundTransparency = 1
    warning.Text = "⚠️ WARNING ⚠️\n\nThis will RESET all your planets,\nresources, levels, and upgrades!\n\nAre you absolutely sure?"
    warning.TextColor3 = Color3.new(1, 1, 1)
    warning.TextSize = 18
    warning.Font = Enum.Font.GothamBold
    warning.TextWrapped = true
    warning.Parent = self._confirmDialog
    
    -- Confirm button
    local confirmBtn = Instance.new("TextButton")
    confirmBtn.Size = UDim2.new(0.45, 0, 0, 50)
    confirmBtn.Position = UDim2.new(0.05, 0, 1, -60)
    confirmBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Green
    confirmBtn.Text = "✓ YES"
    confirmBtn.TextColor3 = Color3.new(1, 1, 1)
    confirmBtn.TextSize = 20
    confirmBtn.Font = Enum.Font.GothamBold
    confirmBtn.Parent = self._confirmDialog
    
    local confirmCorner = Instance.new("UICorner")
    confirmCorner.CornerRadius = UDim.new(0, 8)
    confirmCorner.Parent = confirmBtn
    
    -- Cancel button
    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Size = UDim2.new(0.45, 0, 0, 50)
    cancelBtn.Position = UDim2.new(0.5, 0, 1, -60)
    cancelBtn.BackgroundColor3 = Color3.fromRGB(149, 165, 166) -- Gray
    cancelBtn.Text = "✕ CANCEL"
    cancelBtn.TextColor3 = Color3.new(1, 1, 1)
    cancelBtn.TextSize = 20
    cancelBtn.Font = Enum.Font.GothamBold
    cancelBtn.Parent = self._confirmDialog
    
    local cancelCorner = Instance.new("UICorner")
    cancelCorner.CornerRadius = UDim.new(0, 8)
    cancelCorner.Parent = cancelBtn
    
    -- Button handlers
    confirmBtn.MouseButton1Click:Connect(function()
        self:_executeRebirth()
    end)
    
    cancelBtn.MouseButton1Click:Connect(function()
        self._confirmDialog.Visible = false
    end)
end

--[[ Data Loading ]]--

function RebirthController:_checkEligibilityLoop()
    while true do
        self:_updateRebirthInfo()
        task.wait(self._checkInterval)
    end
end

function RebirthController:_updateRebirthInfo()
    self._rebirthService:GetRebirthInfo():andThen(function(info)
        self._rebirthInfo = info
        
        -- Show/hide rebirth button based on eligibility
        self._rebirthButton.Visible = info.canRebirth
        
        -- Update info panel if visible
        if self._infoPanel and self._infoPanel.Visible then
            self:_refreshInfoPanel()
        end
    end):catch(function(err)
        warn("[RebirthController] Failed to get rebirth info:", err)
    end)
end

function RebirthController:_refreshInfoPanel()
    if not self._rebirthInfo then return end
    
    local scroll = self._infoPanel:FindFirstChild("ContentScroll")
    if not scroll then return end
    
    -- Clear existing content
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("TextLabel") or child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    local info = self._rebirthInfo
    
    -- Progress section
    self:_addInfoSection(scroll, "📊 Progress", string.format(
        "Completion: %.1f%% (%d / %d items)\nLevel: %d (need %d)\n\n%s",
        info.completionPercent,
        info.unlockedItems,
        info.totalItems,
        info.currentLevel,
        info.minLevel,
        info.canRebirth and "✅ Ready to Rebirth!" or "❌ Not ready yet"
    ), 1)
    
    -- Current stats section
    self:_addInfoSection(scroll, "⭐ Current Stats", string.format(
        "Rebirths: %d\nRank: %s\nBonus: +%.0f%%",
        info.rebirthCount,
        info.currentRank,
        info.currentMultiplier * 100
    ), 2)
    
    -- Rewards section
    self:_addInfoSection(scroll, "🎁 Rebirth Rewards", string.format(
        "New Rank: %s\nNew Bonus: +%.0f%% (total)\nBonus Stars: %d\n\n✨ New random solar system!",
        info.nextRank,
        info.newMultiplier * 100,
        info.bonusStars
    ), 3)
    
    -- Keeps section
    self:_addInfoSection(scroll, "✅ What You Keep", 
        "⭐ Stars\n🗺️ Star Map Upgrades\n📈 Rebirth Multiplier\n🏆 Achievements", 4)
    
    -- Resets section
    self:_addInfoSection(scroll, "❌ What Resets", 
        "🌍 All Planets (new solar system)\n💧 All Resources\n📊 All Levels\n🛒 All Upgrades\n🌱 All Biomes", 5)
    
    -- Update canvas size
    local layout = scroll:FindFirstChild("UIListLayout")
    if layout then
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end
end

function RebirthController:_addInfoSection(parent, title: string, content: string, order: number)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 120)
    section.BackgroundColor3 = Color3.fromRGB(52, 73, 94)
    section.BorderSizePixel = 0
    section.LayoutOrder = order
    section.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = section
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 30)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(241, 196, 15) -- Gold
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = section
    
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Size = UDim2.new(1, -20, 1, -40)
    contentLabel.Position = UDim2.new(0, 10, 0, 35)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = content
    contentLabel.TextColor3 = Color3.fromRGB(236, 240, 241)
    contentLabel.TextSize = 14
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextYAlignment = Enum.TextYAlignment.Top
    contentLabel.TextWrapped = true
    contentLabel.Parent = section
    
    -- Auto-size section based on content
    section.Size = UDim2.new(1, 0, 0, math.max(120, contentLabel.TextBounds.Y + 50))
end

--[[ Actions ]]--

function RebirthController:_showInfoPanel()
    self:_updateRebirthInfo()
    task.wait(0.1) -- Wait for info to load
    self:_refreshInfoPanel()
    self._infoPanel.Visible = true
end

function RebirthController:_showConfirmDialog()
    self._infoPanel.Visible = false
    self._confirmDialog.Visible = true
end

function RebirthController:_executeRebirth()
    print("[RebirthController] Executing rebirth...")
    
    self._confirmDialog.Visible = false
    
    self._rebirthService:ExecuteRebirth():andThen(function(success, message)
        if success then
            print("[RebirthController] Rebirth successful!")
            
            -- Hide info panel
            self._infoPanel.Visible = false
            
            -- Refresh planet UI
            if self._planetController and self._planetController.refreshPlanetState then
                task.wait(0.5) -- Wait for server to process
                self._planetController:refreshPlanetState()
            end
            
            -- Show success message (you can make a nicer notification later)
            print("🎉 " .. message)
        else
            warn("[RebirthController] Rebirth failed:", message)
        end
    end):catch(function(err)
        warn("[RebirthController] Rebirth error:", err)
    end)
end

return RebirthController
