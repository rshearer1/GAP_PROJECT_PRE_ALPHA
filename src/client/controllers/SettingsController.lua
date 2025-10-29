--[[
    SettingsController.lua
    Client-side settings UI for volume and graphics controls
    
    Features:
    - Master volume control
    - Music volume control
    - Sound effects volume control
    - Graphics quality settings
]]

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")

local SettingsController = Knit.CreateController {
    Name = "SettingsController",
    _player = nil,
    _ui = nil,
    _settingsPanel = nil,
}

function SettingsController:KnitInit()
    print("[SettingsController] Initializing...")
    self._player = Players.LocalPlayer
end

function SettingsController:KnitStart()
    print("[SettingsController] Starting...")
    self:_createUI()
    print("[SettingsController] Started successfully!")
end

---
-- Create the settings UI
--
function SettingsController:_createUI()
    local playerGui = self._player:WaitForChild("PlayerGui")
    
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SettingsUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui
    
    -- Settings button (right side, vertical layout) - ImageButton
    local Constants = require(game:GetService("ReplicatedStorage").Shared.Constants)
    local navConfig = Constants.UI.PLANET_UI.NAV_BUTTONS
    local buttonIndex = 3 -- Fourth button in vertical stack
    
    local settingsButton = Instance.new("ImageButton")
    settingsButton.Name = "SettingsButton"
    settingsButton.Size = navConfig.BUTTON_SIZE
    settingsButton.Position = UDim2.new(1, -(navConfig.RIGHT_OFFSET + navConfig.BUTTON_SIZE.X.Offset), 0, navConfig.START_Y + (buttonIndex * (navConfig.BUTTON_SIZE.Y.Offset + navConfig.BUTTON_SPACING)))
    settingsButton.AnchorPoint = Vector2.new(0, 0)
    settingsButton.BackgroundTransparency = 1
    settingsButton.Image = "rbxassetid://80743411284468"
    settingsButton.ScaleType = Enum.ScaleType.Fit
    settingsButton.Parent = screenGui
    
    -- Settings panel (hidden by default)
    local settingsPanel = Instance.new("Frame")
    settingsPanel.Name = "SettingsPanel"
    settingsPanel.Size = UDim2.new(0, 500, 0, 450)
    settingsPanel.Position = UDim2.new(0.5, -250, 0.5, -225)
    settingsPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    settingsPanel.BorderSizePixel = 0
    settingsPanel.Visible = false
    settingsPanel.Parent = screenGui
    
    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 12)
    panelCorner.Parent = settingsPanel
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -60, 0, 50)
    title.Position = UDim2.new(0, 20, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "⚙️ Settings"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 28
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = settingsPanel
    
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
    closeButton.Parent = settingsPanel
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton
    
    -- Content frame
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -40, 1, -80)
    contentFrame.Position = UDim2.new(0, 20, 0, 70)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = settingsPanel
    
    -- Volume Section Header
    local volumeHeader = Instance.new("TextLabel")
    volumeHeader.Name = "VolumeHeader"
    volumeHeader.Size = UDim2.new(1, 0, 0, 30)
    volumeHeader.Position = UDim2.new(0, 0, 0, 0)
    volumeHeader.BackgroundTransparency = 1
    volumeHeader.Text = "🔊 Volume Controls"
    volumeHeader.TextColor3 = Color3.fromRGB(255, 200, 100)
    volumeHeader.TextSize = 20
    volumeHeader.Font = Enum.Font.GothamBold
    volumeHeader.TextXAlignment = Enum.TextXAlignment.Left
    volumeHeader.Parent = contentFrame
    
    -- Master Volume
    self:_createSlider(contentFrame, "Master Volume", 0, 40, function(value)
        SoundService.Volume = value
    end)
    
    -- Music Volume
    self:_createSlider(contentFrame, "Music Volume", 0, 90, function(value)
        -- TODO: Implement music volume control when music system is added
        print("[SettingsController] Music volume set to:", value)
    end)
    
    -- SFX Volume
    self:_createSlider(contentFrame, "SFX Volume", 0, 140, function(value)
        -- TODO: Implement SFX volume control when sound system is added
        print("[SettingsController] SFX volume set to:", value)
    end)
    
    -- Graphics Section Header
    local graphicsHeader = Instance.new("TextLabel")
    graphicsHeader.Name = "GraphicsHeader"
    graphicsHeader.Size = UDim2.new(1, 0, 0, 30)
    graphicsHeader.Position = UDim2.new(0, 0, 0, 200)
    graphicsHeader.BackgroundTransparency = 1
    graphicsHeader.Text = "🎨 Graphics"
    graphicsHeader.TextColor3 = Color3.fromRGB(255, 200, 100)
    graphicsHeader.TextSize = 20
    graphicsHeader.Font = Enum.Font.GothamBold
    graphicsHeader.TextXAlignment = Enum.TextXAlignment.Left
    graphicsHeader.Parent = contentFrame
    
    -- Graphics Quality Buttons
    self:_createGraphicsButtons(contentFrame)
    
    -- Button click handlers
    settingsButton.MouseButton1Click:Connect(function()
        settingsPanel.Visible = not settingsPanel.Visible
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        settingsPanel.Visible = false
    end)
    
    self._ui = screenGui
    self._settingsPanel = settingsPanel
end

---
-- Create a volume slider
-- @param parent Parent frame
-- @param labelText Label text
-- @param yPos Y position
-- @param yOffset Y offset from position
-- @param callback Function to call when value changes
--
function SettingsController:_createSlider(parent: Frame, labelText: string, yPos: number, yOffset: number, callback: (number) -> ())
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = labelText:gsub(" ", "") .. "Label"
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, yOffset)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 16
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    
    -- Slider background
    local sliderBg = Instance.new("Frame")
    sliderBg.Name = labelText:gsub(" ", "") .. "SliderBg"
    sliderBg.Size = UDim2.new(1, -100, 0, 8)
    sliderBg.Position = UDim2.new(0, 0, 0, yOffset + 25)
    sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = parent
    
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 4)
    bgCorner.Parent = sliderBg
    
    -- Slider fill
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "Fill"
    sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = sliderFill
    
    -- Value label
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "ValueLabel"
    valueLabel.Size = UDim2.new(0, 80, 0, 30)
    valueLabel.Position = UDim2.new(1, -90, 0, yOffset + 17)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = "50%"
    valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueLabel.TextSize = 16
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = parent
    
    -- Make slider interactive
    local dragging = false
    
    local function updateSlider(input)
        local relativeX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
        valueLabel.Text = math.floor(relativeX * 100) .. "%"
        callback(relativeX)
    end
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)
    
    sliderBg.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    sliderBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

---
-- Create graphics quality buttons
-- @param parent Parent frame
--
function SettingsController:_createGraphicsButtons(parent: Frame)
    local graphicsLevels = {"Low", "Medium", "High", "Ultra"}
    local buttonWidth = 100
    local spacing = 10
    
    for i, level in ipairs(graphicsLevels) do
        local button = Instance.new("TextButton")
        button.Name = level .. "Button"
        button.Size = UDim2.new(0, buttonWidth, 0, 40)
        button.Position = UDim2.new(0, (i - 1) * (buttonWidth + spacing), 0, 240)
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        button.Text = level
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.Font = Enum.Font.GothamBold
        button.TextSize = 14
        button.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = button
        
        -- Click handler
        button.MouseButton1Click:Connect(function()
            self:_setGraphicsQuality(level)
            -- Highlight selected button
            for _, child in ipairs(parent:GetChildren()) do
                if child:IsA("TextButton") and child.Name:match("Button$") then
                    child.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
                end
            end
            button.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
        end)
    end
end

---
-- Set graphics quality
-- @param level Quality level: "Low", "Medium", "High", "Ultra"
--
function SettingsController:_setGraphicsQuality(level: string)
    local settings = UserSettings():GetService("UserGameSettings")
    
    if level == "Low" then
        settings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
    elseif level == "Medium" then
        settings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel5
    elseif level == "High" then
        settings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel8
    elseif level == "Ultra" then
        settings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel10
    end
    
    print(`[SettingsController] Graphics quality set to: {level}`)
end

return SettingsController
