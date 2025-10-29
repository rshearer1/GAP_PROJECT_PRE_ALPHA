-- PetController.lua
-- Client-side pet UI and interactions (basic)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local PetTypes = require(ReplicatedStorage.Shared.PetTypes)

local player = Players.LocalPlayer
local PetController = Knit.CreateController({ Name = "PetController" })

PetController._gui = nil
PetController._janitor = Janitor.new()

function PetController:KnitInit()
    print("[PetController] Initializing...")
end

function PetController:KnitStart()
    print("[PetController] Starting...")
    self._petService = Knit.GetService("PetService")
    self:_createUI()
    
    -- Listen for pet changes and auto-refresh if panel is visible
    self._petService.PetsChanged:Connect(function()
        print("[PetController] Pets changed, refreshing UI...")
        if self._panel and self._panel.Visible then
            self:_refreshPets(self._list, self._layout)
        end
    end)
end

function PetController:_createUI()
    local playerGui = player:WaitForChild("PlayerGui")

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PetUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui

    self._janitor:Add(screenGui)
    self._gui = screenGui

    -- Toggle button (matches existing nav button pattern - will be PNG when uploaded)
    local Constants = require(ReplicatedStorage.Shared.Constants)
    local navConfig = Constants.UI.PLANET_UI.NAV_BUTTONS
    local buttonIndex = 4 -- Fifth button in vertical stack (after Stars, Galaxy, Shop, Settings)
    
    -- Using TextButton temporarily until PNG icon is uploaded
    -- TODO: Replace with ImageButton + rbxassetid when Pet icon PNG is created
    local toggle = Instance.new("TextButton")
    toggle.Name = "PetToggle"
    toggle.Size = navConfig.BUTTON_SIZE
    toggle.Position = UDim2.new(1, -(navConfig.RIGHT_OFFSET + navConfig.BUTTON_SIZE.X.Offset), 0, navConfig.START_Y + (buttonIndex * (navConfig.BUTTON_SIZE.Y.Offset + navConfig.BUTTON_SPACING)))
    toggle.BackgroundColor3 = Color3.fromRGB(142, 68, 173)  -- Amethyst from design system
    toggle.Text = "🐾"
    toggle.TextColor3 = Color3.new(1, 1, 1)
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 28
    toggle.Parent = screenGui
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 8)
    toggleCorner.Parent = toggle

    -- Pet panel (RESPONSIVE - scale-based, centered with AnchorPoint)
    local panel = Instance.new("Frame")
    panel.Name = "PetPanel"
    
    -- RESPONSIVE: Scale-based size (25% width, 50% height)
    panel.Size = UDim2.new(0.25, 0, 0.5, 0)
    
    -- RESPONSIVE: Center with AnchorPoint
    panel.Position = UDim2.new(0.5, 0, 0.5, 0)
    panel.AnchorPoint = Vector2.new(0.5, 0.5)  -- Center anchor for consistent centering
    
    panel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)  -- Deep Space from design system
    panel.BorderSizePixel = 0
    panel.Visible = false
    panel.Parent = screenGui
    
    -- Add constraints for min/max sizes
    local panelConstraint = Instance.new("UISizeConstraint")
    panelConstraint.MinSize = Vector2.new(300, 400)  -- Minimum for mobile readability
    panelConstraint.MaxSize = Vector2.new(600, 800)  -- Maximum for large screens
    panelConstraint.Parent = panel
    
    -- Maintain aspect ratio (slightly taller than wide)
    local panelAspect = Instance.new("UIAspectRatioConstraint")
    panelAspect.AspectRatio = 0.85  -- Width/Height ratio
    panelAspect.Parent = panel
    
    -- Rounded corners (2% of panel size for responsive scaling)
    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0.02, 0)
    panelCorner.Parent = panel

    -- Title (RESPONSIVE - scale-based within panel)
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    
    -- RESPONSIVE: Scale relative to panel (90% width, 8% height)
    title.Size = UDim2.new(0.9, 0, 0.08, 0)
    title.Position = UDim2.new(0.05, 0, 0.02, 0)  -- 5% padding from left, 2% from top
    
    title.BackgroundTransparency = 1
    title.Text = "My Pets"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true  -- RESPONSIVE: Scale text
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = panel
    
    -- Text size constraints
    local titleTextConstraint = Instance.new("UITextSizeConstraint")
    titleTextConstraint.MinTextSize = 14
    titleTextConstraint.MaxTextSize = 22
    titleTextConstraint.Parent = title

    -- Scrolling list (RESPONSIVE - scale relative to panel)
    local list = Instance.new("ScrollingFrame")
    list.Name = "PetList"
    
    -- RESPONSIVE: Fill most of panel (90% width, 82% height)
    list.Size = UDim2.new(0.9, 0, 0.82, 0)
    list.Position = UDim2.new(0.05, 0, 0.12, 0)  -- Below title
    
    list.BackgroundTransparency = 1
    list.BorderSizePixel = 0
    list.CanvasSize = UDim2.new(0, 0, 0, 0)
    list.ScrollBarThickness = 6
    list.Parent = panel

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = list

    -- Toggle to show/hide panel
    toggle.MouseButton1Click:Connect(function()
        panel.Visible = not panel.Visible
        if panel.Visible then
            self:_refreshPets(list, layout)
        end
    end)

    self._panel = panel
    self._list = list
    self._layout = layout
end

function PetController:_refreshPets(list, layout)
    print("[PetController] Refreshing pets...")
    
    -- Clear existing
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local PetService = self._petService
    if not PetService then 
        warn("[PetController] PetService is nil!")
        return 
    end

    -- Request player's pets from server (Knit returns a Promise)
    print("[PetController] Calling PetService:GetPets()...")
    
    -- Use andThen to properly handle the Promise
    PetService:GetPets():andThen(function(pets)
        print("[PetController] Received", #pets, "pets from server")
        if #pets > 0 then
            print("[PetController] First pet:", pets[1].name, pets[1].rarity)
        end
        
        -- Render pets
        print("[PetController] Rendering", #pets, "pets...")
        for i, pet in ipairs(pets) do
            -- RESPONSIVE: Pet row (scale-based)
            local row = Instance.new("Frame")
            row.Name = "PetRow" .. tostring(i)
            row.Size = UDim2.new(1, 0, 0, 56)  -- Full width, fixed height for now
            row.BackgroundTransparency = 1
            row.Parent = list

            -- Pet name label (RESPONSIVE)
            local name = Instance.new("TextLabel")
            name.Size = UDim2.new(0.6, 0, 1, 0)  -- 60% of row width
            name.Position = UDim2.new(0, 0, 0, 0)
            name.BackgroundTransparency = 1
            name.Text = pet.name .. " (" .. pet.rarity .. ")"
            name.TextColor3 = Color3.new(1, 1, 1)
            name.TextScaled = true  -- RESPONSIVE: Scale text
            name.Font = Enum.Font.Gotham
            name.TextXAlignment = Enum.TextXAlignment.Left
            name.Parent = row
            
            -- Text constraints for name
            local nameTextConstraint = Instance.new("UITextSizeConstraint")
            nameTextConstraint.MinTextSize = 10
            nameTextConstraint.MaxTextSize = 16
            nameTextConstraint.Parent = name

            -- Bonus label (RESPONSIVE)
            local bonus = Instance.new("TextLabel")
            bonus.Size = UDim2.new(0.35, 0, 1, 0)  -- 35% of row width
            bonus.Position = UDim2.new(0.65, 0, 0, 0)  -- After name
            bonus.BackgroundTransparency = 1
            bonus.Text = string.format("+%.0f%%", pet.resourceBonus * 100)
            bonus.TextColor3 = Color3.fromRGB(142, 68, 173)  -- Amethyst from design system
            bonus.TextScaled = true  -- RESPONSIVE: Scale text
            bonus.Font = Enum.Font.GothamBold
            bonus.TextXAlignment = Enum.TextXAlignment.Right
            bonus.Parent = row
            
            -- Text constraints for bonus
            local bonusTextConstraint = Instance.new("UITextSizeConstraint")
            bonusTextConstraint.MinTextSize = 10
            bonusTextConstraint.MaxTextSize = 16
            bonusTextConstraint.Parent = bonus
        end

        -- Update canvas size
        task.wait(0)
        list.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end):catch(function(err)
        warn("[PetController] Failed to get pets:", err)
    end)
end

function PetController:KnitStop()
    self._janitor:Destroy()
end

return PetController
