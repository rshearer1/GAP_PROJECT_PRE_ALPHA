# Grow-a-Planet - Quick Reference

## Project Overview
**Type:** Idle/Simulation Game  
**Framework:** Knit (Service/Controller)  
**Language:** Lua/Luau  
**Platform:** Roblox

## Critical Pattern: Knit Promises

**ALL client calls to server services return Promises!**

```lua
-- ❌ WRONG
local data = MyService:GetData()

-- ✅ CORRECT (await - yields)
local data = MyService:GetData():await()

-- ✅ CORRECT (andThen - callback)
MyService:GetData():andThen(function(data)
    print(data)
end)
```

## Current Services (13)
1. DataService - Persistence
2. PlanetService - Planet management
3. PetService - Pet system
4. UpgradeService - Upgrades
5. RebirthService - Prestige
6. SolarSystemService - Solar systems
7. StarMapService - Star map
8. PlotService - Player plots
9. SpawnService - Spawn areas
10. PlanetVisualsService - 3D planets
11. GamePassService - Premium
12. TestingService - Debug
13. TestService - Testing

## Current Controllers (11)
1. PlanetController
2. PetController
3. ShopController
4. UpgradeController
5. RebirthController
6. SolarSystemController
7. StarMapController
8. SettingsController
9. PlanetViewController
10. TestingController
11. TestController

## Approved Modules
- ✅ Knit - Framework
- ✅ Janitor - Cleanup
- ✅ Promise - Async
- ✅ Signal - Events
- ✅ TableUtil - Tables
- ✅ DataStore - Persistence

## Configuration
- **Constants.lua** - All game config values
- **Types.lua** - Type definitions
- **PetTypes.lua** - Pet configurations

## Common Patterns

### Service Pattern
```lua
local Knit = require(ReplicatedStorage.Packages.Knit)

local MyService = Knit.CreateService {
    Name = "MyService",
    Client = {},
}

function MyService:KnitStart()
    -- Init code
end

function MyService.Client:GetData(player)
    return self.Server:GetData(player.UserId)
end

return MyService
```

### Controller Pattern
```lua
local Knit = require(ReplicatedStorage.Packages.Knit)
local Janitor = require(ReplicatedStorage.Packages.Janitor)

local MyController = Knit.CreateController {
    Name = "MyController",
    _janitor = Janitor.new(),
}

function MyController:KnitStart()
    local service = Knit.GetService("MyService")
    local data = service:GetData():await()  -- Promise!
end

return MyController
```

## Remember
1. **Always use :await() or :andThen() for service calls**
2. Use Janitor for cleanup
3. Reference Constants.lua (no hardcoded values)
4. Add function comments
5. Follow existing patterns exactly
