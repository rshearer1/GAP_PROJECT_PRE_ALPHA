# UI Assets

## 📋 Design System Reference

**Before creating any new icons or UI elements, please review:**

1. **[Design System](../../docs/DESIGN_SYSTEM.md)** - Complete color palette, typography, and component standards
2. **[Icon Template Guide](../../docs/ICON_TEMPLATE_GUIDE.md)** - Step-by-step icon creation process

---

## 🎨 Current Navigation Button Icons

These icons are already uploaded to Roblox and active in the game:

| Button | Asset ID | Color | Description |
|--------|----------|-------|-------------|
| **Stars** | `rbxassetid://109076471250268` | Gold (#FFD700) | Star Map navigation |
| **Galaxy** | `rbxassetid://90313785520046` | Purple (#8E44AD) | Solar System view |
| **Shop** | `rbxassetid://140353244803526` | Emerald (#2ECC71) | Shop interface |
| **Settings** | `rbxassetid://80743411284468` | Gray (#969696) | Settings panel |

---

## 📂 Asset Organization

Place new icon files in this directory before uploading:

```
assets/ui/
├── navigation/
│   ├── star_button.png (✅ uploaded)
│   ├── galaxy_button.png (✅ uploaded)
│   ├── shop_button.png (✅ uploaded)
│   └── settings_button.png (✅ uploaded)
├── resources/
│   ├── water_icon.png (planned)
│   ├── mineral_icon.png (planned)
│   ├── energy_icon.png (planned)
│   └── biomass_icon.png (planned)
└── features/
    ├── pet_button.png (needed)
    ├── rebirth_button.png (needed)
    └── achievement_button.png (needed)
```

---

## 🆕 Creating New Icons

### Quick Start:

1. **Review Design System**
   - Read `docs/DESIGN_SYSTEM.md` for color palette
   - Check existing icons for style consistency

2. **Use Icon Template**
   - Canvas: 256x256px, transparent background
   - Safe area: 230x230px (13px padding)
   - Follow `docs/ICON_TEMPLATE_GUIDE.md` for detailed steps

3. **Design Guidelines**
   - ✅ Simple, bold shapes
   - ✅ Use design system colors
   - ✅ Emoji-inspired, friendly style
   - ✅ Test at 50x50px size
   - ❌ No text inside icons
   - ❌ Avoid thin lines (< 8px)

4. **Export**
   - Format: PNG
   - Size: 256x256px
   - Background: Transparent
   - Compression: Medium (< 100KB)

---

## 📤 Upload Process

### Step-by-Step:

1. **Prepare Icon File**
   ```
   - File: your_icon.png
   - Size: 256x256px
   - Format: PNG with transparency
   - Max size: 1MB (preferably < 100KB)
   ```

2. **Upload to Roblox**
   ```
   1. Visit: https://create.roblox.com/
   2. Go to: Development Items → Decals
   3. Click: Upload Asset
   4. Select: Your PNG file
   5. Wait: ~1 minute for moderation
   ```

3. **Get Asset ID**
   ```
   1. Click on your uploaded decal
   2. Copy the ID from the URL
   3. Format: rbxassetid://[ID_NUMBER]
   ```

4. **Update Constants.lua**
   ```lua
   -- In src/shared/Constants.lua
   NAV_BUTTONS = {
       BUTTONS = {
           -- Add your new button:
           {
               name = "YourFeature", 
               assetId = "rbxassetid://YOUR_NEW_ID", 
               tooltip = "Feature Name",
               action = "featurename"
           },
       },
   }
   ```

---

## 🎯 Needed Icons (Priority Order)

### High Priority
- [ ] **Pet Button** - Amethyst paw print (#8E44AD)
- [ ] **Rebirth Button** - Ruby/Gold cycle arrows (#E74C3C → #FFD700)

### Medium Priority
- [ ] **Achievement Button** - Gold trophy (#FFD700)
- [ ] **Quest Button** - Amber scroll (#F39C12)
- [ ] **Inventory Button** - Ocean blue backpack (#6496FF)

### Low Priority (Future Features)
- [ ] **Profile Button** - White user silhouette (#FFFFFF)
- [ ] **Social Button** - Emerald group icon (#2ECC71)
- [ ] **Leaderboard Button** - Gold podium (#FFD700)

---

## 🎨 Icon Design Quick Reference

### Color Assignments (from Design System)

```
Resource Icons:
- Water: #6496FF (Ocean Blue)
- Minerals: #969696 (Stone Gray)
- Energy: #FFC864 (Solar Gold)
- Biomass: #64C864 (Forest Green)

Feature Icons:
- Pets: #8E44AD (Amethyst)
- Shop: #2ECC71 (Emerald)
- Stars: #FFD700 (Gold)
- Galaxy: #9B59B6 (Purple)
- Settings: #969696 (Gray)
- Rebirth: #E74C3C (Ruby)
- Premium: #FFD700 (Gold)
```

### Size Specifications

```
Canvas: 256x256px
Safe Area: 230x230px
Padding: 13px all sides
Stroke Width: 8-12px (main shapes)
Min Detail: 16px (smaller gets lost)
Display Size: 50x50px (in-game)
```

---

## 🛠️ Tools & Resources

### Free Design Software
- **GIMP** - Free Photoshop alternative
- **Inkscape** - Free vector graphics
- **Figma** - Free online design tool
- **Paint.NET** - Simple Windows editor

### Inspiration Sources
- Emoji libraries (for style reference)
- Flaticon.com (for concept ideas - don't copy!)
- Existing game icons (for consistency)

### Testing
- Scale to 50x50px before finalizing
- Test on dark background (#1E1E28)
- Get feedback from team

---

## ✅ Quality Checklist

Before uploading any icon:

- [ ] Reviewed Design System color palette
- [ ] Icon is 256x256px with transparent background
- [ ] Has 13px padding on all sides
- [ ] Uses colors from design system
- [ ] Looks clear at 50x50px size
- [ ] Works well on dark background
- [ ] File size < 200KB
- [ ] No text or small details
- [ ] Matches existing icon style
- [ ] Tested and approved

---

## 📝 Notes

- All icons should maintain the **emoji-inspired, friendly style**
- Use **solid colors** from the design system (avoid random gradients)
- Keep designs **simple and bold** - they display at 50x50px in-game
- **Test at target size** before uploading to Roblox
- When in doubt, reference existing uploaded icons for style consistency

---

**Questions?** Check `docs/DESIGN_SYSTEM.md` and `docs/ICON_TEMPLATE_GUIDE.md` for complete details!
