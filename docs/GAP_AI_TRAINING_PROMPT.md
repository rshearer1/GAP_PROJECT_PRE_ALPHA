🧠 GAP-PRE_ALPHA-TOOLS — AI TRAINING + REFACTOR STANDARD

Purpose:
This document defines the full toolchain, API access, and behavior rules for Claude when working inside this Roblox project.
Claude must strictly follow every rule, module structure, and pattern described here.

🧩 Core Context

**Project Type:** Grow-a-Planet - Idle/Simulation Game
**Tech Stack:** Visual Studio Code + Rojo + Roblox Studio + Luau
**Framework:** Knit (Service/Controller architecture)
**Language:** Lua/Luau (NOT TypeScript)

This is an idle planet-growing game where players:
- Nurture and develop planets
- Collect resources (water, minerals, energy, biomass)
- Hatch and evolve pets for bonuses
- Unlock solar systems and star maps
- Rebirth for permanent multipliers
- Purchase upgrades and game passes

🔧 Approved Modules & Libraries

All code generation and refactoring by Claude must comply with these tool and library definitions:

#	Module Name	Status	Purpose
1	Knit Framework	✅ IN USE	Primary framework - Services (server) and Controllers (client) architecture
2	Janitor (Validark)	✅ IN USE	Cleanup utility for Instances and connections
3	Promise	✅ IN USE	Async handling (Knit remote functions return Promises)
4	Signal	✅ IN USE	Event handling for custom events
5	TableUtil	✅ IN USE	Table manipulation utilities
6	DataStore	✅ IN USE	Player data persistence (wrapped by DataService)
7	Roblox Terrain APIs	⚠️ AVAILABLE	Built-in Workspace.Terrain for planet visuals

🏗️ Project Architecture

### File Structure
```
src/
├── client/
│   └── controllers/          # Client-side Knit controllers
│       ├── PlanetController.lua
│       ├── PetController.lua
│       ├── ShopController.lua
│       └── ... (8 total)
├── server/
│   └── services/             # Server-side Knit services  
│       ├── DataService.lua
│       ├── PlanetService.lua
│       ├── PetService.lua
│       └── ... (13 total)
└── shared/
    ├── Constants.lua         # Game configuration
    ├── Types.lua            # Type definitions
    └── PetTypes.lua         # Pet configurations

Packages/                     # Wally dependencies (Knit, Janitor, etc)
DevPackages/                  # TestEZ and testing tools
assets/                       # Models, meshes, UI assets
docs/                         # Documentation
```

### Knit Framework Patterns

**Server Services:**
```lua
local Knit = require(ReplicatedStorage.Packages.Knit)

local MyService = Knit.CreateService {
    Name = "MyService",
    Client = {
        -- Client-exposed methods (return Promises on client)
        GetData = Knit.CreateProperty(nil),
        -- Signals for client events
        DataChanged = Knit.CreateSignal(),
    },
}

-- Server method
function MyService:ServerMethod(userId)
    -- Implementation
    return data
end

-- Client wrapper (automatically networked)
function MyService.Client:GetData(player)
    return self.Server:ServerMethod(player.UserId)
end

return MyService
```

**Client Controllers:**
```lua
local Knit = require(ReplicatedStorage.Packages.Knit)

local MyController = Knit.CreateController {
    Name = "MyController",
}

function MyController:KnitStart()
    local MyService = Knit.GetService("MyService")
    
    -- Knit remote calls return PROMISES - must await
    MyService:GetData():andThen(function(data)
        print("Received:", data)
    end)
    
    -- Or use await (yields)
    local data = MyService:GetData():await()
end

return MyController
```

**Server Services (13 total):**
1. DataService - Player data persistence with auto-save
2. PlanetService - Planet state management and resources
3. PetService - Pet hatching, evolution, bonuses
4. UpgradeService - Upgrade purchasing and management
5. RebirthService - Prestige system
6. SolarSystemService - Solar system generation
7. StarMapService - Star collection and unlocks
8. PlotService - Player plot assignment
9. SpawnService - Spawn area management
10. PlanetVisualsService - 3D planet rendering
11. GamePassService - Premium purchases
12. TestingService - Debug commands
13. TestService - Framework testing

**Client Controllers (11 total):**
1. PlanetController - Planet UI and interactions
2. PetController - Pet inventory UI
3. ShopController - Premium shop
4. UpgradeController - Upgrade UI
5. RebirthController - Rebirth UI
6. SolarSystemController - Solar system UI
7. StarMapController - Star map UI
8. SettingsController - Settings panel
9. PlanetViewController - Immersive view
10. TestingController - Debug panel
11. TestController - Framework testing

🧰 VS Code / Rojo Setup

Required extensions:
- Rojo – syncs Studio ↔ VSCode
- Selene – Luau linter  
- Luau Language Server – autocomplete, diagnostics
- Git Graph – version control visualization

🧭 Claude's Operating Rules

These rules apply to all Claude activity (generation, refactoring, testing).

🚫 Do Not

- Invent new frameworks, APIs, or file structures
- Rename or delete existing files without permission
- Hardcode values defined in Constants.lua
- Skip comments or function summaries
- Use TypeScript patterns (this is Lua/Luau)
- Forget that Knit remote calls return Promises
- Create synchronous remote calls (always use :await() or :andThen())

✅ Must Do

- Use Knit framework exclusively for services/controllers
- Use Janitor for cleanup in all UI and connections
- Always await Knit Promises: `ServiceMethod():await()` or `:andThen()`
- Follow existing service/controller patterns exactly
- Keep logic safe and identical during refactors
- Improve readability, modularity, and maintainability
- Add inline documentation for new or cleaned functions
- Reference Constants.lua for all configuration values
- Use proper Luau typing where applicable

⚠️ Critical Knit Pattern

**ALWAYS remember:** Client calls to server services return Promises!

```lua
-- ❌ WRONG - Will not work
local data = MyService:GetData()

-- ✅ CORRECT - Using await
local data = MyService:GetData():await()

-- ✅ CORRECT - Using andThen
MyService:GetData():andThen(function(data)
    -- use data
end)
```

⚙️ Claude Strict Safe Refactor Template

Use this mode when improving or cleaning existing scripts.

**CLAUDE SAFE REFACTOR MODE – GAP-PRE_ALPHA-TOOLS**

You are working in the Grow-a-Planet Roblox idle game using Knit framework.
Refactor code only — do not change functionality.

✅ Follow Knit architecture and naming conventions
✅ Use only listed modules (Knit, Janitor, Promise, Signal, TableUtil)
✅ Keep all behavior identical
✅ Clean up structure, comments, and performance
✅ Properly handle all Promises (await or andThen)
✅ Do not rename or remove files
⚠️ Ask before adding new logic or APIs
🧠 Add -- TODO: for uncertain areas

**Output format:**
```
✅ Summary: (describe what was improved)
✅ Refactored Code:
-- cleaned code here
✅ Safety Checklist:
[x] Functionality identical
[x] Module compliant  
[x] Knit Promises handled correctly
[x] No unsafe changes
[x] Rojo paths correct
```
```

🧱 Core Services (Existing)

🧰 VS Code / Rojo Setup

Install these for best Claude integration:

Rojo – syncs Studio ↔ VSCode

Selene – Luau linter

Luau Language Server – autocomplete, diagnostics

Git Graph – version control visualization

🧭 Claude’s Operating Rules

These rules apply to all Claude activity (generation, refactoring, testing).

🚫 Do Not

Invent new frameworks, APIs, or file structures.

Rename or delete existing files without permission.

Hardcode values defined in WorldSpec.lua.

Skip comments or function summaries.

✅ Must Do

Use only modules listed above.

Keep logic safe and identical during refactors.

Improve readability, modularity, and maintainability.

Add inline documentation for new or cleaned functions.

Clean up with Janitor.

Use MathPlus / WorldUtils for placement and noise.

Visualize placements via DebugVisualizer.

⚙️ Claude Strict Safe Refactor Template

Use this mode when improving or cleaning existing scripts.

CLAUDE SAFE REFACTOR MODE – GAP-PRE_ALPHA-TOOLS

You are working in an existing Roblox project using GAP-PRE_ALPHA-TOOLS.
Refactor code only — do not change functionality.

✅ Follow GAP architecture and naming conventions
✅ Use only listed modules
✅ Keep all behavior identical
✅ Clean up structure, comments, and performance
✅ Do not rename or remove files
⚠️ Ask before adding new logic or APIs
🧠 Add -- TODO: for uncertain areas

Output format:
✅ Summary: (describe what was improved)
✅ Refactored Code:
-- cleaned code here
✅ Safety Checklist:
[x] Functionality identical
[x] Module compliant
[x] No unsafe changes
[x] Rojo paths correct

🧩 Claude Compliance Checklist (Post-Output)

Claude must verify all responses:

Check	Description
✅ Modules Only	No external code invented
✅ No Breaks	Existing systems remain functional
✅ AI Docs Used	All APIs referenced correctly
✅ Comments	Each function has a brief docstring
✅ Naming Consistent	Matches existing repo conventions
🧠 Claude Context Start Phrase

When starting a Claude session:

“Load and internalize the full GAP_AI_TRAINING_PROMPT.md.
Follow these rules for all future generations and refactors.
Operate in STRICT SAFE REFACTOR MODE.”

🧩 Optional: AI Context Commands

You can also give Claude short reminders:

Command	Effect
“Stay in compliance mode.”	Reaffirms strict rules
“Audit this file for GAP compliance.”	Claude lists noncompliant code
“Safe refactor this script.”	Claude cleans code safely
“Generate new system per WorldSpec.lua.”	Claude builds new module using all allowed APIs
