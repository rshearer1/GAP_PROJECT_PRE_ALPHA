--[[
    PlanetLandingController.lua
    Client-side landing and takeoff UI and camera transitions
    
    Handles:
    - Proximity UI when near planets
    - E key to land on planet
    - Camera transition animations
    - Space key to return to ship
    - Character spawning on planet surface
    
    GAP Compliance:
    - Uses Janitor for cleanup
    - References Constants for all values
    - JSDoc comments on all methods
]]

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Janitor = require(game:GetService("ReplicatedStorage").Packages.Janitor)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local Constants = require(ReplicatedStorage.Shared.Constants)

local PlanetLandingController = Knit.CreateController {
    Name = "PlanetLandingController",
    
    -- State
    _isLanded = false,
    _currentPlanetId = nil,
    _nearbyPlanets = {},
    
    -- UI
    _proximityUI = nil,
    _landingPrompt = nil,
    
    -- Services
    _planetProximityService = nil,
    _spaceController = nil,
    
    -- Janitor
    _janitor = nil,
}

---
-- Initialize PlanetLandingController
--
function PlanetLandingController:KnitInit()
    print("[PlanetLandingController] Initializing...")
    self._janitor = Janitor.new()
end

---
-- Start PlanetLandingController
--
function PlanetLandingController:KnitStart()
    print("[PlanetLandingController] Starting...")
    
    local player = Players.LocalPlayer
    
    -- Wait for character
    if not player.Character then
        player.CharacterAdded:Wait()
    end
    
    -- Get services
    self._planetProximityService = Knit.GetService("PlanetProximityService")
    
    -- Try to get SpaceController (might not exist yet)
    local success, spaceController = pcall(function()
        return Knit.GetController("SpaceController")
    end)
    if success then
        self._spaceController = spaceController
    end
    
    -- Create proximity UI
    self:_createProximityUI()
    
    -- Set up controls
    self:_setupControls()
    
    -- Start proximity check loop
    self:_startProximityLoop()
    
    print("[PlanetLandingController] Started successfully!")
end

---
-- Create proximity UI for landing prompt
-- @private
--
function PlanetLandingController:_createProximityUI()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PlanetLandingUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui
    
    -- Landing prompt (hidden by default)
    local promptFrame = Instance.new("Frame")
    promptFrame.Name = "LandingPrompt"
    promptFrame.Size = UDim2.new(0, 300, 0, 80)
    promptFrame.Position = UDim2.new(0.5, -150, 0.7, 0)
    promptFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    promptFrame.BackgroundTransparency = 0.3
    promptFrame.BorderSizePixel = 0
    promptFrame.Visible = false
    promptFrame.Parent = screenGui
    
    -- Corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = promptFrame
    
    -- Key hint
    local keyLabel = Instance.new("TextLabel")
    keyLabel.Name = "KeyLabel"
    keyLabel.Size = UDim2.new(0, 60, 0, 60)
    keyLabel.Position = UDim2.new(0, 10, 0.5, -30)
    keyLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    keyLabel.BorderSizePixel = 0
    keyLabel.Text = "E"
    keyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyLabel.TextSize = 24
    keyLabel.Font = Enum.Font.GothamBold
    keyLabel.Parent = promptFrame
    
    local keyCorner = Instance.new("UICorner")
    keyCorner.CornerRadius = UDim.new(0, 8)
    keyCorner.Parent = keyLabel
    
    -- Prompt text
    local promptText = Instance.new("TextLabel")
    promptText.Name = "PromptText"
    promptText.Size = UDim2.new(1, -80, 1, 0)
    promptText.Position = UDim2.new(0, 75, 0, 0)
    promptText.BackgroundTransparency = 1
    promptText.Text = "Land on Planet"
    promptText.TextColor3 = Color3.fromRGB(255, 255, 255)
    promptText.TextSize = 18
    promptText.Font = Enum.Font.Gotham
    promptText.TextXAlignment = Enum.TextXAlignment.Left
    promptText.TextWrapped = true
    promptText.Parent = promptFrame
    
    self._proximityUI = screenGui
    self._landingPrompt = promptFrame
    
    self._janitor:Add(screenGui, "Destroy")
end

---
-- Set up input controls
-- @private
--
function PlanetLandingController:_setupControls()
    -- E key to land (only when prompt visible)
    self._janitor:Add(UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.E then
            if not self._isLanded and self._landingPrompt.Visible then
                -- Land on closest planet
                if #self._nearbyPlanets > 0 then
                    self:_requestLanding(self._nearbyPlanets[1])
                end
            end
        end
        
        -- Space key to takeoff (hold for 1 second)
        if input.KeyCode == Enum.KeyCode.Space and self._isLanded then
            -- Only if not jumping (check if on ground)
            local player = Players.LocalPlayer
            if player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid and humanoid.FloorMaterial == Enum.Material.Air then
                    return -- Player is jumping, don't takeoff
                end
            end
            
            -- Start takeoff
            task.delay(0.5, function() -- Short delay to prevent accidental takeoff
                if self._isLanded then
                    self:_requestTakeoff()
                end
            end)
        end
    end), "Disconnect")
end

---
-- Start proximity detection loop
-- @private
--
function PlanetLandingController:_startProximityLoop()
    -- Update every 0.5 seconds (not every frame for performance)
    local updateThread = task.spawn(function()
        while true do
            if not self._isLanded then
                self:_updateProximity()
            end
            task.wait(0.5)
        end
    end)
    
    self._janitor:Add(function()
        task.cancel(updateThread)
    end, true)
end

---
-- Update proximity UI based on nearby planets
-- @private
--
function PlanetLandingController:_updateProximity()
    self._planetProximityService:GetNearbyPlanets():andThen(function(nearbyPlanets)
        self._nearbyPlanets = nearbyPlanets
        
        if #nearbyPlanets > 0 then
            -- Show prompt for closest planet
            local closest = nearbyPlanets[1]
            local promptText = self._landingPrompt:FindFirstChild("PromptText")
            if promptText then
                promptText.Text = `Land on {closest.planetName}\n({math.floor(closest.distance)} studs away)`
            end
            self._landingPrompt.Visible = true
        else
            -- Hide prompt
            self._landingPrompt.Visible = false
        end
    end):catch(function(err)
        -- Silently fail (player might not have planets yet)
    end)
end

---
-- Request landing on a planet
-- @param planetData table - Planet proximity data
-- @private
--
function PlanetLandingController:_requestLanding(planetData)
    print(`[PlanetLandingController] Requesting landing on {planetData.planetName}`)
    
    -- Hide prompt immediately
    self._landingPrompt.Visible = false
    
    self._planetProximityService:RequestLanding(planetData.planetId):andThen(function(landingData)
        print("[PlanetLandingController] Landing approved, starting sequence")
        self:_animateLanding(landingData)
    end):catch(function(err)
        warn("[PlanetLandingController] Landing failed:", err)
        -- Show error briefly
        local promptText = self._landingPrompt:FindFirstChild("PromptText")
        if promptText then
            promptText.Text = `Cannot land: {err}`
            self._landingPrompt.Visible = true
            task.wait(2)
            self._landingPrompt.Visible = false
        end
    end)
end

---
-- Animate landing sequence
-- @param landingData table - Landing position and settings
-- @private
--
function PlanetLandingController:_animateLanding(landingData)
    local player = Players.LocalPlayer
    local character = player.Character
    if not character then return end
    
    local camera = Workspace.CurrentCamera
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return end
    
    -- Notify SpaceController to exit ship if in ship
    if self._spaceController and self._spaceController._inShip then
        -- Force exit ship mode
        self._spaceController._inShip = false
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
    
    -- 1. Set camera to scriptable
    camera.CameraType = Enum.CameraType.Scriptable
    
    -- 2. Zoom to orbit view (3 seconds)
    local orbitPosition = landingData.spawnCFrame.Position + Vector3.new(0, Constants.PLANET_EXPLORATION.ORBIT_CAMERA_DISTANCE, Constants.PLANET_EXPLORATION.ORBIT_CAMERA_DISTANCE)
    local orbitCFrame = CFrame.lookAt(orbitPosition, landingData.spawnCFrame.Position)
    
    local orbitTween = TweenService:Create(camera, TweenInfo.new(
        Constants.PLANET_EXPLORATION.ORBIT_TRANSITION_TIME,
        Enum.EasingStyle.Sine,
        Enum.EasingDirection.InOut
    ), {CFrame = orbitCFrame})
    
    orbitTween:Play()
    orbitTween.Completed:Wait()
    
    -- 3. Descend to surface (2 seconds)
    local surfacePosition = landingData.spawnCFrame.Position + Vector3.new(20, 30, 20)
    local surfaceCFrame = CFrame.lookAt(surfacePosition, landingData.spawnCFrame.Position)
    
    local surfaceTween = TweenService:Create(camera, TweenInfo.new(
        Constants.PLANET_EXPLORATION.SURFACE_TRANSITION_TIME,
        Enum.EasingStyle.Sine,
        Enum.EasingDirection.InOut
    ), {CFrame = surfaceCFrame})
    
    surfaceTween:Play()
    surfaceTween.Completed:Wait()
    
    -- 4. Teleport character to surface
    rootPart.CFrame = landingData.spawnCFrame
    rootPart.AssemblyLinearVelocity = Vector3.zero
    
    -- 5. Show character
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 0
        end
    end
    
    -- 6. Switch to character camera (1 second)
    task.wait(Constants.PLANET_EXPLORATION.CHARACTER_TRANSITION_TIME)
    camera.CameraType = Enum.CameraType.Custom
    camera.CameraSubject = humanoid
    
    -- Update state
    self._isLanded = true
    self._currentPlanetId = landingData.planetId
    
    print(`[PlanetLandingController] Landed on {landingData.planetName}! Hold Space to return to ship.`)
end

---
-- Request takeoff from planet
-- @private
--
function PlanetLandingController:_requestTakeoff()
    print("[PlanetLandingController] Requesting takeoff")
    
    self._planetProximityService:RequestTakeoff():andThen(function(success)
        print("[PlanetLandingController] Takeoff approved")
        self:_animateTakeoff()
    end):catch(function(err)
        warn("[PlanetLandingController] Takeoff failed:", err)
    end)
end

---
-- Animate takeoff sequence
-- @private
--
function PlanetLandingController:_animateTakeoff()
    local player = Players.LocalPlayer
    local character = player.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    -- Update state
    self._isLanded = false
    self._currentPlanetId = nil
    
    -- Teleport back to ship position (above planet)
    local takeoffPosition = rootPart.Position + Vector3.new(0, Constants.PLANET_EXPLORATION.TAKEOFF_HEIGHT, 0)
    rootPart.CFrame = CFrame.new(takeoffPosition)
    
    -- Notify SpaceController to re-enter ship
    if self._spaceController then
        -- Auto re-enter ship after takeoff
        task.wait(0.5)
        if not self._spaceController._inShip then
            self._spaceController:_toggleShip()
        end
    end
    
    print("[PlanetLandingController] Returned to ship!")
end

---
-- Check if player is currently landed
-- @return boolean
--
function PlanetLandingController:IsLanded()
    return self._isLanded
end

return PlanetLandingController
