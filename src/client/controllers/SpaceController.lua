--[[
    SpaceController.lua
    Client-side space combat controls
    
    Handles:
    - Ship movement (WASD controls)
    - Camera following ship
    - Shooting mechanics
    - Combat UI
    
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

local Constants = require(ReplicatedStorage.Shared.Constants)

local SpaceController = Knit.CreateController {
    Name = "SpaceController",
    
    -- Player's ship
    _ship = nil,
    _inShip = false,           -- Whether player is currently in ship
    _stationData = nil,        -- Player's station position
    
    -- Movement - momentum based
    _currentVelocity = Vector3.new(0, 0, 0),
    _thrustInput = Vector3.new(0, 0, 0), -- W/A/S/D thrust direction
    
    -- Camera rotation (controlled by mouse)
    _cameraCFrame = CFrame.new(),
    _mouseX = 0,
    _mouseY = 0,
    
    -- Shooting
    _canShoot = true,
    _shootCooldown = Constants.SPACE_COMBAT.WEAPON_COOLDOWN,
    
    -- Physics tuning (space thruster physics)
    _thrustPower = 3.5,        -- Acceleration from thrusters (increased for bigger space)
    _dampingFactor = 0.98,     -- Momentum retention (very high for space)
    _rotationSmooth = 0.15,    -- Camera smoothing
    _mouseSensitivity = 0.003, -- Mouse look sensitivity
    
    -- Janitor for cleanup
    _janitor = Janitor.new(),
}

---
-- Initialize SpaceController
--
function SpaceController:KnitInit()
    print("[SpaceController] Initializing...")
end

---
-- Start SpaceController
--
function SpaceController:KnitStart()
    print("[SpaceController] Starting...")
    
    local player = Players.LocalPlayer
    
    -- Wait for character
    if not player.Character then
        player.CharacterAdded:Wait()
    end
    
    -- Get player's assigned station from server
    local SpaceArenaService = Knit.GetService("SpaceArenaService")
    self._stationData = SpaceArenaService:GetMyStation():await()
    
    print("[SpaceController] Assigned to plot", self._stationData.plotNumber, "at", self._stationData.position)
    
    -- DON'T auto-create ship - player must toggle it with F key
    task.wait(1)
    
    -- Set up controls (including ship toggle)
    self:_setupControls()
    
    -- Set up camera (normal third person initially)
    self:_setupCamera()
    
    -- Start update loop
    self._janitor:Add(RunService.RenderStepped:Connect(function(deltaTime)
        self:_update(deltaTime)
    end), "Disconnect")
    
    print("[SpaceController] Started! Press F to toggle ship, B for station UI")
end

---
-- Create a simple ship for the player
-- @param stationData table - Station data with position and orientation
-- @private
--
function SpaceController:_createShip(stationData)
    local player = Players.LocalPlayer
    
    -- Calculate spawn position (offset from station position)
    local spawnOffset = Constants.SPACE_ARENA.STATION_SPAWN_OFFSET
    local spawnPos = stationData.position + stationData.lookAtCenter:VectorToWorldSpace(spawnOffset)
    
    -- Create ship model
    local ship = Instance.new("Part")
    ship.Name = "PlayerShip"
    ship.Size = Vector3.new(6, 2, 8)
    ship.Color = Color3.fromRGB(100, 150, 255)
    ship.Material = Enum.Material.SmoothPlastic
    ship.Position = spawnPos
    ship.CFrame = stationData.lookAtCenter -- Face black hole initially
    ship.Anchored = false
    ship.CanCollide = true
    ship.CustomPhysicalProperties = PhysicalProperties.new(1, 0, 0, 1, 1) -- Space physics
    ship.Parent = Workspace
    
    -- Make it aerodynamic looking
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.Wedge
    mesh.Parent = ship
    
    -- Add engine glow effect
    local engineGlow = Instance.new("Part")
    engineGlow.Name = "EngineGlow"
    engineGlow.Size = Vector3.new(2, 0.5, 0.5)
    engineGlow.Color = Color3.fromRGB(0, 200, 255)
    engineGlow.Material = Enum.Material.Neon
    engineGlow.Transparency = 0.3
    engineGlow.CanCollide = false
    engineGlow.Anchored = false
    
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = ship
    weld.Part1 = engineGlow
    weld.Parent = engineGlow
    
    local attachment0 = Instance.new("Attachment")
    attachment0.Position = Vector3.new(0, 0, 4) -- Back of ship
    attachment0.Parent = ship
    
    local attachment1 = Instance.new("Attachment")
    attachment1.Parent = engineGlow
    
    engineGlow.Parent = ship
    
    self._ship = ship
    
    print("[SpaceController] Created ship at station plot", stationData.plotNumber)
end

---
-- Set up player controls
-- @private
--
function SpaceController:_setupControls()
    -- F key to toggle ship (don't check gameProcessed - we always want this to work)
    self._janitor:Add(UserInputService.InputBegan:Connect(function(input, gameProcessed)
        -- F key to toggle ship - allow even if game processed (chat/UI won't block it)
        if input.KeyCode == Enum.KeyCode.F then
            print("[SpaceController] F key pressed - toggling ship")
            self:_toggleShip()
            return
        end
        
        -- For other controls, check if game processed (chat/UI active)
        if gameProcessed then return end
        
        -- Only allow ship controls when in ship
        if not self._inShip then return end
        
        -- Thrust direction (relative to camera)
        if input.KeyCode == Enum.KeyCode.W then
            self._thrustInput = self._thrustInput + Vector3.new(0, 0, -1) -- Forward
        elseif input.KeyCode == Enum.KeyCode.S then
            self._thrustInput = self._thrustInput + Vector3.new(0, 0, 1) -- Backward
        elseif input.KeyCode == Enum.KeyCode.A then
            self._thrustInput = self._thrustInput + Vector3.new(-1, 0, 0) -- Left
        elseif input.KeyCode == Enum.KeyCode.D then
            self._thrustInput = self._thrustInput + Vector3.new(1, 0, 0) -- Right
        elseif input.KeyCode == Enum.KeyCode.Space then
            self._thrustInput = self._thrustInput + Vector3.new(0, 1, 0) -- Up
        elseif input.KeyCode == Enum.KeyCode.LeftShift then
            self._thrustInput = self._thrustInput + Vector3.new(0, -1, 0) -- Down
        end
        
        -- Shooting
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:_shoot()
        end
    end), "Disconnect")
    
    self._janitor:Add(UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.W then
            self._thrustInput = self._thrustInput - Vector3.new(0, 0, -1)
        elseif input.KeyCode == Enum.KeyCode.S then
            self._thrustInput = self._thrustInput - Vector3.new(0, 0, 1)
        elseif input.KeyCode == Enum.KeyCode.A then
            self._thrustInput = self._thrustInput - Vector3.new(-1, 0, 0)
        elseif input.KeyCode == Enum.KeyCode.D then
            self._thrustInput = self._thrustInput - Vector3.new(1, 0, 0)
        elseif input.KeyCode == Enum.KeyCode.Space then
            self._thrustInput = self._thrustInput - Vector3.new(0, 1, 0)
        elseif input.KeyCode == Enum.KeyCode.LeftShift then
            self._thrustInput = self._thrustInput - Vector3.new(0, -1, 0)
        end
    end), "Disconnect")
    
    -- Mouse look (delta movement) - only when in ship
    self._janitor:Add(UserInputService.InputChanged:Connect(function(input)
        if not self._inShip then return end
        
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            self._mouseX = self._mouseX + input.Delta.X * self._mouseSensitivity
            self._mouseY = self._mouseY - input.Delta.Y * self._mouseSensitivity
            
            -- Clamp vertical rotation to prevent flipping
            self._mouseY = math.clamp(self._mouseY, -math.pi/2 + 0.1, math.pi/2 - 0.1)
        end
    end), "Disconnect")
end

---
-- Set up camera to follow ship
-- @private
--
function SpaceController:_setupCamera()
    local camera = Workspace.CurrentCamera
    camera.CameraType = Enum.CameraType.Scriptable
end

---
-- Update loop - Thruster-based momentum physics
-- @param deltaTime number - Time since last frame
-- @private
--
function SpaceController:_update(deltaTime)
    -- Only update ship physics if in ship
    if not self._inShip or not self._ship or not self._ship.Parent then
        return
    end
    
    -- Update camera rotation from mouse input
    local targetCameraCFrame = CFrame.new(self._ship.Position) 
        * CFrame.Angles(0, self._mouseX, 0)  -- Yaw (horizontal)
        * CFrame.Angles(self._mouseY, 0, 0)  -- Pitch (vertical)
    
    -- Smooth camera rotation
    self._cameraCFrame = self._cameraCFrame:Lerp(targetCameraCFrame, self._rotationSmooth)
    
    -- Apply thrust in camera's local space (W goes forward relative to where you're looking)
    local thrustDirection = self._thrustInput.Magnitude > 0 and self._thrustInput.Unit or Vector3.new(0, 0, 0)
    local worldThrustDirection = self._cameraCFrame:VectorToWorldSpace(thrustDirection)
    
    -- Apply thruster force (acceleration)
    self._currentVelocity = self._currentVelocity + (worldThrustDirection * self._thrustPower)
    
    -- Apply space drag (very minimal - space has no air resistance)
    self._currentVelocity = self._currentVelocity * self._dampingFactor
    
    -- Clamp max velocity
    local maxSpeed = Constants.SPACE_COMBAT.SHIP_SPEED
    if self._currentVelocity.Magnitude > maxSpeed then
        self._currentVelocity = self._currentVelocity.Unit * maxSpeed
    end
    
    -- Apply velocity to ship
    self._ship.AssemblyLinearVelocity = self._currentVelocity
    
    -- Rotate ship to face movement direction (smooth)
    if self._currentVelocity.Magnitude > 1 then
        local targetShipCFrame = CFrame.lookAt(self._ship.Position, self._ship.Position + self._currentVelocity)
        self._ship.CFrame = self._ship.CFrame:Lerp(targetShipCFrame, 0.1)
    end
    
    -- Position camera behind ship (first-person-ish view)
    local camera = Workspace.CurrentCamera
    local cameraOffset = Vector3.new(0, 2, 8) -- Slightly above and behind
    local cameraWorldPos = self._ship.Position + self._cameraCFrame:VectorToWorldSpace(cameraOffset)
    
    camera.CFrame = CFrame.lookAt(cameraWorldPos, self._ship.Position)
end

---
-- Toggle ship on/off (F key)
-- @private
--
function SpaceController:_toggleShip()
    local player = Players.LocalPlayer
    
    if self._inShip then
        -- Exit ship
        print("[SpaceController] Exiting ship...")
        
        -- Unlock mouse
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        
        -- Show character
        if player.Character then
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0
                end
            end
        end
        
        -- Reset camera to normal
        local camera = Workspace.CurrentCamera
        camera.CameraType = Enum.CameraType.Custom
        camera.CameraSubject = player.Character and player.Character:FindFirstChild("Humanoid")
        
        -- Hide ship
        if self._ship then
            self._ship.Transparency = 1
            for _, child in ipairs(self._ship:GetDescendants()) do
                if child:IsA("BasePart") then
                    child.Transparency = 1
                end
            end
        end
        
        self._inShip = false
        print("[SpaceController] Exited ship - walk around station")
        
    else
        -- Enter ship
        print("[SpaceController] Entering ship...")
        
        -- Create ship if it doesn't exist
        if not self._ship then
            self:_createShip(self._stationData)
        end
        
        -- Position ship near player
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local playerPos = player.Character.HumanoidRootPart.Position
            self._ship.Position = playerPos + Vector3.new(0, 5, 0)
        end
        
        -- Lock mouse
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        
        -- Hide character
        if player.Character then
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Transparency = 1
                end
            end
        end
        
        -- Show ship
        self._ship.Transparency = 0
        for _, child in ipairs(self._ship:GetDescendants()) do
            if child:IsA("BasePart") then
                child.Transparency = child.Name == "EngineGlow" and 0.3 or 0
            end
        end
        
        -- Set camera to ship mode
        local camera = Workspace.CurrentCamera
        camera.CameraType = Enum.CameraType.Scriptable
        
        -- Initialize camera facing black hole
        local SpaceArenaService = Knit.GetService("SpaceArenaService")
        SpaceArenaService:GetBlackHolePosition():andThen(function(blackHolePos)
            self._cameraCFrame = CFrame.lookAt(self._ship.Position, blackHolePos)
        end)
        
        self._inShip = true
        print("[SpaceController] Entered ship - WASD to fly, Mouse to aim, Click to shoot")
    end
end

---
-- Shoot projectile (fires in camera look direction)
-- @private
--
function SpaceController:_shoot()
    if not self._canShoot or not self._ship or not self._inShip then
        return
    end
    
    self._canShoot = false
    
    -- Fire in camera's forward direction
    local shootDirection = self._cameraCFrame.LookVector
    
    -- Create projectile
    local projectile = Instance.new("Part")
    projectile.Name = "Projectile"
    projectile.Size = Vector3.new(0.5, 0.5, 2)
    projectile.Color = Color3.fromRGB(255, 255, 0)
    projectile.Material = Enum.Material.Neon
    projectile.Position = self._ship.Position + (shootDirection * 5)
    projectile.CFrame = CFrame.lookAt(projectile.Position, projectile.Position + shootDirection)
    projectile.Anchored = false
    projectile.CanCollide = false
    projectile.Parent = Workspace
    
    -- Add velocity (inherit ship's momentum + projectile speed)
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
    bodyVelocity.Velocity = self._currentVelocity + (shootDirection * Constants.SPACE_COMBAT.PROJECTILE_SPEED)
    bodyVelocity.Parent = projectile
    
    -- Detect collision
    projectile.Touched:Connect(function(hit)
        if hit.Name:match("Asteroid") then
            -- Hit an asteroid! Call server to deal damage
            local SpaceCombatService = Knit.GetService("SpaceCombatService")
            SpaceCombatService:DamageAsteroid(hit, Constants.SPACE_COMBAT.WEAPON_DAMAGE, Players.LocalPlayer)
            
            -- Destroy projectile
            projectile:Destroy()
        end
    end)
    
    -- Auto-destroy after 3 seconds
    task.delay(3, function()
        if projectile and projectile.Parent then
            projectile:Destroy()
        end
    end)
    
    -- Cooldown
    task.delay(self._shootCooldown, function()
        self._canShoot = true
    end)
    
    print("[SpaceController] Shot fired!")
end

return SpaceController
