# Grow a Planet - AI Coding Agent Instructions

## Project Overview
Roblox idle/simulation game using **Lua + Knit framework** (NOT TypeScript). Players nurture planets from barren rocks to thriving civilizations through resource management, upgrades, pets, and prestige systems.

**Tech Stack**: VS Code + Rojo 7.x + Wally (package manager) + Knit 1.7.0
**Language**: Pure Lua (migrated from TypeScript - see MIGRATION.md for patterns)

## Critical Architecture

### Knit Framework (Service/Controller Pattern)
**Server Services** (`src/server/services/*.lua`): Game logic, data persistence, validation
**Client Controllers** (`src/client/controllers/*.lua`): UI, input, local state
**Auto-networking**: Service methods in `.Client` table become RemoteFunctions/RemoteEvents automatically

Entry points load all modules via `require()`:
- `src/server/init.server.lua` - Loads all services, starts Knit
- `src/client/init.client.lua` - Loads all controllers, starts Knit

Example Service structure:
```lua
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local MyService = Knit.CreateService {
    Name = "MyService",
    Client = {
        GetData = function(self, player) -- Auto-networked to clients
            return self.Server:_internalMethod(player.UserId)
        end
    },
    -- Server-only methods (prefix with _ by convention)
    _internalMethod = function(self, userId)
        return self._cache[userId]
    end
}
return MyService
```

### Resource Cleanup with Janitor
**CRITICAL**: All connections, threads, and instances MUST use Janitor for cleanup to prevent memory leaks.

Correct thread cleanup pattern:
```lua
local thread = task.spawn(function()
    while true do
        -- loop work
        task.wait(1)
    end
end)
self._janitor:Add(function() task.cancel(thread) end, true)
```

❌ **WRONG**: `self._janitor:Add(task.spawn(...), "task.cancel")` - "task.cancel" is not a valid method name
✅ **RIGHT**: Create thread variable first, then add cleanup function

Connection cleanup:
```lua
self._janitor:Add(Players.PlayerAdded:Connect(function(player)
    -- handle player
end), "Disconnect")
```

### Configuration System
- **Constants.lua**: ALL game balance values, UI sizes, rates - NEVER hardcode values
- **Types.lua**: Type exports for shared data structures (PlanetState, Resources, BiomeType, etc.)
- Extract new constants immediately when refactoring - see `Constants.UI.PLANET_UI` for 30+ UI values

Configuration hierarchy:
```lua
Constants.RESOURCES.BASE_WATER_RATE = 1
Constants.BIOMES.FOREST.biomassBonus = 1.5
Constants.UI.PLANET_UI.MAIN_FRAME_SIZE = UDim2.new(0, 300, 0, 400)
```

## Game Systems Overview

### Core Systems (Implemented)
1. **Planet System** - Resource generation, levels, biome evolution (Barren→Rocky→Oceanic→Forest)
2. **Solar System** - Players manage 3-8 planets with unique types (Mineral World, Ocean World, etc.)
3. **Upgrades** - 7 upgrades (resource rates, caps, size) with level requirements
4. **Star Map** - 13 permanent prestige upgrades (offline earnings, global bonuses, special unlocks)
5. **Rebirth** - Prestige system: reset progress for +10% permanent multiplier + bonus stars
6. **Spawn Area** - Procedurally generated hub with energy cores, tutorial zone, shop district
7. **Game Passes** - 6 premium features (2x Resources, VIP Planet, Auto-Collector, etc.)

### Data Flow
```
Player Input → Controller → Knit.GetService() → Service.Client.Method() 
→ Validation → Game Logic → DataService → DataStore 
→ State Update → Service fires signal → Controller updates UI
```

### Promise Pattern (Async Operations)
```lua
PlanetService:CollectResources():andThen(function(result)
    print("Success:", result.xpGained)
    self:refreshPlanetState()
end):catch(function(err)
    warn("Failed:", err)
end)
```

## GAP Compliance Framework (MANDATORY)
Read `docs/GAP_AI_TRAINING_PROMPT.md` and `docs/GAP-PRE_ALPHA-TOOLS.md` before ANY code generation.

### Approved Modules Only
- ✅ Knit, Janitor, Promise, Signal, TableUtil (via Wally)
- ✅ NevermoreEngine, MathPlus, roblox-geometry (GAP-approved for procedural generation)
- ❌ DO NOT invent new frameworks or import unapproved packages

### Code Standards (GAP Refactor Mode)
1. **JSDoc comments** for every function:
   ```lua
   ---
   -- Brief description of what this does
   -- @param paramName Type and description
   -- @return What it returns
   --
   function MyService:myMethod(paramName)
   ```

2. **No functional changes during refactors** - preserve exact behavior
3. **Extract to Constants.lua** - no magic numbers or hardcoded strings
4. **Janitor cleanup** - add `self._janitor = Janitor.new()` to all Services/Controllers
5. **Safe patterns** - use `FindFirstChild()` with nil checks, not `WaitForChild()` in loops

## Development Workflow

### Package Management
```bash
wally install                         # Install Roblox packages to Packages/
rm -rf Packages && wally install      # Clean reinstall if sync issues
```

**Rojo + Wally Issue**: Nested `default.project.json` files in packages break Rojo. Solution: `.rojoignore` excludes them.

### Build & Sync
```bash
rojo serve                 # Start sync server (localhost:34872)
# In Roblox Studio: Click Rojo plugin → Connect
```

### Git Workflow
```bash
git add .
git commit -m "feat: description"
git push origin main
```

**Lock file issues**: If commits fail, run `find .git -name "*.lock" -delete`

## UI Implementation Patterns

### Image Buttons (Navigation)
Custom asset IDs stored in Constants, created with `BackgroundTransparency = 1`:
```lua
-- StarMapController - Stars button
local starButton = Instance.new("ImageButton")
starButton.Image = "rbxassetid://109076471250268"
starButton.BackgroundTransparency = 1
starButton.ScaleType = Enum.ScaleType.Fit
```

Current navigation buttons:
- Stars: `rbxassetid://109076471250268` (StarMapController)
- Galaxy: `rbxassetid://90313785520046` (SolarSystemController)
- Shop: `rbxassetid://140353244803526` (ShopController)
- Settings: `rbxassetid://80743411284468` (SettingsController)

### Controller UI Updates
Pattern: Store UI references, update via dedicated method:
```lua
function Controller:_updateUI()
    if not self._ui or not self._planetState then return end
    -- Always check intermediate frames - UI is nested in contentFrame
    local contentFrame = self._ui:FindFirstChild("MainFrame"):FindFirstChild("Content")
    if not contentFrame then return end
    
    local label = contentFrame:FindFirstChild("LevelLabel")
    if label then
        label.Text = `Level {self._planetState.level}`
    end
end
```

**Path fix**: UI updates must search in `contentFrame`, not `mainFrame` directly.

### Settings Panel Pattern
SettingsController implements:
- Volume sliders (Master, Music, SFX) with interactive drag
- Graphics quality buttons (Low, Medium, High, Ultra)
- Uses `UserSettings():GetService("UserGameSettings")` for graphics
- Sliders use `InputBegan`, `InputChanged`, `InputEnded` for drag functionality

## Common Errors & Fixes

### "Attempted to call require with invalid argument"
- **Cause**: Wally package not installed or Rojo not synced
- **Fix**: `rm -rf Packages && wally install`, restart Rojo

### "Object is a thread and expected true? for method name"
- **Cause**: Wrong Janitor pattern for threads
- **Fix**: Use cleanup function pattern (see Resource Cleanup above)

### UI not updating
- **Cause**: Wrong parent path in `FindFirstChild()`
- **Fix**: Check hierarchy - often need intermediate `contentFrame`

### "ServerScriptService.init.server:X: attempt to index nil"
- **Cause**: Service not loaded before Knit.Start()
- **Fix**: Check `require()` paths in init.server.lua, verify services folder structure

## Implemented Systems Reference

### Server Services
1. **PlanetService** - Planet state, resources (1s tick), XP/levels, biome evolution
2. **PlanetVisualsService** - 3D sphere visualization, rotation, biome colors
3. **UpgradeService** - 7 upgrades, purchase validation, multiplier application
4. **DataService** - Auto-save (60s), DataStore integration, shutdown handler
5. **SolarSystemService** - 3-8 planets per player, 8 planet types, switching
6. **RebirthService** - 90% completion check, +10% multiplier, rank tiers
7. **StarMapService** - 13 star upgrades, offline earnings, permanent bonuses
8. **SpawnService** - Procedural spawn area with energy cores, effects
9. **GamePassService** - 6 game passes, MarketplaceService integration
10. **TestingService** - Debug commands (press T in-game)

### Client Controllers
1. **PlanetController** - Main planet UI, resource display, XP button
2. **UpgradeController** - Shop UI with grid layout, purchase validation
3. **SolarSystemController** - Planet map, switching, unlock UI
4. **RebirthController** - Rebirth button (shows at 90%), confirmation dialog
5. **StarMapController** - Star upgrades UI, constellation theme
6. **ShopController** - Premium shop, game pass cards, purchase prompts
7. **SettingsController** - Volume sliders, graphics quality buttons
8. **TestingController** - Debug panel (toggle with T key)

### Data Structures (Types.lua)
```lua
export type BiomeType = "Barren" | "Rocky" | "Oceanic" | "Forest"
export type Resources = { water: number, minerals: number, energy: number, biomass: number }
export type PlanetState = {
    userId: number, level: number, experience: number,
    biome: BiomeType, size: number, resources: Resources, lastUpdated: number
}
```

## Key Files Reference
- `docs/GAP_AI_TRAINING_PROMPT.md` - **MUST READ** before coding
- `docs/GAP-PRE_ALPHA-TOOLS.md` - Approved modules and refactor standards
- `docs/DEVELOPMENT_PLAN.md` - Feature roadmap with completion status (32-week plan)
- `docs/REFERENCE.md` - Game design document (premium features, pet system, economy)
- `docs/TECHNICAL.md` - Technical specifications and module contracts
- `ARCHITECTURE.md` - Knit patterns, system design, data flow diagrams
- `MIGRATION.md` - Lua to TypeScript conversion guide (we use Lua now)
- `src/shared/Constants.lua` - Single source of truth for ALL config
- `src/shared/Types.lua` - Type definitions for data structures
- `wally.toml` - Package dependencies (Janitor, Knit, Promise, etc.)
- `.rojoignore` - Prevents Rojo from parsing nested package files

## Development Plan Context

### Completed Phases (✅)
- **Phase 1 (Weeks 1-4)**: Foundation, Core Planet System - 100% COMPLETE
- **Phase 2 (Weeks 5-8)**: Upgrades, Biomes, Star Map - 100% COMPLETE
- **Phase 2 (Weeks 9-11)**: Solar System, Rebirth, Spawn Area, Shop - 100% COMPLETE

### Current Status (Oct 26, 2025)
Core systems implemented and functional:
- Planet management with biome evolution (4 biomes)
- 7 upgrades with validation
- 3-8 planets per solar system (8 unique types)
- Rebirth system with 5 rank tiers
- 13 star upgrades for offline progression
- Plot system (8 plots per server, player assignment)
- Basic spawn area (designer will handle visual polish)
- 6 game passes via MarketplaceService

### Development Focus
**AI Agent Role**: Implement core game systems and mechanics only
**Design/Polish**: Handled by dedicated designer on team
**Priority**: Functionality over aesthetics - keep implementations simple and working

### Next Priorities (Per DEVELOPMENT_PLAN.md)
- **Phase 3 (Weeks 9-12)**: Pet System - hatching, evolution, skills (🟡 High Priority)
- **Phase 4 (Weeks 13-14)**: Data Persistence - ProfileService integration (🔴 Critical)
- **Phase 5 (Weeks 15-17)**: Core gameplay loops - Space Layer implementation (� Critical)

## Testing Checklist
Before committing:
1. ✅ No errors in Roblox Studio Output window
2. ✅ All Janitor cleanup uses correct patterns (cleanup functions, not method names)
3. ✅ No hardcoded values - everything in Constants.lua
4. ✅ JSDoc comments on new functions
5. ✅ UI updates work (check contentFrame paths)
6. ✅ Git lock files cleared if needed (`find .git -name "*.lock" -delete`)

## When Uncertain
- Add `-- TODO: Clarify with GAP_AI_TRAINING_PROMPT.md` comment
- Preserve existing behavior - refactor structure only
- Ask for clarification rather than guess
- Refer to DEVELOPMENT_PLAN.md for feature context and priorities
- Check ARCHITECTURE.md for Knit patterns and service design
- Review MIGRATION.md when converting code patterns from other languages

## Performance Considerations
From TECHNICAL.md and ARCHITECTURE.md:

### Client Optimization
- UI pooling - reuse GUI elements
- Lazy loading - load UI on demand
- View distance culling - hide distant objects
- Use `BindToRenderStep` for smooth animations

### Server Optimization
- Batch updates - update planets in groups (every 5s recommended)
- Spatial partitioning - only process nearby planets
- Caching - cache calculated values
- Throttling - rate limit expensive operations

### Network Optimization
- Delta updates - only send changed data
- Compression - minimize packet size
- Batching - combine multiple updates
- Unreliable events - for non-critical updates

## Security Patterns
From ARCHITECTURE.md - Server authority is critical:

```lua
function Service:HandleUpgradeRequest(player, upgradeId)
    local state = self:_getPlanetState(player.UserId)
    
    -- Validate ownership
    if not state or state.userId ~= player.UserId then
        return { success = false, error = "Invalid planet" }
    end
    
    -- Validate upgrade exists
    local upgrade = Constants.UPGRADES[upgradeId]
    if not upgrade then
        return { success = false, error = "Invalid upgrade" }
    end
    
    -- Validate resources
    if not self:_hasEnoughResources(state.resources, upgrade.cost) then
        return { success = false, error = "Insufficient resources" }
    end
    
    -- Apply upgrade (server-authoritative)
    return self:_applyUpgrade(player.UserId, upgradeId)
end
```

Never trust client data - validate everything on server.

