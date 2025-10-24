# Grow a Planet - Game Reference

## Overview
Grow a Planet is a casual/idle-ish terraforming and world-building experience for Roblox players. Each player owns a single planet instance and progresses from a barren rock to a complex, living world by collecting resources, unlocking upgrades, and making gameplay choices that alter the planet's biome, visuals, and systems.

Core pillars:
- Growth & transformation: clear visual progress keeps players rewarded
- Systems layering: resources → biomes → life → civilization
- Emergent events: disasters and alien encounters requiring player decisions
- Collection & nurturing: pets and rare creatures to collect and evolve
- Social features: trading, visiting friends' planets, and global events

## Premium Features & Monetization
### Game Passes
1. **VIP Status** (899 Robux)
   - 2x resource generation rate
   - Exclusive planet skins
   - VIP badge and chat tag
   - Priority server access
   - Daily VIP rewards

2. **Pet Master** (799 Robux)
   - Hatch 3 pets simultaneously
   - Exclusive pet eggs
   - Pet storage expansion (+20 slots)
   - Auto-pet leveling feature

3. **Planet Expansion** (699 Robux)
   - Double planet size
   - Additional biome slots
   - More city capacity
   - Expanded resource storage

4. **Resource Bundle** (499 Robux)
   - 2x resource storage
   - Auto-resource collection
   - Resource boost aura
   - Premium resource types

### Limited Time Offers
- Seasonal pet collections
- Holiday planet themes
- Event-exclusive upgrades
- Flash sales on boosts

## Pet System
### Pet Types
1. **Cosmic Companions**
   - Space Dragons
   - Star Whales
   - Nebula Foxes
   - Meteor Hounds
   - Galaxy Cats

2. **Element Guardians**
   - Flame Spirits
   - Water Wisps
   - Earth Golems
   - Wind Phoenixes

### Pet Features
- **Rarity Tiers**: Common, Rare, Epic, Legendary, Mythical
- **Evolution System**: Combine duplicate pets to create stronger versions
- **Pet Skills**:
  - Resource generation boost
  - Faster plant growth
  - Auto-collection radius
  - Disaster protection
  - Special abilities (unique to each pet type)

- **Pet Customization**:
  - Color variations
  - Accessories
  - Trails and effects
  - Name tags

### Pet Management
```lua
-- Pet data structure
PetData = {
    id = string,
    type = string,
    rarity = string,
    level = number,
    experience = number,
    skills = {
        [skillId] = {
            level = number,
            cooldown = number
        }
    },
    customization = {
        color = Color3,
        accessories = {accessoryId},
        effects = {effectId}
    }
}
```

## Core Systems
### Resource Generation
- Base collection rate: 1 unit/second
- VIP bonus: +100% (2 units/second)
- Pet bonuses: +10-50% per active pet
- Building bonuses: +5-25% per structure
- Daily streak bonus: +1% per day (caps at +30%)

### Player Progression
1. Early Game (Day 1-3)
   - Basic resource collection
   - First pet egg (tutorial reward)
   - Initial planet customization

2. Mid Game (Week 1-2)
   - Multiple pet management
   - City development
   - Trading unlocked
   - First disasters

3. Late Game (Month 1+)
   - Legendary pets
   - Advanced civilizations
   - Cross-planet trading
   - Global events participation

### Social Features
- **Trading System**
  - Pet trading
  - Resource exchange
  - Limited items marketplace
  
- **Friend Features**
  - Visit friend planets
  - Co-op disaster management
  - Resource gifting
  - Pet breeding partnerships

- **Global Events**
  - Weekly challenges
  - Season pass progression
  - Community goals
  - Special limited-time zones

### Season Pass System (Premium - 799 Robux)
- 100 tiers of rewards
- Premium exclusive pets
- Bonus resource multipliers
- Special planet effects
- Exclusive building skins
- Premium currency rewards

## Technical Implementation
### Pet System Backend
```lua
local PetManager = {
    -- Pet spawning and management
    spawnPet = function(userId, petData),
    levelUpPet = function(userId, petId),
    evolvePet = function(userId, petId1, petId2),
    
    -- Pet abilities and effects
    activatePetSkill = function(userId, petId, skillId),
    calculatePetBonus = function(userId),
    
    -- Pet customization
    updatePetAppearance = function(userId, petId, customData)
}
```

### Economy Balance
- **Resource Generation**
  ```lua
  function calculateResourceGen(player)
    local base = 1 -- Base rate
    local vipMult = player.hasVIP and 2 or 1
    local petBonus = PetManager.calculatePetBonus(player.userId)
    local buildingBonus = BuildingManager.calculateBonus(player.userId)
    
    return base * vipMult * (1 + petBonus) * (1 + buildingBonus)
  end
  ```

## UI/UX Design
### Main Interface
- Resource counters (top)
- Pet inventory (right sidebar)
- Build menu (bottom)
- Social features (left sidebar)
- Events panel (top right)

### Pet Interface
- Collection book
- Evolution calculator
- Skill tree viewer
- Trading interface
- Customization panel

## Data Storage
### Player Data Structure
```lua
PlayerData = {
    userId = number,
    inventory = {
        pets = {PetData},
        resources = {
            [resourceType] = amount
        },
        items = {[itemId] = amount}
    },
    progression = {
        level = number,
        experience = number,
        achievements = {achievementId = true},
        seasonPass = {
            tier = number,
            premium = boolean,
            rewards = {[rewardId] = claimed}
        }
    },
    planet = PlanetState
}
```

## Development Roadmap
### Phase 1 (MVP + Pets)
- Core resource generation
- Basic planet customization
- Initial pet system (5 pet types)
- VIP and Pet Master passes

### Phase 2 (Social)
- Trading system
- Friend visits
- Global events
- Season Pass

### Phase 3 (Expansion)
- New pet types
- Advanced civilizations
- Cross-server trading
- Community events