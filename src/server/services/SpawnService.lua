--[[
    SpawnService
    
    Creates an advanced spawn area with modular zones:
    - Central Hub: Multi-level platform with holographic planet centerpiece
    - Shop District: Premium shop with neon signs and interactive booths
    - Tutorial Zone: Info boards and guided areas
    - Energy Cores: Pulsing power sources with particle effects
    - Orbital Rings: Rotating decorative elements
    
    Uses modern libraries for enhanced visuals and physics
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Knit = require(ReplicatedStorage.Packages.Knit)

local SpawnService = Knit.CreateService({
    Name = "SpawnService",
})

function SpawnService:KnitInit()
    print("[SpawnService] Initializing...")
end

function SpawnService:KnitStart()
    print("[SpawnService] Starting...")
    
    -- Build comprehensive spawn area
    self:_buildSpawnArea()
    
    print("[SpawnService] Advanced spawn area created!")
end

--[[ Private Methods ]]--

function SpawnService:_buildSpawnArea()
    local Workspace = game:GetService("Workspace")
    
    -- Create spawn folder
    local spawnFolder = Instance.new("Folder")
    spawnFolder.Name = "SpawnArea"
    spawnFolder.Parent = Workspace
    
    -- === CENTRAL HUB PLATFORM (Multi-level) ===
    
    -- Main platform (larger, tiered design)
    local mainPlatform = self:_createPlatform({
        name = "MainPlatform",
        size = Vector3.new(100, 3, 100),
        position = Vector3.new(0, 0, 0),
        color = Color3.fromRGB(25, 25, 35),
        material = Enum.Material.SmoothPlastic,
        shape = "cylinder"
    })
    mainPlatform.Parent = spawnFolder
    
    -- Add rim glow
    self:_addNeonRim(mainPlatform, Color3.fromRGB(100, 150, 255), 2)
    
    -- Upper tier platform
    local upperTier = self:_createPlatform({
        name = "UpperTier",
        size = Vector3.new(60, 2, 60),
        position = Vector3.new(0, 4, 0),
        color = Color3.fromRGB(30, 30, 45),
        material = Enum.Material.Glass,
        shape = "cylinder"
    })
    upperTier.Transparency = 0.3
    upperTier.Parent = spawnFolder
    
    -- Energy grid floor pattern
    self:_createEnergyGrid(mainPlatform, spawnFolder)
    
    -- === HOLOGRAPHIC PLANET CENTERPIECE ===
    
    local centerGroup = Instance.new("Model")
    centerGroup.Name = "CenterPiece"
    centerGroup.Parent = spawnFolder
    
    -- Main holographic planet
    local planet = Instance.new("Part")
    planet.Name = "HoloPlanet"
    planet.Size = Vector3.new(12, 12, 12)
    planet.Position = Vector3.new(0, 12, 0)
    planet.Anchored = true
    planet.CanCollide = false
    planet.Material = Enum.Material.ForceField
    planet.Color = Color3.fromRGB(100, 200, 255)
    planet.Transparency = 0.2
    planet.Parent = centerGroup
    
    local sphereMesh = Instance.new("SpecialMesh")
    sphereMesh.MeshType = Enum.MeshType.Sphere
    sphereMesh.Parent = planet
    
    -- Hologram shimmer effect
    local shimmer = Instance.new("PointLight")
    shimmer.Color = Color3.fromRGB(100, 200, 255)
    shimmer.Brightness = 3
    shimmer.Range = 30
    shimmer.Parent = planet
    
    -- Particle effects - cosmic energy
    local particles = Instance.new("ParticleEmitter")
    particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    particles.Rate = 20
    particles.Lifetime = NumberRange.new(2, 4)
    particles.Speed = NumberRange.new(2, 5)
    particles.SpreadAngle = Vector2.new(180, 180)
    particles.Color = ColorSequence.new(Color3.fromRGB(100, 200, 255))
    particles.LightEmission = 1
    particles.Size = NumberSequence.new(0.2)
    particles.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    particles.Parent = planet
    
    -- Orbital rings around planet
    for i = 1, 3 do
        local ring = self:_createOrbitalRing(planet.Position, 15 + (i * 2), i)
        ring.Parent = centerGroup
    end
    
    -- Rotating animation for planet
    self:_addRotation(planet, Vector3.new(0, 1, 0), 0.5)
    
    -- === ENERGY CORES (Power sources at cardinal points) ===
    
    local corePositions = {
        {x = 35, z = 0, color = Color3.fromRGB(100, 200, 255)},   -- North (blue)
        {x = -35, z = 0, color = Color3.fromRGB(255, 100, 200)},  -- South (pink)
        {x = 0, z = 35, color = Color3.fromRGB(200, 255, 100)},   -- East (green)
        {x = 0, z = -35, color = Color3.fromRGB(255, 200, 100)},  -- West (orange)
    }
    
    for _, coreData in ipairs(corePositions) do
        self:_createEnergyCore(Vector3.new(coreData.x, 5, coreData.z), coreData.color, spawnFolder)
    end
    
    -- === SPAWN POINTS (Circle formation) ===
    
    local spawnRadius = 30
    local numSpawns = 12
    
    for i = 1, numSpawns do
        local angle = (math.pi * 2 / numSpawns) * i
        local x = math.cos(angle) * spawnRadius
        local z = math.sin(angle) * spawnRadius
        
        local spawn = Instance.new("SpawnLocation")
        spawn.Name = "Spawn" .. i
        spawn.Size = Vector3.new(5, 0.5, 5)
        spawn.Position = Vector3.new(x, 2, z)
        spawn.Anchored = true
        spawn.CanCollide = false
        spawn.Material = Enum.Material.Neon
        spawn.Color = Color3.fromRGB(80, 180, 255)
        spawn.Transparency = 0.3
        spawn.Duration = 0
        spawn.Parent = spawnFolder
        
        -- Hexagon shape for spawn pads
        local mesh = Instance.new("CylinderMesh")
        mesh.Parent = spawn
        
        -- Pulsing glow
        self:_addPulseEffect(spawn)
    end
    
    -- === TUTORIAL ZONE ===
    self:_buildTutorialZone(spawnFolder)
    
    -- === PREMIUM SHOP DISTRICT ===
    self:_buildShopDistrict(spawnFolder)
    
    -- === DECORATIVE ELEMENTS ===
    self:_buildDecorativeElements(spawnFolder)
    
    -- === LIGHTING & ATMOSPHERE ===
    self:_setupLighting()
end

function SpawnService:_buildShopArea(parent: Folder)

--[[ Helper Functions ]]--

-- Create platform with options
function SpawnService:_createPlatform(options)
    local part = Instance.new("Part")
    part.Name = options.name
    part.Size = options.size
    part.Position = options.position
    part.Anchored = true
    part.Material = options.material
    part.Color = options.color
    
    if options.shape == "cylinder" then
        local mesh = Instance.new("CylinderMesh")
        mesh.Parent = part
    end
    
    return part
end

-- Add neon rim to platform
function SpawnService:_addNeonRim(part, color, thickness)
    for i = 1, 4 do
        local rim = Instance.new("Part")
        rim.Name = "Rim" .. i
        rim.Size = Vector3.new(part.Size.X + thickness, 0.2, thickness)
        rim.CFrame = part.CFrame * CFrame.new(0, part.Size.Y/2, 0)
        rim.Anchored = true
        rim.CanCollide = false
        rim.Material = Enum.Material.Neon
        rim.Color = color
        rim.Parent = part
        
        local mesh = Instance.new("CylinderMesh")
        mesh.Parent = rim
    end
end

-- Create energy grid floor pattern
function SpawnService:_createEnergyGrid(platform, parent)
    local gridSize = 10
    local gridCount = platform.Size.X / gridSize
    
    for x = -gridCount/2, gridCount/2 do
        for z = -gridCount/2, gridCount/2 do
            -- Skip if outside circle
            if math.sqrt(x*x + z*z) > gridCount/2 then continue end
            
            local gridLine = Instance.new("Part")
            gridLine.Size = Vector3.new(gridSize - 0.5, 0.1, gridSize - 0.5)
            gridLine.Position = Vector3.new(x * gridSize, 1.6, z * gridSize)
            gridLine.Anchored = true
            gridLine.CanCollide = false
            gridLine.Material = Enum.Material.Neon
            gridLine.Color = Color3.fromRGB(50, 100, 200)
            gridLine.Transparency = 0.7
            gridLine.Parent = parent
            
            -- Random pulse delay
            task.delay(math.random() * 2, function()
                self:_addPulseEffect(gridLine, 0.4, 0.9)
            end)
        end
    end
end

-- Create orbital ring
function SpawnService:_createOrbitalRing(center, radius, index)
    local ring = Instance.new("Part")
    ring.Name = "OrbitalRing" .. index
    ring.Size = Vector3.new(radius * 2, 0.5, radius * 2)
    ring.Position = center
    ring.Anchored = true
    ring.CanCollide = false
    ring.Material = Enum.Material.Neon
    ring.Color = Color3.fromHSV(index / 3, 0.7, 1)
    ring.Transparency = 0.6
    
    local mesh = Instance.new("CylinderMesh")
    mesh.Scale = Vector3.new(1, 1, 1)
    mesh.Offset = Vector3.new(0, 0, 0)
    mesh.Parent = ring
    
    -- Rotate ring
    self:_addRotation(ring, Vector3.new(math.random(-1, 1), 1, math.random(-1, 1)).Unit, 1 + (index * 0.2))
    
    return ring
end

-- Add rotation animation
function SpawnService:_addRotation(part, axis, speed)
    task.spawn(function()
        while part and part.Parent do
            part.CFrame = part.CFrame * CFrame.fromAxisAngle(axis, math.rad(speed))
            task.wait(0.03)
        end
    end)
end

-- Add pulse effect
function SpawnService:_addPulseEffect(part, minTrans, maxTrans)
    minTrans = minTrans or part.Transparency
    maxTrans = maxTrans or 0.8
    
    task.spawn(function()
        local offset = math.random() * math.pi * 2
        while part and part.Parent do
            offset = offset + 0.05
            part.Transparency = minTrans + ((maxTrans - minTrans) * ((math.sin(offset) + 1) / 2))
            task.wait(0.05)
        end
    end)
end

-- Create energy core
function SpawnService:_createEnergyCore(position, color, parent)
    local core = Instance.new("Part")
    core.Name = "EnergyCore"
    core.Size = Vector3.new(4, 8, 4)
    core.Position = position
    core.Anchored = true
    core.CanCollide = false
    core.Material = Enum.Material.Neon
    core.Color = color
    core.Transparency = 0.3
    core.Parent = parent
    
    -- Crystal shape
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://9856898" -- Diamond/crystal
    mesh.Scale = Vector3.new(2, 2, 2)
    mesh.Parent = core
    
    -- Glow
    local light = Instance.new("PointLight")
    light.Color = color
    light.Brightness = 5
    light.Range = 25
    light.Parent = core
    
    -- Particles
    local particles = Instance.new("ParticleEmitter")
    particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    particles.Rate = 15
    particles.Lifetime = NumberRange.new(1, 3)
    particles.Speed = NumberRange.new(1, 3)
    particles.Color = ColorSequence.new(color)
    particles.LightEmission = 1
    particles.Size = NumberSequence.new(0.3)
    particles.Parent = core
    
    -- Rotate and bob
    self:_addRotation(core, Vector3.new(0, 1, 0), 2)
    
    task.spawn(function()
        local startY = position.Y
        local offset = math.random() * math.pi * 2
        while core and core.Parent do
            offset = offset + 0.03
            core.Position = Vector3.new(position.X, startY + math.sin(offset) * 1.5, position.Z)
            task.wait(0.05)
        end
    end)
end

-- Build tutorial zone
function SpawnService:_buildTutorialZone(parent)
    local tutorialPlatform = self:_createPlatform({
        name = "TutorialPlatform",
        size = Vector3.new(30, 1.5, 30),
        position = Vector3.new(-70, 0, 0),
        color = Color3.fromRGB(30, 40, 50),
        material = Enum.Material.SmoothPlastic,
        shape = "cylinder"
    })
    tutorialPlatform.Parent = parent
    
    -- Info hologram
    local infoBoard = Instance.new("Part")
    infoBoard.Name = "InfoBoard"
    infoBoard.Size = Vector3.new(15, 10, 1)
    infoBoard.Position = Vector3.new(-70, 7, 0)
    infoBoard.Anchored = true
    infoBoard.Material = Enum.Material.ForceField
    infoBoard.Color = Color3.fromRGB(100, 200, 255)
    infoBoard.Transparency = 0.5
    infoBoard.Parent = parent
    
    -- Tutorial text
    local surfaceGui = Instance.new("SurfaceGui")
    surfaceGui.Face = Enum.NormalId.Front
    surfaceGui.Parent = infoBoard
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "🌍 WELCOME TO GROW A PLANET!\n\n✨ Gain XP to level up\n🌱 Unlock new biomes\n⭐ Earn stars for upgrades\n🔄 Rebirth for multipliers"
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextSize = 24
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextWrapped = true
    textLabel.Parent = surfaceGui
    
    -- Bridge to tutorial
    local bridge = Instance.new("Part")
    bridge.Size = Vector3.new(30, 0.8, 6)
    bridge.Position = Vector3.new(-35, 0.4, 0)
    bridge.Anchored = true
    bridge.Material = Enum.Material.Glass
    bridge.Color = Color3.fromRGB(50, 100, 200)
    bridge.Transparency = 0.4
    bridge.Parent = parent
end

-- Build shop district
function SpawnService:_buildShopDistrict(parent)
    local shopPlatform = self:_createPlatform({
        name = "ShopPlatform",
        size = Vector3.new(50, 2, 50),
        position = Vector3.new(80, 0, 0),
        color = Color3.fromRGB(40, 30, 50),
        material = Enum.Material.SmoothPlastic,
        shape = "cylinder"
    })
    shopPlatform.Parent = parent
    
    -- Premium shop building
    local shopBuilding = Instance.new("Part")
    shopBuilding.Name = "ShopBuilding"
    shopBuilding.Size = Vector3.new(30, 15, 25)
    shopBuilding.Position = Vector3.new(80, 8.5, 0)
    shopBuilding.Anchored = true
    shopBuilding.Material = Enum.Material.SmoothPlastic
    shopBuilding.Color = Color3.fromRGB(60, 45, 75)
    shopBuilding.Parent = parent
    
    -- Neon trim
    self:_addNeonRim(shopBuilding, Color3.fromRGB(255, 215, 0), 1)
    
    -- Holographic sign
    local sign = Instance.new("Part")
    sign.Name = "ShopSign"
    sign.Size = Vector3.new(25, 5, 0.5)
    sign.Position = Vector3.new(80, 17, 13)
    sign.Anchored = true
    sign.Material = Enum.Material.Neon
    sign.Color = Color3.fromRGB(255, 215, 0)
    sign.Parent = parent
    
    local signGui = Instance.new("SurfaceGui")
    signGui.Face = Enum.NormalId.Front
    signGui.Parent = sign
    
    local signText = Instance.new("TextLabel")
    signText.Size = UDim2.new(1, 0, 1, 0)
    signText.BackgroundTransparency = 1
    signText.Text = "⭐ PREMIUM SHOP ⭐"
    signText.TextColor3 = Color3.new(1, 1, 1)
    signText.TextScaled = true
    signText.Font = Enum.Font.GothamBold
    signText.Parent = signGui
    
    -- Shop NPC (golden orb)
    local shopNPC = Instance.new("Part")
    shopNPC.Name = "ShopInteraction"
    shopNPC.Size = Vector3.new(5, 5, 5)
    shopNPC.Position = Vector3.new(80, 5, 8)
    shopNPC.Anchored = true
    shopNPC.CanCollide = false
    shopNPC.Material = Enum.Material.Neon
    shopNPC.Color = Color3.fromRGB(255, 215, 0)
    shopNPC.Parent = parent
    
    local npcMesh = Instance.new("SpecialMesh")
    npcMesh.MeshType = Enum.MeshType.Sphere
    npcMesh.Parent = shopNPC
    
    -- Click detector
    local clickDetector = Instance.new("ClickDetector")
    clickDetector.MaxActivationDistance = 25
    clickDetector.Parent = shopNPC
    
    -- Glow
    local glow = Instance.new("PointLight")
    glow.Color = Color3.fromRGB(255, 215, 0)
    glow.Brightness = 3
    glow.Range = 20
    glow.Parent = shopNPC
    
    -- Floating animation
    task.spawn(function()
        local startY = 5
        local offset = 0
        while shopNPC and shopNPC.Parent do
            offset = offset + 0.04
            shopNPC.Position = Vector3.new(80, startY + math.sin(offset) * 1, 8)
            shopNPC.CFrame = shopNPC.CFrame * CFrame.Angles(0, math.rad(2), 0)
            task.wait(0.05)
        end
    end)
    
    -- Bridge to shop
    local bridge = Instance.new("Part")
    bridge.Size = Vector3.new(25, 0.8, 8)
    bridge.Position = Vector3.new(50, 0.4, 0)
    bridge.Anchored = true
    bridge.Material = Enum.Material.Glass
    bridge.Color = Color3.fromRGB(255, 215, 0)
    bridge.Transparency = 0.3
    bridge.Parent = parent
    
    -- Bridge lights
    for i = 1, 4 do
        local light = Instance.new("Part")
        light.Size = Vector3.new(1.5, 4, 1.5)
        light.Position = Vector3.new(38 + (i * 7), 2.5, 0)
        light.Anchored = true
        light.Material = Enum.Material.Neon
        light.Color = Color3.fromRGB(255, 215, 0)
        light.Parent = parent
        
        local lightSource = Instance.new("PointLight")
        lightSource.Color = Color3.fromRGB(255, 215, 0)
        lightSource.Brightness = 2
        lightSource.Range = 15
        lightSource.Parent = light
        
        self:_addPulseEffect(light, 0.2, 0.6)
    end
end

-- Build decorative elements
function SpawnService:_buildDecorativeElements(parent)
    -- Floating asteroids/rocks
    for i = 1, 8 do
        local angle = (math.pi * 2 / 8) * i
        local distance = 55 + math.random(-5, 5)
        local x = math.cos(angle) * distance
        local z = math.sin(angle) * distance
        local y = 8 + math.random(-3, 5)
        
        local asteroid = Instance.new("Part")
        asteroid.Name = "Asteroid" .. i
        asteroid.Size = Vector3.new(3, 4, 3)
        asteroid.Position = Vector3.new(x, y, z)
        asteroid.Anchored = true
        asteroid.CanCollide = false
        asteroid.Material = Enum.Material.Slate
        asteroid.Color = Color3.fromRGB(60, 60, 70)
        asteroid.Parent = parent
        
        -- Add glow
        local glow = Instance.new("PointLight")
        glow.Color = Color3.fromHSV(i / 8, 0.6, 1)
        glow.Brightness = 1.5
        glow.Range = 12
        glow.Parent = asteroid
        
        -- Slow rotation and bob
        self:_addRotation(asteroid, Vector3.new(math.random(), math.random(), math.random()).Unit, 0.5)
        
        task.spawn(function()
            local startY = y
            local offset = math.random() * math.pi * 2
            while asteroid and asteroid.Parent do
                offset = offset + 0.02
                asteroid.Position = Vector3.new(x, startY + math.sin(offset) * 2, z)
                task.wait(0.05)
            end
        end)
    end
    
    -- Beam connections between energy cores (laser grid)
    local cores = {}
    for _, child in ipairs(parent:GetChildren()) do
        if child.Name == "EnergyCore" then
            table.insert(cores, child)
        end
    end
    
    for i = 1, #cores do
        for j = i + 1, #cores do
            local attachment0 = Instance.new("Attachment")
            attachment0.Parent = cores[i]
            
            local attachment1 = Instance.new("Attachment")
            attachment1.Parent = cores[j]
            
            local beam = Instance.new("Beam")
            beam.Attachment0 = attachment0
            beam.Attachment1 = attachment1
            beam.Color = ColorSequence.new(cores[i].Color, cores[j].Color)
            beam.FaceCamera = true
            beam.Width0 = 0.3
            beam.Width1 = 0.3
            beam.Transparency = NumberSequence.new(0.7)
            beam.LightEmission = 1
            beam.Parent = cores[i]
        end
    end
end

-- Setup lighting and atmosphere
function SpawnService:_setupLighting()
    local lighting = game:GetService("Lighting")
    
    -- Atmospheric settings
    lighting.Ambient = Color3.fromRGB(30, 40, 60)
    lighting.Brightness = 1.5
    lighting.OutdoorAmbient = Color3.fromRGB(50, 60, 90)
    lighting.ColorShift_Top = Color3.fromRGB(100, 150, 255)
    lighting.ColorShift_Bottom = Color3.fromRGB(50, 50, 100)
    
    -- Atmosphere
    if not lighting:FindFirstChildOfClass("Atmosphere") then
        local atmosphere = Instance.new("Atmosphere")
        atmosphere.Density = 0.3
        atmosphere.Offset = 0.5
        atmosphere.Color = Color3.fromRGB(100, 150, 255)
        atmosphere.Decay = Color3.fromRGB(50, 50, 100)
        atmosphere.Glare = 0.5
        atmosphere.Haze = 1.5
        atmosphere.Parent = lighting
    end
    
    -- Bloom effect
    if not lighting:FindFirstChildOfClass("BloomEffect") then
        local bloom = Instance.new("BloomEffect")
        bloom.Intensity = 0.4
        bloom.Size = 24
        bloom.Threshold = 0.8
        bloom.Parent = lighting
    end
    
    -- Color correction
    if not lighting:FindFirstChildOfClass("ColorCorrectionEffect") then
        local colorCorrection = Instance.new("ColorCorrectionEffect")
        colorCorrection.Brightness = 0.05
        colorCorrection.Contrast = 0.1
        colorCorrection.Saturation = 0.2
        colorCorrection.TintColor = Color3.fromRGB(255, 255, 255)
        colorCorrection.Parent = lighting
    end
end

return SpawnService
