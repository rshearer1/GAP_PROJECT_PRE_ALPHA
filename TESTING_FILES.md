# 🔴 TESTING FILES - DELETE BEFORE PRODUCTION 🔴

This document lists all testing/debug files that **MUST BE DELETED** before publishing the final game.

## Files to Delete

### Server Services
- [ ] `src/server/services/TestingService.lua` - Debug commands for testing

### Client Controllers
- [ ] `src/client/controllers/TestingController.lua` - Debug UI panel with test buttons

### Legacy Test Files (if still present)
- [ ] `src/server/services/TestService.lua` - Original test service
- [ ] `src/client/controllers/TestController.lua` - Original test controller

## How to Delete

1. **Before final release**, delete the files listed above
2. **Remove from Git** (if using version control):
   ```bash
   git rm src/server/services/TestingService.lua
   git rm src/client/controllers/TestingController.lua
   git rm src/server/services/TestService.lua
   git rm src/client/controllers/TestController.lua
   git commit -m "Remove testing files for production"
   ```

3. **Restart Rojo** and sync to ensure they're removed from the game

4. **Test in Studio** to make sure game still works without debug files

## Testing Features

### Debug Panel (Press 'T' to toggle)

The testing UI provides these shortcuts:

1. **💰 Add Resources (+1000)** - Adds 1000 of each resource (water, minerals, energy, biomass)
2. **📈 Add Levels (+5)** - Instantly gain 5 levels (updates biome automatically)
3. **🌍 Unlock All Planets** - Unlocks all planets in your solar system
4. **🛒 Buy All Upgrades** - Maxes out all upgrades instantly
5. **⭐ Force Rebirth Ready** - Sets progress to ~95% completion (Level 15, most upgrades/planets)
6. **🌟 Add Stars (+50)** - Adds 50 stars (for Star Map system when implemented)
7. **🔄 Refresh All UI** - Manually refreshes all UI panels

### Usage Instructions

**To test Data Persistence:**
1. Click "💰 Add Resources" a few times
2. Click "📈 Add Levels" to level up
3. Stop the game
4. Restart the game
5. Your resources and level should be saved!

**To test Solar System:**
1. Click "💰 Add Resources" (need resources to unlock planets)
2. Open the 🌌 Map
3. Click "Unlock Planet" on locked planets
4. Click "Switch" to change active planet
5. Your progress on each planet is independent!

**To test Rebirth System:**
1. Click "⭐ Force Rebirth Ready" (sets you to 95% completion)
2. The 🔄 Rebirth button should appear in top-right
3. Click it to see your rebirth info
4. Click "REBIRTH NOW" → Confirm
5. You'll get a new solar system + +10% permanent multiplier!

**To test Upgrades:**
1. Click "💰 Add Resources" for money
2. Open 🛒 Shop
3. Buy some upgrades manually
4. OR click "🛒 Buy All Upgrades" to max everything

**To test Multi-Planet:**
1. Click "🌍 Unlock All Planets"
2. Open 🌌 Map
3. Switch between different planets
4. Each planet has different bonuses (check planet type)

## ⚠️ IMPORTANT REMINDERS

- **DO NOT** publish the game with these testing files
- **DO NOT** commit testing files to main branch (use a dev branch)
- **DO NOT** forget to delete TestingService.lua and TestingController.lua
- **DO** test the game thoroughly after removing testing files
- **DO** keep a backup of the testing files in case you need them again

## Alternative: Disable Instead of Delete

If you want to keep testing files for future updates, you can disable them instead:

### Option 1: Comment out the require statements
In `src/server/init.server.lua` and `src/client/init.client.lua`, comment out loading of test services/controllers.

### Option 2: Use a feature flag
Add a `_TESTING_MODE = false` constant and wrap all testing code in:
```lua
if _TESTING_MODE then
    -- Testing code here
end
```

## Production Checklist

Before publishing:
- [ ] Delete all testing files
- [ ] Remove debug print statements
- [ ] Test game without testing files
- [ ] Verify no errors in console
- [ ] Test save/load works
- [ ] Test all major features (upgrades, planets, rebirth)
- [ ] Check performance (FPS, server load)
- [ ] Test on mobile if possible
- [ ] Review all UI text for typos
- [ ] Check monetization if implemented

---

**Last Updated:** October 23, 2025  
**Testing Files Version:** 1.0
