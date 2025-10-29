# Grow a Planet - Game Reference

## Overview
Grow a Planet is a casual/idle-ish terraforming and world-building experience for Roblox featuring a **two-layer gameplay structure**: active space exploration and passive planet customization. Players progress from a barren rock to a complex, living world through combat, exploration, resource collection, and creative planet building.

### 🌍 Two-Layer Gameplay Structure

#### 1️⃣ The Space Layer (Active Gameplay)
The **action zone** where players actively engage in combat, exploration, and territory expansion.

**What You Do:**
- **Combat & Destruction** - Destroy asteroids and alien outposts
- **Territory Expansion** - Claim space around your planet (growing bubble effect)
- **Resource Collection** - Gather Planet Essence, Biome Energy, and special fragments
- **Exploration** - Discover new sectors and rare biome fragments
- **Ship Upgrades** - Improve your ship's speed, damage, and capacity

**Resources Earned:**
- **Planet Essence** - Primary currency for planet customization
- **Biome Energy** - Used to place and upgrade biomes
- **Biome Fragments** - Special unlock items:
  - Volcanic Core (Lava biome)
  - Frozen Crystal (Ice biome)
  - Ocean Pearl (Ocean enhancements)
  - Forest Seed (Forest enhancements)
  - Desert Shard (Desert biome)

**Territory System:**
- Start with 100 stud radius around your planet
- Expand to 500+ studs by destroying asteroids/aliens
- Larger territory = more resource spawns
- Visual sphere shows your claimed space
- Territory persists across sessions

#### 2️⃣ The Planet Layer (Customization & Progression)
The **creative zone** accessed via "View My Planet" button - a dedicated camera view or UI screen.

**What You Do:**
- **Biome Placement** - Apply discovered biomes to your planet (drag-and-drop)
- **Visual Customization** - Change atmosphere color, add rings, place moons
- **Planet Skins** - Apply themed skins (Candy, Cyber, Toxic, Lava, Ice, Crystal)
- **Civilization Building** - Watch settlements grow into sprawling cities
- **Idle Progression** - Planet generates resources passively when offline

**Customization Options:**
- **Biomes** (4-8 slots, expandable)
  - Requires: Biome Fragment + Biome Energy + Planet Essence
  - Visual growth animation when placed
  - Affects resource generation and civilization type
  
- **Atmosphere**
  - Glow color (unlocked via achievements)
  - Density (thin/medium/thick)
  - Cloud patterns
  
- **Orbital Objects**
  - Moons (1-3 total)
  - Rings (color, density, rotation)
  - Space stations
  - Satellites
  
- **Civilization Stages** (Passive Growth)
  1. Small settlements (campfires)
  2. Towns (buildings)
  3. Cities (lights, roads)
  4. Metropolis (sprawling urban areas)
  5. Advanced (orbiting structures)

**Visual Payoff:**
- Beautiful rotating planet to showcase
- Share screenshots with friends
- Show off rare planet skins
- Watch civilizations develop in real-time
- Lights appear on the night side of your planet

### Core Pillars
- **Two-Layer Engagement** - Active space combat + passive planet building
- **Growth & transformation** - Clear visual progress keeps players rewarded
- **Systems layering** - Resources → biomes → life → civilization
- **Emergent events** - Disasters and alien encounters requiring player decisions
- **Collection & nurturing** - Pets and rare creatures to collect and evolve
- **Social features** - Trading, visiting friends' planets, and global events

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

## Space Layer Systems

### Combat & Destruction

#### Asteroids
**Common Asteroids** (50% spawn rate)
- Health: 10-30 HP
- Respawn: 5 seconds
- Drops: Minerals (5-15), Energy (2-8)

**Rare Asteroids** (35% spawn rate)
- Health: 40-80 HP
- Respawn: 15 seconds
- Drops: Planet Essence (10-25), Energy (10-20), Minerals (20-40)

**Epic Asteroids** (15% spawn rate)
- Health: 100-200 HP
- Respawn: 30 seconds
- Drops: Planet Essence (50-100), Biome Energy (5-15), Biome Fragments (5% chance)

#### Alien Enemies
**Scout Ships** (Common)
- Health: 50 HP
- Respawn: 2 minutes
- Drops: Planet Essence (20-40), Credits (10-20)
- Behavior: Patrols territory border

**Fighter Ships** (Uncommon)
- Health: 150 HP
- Respawn: 5 minutes
- Drops: Planet Essence (60-120), Biome Fragments (10% chance), Stars (1-3)
- Behavior: Actively attacks player

**Alien Outposts** (Rare)
- Health: 500 HP
- Respawn: 15 minutes
- Drops: Biome Fragments (50% chance), Premium Fragments (10% chance), Stars (5-10), Planet Essence (200-500)
- Behavior: Stationary, shoots projectiles

#### Ship System
**Starting Ship: "Pioneer"**
- Speed: 50 studs/second
- Damage: 10 per shot
- Health: 100 HP
- Capacity: 100 resources

**Ship Upgrade Path:**
- Speed: +10 studs/s per level (max 150 studs/s)
- Damage: +5 per level (max 100 damage)
- Health: +25 HP per level (max 500 HP)
- Capacity: +50 per level (max 1000)

**Ship Cosmetics** (Premium & Earned)
- Color customization
- Engine trail effects
- Hull designs
- Weapon visual effects

### Territory System
**Territory Mechanics:**
- Base radius: 100 studs
- Expansion: +1-5 studs per asteroid destroyed
- Max radius: 500 studs (expandable with premium/upgrades)
- Territory shown as transparent sphere around planet
- Asteroids only spawn within territory

**Territory Bonuses:**
- 100-200 studs: +10% asteroid spawn rate
- 200-300 studs: +25% asteroid spawn rate, unlock rare asteroids
- 300-400 studs: +50% spawn rate, unlock epic asteroids
- 400-500 studs: +100% spawn rate, alien scouts appear
- 500+ studs: All spawn types, alien outposts appear

### Biome Fragment Discovery
**Fragment Types & Uses:**
1. **Volcanic Core** - Unlocks Lava biome
   - Drop source: Epic asteroids (5%), Fighter ships (10%)
   - Visual: Glowing orange crystal
   
2. **Frozen Crystal** - Unlocks Ice biome
   - Drop source: Epic asteroids (5%), Outposts (20%)
   - Visual: Crystalline blue shard
   
3. **Ocean Pearl** - Enhances Oceanic biome (+50% water bonus)
   - Drop source: Rare asteroids (2%), Fighter ships (15%)
   - Visual: Shimmering pearl
   
4. **Forest Seed** - Enhances Forest biome (+50% biomass bonus)
   - Drop source: Epic asteroids (8%), Scouts (5%)
   - Visual: Glowing green seed
   
5. **Desert Shard** - Unlocks Desert biome
   - Drop source: Outposts (30%), Epic asteroids (3%)
   - Visual: Golden sand crystal

**Fragment Storage:**
- Max 999 per fragment type
- Stored in player inventory
- Used in Planet Layer for biome placement

## Planet Layer Systems

### Biome Placement System
**How It Works:**
1. Enter Planet View mode ("View My Planet" button)
2. Open Biome Inventory (shows collected fragments)
3. Select biome to place
4. Click region on planet surface (4-8 slots available)
5. Confirm placement (consumes fragment + Biome Energy + Planet Essence)
6. Watch biome grow with visual effects

**Placement Costs:**
- **Barren** (default) - Free
- **Rocky** - 50 Planet Essence
- **Oceanic** - 1 Ocean Pearl + 100 Biome Energy + 200 Planet Essence
- **Forest** - 1 Forest Seed + 150 Biome Energy + 300 Planet Essence
- **Lava** - 1 Volcanic Core + 200 Biome Energy + 500 Planet Essence
- **Ice** - 1 Frozen Crystal + 200 Biome Energy + 500 Planet Essence
- **Desert** - 1 Desert Shard + 150 Biome Energy + 350 Planet Essence

**Biome Effects on Planet:**
- Visual appearance changes (color, texture, effects)
- Affects civilization type (desert cities, ice settlements, etc.)
- Provides passive resource bonuses
- Changes atmosphere effects

### Planet Skin System
**Free Skins** (Earned through gameplay)
- Classic Planet (default)
- Rocky World (reach level 10)
- Ocean Paradise (unlock all water biomes)
- Forest Haven (unlock all forest biomes)

**Premium Skins** (399 Robux each or included in VIP)
- Candy Planet - Pink/pastel, candy textures
- Cyber Planet - Neon grid, digital effects
- Toxic Planet - Green glow, hazardous look
- Lava World - Molten surface, ember particles
- Ice World - Frozen blue, aurora effects
- Crystal Planet - Gem facets, sparkle effects

**Seasonal Skins** (Limited time)
- Halloween Planet (October) - 299 Robux
- Christmas Planet (December) - 299 Robux
- Valentine Planet (February) - 299 Robux
- Summer Beach Planet (July) - 299 Robux

**How Skins Work:**
- Override biome colors and textures
- Keep biome bonuses (stats unchanged)
- Can be toggled on/off
- Mix and match with customization options

### Civilization Development
**Growth Mechanics:**
- **Population Growth Rate** - Based on biome quality (1-100 citizens/hour)
- **Growth Factors:**
  - Number of biomes placed (+10% per biome)
  - Biome quality (higher tier = faster growth)
  - Planet Essence investments (speed up growth)
  - Time spent in Planet View (watch it grow!)

**Civilization Stages:**
1. **Tribal** (0-1,000 population)
   - Small campfires visible at night
   - Scattered settlements
   - Basic resource gathering
   
2. **Towns** (1,000-10,000 population)
   - Buildings appear
   - Roads connect settlements
   - Markets and farms visible
   
3. **Cities** (10,000-100,000 population)
   - City lights at night
   - Road networks expand
   - Industrial zones
   
4. **Metropolis** (100,000-1,000,000 population)
   - Sprawling urban areas
   - Skyscrapers and monuments
   - Advanced infrastructure
   
5. **Advanced Civilization** (1,000,000+ population)
   - Space stations orbiting planet
   - Satellites and communication arrays
   - Planetary defense systems
   - Futuristic megastructures

**Visual Indicators:**
- **Day Side:** Buildings, roads, structures
- **Night Side:** City lights, illuminated roads
- **Orbit:** Satellites, space stations, ships
- **Atmosphere:** Communication beams, launch trails

### Camera & Controls
**Planet View Mode:**
- Toggle with "View My Planet" button
- Smooth camera transition (2 second animation)
- Camera orbits planet automatically (can pause)
- Mouse drag to rotate view
- Scroll wheel to zoom in/out
- Click planet surface to place biomes
- Return to Space Layer with "Back to Space" button

**Customization Interface:**
- Left panel: Biome inventory and options
- Right panel: Visual customization (atmosphere, rings, moons)
- Bottom bar: Planet stats and civilization progress
- Top bar: Resources (Planet Essence, Biome Energy)

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