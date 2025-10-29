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
    
    -- Movement input
    _moveDirection = Vector3.new(0, 0, 0),
    
    -- Shooting
    _canShoot = true,
    _shootCooldown = Constants.SPACE_COMBAT.WEAPON_COOLDOWN,
    
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
    
    -- Create simple ship
    task.wait(1) -- Wait for spawn
    self:_createShip()
    
    -- Set up controls
    self:_setupControls()
    
    -- Set up camera
    self:_setupCamera()
    
    -- Start update loop
    self._janitor:Add(RunService.RenderStepped:Connect(function(deltaTime)
        self:_update(deltaTime)
    end), "Disconnect")
    
    print("[SpaceController] Started!")
end

---
-- Create a simple ship for the player
-- @private
--
function SpaceController:_createShip()
    local player = Players.LocalPlayer
    
    -- Create ship model
    local ship = Instance.new("Part")
    ship.Name = "PlayerShip"
    ship.Size = Vector3.new(6, 2, 8)
    ship.Color = Color3.fromRGB(100, 150, 255)
    ship.Material = Enum.Material.SmoothPlastic
    ship.Position = Vector3.new(0, 55, 0) -- Above spawn
    ship.Anchored = false
    ship.CanCollide = true
    ship.Parent = Workspace
    
    -- Make it aerodynamic looking
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.Wedge
    mesh.Parent = ship
    
    -- Add body velocity for movement
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = ship
    
    -- Add body gyro for rotation
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
    bodyGyro.CFrame = ship.CFrame
    bodyGyro.Parent = ship
    
    self._ship = ship
    
    print("[SpaceController] Created ship")
end

---
-- Set up player controls
-- @private
--
function SpaceController:_setupControls()
    -- WASD movement
    self._janitor:Add(UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.W then
            self._moveDirection = self._moveDirection + Vector3.new(0, 0, -1)
        elseif input.KeyCode == Enum.KeyCode.S then
            self._moveDirection = self._moveDirection + Vector3.new(0, 0, 1)
        elseif input.KeyCode == Enum.KeyCode.A then
            self._moveDirection = self._moveDirection + Vector3.new(-1, 0, 0)
        elseif input.KeyCode == Enum.KeyCode.D then
            self._moveDirection = self._moveDirection + Vector3.new(1, 0, 0)
        elseif input.KeyCode == Enum.KeyCode.Space then
            self._moveDirection = self._moveDirection + Vector3.new(0, 1, 0)
        elseif input.KeyCode == Enum.KeyCode.LeftShift then
            self._moveDirection = self._moveDirection + Vector3.new(0, -1, 0)
        end
        
        -- Shooting
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:_shoot()
        end
    end), "Disconnect")
    
    self._janitor:Add(UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.W then
            self._moveDirection = self._moveDirection - Vector3.new(0, 0, -1)
        elseif input.KeyCode == Enum.KeyCode.S then
            self._moveDirection = self._moveDirection - Vector3.new(0, 0, 1)
        elseif input.KeyCode == Enum.KeyCode.A then
            self._moveDirection = self._moveDirection - Vector3.new(-1, 0, 0)
        elseif input.KeyCode == Enum.KeyCode.D then
            self._moveDirection = self._moveDirection - Vector3.new(1, 0, 0)
        elseif input.KeyCode == Enum.KeyCode.Space then
            self._moveDirection = self._moveDirection - Vector3.new(0, 1, 0)
        elseif input.KeyCode == Enum.KeyCode.LeftShift then
            self._moveDirection = self._moveDirection - Vector3.new(0, -1, 0)
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
-- Update loop
-- @param deltaTime number - Time since last frame
-- @private
--
function SpaceController:_update(deltaTime)
    if not self._ship or not self._ship.Parent then
        return
    end
    
    -- Apply movement
    local bodyVelocity = self._ship:FindFirstChildOfClass("BodyVelocity")
    if bodyVelocity then
        local moveDir = self._moveDirection.Magnitude > 0 and self._moveDirection.Unit or Vector3.new(0, 0, 0)
        bodyVelocity.Velocity = moveDir * Constants.SPACE_COMBAT.SHIP_SPEED
    end
    
    -- Rotate ship to face mouse
    local mouse = Players.LocalPlayer:GetMouse()
    if mouse then
        local bodyGyro = self._ship:FindFirstChildOfClass("BodyGyro")
        if bodyGyro then
            local mousePos = mouse.Hit.Position
            local shipPos = self._ship.Position
            local lookVector = (mousePos - shipPos).Unit
            bodyGyro.CFrame = CFrame.lookAt(shipPos, shipPos + lookVector)
        end
    end
    
    -- Update camera
    local camera = Workspace.CurrentCamera
    local offset = Vector3.new(0, 30, 30) -- Above and behind ship
    camera.CFrame = CFrame.lookAt(self._ship.Position + offset, self._ship.Position)
end

---
-- Shoot projectile
-- @private
--
function SpaceController:_shoot()
    if not self._canShoot or not self._ship then
        return
    end
    
    self._canShoot = false
    
    -- Create projectile
    local projectile = Instance.new("Part")
    projectile.Name = "Projectile"
    projectile.Size = Vector3.new(0.5, 0.5, 2)
    projectile.Color = Color3.fromRGB(255, 255, 0)
    projectile.Material = Enum.Material.Neon
    projectile.Position = self._ship.Position + (self._ship.CFrame.LookVector * 5)
    projectile.CFrame = self._ship.CFrame
    projectile.Anchored = false
    projectile.CanCollide = false
    projectile.Parent = Workspace
    
    -- Add velocity
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
    bodyVelocity.Velocity = self._ship.CFrame.LookVector * Constants.SPACE_COMBAT.PROJECTILE_SPEED
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
