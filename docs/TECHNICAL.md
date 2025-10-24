# Technical Specification

## Technology Stack

- **Language**: TypeScript (via roblox-ts)
- **Compiler**: roblox-ts 2.x
- **Sync Tool**: Rojo 7.x
- **Runtime**: Roblox Luau

## Module Architecture

### Core Modules Overview
```
src/
├── server/
│   ├── init.server.ts       # Server entry point
│   ├── PlanetManager.ts     # Planet state and persistence
│   └── DataManager.ts       # DataStore management
├── client/
│   ├── init.client.ts      # Client entry point
│   └── ui/
│       ├── PlanetUI.ts     # Main planet view
│       ├── PetUI.ts        # Pet management interface
│       └── ShopUI.ts       # Premium shop interface
├── modules/
│   ├── EcosystemModule.ts  # Animal/plant simulation
│   ├── GrowthModule.ts     # Resource growth rules
│   ├── PetModule.ts        # Pet system logic
│   └── TradeModule.ts      # Trading system
└── shared/
    ├── types.ts            # Type definitions
    └── constants.ts        # Shared configuration
```

## Module Contracts

### PlanetManager
```typescript
/**
 * @class PlanetManager
 * Manages planet instances, state persistence, and player ownership
 */
export class PlanetManager {
    private planets = new Map<number, PlanetState>();
    
    /**
     * Get a player's planet
     * @param userId - Player's Roblox ID
     * @returns Planet data for the player
     */
    getPlanet(userId: number): PlanetState | undefined {
        return this.planets.get(userId);
    }
    
    /**
     * Apply an upgrade to a planet
     * @param userId - Player's Roblox ID
     * @param upgradeId - ID of upgrade to apply
     * @returns Success status and optional error message
     */
    applyUpgrade(userId: number, upgradeId: string): { success: boolean; error?: string } {
        // Implementation
    }
    
    /**
     * Update planet state based on time passed
     * @param planetState - Current planet state
     * @param deltaTime - Time since last update in seconds
     * @returns Updated planet state
     */
    updatePlanet(planetState: PlanetState, deltaTime: number): PlanetState {
        // Implementation
    }
}

interface PlanetState {
    id: string;
    ownerUserId: number;
    resources: Resources;
    biome: BiomeType;
    coverage: Coverage;
    biodiversity: number;
    animals: Map<string, number>;
    upgradesUnlocked: Set<string>;
    lastUpdated: number;
}
```

### PetModule
```typescript
/**
 * @class PetModule
 * Handles pet management, evolution, and skill systems
 */
export class PetModule {
    private pets = new Map<string, PetData>();
    
    /**
     * Create a new pet for a player
     * @param userId - Player's Roblox ID
     * @param petType - Type of pet to create
     * @returns New pet instance
     */
    createPet(userId: number, petType: string): PetData {
        // Implementation
    }
    
    /**
     * Evolve a pet by consuming another
     * @param userId - Player's Roblox ID
     * @param petId - Pet to evolve
     * @param sacrificePetId - Pet to consume for evolution
     * @returns Success status and optional error
     */
    evolvePet(
        userId: number, 
        petId: string, 
        sacrificePetId: string
    ): { success: boolean; error?: string } {
        // Implementation
    }
}

interface PetData {
    id: string;
    type: string;
    rarity: RarityType;
    level: number;
    experience: number;
    skills: Map<string, PetSkill>;
    customization: {
        color: Color3;
        accessories: string[];
        effects: string[];
    };
}

interface PetSkill {
    level: number;
    cooldown: number;
}
```

### GrowthModule
```typescript
/**
 * @class GrowthModule
 * Handles resource growth, plant stages, and biome transitions
 */
export class GrowthModule {
    /**
     * Start plant growth on a planet
     * @param planetState - Current planet state
     * @param plantType - Type of plant to grow
     * @returns Success status and optional error
     */
    startPlantGrowth(
        planetState: PlanetState, 
        plantType: string
    ): { success: boolean; error?: string } {
        // Implementation
    }
    
    /**
     * Progress all growth states
     * @param planetState - Current planet state
     * @param deltaTime - Time since last update
     * @returns Updated growth states
     */
    progressGrowth(planetState: PlanetState, deltaTime: number): GrowthState[] {
        // Implementation
    }
}

interface GrowthState {
    plantType: string;
    stage: number;
    progress: number;
    resourceRequirements: Resources;
    timeRemaining: number;
}
```

### EcosystemModule
```typescript
/**
 * @class EcosystemModule
 * Manages animal populations, food webs, and ecosystem balance
 */
export class EcosystemModule {
    /**
     * Add animals to a planet
     * @param planetState - Current planet state
     * @param animalType - Type of animal to add
     * @param count - Number of animals to add
     * @returns Success status and optional error
     */
    addAnimals(
        planetState: PlanetState, 
        animalType: string, 
        count: number
    ): { success: boolean; error?: string } {
        // Implementation
    }
    
    /**
     * Calculate biodiversity score
     * @param planetState - Current planet state
     * @returns Current biodiversity score
     */
    calculateBiodiversity(planetState: PlanetState): number {
        // Implementation
    }
}
```

### TradeModule
```typescript
/**
 * @class TradeModule
 * Handles player-to-player trading of pets and resources
 */
export class TradeModule {
    /**
     * Create a trade offer between players
     * @param senderId - Trading player's ID
     * @param receiverId - Target player's ID
     * @param offer - Items being offered
     * @returns Success status and optional error
     */
    createTrade(
        senderId: number, 
        receiverId: number, 
        offer: TradeOffer
    ): { success: boolean; error?: string } {
        // Implementation
    }
}

interface TradeOffer {
    pets: string[];
    resources: Resources;
    items: Map<string, number>;
}
```

## Data Persistence

### DataStore Keys
```typescript
export const DataStores = {
    PlayerData: "GrowPlanet_PlayerData_v1",
    PlanetStates: "GrowPlanet_Planets_v1",
    PetInventory: "GrowPlanet_Pets_v1",
    TradeHistory: "GrowPlanet_Trades_v1"
} as const;
```

### Save Structure
```typescript
interface PlayerSaveData {
    userId: number;
    inventory: {
        pets: PetData[];
        resources: Resources;
        items: Map<string, number>;
    };
    progression: {
        level: number;
        experience: number;
        achievements: Set<string>;
        seasonPass: {
            tier: number;
            premium: boolean;
            rewards: Map<string, boolean>;
        };
    };
    settings: {
        notifications: boolean;
        privacy: {
            allowVisits: boolean;
            allowTrades: boolean;
        };
    };
    lastUpdate: number;
}
```

## Network Protocol

### RemoteEvents
```typescript
import { ReplicatedStorage } from "@rbxts/services";

const remotes = ReplicatedStorage.WaitForChild("Remotes") as Folder;

// Planet updates
export const PlanetStateUpdated = remotes.WaitForChild("PlanetStateUpdated") as RemoteEvent;
export const ResourceCollected = remotes.WaitForChild("ResourceCollected") as RemoteEvent;
export const UpgradeApplied = remotes.WaitForChild("UpgradeApplied") as RemoteEvent;

// Pet system
export const PetCreated = remotes.WaitForChild("PetCreated") as RemoteEvent;
export const PetEvolved = remotes.WaitForChild("PetEvolved") as RemoteEvent;
export const PetSkillActivated = remotes.WaitForChild("PetSkillActivated") as RemoteEvent;

// Trading
export const TradeRequested = remotes.WaitForChild("TradeRequested") as RemoteEvent;
export const TradeAccepted = remotes.WaitForChild("TradeAccepted") as RemoteEvent;
export const TradeCancelled = remotes.WaitForChild("TradeCancelled") as RemoteEvent;
```

### RemoteFunctions
```typescript
// Planet queries
export const GetPlanetState = remotes.WaitForChild("GetPlanetState") as RemoteFunction;
export const GetResourceRates = remotes.WaitForChild("GetResourceRates") as RemoteFunction;

// Pet queries
export const GetPetInventory = remotes.WaitForChild("GetPetInventory") as RemoteFunction;
export const GetPetDetails = remotes.WaitForChild("GetPetDetails") as RemoteFunction;

// Trading
export const GetActiveOffers = remotes.WaitForChild("GetActiveOffers") as RemoteFunction;
export const GetTradeHistory = remotes.WaitForChild("GetTradeHistory") as RemoteFunction;
```

## Performance Considerations

### Client-Side Optimization
- Use BindToRenderStep for smooth planet rotation
- Implement view distance culling for city/plant models
- Cache pet animations and effects
- Lazy load UI elements for shop and trading

### Server-Side Optimization
- Batch planet state updates (every 5 seconds)
- Cache frequent DataStore queries
- Use spatial partitioning for multi-planet instances
- Queue and batch trade processing

## Testing

### Unit Tests
```typescript
// Example test structure (using hypothetical test framework)
describe("PetEvolution", () => {
    it("should successfully evolve with valid pets", () => {
        const userId = 123;
        const petModule = new PetModule();
        
        // Create test pets
        const pet1 = petModule.createPet(userId, "SpaceDragon");
        const pet2 = petModule.createPet(userId, "SpaceDragon");
        
        // Test evolution
        const result = petModule.evolvePet(userId, pet1.id, pet2.id);
        expect(result.success).toBe(true);
    });
});
```

### Integration Tests
```typescript
// Example integration test
describe("CompleteUpgradeFlow", () => {
    it("should allow plant growth after water upgrade", () => {
        const userId = 123;
        const planetManager = new PlanetManager();
        const growthModule = new GrowthModule();
        
        // Test full upgrade sequence
        const planet = planetManager.getPlanet(userId)!;
        const upgradeResult = planetManager.applyUpgrade(userId, "AddWater");
        expect(upgradeResult.success).toBe(true);
        
        // Verify growth enabled
        const growthResult = growthModule.startPlantGrowth(planet, "BasicPlant");
        expect(growthResult.success).toBe(true);
    });
});
```

## Error Handling

### Error Types
```typescript
export enum ErrorType {
    INSUFFICIENT_RESOURCES = "InsufficientResources",
    INVALID_UPGRADE = "InvalidUpgrade",
    PET_NOT_FOUND = "PetNotFound",
    TRADE_FAILED = "TradeFailed",
    SAVE_FAILED = "SaveFailed"
}

interface GameError {
    type: ErrorType;
    message: string;
    context?: unknown;
}
```

### Error Handling Pattern
```typescript
function safeCall<T>(callback: () => T): { value?: T; error?: GameError } {
    try {
        const value = callback();
        return { value };
    } catch (err) {
        warn("[GrowPlanet] Error:", err);
        return {
            error: {
                type: ErrorType.SAVE_FAILED,
                message: `Operation failed: ${tostring(err)}`
            }
        };
    }
}

// Usage
const result = safeCall(() => saveData(player));
if (result.error) {
    // Handle error
    warn("Save failed:", result.error.message);
} else {
    // Use value
    print("Saved:", result.value);
}
```

## Constants and Configuration

### Game Balance
```typescript
export const GameConstants = {
    BASE_RESOURCE_RATE: 1,
    VIP_MULTIPLIER: 2,
    PET_EVOLUTION_COST: 100,
    MAX_PLANET_SIZE: 1000,
    MAX_PETS_PER_PLAYER: 50,
    DISASTER_CHANCE: 0.1,
    TRADE_TAX_RATE: 0.05
} as const;
```

### Premium Features
```typescript
interface ProductBenefits {
    resourceMultiplier?: number;
    extraPetSlots?: number;
    uniquePlanetSkins?: boolean;
    multiHatch?: boolean;
    exclusivePets?: boolean;
    autoLevel?: boolean;
}

interface PremiumProduct {
    id: string;
    price: number;
    benefits: ProductBenefits;
}

export const PremiumProducts: Record<string, PremiumProduct> = {
    VIP_PASS: {
        id: "com.growplanet.vip",
        price: 899,
        benefits: {
            resourceMultiplier: 2,
            extraPetSlots: 10,
            uniquePlanetSkins: true
        }
    },
    PET_MASTER: {
        id: "com.growplanet.petmaster",
        price: 799,
        benefits: {
            multiHatch: true,
            exclusivePets: true,
            autoLevel: true
        }
    }
} as const;
```