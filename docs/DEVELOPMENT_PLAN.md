no# Grow a Planet - Development Plan

## 📋 Table of Contents
1. [Project Overview](#project-overview)
2. [Development Phases](#development-phases)
3. [Technical Roadmap](#technical-roadmap)
4. [Team & Resources](#team--resources)
5. [Timeline Estimates](#timeline-estimates)
6. [Risk Management](#risk-management)

---

## 🚀 Current Status (As of October 28, 2025)

### ✅ **Completed Systems** 
**Phases 1 & 2 COMPLETE** - Core game loop fully functional!

#### **Server Services (11/11 Complete):**
1. ✅ **PlanetService** - Planet state, resources, biome evolution
2. ✅ **PlanetVisualsService** - 3D planet spheres with rotation
3. ✅ **UpgradeService** - 7 upgrade types with purchase system
4. ✅ **DataService** - Auto-save every 60 seconds
5. ✅ **SolarSystemService** - Multi-planet solar systems (3-8 planets)
6. ✅ **RebirthService** - 90% completion prestige system
7. ✅ **StarMapService** - 13 star upgrades, offline earnings
8. ✅ **SpawnService** - Procedural spawn area with effects
9. ✅ **GamePassService** - 6 premium game passes
10. ✅ **PlotService** - Plot management system
11. ✅ **TestingService** - Debug commands (remove before production)

#### **Client Controllers (8/8 Complete):**
1. ✅ **PlanetController** - Main planet UI (left sidebar)
2. ✅ **UpgradeController** - Shop UI (🛒 button)
3. ✅ **SolarSystemController** - Solar system map (🗺️ button)  
4. ✅ **RebirthController** - Rebirth UI (🔄 button, 90% completion)
5. ✅ **StarMapController** - Star upgrades (⭐ button)
6. ✅ **ShopController** - Premium shop (golden NPC interaction)
7. ✅ **PlanetViewController** - Immersive planet view (🌍 button)
8. ✅ **TestingController** - Debug panel (T key, remove before production)

### 🎯 **Current Game Features:**
- ✅ **Multi-Planet Solar Systems** - Manage 3-8 planets per solar system
- ✅ **Resource Generation** - 4 resources with biome-based bonuses
- ✅ **Progression System** - Level up planets through 4 biome stages
- ✅ **Upgrade Shop** - 7 upgrades to boost resource generation
- ✅ **Rebirth/Prestige** - Reset progress for +10% permanent bonuses
- ✅ **Star Map Upgrades** - 13 permanent upgrades using Stars currency
- ✅ **Premium Shop** - 6 game passes for enhanced gameplay
- ✅ **Planet View Mode** - Immersive camera view of your planets
- ✅ **Visual Effects** - Professional spawn area with particles/lighting
- ✅ **Auto-Save System** - Progress saved every 60 seconds

### 🎮 **Ready for Alpha Testing!**
The core game loop is complete and ready for player testing:
1. **Start** → Spawn with 1 planet in a random solar system
2. **Grow** → Collect resources, level up, evolve through biomes  
3. **Expand** → Unlock additional planets in your solar system
4. **Upgrade** → Purchase upgrades and star map enhancements
5. **Prestige** → Rebirth at 90% completion for permanent bonuses
6. **Premium** → Optional game passes for enhanced experience

---

## 📋 **Current Focus: Phase 3 - Pet System + UI Polish**

### **Phase 3A: Pet System (Weeks 13-16)** 
✅ **Week 13 (COMPLETE)** - Pet foundation implemented
- ✅ PetService.lua with hatching, storage, evolution
- ✅ PetController.lua with inventory UI
- ✅ DataService integration for persistence
- ✅ Testing commands in TestingController

⏳ **Remaining Week 13-16 Work:**
- [ ] Pet hatching UI (dedicated screen)
- [ ] Pet evolution UI and confirmation dialogs
- [ ] Pet bonus integration with resource calculations
- [ ] Visual pet representations (3D models or sprites)
- [ ] Pet leveling system

### **Phase 3B: UI Responsive Design Refactor (NEW - Weeks 14-17)** 🆕
**Goal:** Convert all UI to responsive scale-based design for cross-platform consistency

**Why:** Current pixel-based UI causes issues on mobile, tablets, and consoles

**Documents Created:**
- ✅ `docs/DESIGN_SYSTEM.md` - Complete design system with colors, typography, standards
- ✅ `docs/ICON_TEMPLATE_GUIDE.md` - Step-by-step icon creation guide
- ✅ `docs/UI_REFACTOR_GUIDE.md` - Conversion templates and testing checklist

**Refactoring Priority:**
1. ⏳ **High Priority (Week 14-15):**
   - [ ] PetController - Pet inventory panel
   - [ ] ShopController - Shop UI
   - [ ] Navigation Buttons - Right-side vertical stack
   - [ ] UpgradeController - Upgrade panel

2. ⏳ **Medium Priority (Week 15-16):**
   - [ ] StarMapController - Star map view
   - [ ] SolarSystemController - Galaxy view
   - [ ] SettingsController - Settings panel
   - [ ] RebirthController - Rebirth UI

3. ⏳ **Low Priority (Week 16-17):**
   - [ ] TestingController - Debug panel
   - [ ] Polish and optimization

**Key Principles:**
- Use **Scale** instead of **Offset** for all positioning/sizing
- Set **AnchorPoint = 0.5, 0.5** for centered elements
- Add **UIAspectRatioConstraint** to maintain proportions
- Add **UISizeConstraint** for min/max size limits
- Use **TextScaled** with **UITextSizeConstraint** for responsive text
- Test on PC, mobile, tablet, and console

**Estimated Timeline:** 4 weeks
**Target Completion:** December 9, 2025

---

## Project Overview

### Vision
Create an engaging idle/simulation game where players nurture their own planet from a barren rock to a thriving civilization through a **two-layer gameplay structure**: active space exploration and passive planet customization.

### 🌍 Two-Layer Gameplay Structure

#### 1️⃣ The Space Layer (Active Gameplay)
This is where players actively engage in combat, exploration, and resource collection.
Think of it as the "active income" or "resource generation" area.

**Core Activities:**
- **Destroy Asteroids & Alien Outposts** - Collect Planet Essence and Biome Energy
- **Claim Territory** - Visually expand the "bubble" where your planet can grow
- **Discover Biome Fragments** - Find rare fragments like "Volcanic Core," "Frozen Crystal," "Ocean Pearl"
- **Combat & Exploration** - Fight alien threats, explore new sectors, mine resources
- **Active Resource Generation** - Earn resources through gameplay actions

**Visual Feedback:**
- Growing territory sphere around your planet
- Expanding influence zone in space
- Resource particle effects from destroyed asteroids
- Visual progression as you claim more space

#### 2️⃣ The Planet Layer (Customization & Progression)
Accessed via a "View My Planet" button - takes you to a UI screen or floating camera view of your planet.
Players use resources earned in the Space Layer to evolve and customize their planet.

**Core Features:**
- **Biome Placement** - Add unlocked biomes (e.g., place ice caps, forests, oceans)
- **Visual Customization** - Sky color, atmosphere glow, orbiting moons, planetary rings
- **Planet Skins** - Apply themed skins (Candy Planet, Cyber Planet, Toxic Planet, Lava World)
- **Civilization Development** - Watch cities form, lights appear, populations grow
- **Idle Progression** - Planet generates resources passively when you're away
- **Biome Fragment Application** - Use discovered fragments to unlock and enhance biomes

**Visual Payoff:**
- Beautiful, rotating planet to showcase your progress
- Share screenshots with friends
- Unlock unique planetary features as you progress
- Watch your world come alive with civilizations

### Core Pillars
1. **Two-Layer Engagement** - Active space combat + passive planet building
2. **Growth & Progression** - Clear visual feedback on planet evolution
3. **Collection & Discovery** - Biome fragments, pets, and rare resources
4. **Social Interaction** - Trading, visiting, and competing with friends
5. **Monetization** - Fair premium features that enhance but don't gate content

### Target Audience
- Primary: Ages 10-16 (casual/idle game enthusiasts)
- Secondary: Ages 8-25 (Roblox simulation game players)
- Platform: Desktop and Mobile (optimized for both)

---

## Development Phases

## Phase 1: Foundation & Core Systems (Weeks 1-4)

### Week 1-2: Project Setup & Infrastructure
**Goal:** Establish development environment and core framework

#### Tasks:
- [x] Set up TypeScript/roblox-ts project structure ✅ (Switched to Lua for better Knit compatibility)
- [x] Configure Knit framework (Services/Controllers) ✅
- [x] Set up Wally for package management ✅
- [x] Create documentation structure ✅
- [ ] Set up version control workflows (Git branches, PR templates)
- [ ] Configure CI/CD pipeline (optional but recommended)
- [ ] Set up testing framework (TestEZ)
- [ ] Create development/staging place files

#### Deliverables:
- ✅ Working Lua build pipeline with Rojo
- ✅ Knit Services and Controllers initialized
- ✅ Complete project documentation (ARCHITECTURE.md, SETUP.md, CONTRIBUTING.md, MIGRATION.md)
- ✅ Development environment guide

**Priority:** 🔴 Critical
**Status:** ✅ COMPLETE (Oct 23, 2025)

---

### Week 3-4: Core Planet System
**Goal:** Implement basic planet creation and resource generation

#### Services Created:
1. ✅ **PlanetService** (Server)
   - ✅ Create planet for new players
   - ✅ Store planet state (biome, size, resources)
   - ✅ Update resources over time (1s tick rate)
   - ✅ Level-up and biome evolution system
   
2. ✅ **PlanetVisualsService** (Server)
   - ✅ 3D sphere visualization in Workspace
   - ✅ Biome-based colors and materials
   - ✅ Rotation animation via RunService
   - ✅ Player name labels
   - ✅ Dynamic size and color updates

3. ✅ **PlanetController** (Client)
   - ✅ Display planet UI with resources
   - ✅ Show level, biome, and resource counters
   - ✅ Real-time updates every 0.5s
   - ✅ Professional UI design with emojis

#### Tasks:
- [x] Create `PlanetState` data structure ✅
- [x] Implement resource generation algorithm ✅
- [x] Create basic planet visualization (sphere with texture) ✅
- [x] Build resource UI (water, minerals, energy, biomass) ✅
- [ ] Implement auto-save system (every 5 minutes) - ProfileService pending
- [x] Add planet rotation and camera controls ✅

#### Technical Details:
```lua
-- Resource Generation Formula (Implemented)
baseRate = Constants.RESOURCES.BASE_*_RATE
biomeBonus = Constants.BIOMES[biome].*Bonus
actualRate = baseRate * (1 + biomeBonus)
newAmount = currentAmount + (actualRate * deltaTime)
```

#### Deliverables:
- ✅ Players spawn with a basic planet
- ✅ Resources generate automatically (Water: 1/s, Minerals: 0.8/s, Energy: 0.5/s, Biomass: 0.3/s)
- ✅ Resources display in clean UI panel
- ✅ 3D planet sphere rotates and changes based on biome
- ✅ Biome evolution: Barren → Rocky (Lvl 3) → Oceanic (Lvl 7) → Forest (Lvl 12)

**Priority:** 🔴 Critical
**Status:** ✅ COMPLETE (Oct 23, 2025)

**Notes:**
- Successfully implemented in Lua instead of TypeScript for better Knit compatibility
- Combined ResourceService logic into PlanetService for simplicity
- 3D visualization added as bonus feature with rotating spheres
- All core systems verified working with no console errors
- **TODO:** Expand to multi-planet solar system (see Phase 2, Week 9)

---

## Phase 2: Progression & Upgrades (Weeks 5-8)

### Week 5-6: Upgrade System
**Goal:** Allow players to spend resources to improve their planet

#### Services Created:
1. ✅ **UpgradeService** (Server)
   - ✅ Store available upgrades (7 types defined)
   - ✅ Validate upgrade requirements (resources, level, max level)
   - ✅ Apply upgrade effects (rate multipliers, caps, size)
   - ✅ Track unlocked upgrades per player

2. ✅ **UpgradeController** (Client)
   - ✅ Display upgrade shop UI (scrollable cards)
   - ✅ Show costs and benefits (color-coded affordability)
   - ✅ Handle purchase requests (Promise-based)
   - ✅ Show locked/unlocked states (level requirements, max level)

#### Upgrade Categories Implemented:
1. ✅ **Resource Rate Upgrades**
   - ✅ Water Pump I (+25% per level, max 5)
   - ✅ Mining Drill I (+25% per level, max 5)
   - ✅ Solar Panel I (+25% per level, max 5)
   - ✅ Bio-Reactor I (+25% per level, max 5)

2. ✅ **Resource Cap Upgrades**
   - ✅ Water Tank I (+500 per level, max 10)
   - ✅ Mineral Vault I (+500 per level, max 10)

3. ✅ **Planet Upgrades**
   - ✅ Planetary Growth (+5 size per level, max 10)

#### Tasks:
- [x] Create upgrade data structure and config ✅
- [x] Build upgrade shop UI (scrollable cards) ✅
- [x] Implement purchase validation (resource costs, level requirements) ✅
- [x] Add upgrade effects to resource calculations ✅
- [ ] Create upgrade unlock tree (dependencies) - Future enhancement
- [x] Add visual feedback for purchases (UI refresh) ✅

#### Deliverables:
- ✅ Functional upgrade shop with toggle button
- ✅ 7 unique upgrades (expandable to 15-20)
- ✅ Resource generation multipliers working
- ✅ Resource caps enforced
- ✅ Planet size increases visual on purchase

**Priority:** 🔴 Critical
**Status:** ✅ COMPLETE (Oct 23, 2025)

**Notes:**
- Shop UI features 🛒 button in top-right corner
- Upgrade cards show name, description, level, costs (color-coded)
- Purchase validation prevents overspending
- Multipliers successfully apply to resource generation
- Tested and verified working with no errors

---

### Week 7-8: Biome System
**Goal:** Planets evolve through different biomes

**Status:** ✅ ALREADY COMPLETE (implemented in Phase 1)

#### Biome Types:
1. ✅ **Barren** (Starting - Level 1)
   - Gray/brown colors
   - No atmosphere
   - Minimal resources

2. ✅ **Rocky** (Level 3)
   - Brown/red terrain (Slate material)
   - Small atmosphere
   - +50% Mineral generation

3. ✅ **Oceanic** (Level 7)
   - Blue water coverage (Water material)
   - Thick atmosphere
   - +100% Water generation
   - +30% Energy, +20% Biomass

4. ✅ **Forest** (Level 12)
   - Green vegetation (Grass material)
   - Full atmosphere
   - +150% Biomass generation
   - +50% Water, +30% Minerals, +80% Energy

5. **Advanced** (Future)
   - Lava, Ice, Jungle, Desert

#### Tasks:
- [x] Create biome data configuration ✅
- [x] Implement biome transition logic (level-based) ✅
- [x] Build biome-specific materials/textures ✅
- [ ] Add particle effects per biome - Future enhancement
- [x] Create transition animations (color/material changes) ✅
- [x] Update resource rates per biome ✅

#### Technical Details:
```lua
-- Biome Transition Requirements (Level-Based)
Barren → Rocky: Level 3
Rocky → Oceanic: Level 7
Oceanic → Forest: Level 12

-- Implemented in PlanetService:_calculateBiome()
-- Colors and bonuses in Constants.BIOMES
```

#### Deliverables:
- 4 distinct biome types
- Smooth transition animations
- Biome-specific resource bonuses
- Visual variety in planets

**Priority:** 🟡 High

---

### Week 8: Star Map & Prestige System
**Goal:** Endgame progression system with offline earnings upgrades

#### Star Map Overview:
Once a player reaches max level (Level 12+ with Forest biome) on any planet in their solar system, they unlock the **Star Map** - a prestige system where players can spend special "Stars" currency to unlock permanent bonuses that persist through rebirths.

#### Star System:
1. **Earning Stars**
   - Unlock 1 Star per biome mastered per planet (4 stars × number of planets)
   - Bonus stars for achievements (first planet to max level, unlock all planets in solar system, etc.)
   - Bonus stars from rebirthing (10-50 stars per rebirth based on progress)
   - Stars can be purchased with premium currency (optional)
   - **Stars are PERMANENT** - Keep through rebirths!
   
2. **Star Map UI**
   - Visual star constellation map
   - Click stars to unlock permanent upgrades
   - Shows locked/unlocked stars
   - Preview benefits before purchasing
   - Shows total stars earned across all rebirths

#### Star Upgrades:
1. **Offline Earnings**
   - Tier 1: +2 hours offline earnings (1 Star)
   - Tier 2: +4 hours offline earnings (2 Stars)
   - Tier 3: +8 hours offline earnings (3 Stars)
   - Tier 4: +24 hours offline earnings (5 Stars)

2. **Offline Resource Multiplier**
   - Tier 1: 50% of normal rate while offline (1 Star)
   - Tier 2: 75% of normal rate while offline (2 Stars)
   - Tier 3: 100% of normal rate while offline (3 Stars)

3. **Global Bonuses**
   - All Resource Generation +10% (2 Stars)
   - All Resource Caps +50% (2 Stars)
   - XP Gain +25% (3 Stars)
   - Upgrade Costs -10% (3 Stars)

4. **Special Unlocks**
   - Auto-collect resources (4 Stars)
   - Unlock 5th biome slot (5 Stars)
   - Pet storage +10 slots (2 Stars)

#### Services to Create:
1. **StarMapService** (Server)
   - Track player stars earned
   - Validate star purchases
   - Apply star upgrade effects
   - Calculate offline earnings

2. **StarMapController** (Client)
   - Display star map UI
   - Show constellation visualization
   - Handle star upgrade purchases
   - Preview upgrade benefits

#### Tasks:
- [ ] Create star earning system (biome completion)
- [ ] Design star map UI (constellation theme)
- [ ] Implement star upgrade tree
- [ ] Add offline earnings calculation
- [ ] Create star unlock animations
- [ ] Integrate with existing systems (resources, upgrades)
- [ ] Add achievement system for bonus stars

#### Technical Details:
```lua
-- Offline Earnings Formula
timeOffline = currentTime - lastSaveTime
maxOfflineTime = baseOfflineTime + starUpgrades.offlineTimeBonus
cappedTime = math.min(timeOffline, maxOfflineTime)
offlineMultiplier = starUpgrades.offlineRateMultiplier
offlineResources = (normalRate * offlineMultiplier * cappedTime)
```

#### Deliverables:
- Star Map UI with constellation design
- 4 tiers of offline earnings upgrades
- Star earning system
- Offline earnings calculation
- 10+ star upgrades
- Achievement integration

**Priority:** 🟢 Medium (Endgame Content)

---

### Week 9: Solar System & Multi-Planet Expansion
**Goal:** Expand from single planet to entire solar system

#### Services Created:
1. ✅ **SolarSystemService** (Server)
   - ✅ Generates 3-8 random planets per solar system
   - ✅ 8 unique planet types (Mineral World, Ocean World, Energy Core, Life Planet, etc.)
   - ✅ Planet switching and unlocking system  
   - ✅ Tracks active planet per player
   - ✅ Planet unlock cost calculations (escalating resources)
   - ✅ Handles solar system-wide bonuses and shared resources

2. ✅ **SolarSystemController** (Client)
   - ✅ Map button (🗺️) in top-right corner
   - ✅ Solar system map UI showing all planets in orbital view
   - ✅ Planet cards with type, level, biome, unlock status
   - ✅ Switch/Unlock buttons per planet
   - ✅ Visual indicators for locked/active/current planets
   - ✅ Close button and scrollable planet grid

#### Planet Types Implemented:
1. ✅ **Home Planet** - Balanced starting planet
2. ✅ **Mineral World** - +50% mineral generation, slower water
3. ✅ **Ocean World** - +100% water generation, more biomass
4. ✅ **Energy Core** - +75% energy generation, faster XP gain
5. ✅ **Life Planet** - +100% biomass, unlocks special pets
6. ✅ **Volcanic World** - High temperature, +100% minerals, -50% water
7. ✅ **Ice World** - Low temperature, slow generation, +200% resource caps
8. ✅ **Gas Giant** - Huge size, generates all resources equally
9. ✅ **Barren Moon** - Small, fast XP gain, low resource generation

#### Tasks:
- [x] Create solar system generation algorithm ✅
- [x] Implement planet unlock system ✅
- [x] Build solar system map UI (orbital view) ✅
- [x] Add planet switching mechanics ✅
- [x] Create unique planet types with bonuses ✅
- [x] Implement solar system-wide upgrades ✅
- [ ] Add visual orbital paths for planets - Future enhancement

#### Deliverables:
- ✅ Solar system generation system (3-8 planets per system)
- ✅ Planet unlock progression with escalating costs
- ✅ Solar system map UI with orbital visualization
- ✅ 9 unique planet types with specialized bonuses
- ✅ Planet switching functionality with live updates
- ✅ Visual planet cards with lock/unlock states

**Priority:** 🔴 Critical (Core Gameplay Loop)
**Status:** ✅ COMPLETE (Oct 24, 2025)

---

### Week 10: Rebirth System (Prestige)
**Goal:** Allow players to reset progress for permanent bonuses

#### Rebirth Overview:
When players unlock **90% of available items** (upgrades, planets, pets, etc.) in their current solar system, they can **Rebirth** - resetting their progress but gaining powerful permanent bonuses and a new randomly generated solar system.

#### Rebirth Mechanics:
1. **Rebirth Requirements**
   - Unlock 90% of all items:
     - 90% of upgrades purchased
     - 90% of planets unlocked
     - 90% of pets collected (or skip this requirement)
   - Reach minimum level (e.g., Level 15+)
   
2. **What You Keep**
   - ⭐ **Stars** (prestige currency) - KEEP ALL
   - 🏆 **Star Map upgrades** - PERMANENT
   - 👾 **Pets** - KEEP ALL (optional: only keep favorites)
   - 💎 **Premium purchases** (game passes, etc.) - PERMANENT
   - 📊 **Rebirth multipliers** - ACCUMULATE

3. **What Resets**
   - All planets (new random solar system generated)
   - All resources
   - All non-Star upgrades
   - Planet levels/biomes
   - Solar system size (new random 3-8 planets)

4. **Rebirth Rewards**
   - **Rebirth Stars**: Earn bonus stars based on progress (10-50 stars per rebirth)
   - **Rebirth Multiplier**: Permanent +10% to all resource generation (stacks!)
   - **New Solar System**: Fresh random solar system with new planet types
   - **Rebirth Rank**: Prestige level shown on profile (Bronze → Silver → Gold → Platinum → Diamond)
   - **Exclusive Pets**: Unlock special "Rebirth Pets" (one per rebirth)
   - **Faster Progression**: Keep star upgrades for faster offline earnings

#### Rebirth Tiers:
- **Rebirth 1-5**: Bronze Rank (+10% per rebirth = +50% total)
- **Rebirth 6-10**: Silver Rank (+60-100% bonus)
- **Rebirth 11-20**: Gold Rank (+110-200% bonus)
- **Rebirth 21-50**: Platinum Rank (+210-500% bonus)
- **Rebirth 51+**: Diamond Rank (+500%+ bonus)

#### Services to Create:
1. **RebirthService** (Server)
   - Track rebirth count and progress
   - Calculate 90% completion threshold
   - Handle rebirth execution
   - Apply rebirth multipliers
   - Award rebirth stars and pets
   
2. **RebirthController** (Client)
   - Display rebirth UI with requirements
   - Show rebirth rewards preview
   - Confirmation dialog with warning
   - Rebirth animation/cutscene
   - Display rebirth rank badge

#### Tasks:
- [ ] Create rebirth eligibility calculation (90% items)
- [ ] Implement rebirth execution (reset planets, keep stars)
- [ ] Build rebirth UI with rewards preview
- [ ] Add rebirth multiplier system
- [ ] Create rebirth rank badges
- [ ] Design rebirth animation/cutscene
- [ ] Add rebirth-exclusive pets (5-10 types)
- [ ] Implement rebirth statistics tracking

#### Technical Details:
```lua
-- Rebirth Eligibility Check
totalItems = upgradesCount + planetsCount + petsCount
unlockedItems = player.upgradesUnlocked + player.planetsUnlocked + player.petsCollected
completionPercent = (unlockedItems / totalItems) * 100
canRebirth = completionPercent >= 90 and player.level >= 15

-- Rebirth Multiplier
rebirthBonus = player.rebirthCount * 0.10  -- +10% per rebirth
finalRate = baseRate * (1 + rebirthBonus) * (1 + starBonuses)
```

#### Rebirth UI:
- **Rebirth Button**: Shows in UI when 90% requirement met
- **Progress Tracker**: "Completion: 87% (need 90%)"
- **Rewards Preview**: "You will gain: 25 Stars, +10% permanent bonus, 1 exclusive pet"
- **Warning**: "Are you sure? This will reset all planets and resources!"
- **Confirmation**: Requires typing "REBIRTH" to confirm

#### Deliverables:
- Rebirth eligibility system
- 90% completion tracker
- Rebirth execution with resets
- Rebirth multiplier system (stacking)
- 5 rebirth rank tiers with badges
- Rebirth UI and confirmation
- 5-10 exclusive rebirth pets
- Rebirth animation

**Priority:** 🔴 Critical (Core Endgame Loop)

**Status:** ✅ COMPLETE (Oct 24, 2025)

---

### Week 11: Spawn Area & Premium Shop
**Goal:** Create an impressive spawn hub with premium shop for game passes

#### Spawn Area Features:
A multi-zone spawn area built with procedural generation and advanced visual effects:

1. **Central Hub Platform**
   - 100x100 multi-tiered circular platform with glass upper tier
   - Neon rim lighting around platform edges
   - Energy grid floor pattern with pulsing animations
   - Holographic planet centerpiece with particle effects
   - 3 orbital rings rotating around center planet
   - 12 hexagonal spawn points with pulse effects

2. **Energy Cores (4 Cardinal Directions)**
   - North (Blue), South (Pink), East (Green), West (Orange)
   - Rotating crystal cores with PointLights and ParticleEmitters
   - Floating/bobbing animations
   - Laser beam grid connecting all cores

3. **Tutorial Zone** (West Side)
   - Separate platform with holographic info board
   - Welcome message with game instructions
   - Glass bridge connecting to main hub

4. **Premium Shop District** (East Side)
   - 50x50 platform with premium building
   - Golden neon trim and holographic signs
   - Floating golden orb NPC (interactive)
   - Golden glass bridge with pulsing light posts

5. **Decorative Elements**
   - 8 floating asteroids with colored glows
   - Rotation and bobbing animations
   - Atmospheric effects (fog, bloom, color correction)
   - Space-themed lighting with blue/purple tones

#### Game Pass System:
Premium purchases that enhance gameplay:

**Available Game Passes:**
1. **💎 2x Resources** (199 R$)
   - Double all resource generation permanently
   - Benefit: `resourceMultiplier = 2.0`

2. **🌍 VIP Planet Slot** (299 R$)
   - +1 extra planet in solar system (max 9 planets)
   - Benefit: `extraPlanetSlot = 1`

3. **⚡ Auto-Collector** (399 R$)
   - Resources automatically collect every 10 seconds
   - Benefit: `autoCollect = true`

4. **🐾 Premium Pet Slots** (249 R$)
   - +10 pet storage slots
   - Benefit: `petSlots = 10`

5. **⚡ XP Boost** (349 R$)
   - 2x XP gain from all sources permanently
   - Benefit: `xpMultiplier = 2.0`

6. **🔄 Instant Rebirth** (499 R$)
   - Skip rebirth cooldowns and rebirth instantly
   - Benefit: `instantRebirth = true`

#### Services Created:
1. ✅ **SpawnService** (Server)
   - Procedurally generates spawn area on server start
   - Creates multi-level platforms with effects
   - Builds energy cores with particle systems
   - Constructs tutorial and shop zones
   - Adds decorative floating elements
   - Sets up atmospheric lighting and post-processing

2. ✅ **GamePassService** (Server)
   - Tracks player game pass ownership
   - Validates and processes purchases via MarketplaceService
   - Applies benefits (multipliers, slots, features)
   - Handles PromptGamePassPurchaseFinished events
   - Provides benefit calculation for other services

3. ✅ **ShopController** (Client)
   - Opens premium shop UI when clicking golden NPC orb
   - Displays all 6 game passes in grid layout
   - Shows "✓ OWNED" for purchased passes
   - Handles purchase prompts via GamePassService
   - Updates UI when purchases complete

#### Visual Effects Used:
- **Rotation animations** on planet, rings, cores, asteroids
- **Pulse effects** on spawn pads, grid tiles, lights
- **Particle emitters** for cosmic energy effects
- **PointLights** for ambient glow throughout
- **Beam effects** connecting energy cores
- **Post-processing**: Bloom, Atmosphere, ColorCorrection
- **Material effects**: Neon, ForceField, Glass

#### Technical Implementation:
- Uses TweenService for smooth animations
- Procedural generation avoids manual building
- Modular helper functions for reusable effects
- Async animations with task.spawn for performance
- Click detectors for NPC interaction
- Surface GUIs for holographic displays

#### Deliverables:
- ✅ Advanced spawn area with multiple themed zones
- ✅ 6 game pass products defined with benefits
- ✅ GamePassService for purchase handling
- ✅ Premium shop UI with grid display
- ✅ Visual effects and atmospheric lighting
- ✅ Interactive shop NPC with animations

**Priority:** 🟡 High (Monetization & First Impressions)

**Status:** ✅ COMPLETE (Oct 24, 2025)

---

### Week 12: Planet View System & UI Polish  
**Goal:** Add immersive planet viewing mode and polish existing UI

#### Services Created:
1. ✅ **PlanetViewController** (Client)
   - ✅ View Planet button (🌍) in navigation area
   - ✅ Smooth camera transitions to close-up planet view
   - ✅ Planet info overlay with resources and level display
   - ✅ Automatic camera rotation around planet
   - ✅ Interactive XP collection in planet view
   - ✅ Exit View button positioned to avoid UI overlaps

#### Features Implemented:
- ✅ **Camera Control System**
  - Scriptable camera for planet focus mode
  - Smooth TweenService transitions (1 second duration)
  - Automatic orbital rotation around planet core
  - Restore original camera position on exit

- ✅ **Planet View UI**
  - Title display ("My Planet" with player name)
  - Comprehensive info panel showing level, biome, resources
  - Two-column resource layout for clean display
  - Interactive "Gain XP" button within view
  - Exit button positioned in bottom-right (fixed overlap issue)

- ✅ **Integration Features**
  - Real-time resource updates in planet view
  - Seamless integration with existing planet system
  - Uses existing PlanetController for data consistency
  - Janitor cleanup for memory management

#### UI Bug Fixes:
- ✅ **Fixed Exit View Button Overlap** (Oct 28, 2025)
  - Repositioned from bottom-center to bottom-right
  - Changed position from `UDim2.new(0.5, -60, 1, -60)` to `UDim2.new(1, -140, 1, -60)`
  - Eliminated overlap with info panel's "Gain XP" button
  - Added descriptive comments for future maintenance

#### Tasks:
- [x] Create planet view toggle system ✅
- [x] Implement smooth camera transitions ✅
- [x] Build planet info overlay UI ✅
- [x] Add automatic camera rotation ✅
- [x] Integrate with existing planet data ✅
- [x] Fix UI element overlapping issues ✅
- [ ] Add zoom controls - Future enhancement
- [ ] Add particle effects in view mode - Future enhancement

#### Deliverables:
- ✅ Fully functional planet viewing mode
- ✅ Professional UI overlay with resource display
- ✅ Smooth camera animations and controls
- ✅ Integration with existing game systems
- ✅ Bug-free UI layout without overlaps

**Priority:** 🟡 High (Player Engagement & Polish)
**Status:** ✅ COMPLETE (Oct 28, 2025)

---

## Phase 3: Pet System (Weeks 13-16)

### Week 13-14: Pet Foundation
**Goal:** Implement pet hatching, display, and basic mechanics

#### Services to Create:
1. **PetService** (Server)
   - Store pet inventory per player
   - Handle pet creation/hatching
   - Calculate pet bonuses
   - Manage pet evolution
   
2. **PetController** (Client)
   - Display pet inventory UI
   - Show pet stats and abilities
   - Handle hatching animations
   - Equip/unequip pets

#### Pet System Design:
```typescript
interface PetData {
    id: string;
    type: PetType;
    rarity: "Common" | "Rare" | "Epic" | "Legendary" | "Mythical";
    level: number;
    experience: number;
    resourceBonus: number; // +10% to +50%
    specialAbility?: string;
}
```

#### Pet Types (Initial):
1. **Cosmic Companions**
   - Space Dragon (Legendary) - +40% all resources
   - Star Whale (Epic) - +25% water
   - Nebula Fox (Rare) - +15% energy
   
2. **Element Guardians**
   - Flame Spirit (Epic) - +30% temperature control
   - Water Wisp (Rare) - +20% water generation

#### Tasks:
- [ ] Create pet data structures and configs
- [ ] Implement pet egg system
- [ ] Build hatching mechanic with animations
- [ ] Create pet inventory UI
- [ ] Add pet models/visuals to planet
- [ ] Implement pet bonus calculations
- [ ] Create pet rarity system with drop rates

#### Drop Rates:
- Common: 50%
- Rare: 30%
- Epic: 15%
- Legendary: 4.5%
- Mythical: 0.5%

#### Deliverables:
- Pet hatching system
- 10-15 unique pet types
- Pet inventory and management UI
- Visual pet companions on planet
- Working bonus system

**Priority:** 🟡 High

---

### Week 15-16: Pet Evolution & Skills
**Goal:** Add depth to pet system through evolution

#### Evolution System:
- Combine 2 identical pets → Higher level evolved pet
- Evolved pets get +10% bonus per evolution
- Max 5 evolutions per pet
- Visual changes per evolution stage

#### Pet Skills:
1. **Passive Skills**
   - Resource generation boost
   - Offline earnings multiplier
   - Resource cap increase
   
2. **Active Skills** (Cooldown-based)
   - Instant resource burst (1hr cooldown)
   - Double generation (30min duration, 2hr cooldown)
   - Shield from disasters (blocks next disaster)

#### Tasks:
- [ ] Implement evolution mechanics
- [ ] Create evolution UI with preview
- [ ] Design skill system
- [ ] Add skill activation UI
- [ ] Create cooldown tracking
- [ ] Add visual evolution indicators

#### Deliverables:
- Working evolution system
- 3-5 pet skills implemented
- Skill UI and activation
- Evolution visual feedback

**Priority:** 🟢 Medium

---

## 🎯 **Immediate Next Steps (Week 13)**

### **Step 1: Design Pet System Architecture**
Before implementing, we need to design the pet system structure:

1. **Pet Data Structure**
   ```lua
   -- Create: src/shared/PetTypes.lua
   PetData = {
       id: string,
       type: PetType,
       rarity: "Common" | "Rare" | "Epic" | "Legendary" | "Mythical", 
       level: number,
       experience: number,
       resourceBonus: number, -- +10% to +50%
       specialAbility?: string
   }
   ```

2. **Services to Create**
   - `PetService.lua` (Server) - Handle pet creation, bonuses, evolution
   - `PetController.lua` (Client) - Pet UI, inventory, hatching animations

3. **Integration Points**
   - Integrate with existing `PlanetService` for resource bonus calculations
   - Add pet data to `DataService` save structure  
   - Create pet inventory UI accessible from main navigation

### **Step 2: Create Pet Foundation (This Week)**
**Recommended approach for GAP-PRE_ALPHA-TOOLS compliance:**

1. **Create Pet Service** 
   ```bash
   # Create new files:
   src/server/services/PetService.lua
   src/client/controllers/PetController.lua
   ```

2. **Design Pet Types**
   - Start with 5 basic pet types
   - Focus on resource generation bonuses
   - Simple rarity system (Common, Rare, Epic)

3. **Basic Pet UI**
   - Pet inventory button in navigation area
   - Simple grid layout for pet collection
   - Show owned pets and their bonuses

### **Step 3: Testing & Iteration**
- Use existing `TestingController` to add pet testing commands
- Add pets via debug panel for rapid testing
- Verify bonus calculations work with existing systems

### **Recommended Development Order:**
1. **Day 1-2:** Create PetService.lua with basic pet creation
2. **Day 3-4:** Build PetController.lua with simple inventory UI
3. **Day 5-6:** Integrate pet bonuses with resource generation
4. **Day 7:** Testing, debugging, and polish

---

## Phase 4: Data Persistence (Weeks 17-18)

### Week 17-18: Save System
**Goal:** Reliable data saving and loading

#### Services to Create:
1. **DataService** (Server)
   - ProfileService integration
   - Auto-save every 5 minutes
   - Save on player leave
   - Data migration system
   - Backup/restore functionality

#### Data Structure:
```typescript
interface PlayerData {
    userId: number;
    
    // Solar System Data
    solarSystem: {
        id: string; // Unique solar system ID
        planets: PlanetState[]; // Array of planets (3-8)
        activePlanetIndex: number; // Currently selected planet
        planetsUnlocked: number; // How many planets unlocked
    };
    
    // Legacy (kept for backwards compatibility)
    planet: PlanetState; // Deprecated - use solarSystem.planets[0]
    
    pets: PetData[];
    inventory: {
        resources: Resources; // Current planet resources
        items: Map<string, number>;
        stars: number; // Premium currency for Star Map
    };
    progression: {
        level: number;
        experience: number;
        upgradesUnlocked: Set<string>;
        achievements: Set<string>;
        starUpgrades: Set<string>; // Star Map upgrades purchased (PERMANENT)
        biomesCompleted: Set<BiomeType>; // Biomes mastered for star rewards
        
        // Rebirth Data
        rebirthCount: number; // How many times player has rebirthed
        rebirthRank: string; // "Bronze", "Silver", "Gold", "Platinum", "Diamond"
        rebirthMultiplier: number; // Permanent bonus (e.g., 0.50 = +50%)
        totalItemsAvailable: number; // Total items player can unlock
        itemsUnlocked: number; // Current items unlocked
        completionPercent: number; // itemsUnlocked / totalItemsAvailable
    };
    stats: {
        totalPlayTime: number;
        resourcesEarned: Resources;
        petsHatched: number;
        starsEarned: number;
        maxLevelReached: number;
        totalRebirths: number;
        planetsUnlockedAllTime: number;
    };
    settings: PlayerSettings;
    lastSave: number;
}

interface SolarSystem {
    id: string;
    planetCount: number; // 3-8 planets
    planets: PlanetState[];
    seed: number; // For procedural generation
}

interface PlanetState {
    userId: number;
    planetId: string; // Unique ID within solar system
    planetType: string; // "Mineral World", "Ocean World", etc.
    level: number;
    experience: number;
    biome: BiomeType;
    size: number;
    temperature: number;
    atmosphere: number;
    resources: Resources;
    lastUpdated: number;
    bonuses: { // Planet-specific bonuses
        waterBonus: number;
        mineralsBonus: number;
        energyBonus: number;
        biomassBonus: number;
        xpBonus: number;
    };
    isUnlocked: boolean;
    unlockCost: Resources; // Cost to unlock this planet
}
```

#### Tasks:
- [ ] Integrate ProfileService
- [ ] Create data schema and defaults
- [ ] Implement auto-save system
- [ ] Add data validation
- [ ] Create data migration system
- [ ] Add error handling and retries
- [ ] Implement data backup system
- [ ] Create admin data tools

#### Safety Features:
- Session locking (prevent duplication)
- Rollback on corrupted data
- Regular backups
- Data versioning

#### Deliverables:
- Reliable save/load system
- Data migration framework
- Error recovery
- Admin tools for data management

**Priority:** 🔴 Critical

---

## Phase 5: UI/UX Polish (Weeks 19-21)

### Week 19-20: Core UI Overhaul
**Goal:** Professional, intuitive user interface

#### UI Components to Create:
1. **Main HUD**
   - Resource counters (top)
   - Level/XP bar
   - Currency display
   - Quick actions menu
   
2. **Planet View**
   - Planet visualization
   - Rotation controls
   - Zoom controls
   - Planet info panel
   
3. **Menus**
   - Upgrade shop
   - Pet inventory
   - Settings
   - Premium shop
   - Social features

#### UI Framework:
- Use Roact (React for Roblox) or Fusion
- Responsive design for mobile
- Smooth animations and transitions
- Consistent color scheme and branding

#### Tasks:
- [ ] Design UI mockups (Figma)
- [ ] Implement UI framework (Roact/Fusion)
- [ ] Create reusable UI components
- [ ] Build all main menus
- [ ] Add animations and transitions
- [ ] Implement responsive layouts
- [ ] Mobile optimization
- [ ] Accessibility features

#### Deliverables:
- Polished, professional UI
- Mobile-responsive design
- Smooth animations
- Consistent visual style

**Priority:** 🟡 High

---

## Phase 5.5: Space Layer - Active Gameplay (Weeks 17-20)

### Week 17-18: Space Combat & Exploration
**Goal:** Implement the active gameplay layer where players explore space and fight enemies

#### Space Layer Overview:
The Space Layer is the **active gameplay zone** where players engage in combat, exploration, and resource collection. This contrasts with the Planet Layer (passive customization). Players navigate their spaceship around their planet, expanding territory and collecting resources through gameplay actions.

#### Services to Create:
1. **SpaceExplorationService** (Server)
   - Generate asteroid fields around planets
   - Spawn alien outposts and enemies
   - Handle territory claiming mechanics
   - Track player's claimed territory radius
   - Manage biome fragment drops
   
2. **SpaceCombatService** (Server)
   - Process asteroid destruction
   - Handle alien combat
   - Calculate resource drops
   - Award Planet Essence and Biome Energy
   - Validate player actions (anti-exploit)

3. **SpaceController** (Client)
   - Ship movement and controls
   - Combat UI and targeting
   - Territory visualization (expanding bubble)
   - Resource pickup effects
   - Visual feedback for actions

#### Core Mechanics:

**Territory System:**
- Each planet has a **territory radius** (starts at 100 studs)
- Destroying asteroids/aliens **expands territory** by 1-5 studs
- Visual bubble/sphere shows claimed territory
- Larger territory = more asteroid spawns = more resources
- Max territory radius: 500 studs (expandable with upgrades)

**Combat & Destruction:**
- **Asteroids**
  - Health: 10-100 HP (scales with territory size)
  - Drops: Minerals, Energy, Planet Essence
  - Respawn: 5-30 seconds
  - Types: Common, Rare, Epic (different drops)
  
- **Alien Outposts**
  - Health: 50-500 HP
  - Drops: Biome Fragments, Premium resources, Stars
  - Respawn: 5-15 minutes
  - Types: Scout, Fighter, Fortress

**Resource Drops:**
- **Planet Essence** - Used in Planet Layer for upgrades
- **Biome Energy** - Used to place/upgrade biomes
- **Biome Fragments** - Special items for unlocking biomes
  - Volcanic Core (unlocks Lava biome)
  - Frozen Crystal (unlocks Ice biome)
  - Ocean Pearl (unlocks Ocean enhancements)
  - Forest Seed (unlocks Forest enhancements)
  - Desert Shard (unlocks Desert biome)

#### Ship System:
- Each player has a **spaceship** (starts with basic ship)
- Ship stats: Speed, Damage, Health, Resource Capacity
- Ship upgrades purchased with Planet Essence
- Cosmetic ship skins (premium & earned)

#### Tasks:
- [ ] Create space environment around planets (asteroid fields)
- [ ] Implement ship movement controls (WASD + mouse)
- [ ] Build asteroid destruction mechanics
- [ ] Add alien enemy AI and spawning
- [ ] Create territory expansion system
- [ ] Implement resource drop system
- [ ] Add biome fragment discovery
- [ ] Create visual effects (explosions, resource pickups)
- [ ] Build territory visualization (expanding sphere)
- [ ] Add combat UI (health bars, damage numbers)

#### Deliverables:
- Functional ship controls
- Asteroid destruction mechanics
- Territory expansion system
- Resource drop and collection
- Biome fragment system
- Visual territory bubble
- Combat feedback and effects

**Priority:** 🔴 Critical (Core Gameplay Loop)

---

### Week 19-20: Planet Layer Integration
**Goal:** Connect Space Layer resources to Planet Layer customization

#### Planet Layer Features:
Players access their **Planet View** via a "View My Planet" button. This is a separate camera mode or UI screen showing their planet up close with customization options.

#### Services to Create/Expand:
1. **PlanetCustomizationService** (Server)
   - Apply biome fragments to planet
   - Place biomes in specific regions
   - Validate customization purchases
   - Track applied customizations
   - Generate civilization visuals

2. **PlanetCustomizationController** (Client)
   - Planet view camera mode
   - Biome placement UI
   - Visual customization panel
   - Planet skin selection
   - Civilization progress display

#### Customization Features:

**Biome Placement:**
- Planets have 4-8 **biome slots** (expandable)
- Drag-and-drop biomes onto planet surface
- Each biome requires:
  - Biome Fragment (from Space Layer)
  - Biome Energy (from Space Layer)
  - Planet Essence cost
- Visual effect when placing biomes (grows from center)

**Visual Customization:**
- **Atmosphere Effects**
  - Glow color (unlocked colors via achievements)
  - Atmosphere density (thin, medium, thick)
  - Cloud patterns and movement
  
- **Planetary Rings**
  - Ring color and material
  - Ring density (thin, medium, thick)
  - Ring rotation speed
  
- **Orbiting Objects**
  - Moons (1-3 moons)
  - Space stations
  - Asteroid belts
  - Satellites

**Planet Skins (Premium & Earned):**
- **Themed Skins** (Override biome colors)
  - Candy Planet (pink/pastel colors, candy textures)
  - Cyber Planet (neon grid, digital aesthetic)
  - Toxic Planet (green glow, hazardous look)
  - Lava World (molten surface, ember effects)
  - Ice World (frozen blue, aurora effects)
  - Crystal Planet (gem-like facets, sparkles)
  
- **Seasonal Skins**
  - Halloween Planet (jack-o-lanterns, spooky)
  - Christmas Planet (snow, lights, festive)
  - Valentine Planet (hearts, pink/red)

**Civilization Development:**
- **Population Growth** (passive, based on biome quality)
  - Stage 1: Small settlements (campfires visible)
  - Stage 2: Towns (buildings appear)
  - Stage 3: Cities (lights at night, roads)
  - Stage 4: Metropolis (sprawling cities, satellites)
  - Stage 5: Advanced Civilization (space stations orbiting)

- **Visual Indicators**
  - Lights appear on night side of planet
  - Roads and city grids form
  - Satellites and ships orbit planet
  - Communication arrays and structures

#### Planet View UI:
- **View My Planet Button** - Toggles planet view mode
- **Camera Controls** - Rotate, zoom, pan around planet
- **Customization Panel** - Shows available options
- **Biome Inventory** - Displays collected fragments
- **Preview Mode** - Preview changes before applying
- **Save Changes** - Confirm and apply customizations

#### Tasks:
- [ ] Create planet view camera mode
- [ ] Implement biome placement system
- [ ] Build visual customization options
- [ ] Add planet skin application
- [ ] Create civilization progression visuals
- [ ] Design customization UI panel
- [ ] Implement biome fragment consumption
- [ ] Add preview system for changes
- [ ] Create smooth camera transitions
- [ ] Add particle effects for customization

#### Integration Points:
- Space Layer resources → Planet Layer customization
- Planet progress → Space Layer bonuses (better ship, more territory)
- Biome quality → Civilization growth speed
- Territory size → Available customization options

#### Deliverables:
- Planet view camera mode
- Biome placement system
- Visual customization tools
- Planet skin system
- Civilization development visuals
- Full integration between layers

**Priority:** 🔴 Critical (Core Gameplay Loop)

---

### Week 17: Tutorial & Onboarding (Moved to Week 21)
**Goal:** Guide new players through core mechanics

#### Tutorial Flow:
1. **Welcome** - Planet creation cutscene
2. **Resources** - Explain resource types
3. **Upgrades** - Guide first upgrade purchase
4. **Pets** - Hatch first pet egg (free)
5. **Biomes** - Show biome transition
6. **Goals** - Set first objectives

#### Tasks:
- [ ] Create tutorial script/flow
- [ ] Implement step-by-step guidance
- [ ] Add highlight/focus system
- [ ] Create tutorial UI elements
- [ ] Add skip option for returning players
- [ ] Implement progressive tutorials (unlock new features)

#### Deliverables:
- Complete tutorial system
- New player onboarding
- Feature introductions
- Help/tips system

**Priority:** 🟡 High

---

## Phase 6: Social Features (Weeks 18-20)

### Week 18-19: Trading System
**Goal:** Allow players to trade pets and resources

#### Services to Create:
1. **TradeService** (Server)
   - Create trade offers
   - Validate trades
   - Execute trades
   - Trade history
   
2. **TradeController** (Client)
   - Trade UI
   - Preview trades
   - Accept/reject trades

#### Trade Features:
- Pet for pet trades
- Resource for resource trades
- Mixed trades
- Trade history log
- Trade tax (5% to prevent exploitation)
- Cooldown system (prevent spam)

#### Tasks:
- [ ] Create trade data structures
- [ ] Implement trade offer system
- [ ] Build trade UI (dual inventory view)
- [ ] Add trade validation
- [ ] Implement trade execution
- [ ] Create trade history
- [ ] Add trade notifications
- [ ] Anti-scam measures

#### Deliverables:
- Working trade system
- Intuitive trade UI
- Trade history and logs
- Security measures

**Priority:** 🟢 Medium

---

### Week 20: Social Hub
**Goal:** Visit friends' planets and social interactions

#### Features:
1. **Planet Visiting**
   - Visit friend planets
   - View their progress
   - Leave gifts/messages
   
2. **Friends List**
   - Add/remove friends
   - See online status
   - Quick visit button
   
3. **Leaderboards**
   - Top planets by level
   - Resource rankings
   - Pet collections

#### Tasks:
- [ ] Implement friend system
- [ ] Create planet visiting mechanics
- [ ] Build social hub UI
- [ ] Add leaderboards (ordered DataStore)
- [ ] Create gifting system
- [ ] Add social notifications

#### Deliverables:
- Friends system
- Planet visiting
- Leaderboards
- Social interactions

**Priority:** 🟢 Medium

---

## Phase 7: Monetization (Weeks 21-22)

### Week 21-22: Premium Features
**Goal:** Fair monetization that enhances gameplay

#### Game Passes:
1. **VIP Pass** (899 Robux)
   - 2x resource generation
   - Exclusive planet skins
   - Daily VIP rewards
   - Priority support
   
2. **Pet Master** (799 Robux)
   - Hatch 3 pets at once
   - Exclusive pet eggs
   - +20 pet storage slots
   - Auto-level pets
   
3. **Planet Expansion** (699 Robux)
   - 2x planet size
   - Extra biome slots
   - More city capacity
   - Expanded storage
   
4. **Auto-Collector** (499 Robux)
   - Auto-collect resources
   - Extended offline earnings (24hrs)
   - Resource boost aura

#### Developer Products:
- Resource bundles (100-500 Robux)
- Premium pet eggs (150-400 Robux)
- Instant upgrades (varies)
- XP boosters (200 Robux, 24hrs)

#### Tasks:
- [ ] Implement game pass detection
- [ ] Create premium shop UI
- [ ] Add game pass benefits to calculations
- [ ] Implement developer products
- [ ] Create purchase flows
- [ ] Add receipt/confirmation system
- [ ] Test purchases thoroughly
- [ ] Add promotional systems

#### Monetization Ethics:
✅ No pay-to-win mechanics
✅ All content accessible to free players
✅ Premium = convenience, not power
✅ Clear value proposition
✅ No aggressive upselling

#### Deliverables:
- 4 game passes implemented
- Developer products catalog
- Premium shop UI
- Purchase verification

**Priority:** 🟡 High

---

## Phase 8: Content Expansion (Weeks 23-26)

### Week 23-24: Ecosystem & Life
**Goal:** Add life and activity to planets

#### Features:
1. **Ecosystem Module**
   - Animals spawn based on biome
   - Population dynamics
   - Food web simulation
   - Biodiversity scoring
   
2. **Plant System**
   - Trees and vegetation
   - Growth over time
   - Resource production
   - Seasonal changes

#### Animals by Biome:
- **Rocky:** Lizards, Beetles, Scorpions
- **Oceanic:** Fish, Dolphins, Whales, Coral
- **Forest:** Birds, Deer, Bears, Insects

#### Tasks:
- [ ] Create animal data and configs
- [ ] Implement spawning system
- [ ] Add animal AI (wandering)
- [ ] Create plant growth system
- [ ] Add ecosystem calculations
- [ ] Build biodiversity scoring
- [ ] Create ecosystem UI panel

#### Deliverables:
- Living, breathing planets
- 20+ animal types
- Dynamic ecosystems
- Biodiversity system

**Priority:** 🟢 Medium

---

### Week 25-26: City Building
**Goal:** Players build civilizations on their planet

#### City Features:
1. **Buildings**
   - Houses (population capacity)
   - Factories (resource production)
   - Labs (research unlocks)
   - Monuments (prestige)
   
2. **Population**
   - Citizens generate resources
   - Happiness affects production
   - Population growth over time

#### Tasks:
- [ ] Create building system
- [ ] Implement placement mechanics
- [ ] Add building upgrade paths
- [ ] Create population simulation
- [ ] Build city management UI
- [ ] Add visual city buildings to planet

#### Deliverables:
- Building placement system
- 8-10 building types
- Population mechanics
- City management UI

**Priority:** 🟢 Medium

---

## Phase 9: Events & Engagement (Weeks 27-28)

### Week 27: Random Events
**Goal:** Add variety and challenge

#### Event Types:
1. **Disasters** (Negative)
   - Meteor strike (-resources)
   - Solar flare (-energy)
   - Drought (-water)
   - Pet shield can block
   
2. **Blessings** (Positive)
   - Resource rain (+resources)
   - Alien visitors (+rare pet egg)
   - Solar winds (+energy boost)

#### Event System:
- 10% chance per hour
- Player choices affect outcome
- Rewards for good decisions
- Can be mitigated with upgrades/pets

#### Tasks:
- [ ] Create event system
- [ ] Design event logic and rewards
- [ ] Build event notification UI
- [ ] Add event decision system
- [ ] Create event animations
- [ ] Balance event frequency

#### Deliverables:
- Random event system
- 8-10 event types
- Event UI and notifications
- Risk/reward mechanics

**Priority:** 🟢 Medium

---

### Week 28: Seasons & Limited Events
**Goal:** Create FOMO and recurring engagement

#### Seasonal Events:
1. **Summer** - Beach biome, water pets
2. **Halloween** - Spooky pets, dark planets
3. **Winter** - Ice biome, snow effects
4. **Spring** - Flower events, garden pets

#### Event Features:
- Limited-time pets
- Exclusive upgrades
- Seasonal currency
- Event leaderboards
- Special rewards

#### Tasks:
- [ ] Create season system
- [ ] Design seasonal content
- [ ] Implement event currency
- [ ] Build event pass (optional premium)
- [ ] Add seasonal decorations
- [ ] Create event UI

#### Deliverables:
- Seasonal event framework
- First seasonal event
- Event pass system
- Limited content rotation

**Priority:** 🟢 Medium

---

## Phase 10: Polish & Launch Prep (Weeks 29-32)

### Week 29-30: Bug Fixing & Optimization
**Goal:** Stable, performant game

#### Optimization Tasks:
- [ ] Profile server performance
- [ ] Optimize resource loops
- [ ] Reduce network traffic
- [ ] Optimize UI rendering
- [ ] Mobile performance testing
- [ ] Memory leak detection
- [ ] Fix all critical bugs
- [ ] Load testing (100+ players)

#### Performance Targets:
- Server: <5% CPU usage per player
- Client: 60 FPS on mid-range devices
- Network: <5 KB/s per player
- Load time: <10 seconds

**Priority:** 🔴 Critical

---

### Week 31: Soft Launch & Testing
**Goal:** Limited release for feedback

#### Soft Launch Plan:
1. **Friends & Family** (Days 1-3)
   - 10-20 testers
   - Focus on critical bugs
   
2. **Closed Beta** (Days 4-10)
   - 100-200 players
   - Test server load
   - Gather feedback
   
3. **Open Beta** (Days 11-14)
   - Unlimited players
   - Monitor analytics
   - Final adjustments

#### Tasks:
- [ ] Create feedback forms
- [ ] Set up analytics (PlayFab/Google Analytics)
- [ ] Monitor server metrics
- [ ] Implement crash reporting
- [ ] Create bug tracking system
- [ ] Balance adjustments based on data

**Priority:** 🔴 Critical

---

### Week 32: Full Launch
**Goal:** Public release and marketing

#### Launch Checklist:
- [ ] All critical bugs fixed
- [ ] Tutorial complete and tested
- [ ] Monetization tested and working
- [ ] Social media presence established
- [ ] Launch trailer created
- [ ] Press kit prepared
- [ ] Support system ready

#### Marketing:
- DevForum post with gameplay GIFs
- YouTube trailer
- Twitter/Discord announcements
- Sponsored ads (optional)
- Influencer outreach

**Priority:** 🔴 Critical

---

## Post-Launch: Live Operations

### Monthly Content Updates
- New pets (2-3 per month)
- New upgrades (5-10 per month)
- Seasonal events
- Balance patches
- Bug fixes

### Quarterly Major Updates
- New biomes
- New systems (farming, space travel, etc.)
- Major events
- New game passes

### Ongoing Tasks
- Community management
- Bug fixing
- Performance optimization
- Feature requests
- Economy balancing

---

## Technical Roadmap

### Architecture
```
Server (Knit Services)
├── PlanetService - Core planet management (single planet)
├── SolarSystemService - Multi-planet solar system management
├── RebirthService - Rebirth/prestige system
├── ResourceService - Resource generation
├── PetService - Pet management
├── UpgradeService - Upgrade system
├── StarMapService - Star upgrades & offline earnings
├── TradeService - Trading system
├── DataService - Save/load data
├── EventService - Random events
└── AnalyticsService - Metrics tracking

Client (Knit Controllers)
├── PlanetController - Planet visualization (single planet view)
├── SolarSystemController - Solar system map & planet switching
├── RebirthController - Rebirth UI and confirmation
├── PetController - Pet UI
├── UpgradeController - Shop UI
├── StarMapController - Star Map UI & upgrades
├── TradeController - Trade UI
├── SocialController - Friends/visiting
└── TutorialController - Onboarding

Shared Modules
├── GrowthModule - Resource calculations
├── EcosystemModule - Life simulation
├── BalanceModule - Game balance
├── OfflineModule - Offline earnings calculation
├── ProceduralModule - Solar system generation
└── UtilityModule - Helpers
```

### Tech Stack
- **Language:** TypeScript (via roblox-ts)
- **Framework:** Knit (Services/Controllers)
- **Data:** ProfileService (DataStore wrapper)
- **UI:** Roact or Fusion
- **Networking:** Knit (auto-networking)
- **Testing:** TestEZ
- **Analytics:** PlayFab or custom

---

## Team & Resources

### Recommended Team (Indie/Small Team)
1. **Lead Developer** - Architecture, core systems
2. **Gameplay Developer** - Features, balance
3. **UI/UX Designer** - Interface, user experience
4. **3D Artist** - Planet models, pets, buildings
5. **Animator** - Pet animations, effects
6. **Sound Designer** - Music, SFX (Phase 11+)

### Tools & Software
- **Roblox Studio** - Development
- **VS Code** - Code editing
- **Figma** - UI design
- **Blender** - 3D modeling
- **Git/GitHub** - Version control
- **Trello/Jira** - Project management

### Budget Considerations (Optional)
- Sound effects/music: $200-500
- Marketing/ads: $100-1000
- 3D assets (if outsourced): $500-2000
- Testing devices: $300-500

---

## Timeline Estimates

### Minimum Viable Product (MVP)
**12 weeks** - Phases 1-4
- Core planet system
- Basic upgrades
- Simple pets
- Data persistence

### Feature Complete
**24 weeks** - Phases 1-8
- All core features
- Monetization
- Polish

### Launch Ready
**32 weeks** - All phases
- Full content
- Optimized
- Tested
- Marketed

### Accelerated Timeline (Full Team)
- MVP: 6-8 weeks
- Feature Complete: 14-16 weeks
- Launch: 20-24 weeks

### Solo Developer Timeline
- MVP: 16-20 weeks
- Feature Complete: 32-40 weeks
- Launch: 40-50 weeks

---

## Risk Management

### Technical Risks

**Risk:** DataStore limits exceeded
- **Mitigation:** Use ProfileService, batch updates, compression
- **Impact:** High
- **Probability:** Medium

**Risk:** Server performance issues
- **Mitigation:** Optimize early, load testing, profiling
- **Impact:** High
- **Probability:** Medium

**Risk:** Mobile performance issues
- **Mitigation:** Mobile-first design, LOD systems, testing
- **Impact:** Medium
- **Probability:** High

### Business Risks

**Risk:** Low player retention
- **Mitigation:** Strong tutorial, clear progression, engagement hooks
- **Impact:** High
- **Probability:** Medium

**Risk:** Monetization too aggressive
- **Mitigation:** Fair pricing, no pay-to-win, community feedback
- **Impact:** Medium
- **Probability:** Low

**Risk:** Similar game launches first
- **Mitigation:** Unique features, quality over speed, strong branding
- **Impact:** Medium
- **Probability:** Low

### Scope Risks

**Risk:** Feature creep
- **Mitigation:** Strict phase planning, MVP focus, post-launch updates
- **Impact:** High
- **Probability:** High

**Risk:** Burnout (solo/small team)
- **Mitigation:** Realistic timeline, breaks, scope reduction if needed
- **Impact:** High
- **Probability:** Medium

---

## Success Metrics

### Launch Targets (Month 1)
- 1,000+ unique players
- 30% day-1 retention
- 15% day-7 retention
- $500+ revenue
- 4.5+ star rating

### 6-Month Targets
- 10,000+ unique players
- 25% day-7 retention
- 10% day-30 retention
- $5,000+ revenue
- Active community (Discord/social)

### 1-Year Vision
- 50,000+ unique players
- Profitable ($20,000+ revenue)
- Regular content updates
- Strong community
- Platform recognition (featured)

---

## Phase Priority Summary

### 🔴 Critical (Must Have for MVP)
- Phase 1: Foundation
- Phase 2: Progression
- Phase 4: Data Persistence
- Phase 10: Polish & Launch

### 🟡 High Priority (Needed for Launch)
- Phase 3: Pet System
- Phase 5: UI/UX
- Phase 7: Monetization

### 🟢 Medium Priority (Post-MVP/Nice to Have)
- Phase 6: Social Features
- Phase 8: Content Expansion
- Phase 9: Events

---

## Next Steps (Immediate Actions)

1. ✅ **Review this plan** - Adjust timeline based on team size
2. ⏳ **Set up development environment** - Run `npm install` and `wally install`
3. ⏳ **Create project management board** - Trello/Jira with these phases
4. ⏳ **Start Phase 1, Week 1** - Version control and testing setup
5. ⏳ **Create asset pipeline** - Where will models/sounds come from?
6. ⏳ **Design core loop on paper** - Flowchart the player experience
7. ⏳ **Build first prototype** - Get something playable ASAP

---

## Conclusion

This is an ambitious but achievable project. The key to success:

1. **Start small** - Focus on MVP (Phases 1-4)
2. **Iterate quickly** - Get feedback early and often
3. **Stay organized** - Use project management tools
4. **Don't burn out** - Pace yourself, take breaks
5. **Community first** - Build relationships with players
6. **Have fun!** - Enjoy the creative process

Good luck with Grow a Planet! 🌍🚀

---

**Document Version:** 1.0  
**Last Updated:** October 23, 2025  
**Next Review:** After Phase 1 completion
