# Planet Exploration & Flight System - Technical Specification

## Overview
This document outlines the technical implementation for Phase 3A: allowing players to fly their ships to planets, land on surfaces, explore in third person, and customize their worlds.

## System Architecture

### Services (Server-Side)

#### 1. PlanetProximityService
**Purpose:** Detect when players are near their planets and manage landing mechanics

**Methods:**
```lua
-- Check if player is near any of their planets
function PlanetProximityService:GetNearbyPlanets(userId: number): {PlanetData}

-- Handle landing request (validate ownership, position)
function PlanetProximityService:RequestLanding(userId: number, planetId: string): Promise<LandingData>

-- Handle takeoff request
function PlanetProximityService:RequestTakeoff(userId: number): Promise<boolean>

-- Get landing position on planet surface
function PlanetProximityService:GetLandingPosition(planetId: string): CFrame
```

**Data Structures:**
```lua
type ProximityData = {
    planetId: string,
    distance: number,
    canLand: boolean,
    landingPosition: CFrame,
}

type LandingData = {
    success: boolean,
    planetId: string,
    spawnCFrame: CFrame,
    surfaceGravity: number,
}
```

**Constants to Add:**
```lua
Constants.PLANET_EXPLORATION = {
    PROXIMITY_RADIUS = 150,           -- Distance to show landing prompt (studs)
    LANDING_HEIGHT = 50,              -- Height above surface for landing
    TAKEOFF_HEIGHT = 100,             -- Height to teleport ship on takeoff
    SURFACE_GRAVITY = 196.2,          -- Planet surface gravity (same as Workspace)
    MAX_LANDING_DISTANCE = 200,       -- Max distance to land from
}
```

---

#### 2. PlanetSurfaceService
**Purpose:** Generate and manage planet surfaces for exploration

**Methods:**
```lua
-- Generate terrain for planet (biome-specific)
function PlanetSurfaceService:GenerateSurface(planetId: string, biome: BiomeType): Model

-- Get spawn position on surface
function PlanetSurfaceService:GetSurfaceSpawnPosition(planetId: string): CFrame

-- Add surface features (trees, rocks, resources)
function PlanetSurfaceService:PopulateSurface(planetId: string, biome: BiomeType)

-- Handle resource node collection
function PlanetSurfaceService:CollectSurfaceResource(userId: number, resourceNodeId: string): Promise<Resources>
```

**Surface Generation:**
- Create large Part or Terrain base (500x10x500 studs)
- Parent to planet model
- Add biome-specific materials and colors
- Populate with decorative models (trees, rocks)
- Add resource nodes (glowing parts)

**Data Structures:**
```lua
type SurfaceData = {
    planetId: string,
    biome: BiomeType,
    size: Vector3,
    features: {SurfaceFeature},
    resourceNodes: {ResourceNode},
}

type SurfaceFeature = {
    featureType: "Tree" | "Rock" | "Water" | "Building",
    position: Vector3,
    rotation: number,
    model: Model,
}

type ResourceNode = {
    resourceType: "Water" | "Minerals" | "Energy" | "Biomass",
    position: Vector3,
    amount: number,
    respawnTime: number,
}
```

---

#### 3. PlanetCustomizationService
**Purpose:** Handle building/decoration placement and terrain editing

**Methods:**
```lua
-- Place building on planet surface
function PlanetCustomizationService:PlaceBuilding(userId: number, planetId: string, buildingType: string, cframe: CFrame): Promise<boolean>

-- Place decoration
function PlanetCustomizationService:PlaceDecoration(userId: number, planetId: string, decorationType: string, cframe: CFrame): Promise<boolean>

-- Remove object from planet
function PlanetCustomizationService:RemoveObject(userId: number, objectId: string): Promise<boolean>

-- Update atmosphere settings
function PlanetCustomizationService:UpdateAtmosphere(userId: number, planetId: string, settings: AtmosphereSettings): Promise<boolean>

-- Get unlocked customization options
function PlanetCustomizationService:GetUnlockedOptions(userId: number): {string}
```

**Data Structures:**
```lua
type CustomizationData = {
    buildings: {PlacedBuilding},
    decorations: {PlacedDecoration},
    atmosphereSettings: AtmosphereSettings,
    orbitalFeatures: {OrbitalFeature},
}

type PlacedBuilding = {
    id: string,
    buildingType: string,
    cframe: CFrame,
    level: number,
}

type AtmosphereSettings = {
    skyColor: Color3,
    cloudDensity: number,
    atmosphereGlow: number,
}
```

---

### Controllers (Client-Side)

#### 1. PlanetLandingController
**Purpose:** Handle landing/takeoff UI and camera transitions

**Methods:**
```lua
-- Update proximity UI when near planets
function PlanetLandingController:_updateProximityUI()

-- Handle E key press to land
function PlanetLandingController:_requestLanding()

-- Animate landing sequence
function PlanetLandingController:_animateLanding(landingData: LandingData)

-- Handle takeoff (Space key)
function PlanetLandingController:_requestTakeoff()
```

**UI Elements:**
- Proximity prompt ("Press E to Land on [Planet Name]")
- Landing progress bar
- Takeoff prompt ("Hold Space to Return to Ship")

**Camera Transitions:**
1. **Space → Orbit:** Zoom camera to orbit around planet (3 seconds)
2. **Orbit → Surface:** Lower camera to surface level (2 seconds)
3. **Surface → Character:** Switch to third-person character camera (1 second)

---

#### 2. PlanetExplorationController
**Purpose:** Handle surface movement and interactions

**Methods:**
```lua
-- Enable surface controls (WASD movement)
function PlanetExplorationController:EnableSurfaceControls()

-- Handle interaction raycast (E key to interact)
function PlanetExplorationController:_checkInteractions()

-- Collect resource node
function PlanetExplorationController:_collectResource(resourceNode: Part)

-- Show surface HUD (resources, objectives)
function PlanetExplorationController:_updateSurfaceHUD()
```

**Controls:**
- WASD: Character movement
- Space: Jump
- E: Interact with objects
- Tab: Toggle build mode
- Escape: Return to ship menu

---

#### 3. PlanetCustomizationController
**Purpose:** Handle building/decoration placement UI

**Methods:**
```lua
-- Open customization menu
function PlanetCustomizationController:OpenBuildMenu()

-- Start placement mode (show ghost model)
function PlanetCustomizationController:StartPlacement(itemType: string)

-- Rotate placement preview (Q/E keys)
function PlanetCustomizationController:RotatePlacement(angle: number)

-- Confirm placement (Click)
function PlanetCustomizationController:ConfirmPlacement()

-- Cancel placement (Escape)
function PlanetCustomizationController:CancelPlacement()
```

**UI Layout:**
```
Build Menu (Tab key):
┌─────────────────────────────┐
│  Buildings  Decorations  🎨 │
├─────────────────────────────┤
│  [Icon] House      🪙 500   │
│  [Icon] Factory    🪙 1000  │
│  [Icon] Monument   🪙 2500  │
├─────────────────────────────┤
│  [Atmosphere Settings]      │
│  Sky Color: [Slider]        │
│  Cloud Density: [Slider]    │
└─────────────────────────────┘
```

---

## Implementation Timeline

### Week 13-14: Foundation & Landing
**Tasks:**
1. Create PlanetProximityService
   - Proximity detection (RunService heartbeat)
   - Landing validation and teleport
   - Takeoff handling

2. Create PlanetLandingController
   - Proximity UI prompt
   - E key landing handler
   - Camera transition animations

3. Update SpaceController
   - Disable ship controls when landing
   - Re-enable when taking off

**Test Cases:**
- ✅ Proximity prompt appears within 150 studs of planet
- ✅ E key triggers landing sequence
- ✅ Camera smoothly transitions to surface
- ✅ Player can walk on surface
- ✅ Space key returns to ship

---

### Week 15-16: Surface & Exploration
**Tasks:**
1. Create PlanetSurfaceService
   - Terrain generation per biome
   - Resource node spawning
   - Surface feature placement

2. Create PlanetExplorationController
   - Third-person controls
   - Interaction system
   - Resource collection

3. Add biome-specific assets
   - Forest: Trees, grass, flowers
   - Oceanic: Water, corals, beaches
   - Rocky: Boulders, cliffs, canyons
   - Barren: Craters, rocks, dust

**Test Cases:**
- ✅ Surface matches planet biome
- ✅ Player can walk around freely
- ✅ E key collects resource nodes
- ✅ Resources added to inventory
- ✅ Day/night cycle visible

---

### Week 17: Customization System
**Tasks:**
1. Create PlanetCustomizationService
   - Building catalog (15 buildings)
   - Decoration catalog (30 decorations)
   - Placement validation
   - Data persistence

2. Create PlanetCustomizationController
   - Build menu UI
   - Placement preview system
   - Rotation controls
   - Atmosphere editor

3. Create unlock progression
   - Buildings unlock by level
   - Decorations unlock by achievements
   - Premium decorations (game passes)

**Test Cases:**
- ✅ Tab opens build menu
- ✅ Click item shows ghost preview
- ✅ Q/E rotates placement
- ✅ Click places object
- ✅ Escape cancels placement
- ✅ Objects save/load correctly

---

## Constants Updates

Add to `src/shared/Constants.lua`:

```lua
-- Planet Exploration System
PLANET_EXPLORATION = {
    -- Proximity & Landing
    PROXIMITY_RADIUS = 150,
    LANDING_HEIGHT = 50,
    TAKEOFF_HEIGHT = 100,
    SURFACE_GRAVITY = 196.2,
    MAX_LANDING_DISTANCE = 200,
    
    -- Surface Generation
    SURFACE_SIZE = Vector3.new(500, 10, 500),
    RESOURCE_NODE_COUNT = 20,
    DECORATION_DENSITY = 0.05, -- Objects per stud²
    
    -- Camera Transitions
    ORBIT_TRANSITION_TIME = 3,
    SURFACE_TRANSITION_TIME = 2,
    CHARACTER_TRANSITION_TIME = 1,
    ORBIT_CAMERA_DISTANCE = 200,
    
    -- Controls
    INTERACT_DISTANCE = 10,
    PLACEMENT_GRID_SIZE = 5, -- Snap to 5-stud grid
    ROTATION_STEP = 45, -- Q/E rotates by 45°
},

-- Building Catalog
BUILDINGS = {
    HOUSE = {
        name = "House",
        description = "Basic housing for your citizens",
        cost = { minerals = 500, energy = 250 },
        unlockLevel = 1,
        size = Vector3.new(10, 8, 10),
        meshId = "rbxassetid://PLACEHOLDER",
    },
    FACTORY = {
        name = "Factory",
        description = "+10% resource generation",
        cost = { minerals = 1000, energy = 500, biomass = 250 },
        unlockLevel = 5,
        size = Vector3.new(15, 12, 15),
        meshId = "rbxassetid://PLACEHOLDER",
        bonus = { resourceMultiplier = 1.1 },
    },
    -- ... more buildings
},

-- Decoration Catalog
DECORATIONS = {
    TREE = {
        name = "Tree",
        description = "Natural decoration",
        cost = { biomass = 50 },
        unlockLevel = 1,
        biomeRestriction = {"Forest", "Oceanic"},
        meshId = "rbxassetid://PLACEHOLDER",
    },
    ROCK = {
        name = "Rock",
        description = "Natural rock formation",
        cost = { minerals = 25 },
        unlockLevel = 1,
        meshId = "rbxassetid://PLACEHOLDER",
    },
    -- ... more decorations
}
```

---

## Visual Design

### Landing Sequence
1. Player flies near planet in ship
2. UI prompt appears: "🌍 Press E to Land on Earth"
3. Press E → Ship slows down
4. Camera zooms to orbit view (3 sec)
5. Camera lowers to surface (2 sec)
6. Character spawns on surface (1 sec)
7. Ship disappears, character controls enabled

### Surface Exploration
- Third-person camera behind character
- Minimap showing planet surface
- Resource nodes glow with biome colors
- Interactive objects have highlight on hover
- Tab opens build menu overlay

### Customization Mode
- Ghost preview of selected object
- Green = valid placement, Red = invalid
- Q/E to rotate preview
- Grid snapping for alignment
- Click to confirm, Escape to cancel

---

## Future Enhancements (Post-Phase 3A)

1. **Multiplayer Visiting**
   - Visit friends' planets
   - Leave comments/likes on builds
   - Trade resources on planet surface

2. **Advanced Terrain Editing**
   - Raise/lower terrain with brush
   - Paint biomes (convert Rocky → Forest)
   - Water level controls

3. **Civilization Simulation**
   - NPCs walk around surface
   - Buildings produce resources
   - City lights at night

4. **Orbital Features**
   - Add moons (visual + small bonuses)
   - Planetary rings
   - Satellites (boost offline earnings)

5. **Events & Quests**
   - Meteor shower events on surface
   - Find hidden treasures
   - Defend against alien invasions

---

## Testing Checklist

### Flight & Landing
- [ ] Proximity detection works at 150 studs
- [ ] E key lands on planet
- [ ] Camera transitions are smooth
- [ ] Character spawns on correct surface
- [ ] Gravity works on surface
- [ ] Space key returns to ship
- [ ] Ship repositions correctly on takeoff

### Surface Exploration
- [ ] WASD movement works
- [ ] Terrain matches planet biome
- [ ] Resource nodes spawn correctly
- [ ] E key collects resources
- [ ] Resources added to inventory
- [ ] Decorations render properly
- [ ] Day/night cycle visible

### Customization
- [ ] Tab opens build menu
- [ ] Item selection shows preview
- [ ] Q/E rotation works
- [ ] Placement validation correct
- [ ] Objects save to DataStore
- [ ] Objects load on rejoin
- [ ] Atmosphere changes apply
- [ ] Can remove placed objects

### Edge Cases
- [ ] Can't land on other players' planets
- [ ] Can't place objects on other planets
- [ ] Ship doesn't collide with planet
- [ ] Can't fall off planet edges
- [ ] Resource nodes respawn correctly
- [ ] Undo/redo for placements (optional)

---

## Success Metrics

**Phase 3A Complete When:**
1. ✅ Players can fly to any of their planets
2. ✅ Landing and takeoff work smoothly
3. ✅ Surface exploration feels fun and responsive
4. ✅ Can place at least 15 buildings and 30 decorations
5. ✅ Customizations persist through sessions
6. ✅ No critical bugs or performance issues
7. ✅ Positive player feedback on exploration feel

**Performance Targets:**
- Landing sequence < 6 seconds total
- Surface FPS > 30 on mobile
- < 2 second save time for customizations
- Resource node collection instant feedback

---

## Documentation Status
- [x] Technical specification created
- [ ] Service implementation guides
- [ ] Controller implementation guides
- [ ] UI mockups and wireframes
- [ ] Asset requirements list
- [ ] Testing procedures
- [ ] Video tutorials for players
