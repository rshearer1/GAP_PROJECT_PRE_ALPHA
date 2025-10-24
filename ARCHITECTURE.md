# Architecture Documentation

## System Overview

Grow a Planet is a multiplayer Roblox game where players nurture and develop their own planets. The architecture uses the **Knit framework** for clean service/controller separation, built with TypeScript via roblox-ts.

## Framework Choice: Knit

**Why Knit?**
- **Lightweight**: Minimal overhead, maximum control
- **Clean Architecture**: Clear separation between server (Services) and client (Controllers)
- **Auto-networking**: Automatic RemoteEvent/RemoteFunction creation
- **Type-safe**: Works seamlessly with TypeScript/roblox-ts
- **Battle-tested**: Used in many production Roblox games

### Knit Core Concepts

**Services** (Server-side):
- Handle game logic, data persistence, validation
- Expose methods to clients via `.Client` table
- Communicate with other services directly

**Controllers** (Client-side):
- Handle UI, input, client-side logic
- Consume services through Knit's networking layer
- Manage local player state

## Architecture Principles

### 1. **Service-Oriented Architecture**
- Each major system is a Service (server) or Controller (client)
- Services are singletons - one instance per server
- Controllers are singletons - one instance per client

### 2. **Type Safety**
- TypeScript provides compile-time type checking
- Shared type definitions ensure client-server consistency
- Knit's API is fully typed via @rbxts/knit

### 3. **Separation of Concerns**
- **Server Services**: Game logic, validation, persistence
- **Client Controllers**: UI, rendering, input handling
- **Shared Modules**: Pure functions, utilities, constants

### 4. **Data Flow**
```
Player Input → Controller → Service (via Knit) → Validation → 
Game Logic → DataStore → State Update → Service → Controller → UI Update
```

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                         CLIENT SIDE                          │
│                      (Knit Controllers)                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────┐  ┌──────────────────┐                │
│  │ PlanetController │  │  PetController   │                │
│  │  - UI Management │  │  - Pet UI        │                │
│  │  - Input Handler │  │  - Animations    │                │
│  └────────┬─────────┘  └────────┬─────────┘                │
│           │                      │                           │
│           └──────────┬───────────┘                           │
│                      │                                       │
│              ┌───────▼────────┐                             │
│              │ Knit.GetService│                             │
│              │ (Auto Network) │                             │
│              └───────┬────────┘                             │
└──────────────────────┼──────────────────────────────────────┘
                       │
              ┌────────▼─────────┐
              │   Knit Bridge    │
              │ RemoteEvents &   │
              │ RemoteFunctions  │
              └────────┬─────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                        SERVER SIDE                           │
│                      (Knit Services)                         │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌────────────┐  ┌──────────┐  ┌──────────┐               │
│  │  Planet    │  │   Pet    │  │  Trade   │               │
│  │  Service   │  │ Service  │  │ Service  │               │
│  │            │  │          │  │          │               │
│  │ .Client {} │  │.Client{} │  │.Client{} │               │
│  └─────┬──────┘  └────┬─────┘  └────┬─────┘               │
│        │              │             │                       │
│        └──────────────┼─────────────┘                       │
│                       │                                      │
│              ┌────────▼─────────┐                          │
│              │   DataService    │                          │
│              │  - ProfileService│                          │
│              │  - DataStores    │                          │
│              └────────┬─────────┘                          │
│                       │                                      │
│              ┌────────▼─────────┐                          │
│              │  DataStoreService│                          │
│              └──────────────────┘                          │
│                                                              │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                      SHARED MODULES                          │
├─────────────────────────────────────────────────────────────┤
│  Types  │  Constants  │  Utilities  │  Game Logic           │
└─────────────────────────────────────────────────────────────┘
```

## Module Breakdown

### Server Services (Knit)

#### **PlanetService** (`src/server/services/PlanetService.ts`)
**Purpose:** Manage planet instances and state
**Responsibilities:**
- Create/destroy planets
- Update planet resources
- Handle upgrades and biome changes
- Calculate growth and progression

**Knit Structure:**
```typescript
import { KnitServer as Knit } from "@rbxts/knit";
import { Players } from "@rbxts/services";

interface PlanetService {
    // Server-side methods
    createPlanet(userId: number): PlanetState;
    updatePlanet(userId: number, deltaTime: number): void;
    
    // Client-exposed methods (accessed via .Client)
    Client: {
        GetPlanetState(player: Player): PlanetState;
        RequestUpgrade(player: Player, upgradeId: string): boolean;
        CollectResources(player: Player): Resources;
    };
}

const PlanetService = Knit.CreateService<PlanetService>({
    Name: "PlanetService",
    
    Client: {
        // These methods are automatically networked
        GetPlanetState(player) {
            return this.Server.getPlanetData(player.UserId);
        },
        
        RequestUpgrade(player, upgradeId) {
            return this.Server.applyUpgrade(player.UserId, upgradeId);
        }
    },
    
    // Server-only methods
    createPlanet(userId: number): PlanetState {
        // Implementation
    },
    
    getPlanetData(userId: number): PlanetState {
        // Implementation
    }
});

export = PlanetService;
```

#### **PetService** (`src/server/services/PetService.ts`)
**Purpose:** Handle pet system logic
**Responsibilities:**
- Create new pets
- Handle evolution
- Calculate pet bonuses
- Manage pet skills

**Knit Structure:**
```typescript
import { KnitServer as Knit } from "@rbxts/knit";

const PetService = Knit.CreateService({
    Name: "PetService",
    
    Client: {
        HatchPet(player: Player, eggType: string) {
            return this.Server.createPet(player.UserId, eggType);
        },
        
        EvolvePet(player: Player, petId: string, sacrificeId: string) {
            return this.Server.evolvePet(player.UserId, petId, sacrificeId);
        },
        
        GetPets(player: Player) {
            return this.Server.getPlayerPets(player.UserId);
        }
    },
    
    createPet(userId: number, petType: string): PetData {
        // Implementation
    },
    
    evolvePet(userId: number, petId: string, sacrificeId: string) {
        // Implementation
    }
});

export = PetService;
```

#### **DataService** (`src/server/services/DataService.ts`)
**Purpose:** Handle all DataStore operations
**Responsibilities:**
- Save/load player data
- Handle data migrations
- Implement retry logic
- Cache frequently accessed data

**Uses ProfileService for data management:**
```typescript
import { KnitServer as Knit } from "@rbxts/knit";
import ProfileService from "@rbxts/profileservice";

const DataService = Knit.CreateService({
    Name: "DataService",
    
    profiles: new Map<number, Profile>(),
    
    KnitInit() {
        // Initialize ProfileService
        this.profileStore = ProfileService.GetProfileStore(
            "PlayerData",
            DEFAULT_DATA
        );
    },
    
    loadProfile(player: Player) {
        const profile = this.profileStore.LoadProfileAsync(`Player_${player.UserId}`);
        if (profile) {
            profile.AddUserId(player.UserId);
            profile.ListenToRelease(() => {
                this.profiles.delete(player.UserId);
                player.Kick();
            });
            this.profiles.set(player.UserId, profile);
        }
        return profile;
    }
});

export = DataService;
```

### Client Controllers (Knit)

#### **PlanetController** (`src/client/controllers/PlanetController.ts`)
**Purpose:** Manage planet UI and client-side planet logic
**Responsibilities:**
- Display planet visuals
- Handle resource UI updates
- Manage planet interactions
- Request server updates

**Knit Structure:**
```typescript
import { KnitClient as Knit } from "@rbxts/knit";
import { Players } from "@rbxts/services";

const PlanetController = Knit.CreateController({
    Name: "PlanetController",
    
    planetState: undefined as PlanetState | undefined,
    
    KnitStart() {
        // Get the PlanetService from server
        const PlanetService = Knit.GetService("PlanetService");
        
        // Fetch initial state
        PlanetService.GetPlanetState().then((state) => {
            this.planetState = state;
            this.updateUI(state);
        });
        
        // Listen for updates
        PlanetService.OnStateUpdate.Connect((state: PlanetState) => {
            this.planetState = state;
            this.updateUI(state);
        });
    },
    
    requestUpgrade(upgradeId: string) {
        const PlanetService = Knit.GetService("PlanetService");
        return PlanetService.RequestUpgrade(upgradeId);
    },
    
    updateUI(state: PlanetState) {
        // Update UI elements
    }
});

export = PlanetController;
```

#### **PetController** (`src/client/controllers/PetController.ts`)
**Purpose:** Manage pet UI and animations
**Responsibilities:**
- Display pet inventory
- Handle pet UI interactions
- Manage pet animations
- Request pet actions from server

```typescript
import { KnitClient as Knit } from "@rbxts/knit";

const PetController = Knit.CreateController({
    Name: "PetController",
    
    pets: [] as PetData[],
    
    KnitStart() {
        const PetService = Knit.GetService("PetService");
        
        // Load pets
        PetService.GetPets().then((pets) => {
            this.pets = pets;
            this.renderPetUI();
        });
    },
    
    hatchPet(eggType: string) {
        const PetService = Knit.GetService("PetService");
        return PetService.HatchPet(eggType);
    },
    
    evolvePet(petId: string, sacrificeId: string) {
        const PetService = Knit.GetService("PetService");
        return PetService.EvolvePet(petId, sacrificeId);
    }
});

export = PetController;
```

## Knit Initialization

### Server Entry Point (`src/server/init.server.ts`)
```typescript
import { KnitServer as Knit } from "@rbxts/knit";
import { Players, ReplicatedStorage } from "@rbxts/services";

// Load all services
const services = ReplicatedStorage.WaitForChild("TS").WaitForChild("server").WaitForChild("services");
for (const service of services.GetChildren()) {
    require(service);
}

// Start Knit
Knit.Start().catch(warn);

// Handle player connections after Knit starts
Players.PlayerAdded.Connect((player) => {
    const DataService = Knit.GetService("DataService");
    DataService.loadProfile(player);
});
```

### Client Entry Point (`src/client/init.client.ts`)
```typescript
import { KnitClient as Knit } from "@rbxts/knit";
import { ReplicatedStorage } from "@rbxts/services";

// Load all controllers
const controllers = ReplicatedStorage.WaitForChild("TS").WaitForChild("client").WaitForChild("controllers");
for (const controller of controllers.GetChildren()) {
    require(controller);
}

// Start Knit
Knit.Start().catch(warn).await();

// Knit is now ready - controllers can access services
```

#### **Types** (`src/shared/types.ts`)
**Purpose:** Type definitions used across client and server
**Contents:**
- `PlanetState` - Planet data structure
- `PetData` - Pet information
- `Resources` - Resource types and amounts
- `BiomeType` - Available biomes

#### **Constants** (`src/shared/constants.ts`)
**Purpose:** Game configuration and balance values
**Categories:**
- `GAMEPLAY` - Core game parameters
- `RESOURCES` - Resource definitions
- `BIOMES` - Biome configurations
- `UI` - UI styling constants

### Game Modules

#### **GrowthModule** (`src/modules/GrowthModule.ts`)
**Purpose:** Handle resource growth and planet development
**Algorithms:**
```typescript
function calculateResourceGeneration(state: PlanetState): ResourceRates {
    let baseRate = GAMEPLAY.BASE_RESOURCE_RATE;
    
    // Apply biome multipliers
    const biomeMult = getBiomeMultiplier(state.biome);
    
    // Apply pet bonuses
    const petBonus = calculatePetBonus(state.pets);
    
    // Apply building bonuses
    const buildingBonus = state.coverage.cities * 0.1;
    
    return {
        water: baseRate * biomeMult.water * (1 + petBonus + buildingBonus),
        minerals: baseRate * biomeMult.minerals * (1 + petBonus),
        energy: baseRate * biomeMult.energy,
        biomass: baseRate * state.biodiversity * 0.5
    };
}
```

#### **EcosystemModule** (`src/modules/EcosystemModule.ts`)
**Purpose:** Simulate animal and plant life
**Features:**
- Population dynamics
- Food web simulation
- Biodiversity calculation
- Extinction/thriving mechanics

## Communication Protocols

### RemoteEvents

#### Client → Server
```typescript
// Request upgrade
remotes.RequestUpgrade.FireServer(upgradeId);

// Hatch pet
remotes.HatchPet.FireServer(eggType);

// Initiate trade
remotes.RequestTrade.FireServer(targetPlayerId, offer);
```

#### Server → Client
```typescript
// Update planet state
remotes.PlanetStateUpdated.FireClient(player, newState);

// Notify resource collection
remotes.ResourceCollected.FireClient(player, resourceType, amount);

// Pet evolution complete
remotes.PetEvolved.FireClient(player, petData);
```

### RemoteFunctions

#### Request/Response Pattern
```typescript
// Client requests current state
const state = remotes.GetPlanetState.InvokeServer();

// Server responds with data
remotes.GetPlanetState.OnServerInvoke = (player) => {
    return planetManager.getPlanet(player.UserId);
};
```

## Data Persistence

### DataStore Structure

```typescript
// Key: Player_<userId>
{
    userId: number;
    planet: PlanetState;
    pets: PetData[];
    inventory: ItemInventory;
    progression: {
        level: number;
        experience: number;
        achievements: string[];
    };
    settings: UserSettings;
    lastSave: number;
}
```

### Save Strategy
1. **Auto-save** every 5 minutes
2. **On player leave** - guaranteed save
3. **Before critical actions** - trades, purchases
4. **Cache layer** - reduce DataStore calls

### Data Migration
```typescript
interface DataVersion {
    version: number;
    migrate: (oldData: any) => any;
}

const migrations: DataVersion[] = [
    {
        version: 2,
        migrate: (data) => ({
            ...data,
            pets: data.pets || []
        })
    }
];
```

## Performance Considerations

### Client Optimizations
- **UI pooling** - Reuse GUI elements
- **Lazy loading** - Load UI on demand
- **View distance culling** - Hide distant objects
- **Animation caching** - Pre-load animations

### Server Optimizations
- **Batch updates** - Update planets in groups
- **Spatial partitioning** - Only process nearby planets
- **Caching** - Cache calculated values
- **Throttling** - Rate limit expensive operations

### Network Optimizations
- **Delta updates** - Only send changed data
- **Compression** - Minimize packet size
- **Batching** - Combine multiple updates
- **Unreliable events** - For non-critical updates

## Security

### Server Authority
- All game logic runs on server
- Client sends requests, server validates
- Never trust client data

### Validation Pattern
```typescript
function handleUpgradeRequest(player: Player, upgradeId: string) {
    const state = planetManager.getPlanet(player.UserId);
    
    // Validate player owns this planet
    if (state.ownerUserId !== player.UserId) {
        return false;
    }
    
    // Validate upgrade exists
    const upgrade = UPGRADES[upgradeId];
    if (!upgrade) {
        return false;
    }
    
    // Validate resources
    if (!hasEnoughResources(state.resources, upgrade.cost)) {
        return false;
    }
    
    // Apply upgrade
    return planetManager.applyUpgrade(player.UserId, upgradeId);
}
```

### Anti-Exploit Measures
- Rate limiting on RemoteEvents
- Resource validation
- Impossible state detection
- Cheat detection systems

## Testing Strategy

### Unit Tests
- Test individual modules in isolation
- Mock dependencies
- Test edge cases

### Integration Tests
- Test module interactions
- Test full workflows
- Test data persistence

### Load Tests
- Simulate many players
- Test server performance
- Identify bottlenecks

## Deployment

### Build Process
1. Compile TypeScript → Lua
2. Sync with Rojo
3. Test in Studio
4. Publish to Roblox

### Version Control
- Git for source control
- Feature branches
- Pull request reviews
- Semantic versioning

## Future Architecture Improvements

1. **Event sourcing** - Store all game events
2. **Microservices** - Split large modules
3. **Message queue** - Decouple systems
4. **Analytics pipeline** - Track player behavior
5. **A/B testing framework** - Test game balance

---

## Implemented Services & Controllers (As of Oct 24, 2025)

### Server Services

#### ✅ PlanetService
- Manages planet state (resources, levels, biomes)
- 1-second tick rate for resource generation
- Handles XP gain and level-up logic
- Integrates with StarMapService for biome completion rewards

#### ✅ PlanetVisualsService
- Creates 3D planet spheres in Workspace
- Biome-based colors and materials
- Rotation animation via RunService
- Dynamic size and color updates based on planet state

#### ✅ UpgradeService
- 7 upgrade definitions (Better Collectors, Efficient Mining, etc.)
- Purchase validation and cost calculation
- Level-based upgrade system (max level 5)
- Applies multipliers to resource generation

#### ✅ DataService
- Auto-save every 60 seconds
- Shutdown handler for data persistence
- DataStore integration (requires published game)
- Default data template for new players

#### ✅ SolarSystemService
- Generates 3-8 random planets per player
- 8 unique planet types (Mineral World, Ocean World, Energy Core, etc.)
- Planet switching and unlocking system
- Tracks active planet per player

#### ✅ RebirthService
- 90% completion requirement calculation
- Rebirth execution with resource/planet reset
- +10% permanent multiplier per rebirth
- 5 rank tiers (Bronze → Diamond)
- Bonus star rewards

#### ✅ StarMapService
- 13 star upgrade definitions across 4 categories
- Offline earnings system (up to 24 hours)
- Global bonuses (resources, XP, cost reduction)
- Special unlocks (auto-collect, 5th biome)
- Stars persist through rebirths

#### ✅ SpawnService
- Procedurally generates spawn area on server start
- Multi-tiered platforms with energy grid
- Holographic planet centerpiece with orbital rings
- 4 energy cores at cardinal directions
- Tutorial zone and shop district
- Floating asteroids and decorative elements
- Atmospheric lighting and post-processing

#### ✅ GamePassService
- 6 game pass definitions (2x Resources, VIP Planet, Auto-Collector, etc.)
- MarketplaceService integration for purchases
- Ownership tracking per player
- Benefit calculation (multipliers, slots, features)
- PromptGamePassPurchaseFinished event handling

#### ✅ TestingService
- 7 debug commands for testing
- Add resources, levels, stars
- Unlock all planets, buy all upgrades
- Force rebirth eligibility
- Commands accessible via testing panel (press T)

### Client Controllers

#### ✅ PlanetController
- Main planet UI (left side of screen)
- Displays resources, level, biome, XP
- "Gain XP" button
- Minimize button for collapsing UI
- Real-time updates every 0.5 seconds

#### ✅ UpgradeController
- Shop button (🛒) in top-right
- Shop UI with grid layout
- Shows all 7 upgrades with costs and levels
- Purchase button with validation
- "Maxed Out" indicator for completed upgrades

#### ✅ SolarSystemController
- Map button (🗺️) in top-right
- Solar system map UI showing all planets
- Planet cards with type, level, biome
- Switch/Unlock buttons per planet
- Visual indicators for locked/active planets

#### ✅ RebirthController
- Rebirth button (🔄) in top-right (shows at 90% completion)
- Info panel showing rebirth benefits
- Confirmation dialog with warning
- Displays multiplier, stars earned, new rank
- Integrates with RebirthService

#### ✅ StarMapController
- Stars button (⭐) in top-right
- Constellation-themed upgrade UI
- Grid layout showing all 13 star upgrades
- Owned vs locked visual indicators
- Requirement chains (tier prerequisites)
- Real-time star counter

#### ✅ ShopController
- Opens when clicking golden shop NPC orb
- Premium shop UI with game pass grid
- 6 game pass cards with icons and descriptions
- Purchase buttons with Robux prices
- "✓ OWNED" indicator for purchased passes

#### ✅ TestingController
- Debug panel (press T to toggle)
- 7 command buttons
- Starts hidden, toggles with keyboard input
- Compact UI design

### Shared Modules

#### ✅ Constants.lua
- Resource base rates and caps
- Biome definitions and bonuses
- Planet configuration (XP scale, starting size)
- System-wide constants

#### ✅ Types.lua
- Type definitions for PlanetState, Resources, BiomeType
- Shared type safety across services and controllers

---

For implementation details, see [TECHNICAL.md](docs/TECHNICAL.md)  
For setup instructions, see [SETUP.md](SETUP.md)
