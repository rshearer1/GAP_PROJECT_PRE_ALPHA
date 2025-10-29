# 🎨 Icon Design Template Guide

Quick reference for creating new icons for Grow-a-Planet

---

## 📐 Canvas Setup

**Software Options:**
- Adobe Illustrator / Photoshop
- Figma / Sketch
- GIMP (free)
- Inkscape (free, vector)

**Canvas Settings:**
```
Width: 256px
Height: 256px
Background: Transparent
Color Mode: RGB
Bit Depth: 32-bit (RGBA)
Resolution: 72-96 DPI
```

---

## 📏 Design Grid

```
┌─────────────────────────────────────┐
│ 13px padding                        │
│   ┌───────────────────────────┐    │
│   │                           │    │
│   │    Safe Area: 230x230     │    │
│   │                           │    │
│   │   Your icon design here   │    │
│   │                           │    │
│   │                           │    │
│   └───────────────────────────┘    │
│                        13px padding │
└─────────────────────────────────────┘
```

**Key Measurements:**
- Total canvas: 256x256px
- Safe area: 230x230px (center aligned)
- Padding: 13px on all sides
- Recommended stroke: 8-12px (for main shapes)
- Minimum detail size: 16px (anything smaller may be lost)

---

## 🎨 Color Application

### Method 1: Solid Color (Recommended)
Use one primary color from the design system:

```
Examples:
- Star icon: #FFD700 (Gold)
- Water icon: #6496FF (Ocean Blue)
- Pet icon: #8E44AD (Amethyst)
```

### Method 2: Two-Color with Depth
Add subtle highlight or shadow:

```
Primary: Main color from design system
Secondary: 20% lighter or darker version

Example (Shop Icon):
- Main: #2ECC71 (Emerald)
- Highlight: #3AE882 (+20% brightness)
```

### Method 3: Outline Style
For clarity on any background:

```
Fill: Transparent or solid color
Stroke: 8-10px, solid color
Effect: Clean, modern look
```

---

## ✅ Design Checklist

Before exporting your icon:

### Composition
- [ ] Icon is centered in safe area
- [ ] At least 13px padding on all sides
- [ ] Main shape is recognizable at 50x50px
- [ ] No text or numbers inside icon
- [ ] Shapes are simple and bold

### Color
- [ ] Uses colors from DESIGN_SYSTEM.md
- [ ] Maximum 2-3 colors total
- [ ] High contrast if using multiple colors
- [ ] Looks good on dark background (#1E1E28)

### Technical
- [ ] Background is transparent
- [ ] No stray pixels or artifacts
- [ ] Edges are smooth (anti-aliased)
- [ ] File size < 200KB (preferably < 100KB)
- [ ] Saved as PNG format

---

## 📤 Export Settings

### PNG Export (Recommended for Roblox)

**Photoshop:**
```
File → Export → Export As...
Format: PNG
Transparency: ON
Resolution: 72 DPI
Size: 256x256px
```

**Figma:**
```
Select artboard
Export: PNG
Scale: 1x
Size: 256x256px
```

**GIMP:**
```
File → Export As...
Format: PNG
Compression: 9
Save background color: OFF
Save resolution: ON (72 DPI)
```

---

## 🎯 Icon Examples (Breakdown)

### Example 1: Pet Button Icon (🐾)

**Concept:** Friendly paw print

```
Shape: Four toe pads + one main pad
Size: 200x200px in safe area
Color: #8E44AD (Amethyst)
Style: Rounded, playful shapes
Stroke: None (solid fill)
```

**Construction:**
1. Create main pad: 80x90px rounded rectangle (bottom center)
2. Add 4 toe pads: 40x50px ovals (arranged in arc above)
3. Unite shapes, center in canvas
4. Apply color, export

### Example 2: Rebirth Button Icon (🔄)

**Concept:** Circular arrows showing cycle

```
Shape: Two curved arrows forming circle
Size: 210x210px in safe area
Color: #E74C3C (Ruby) → #FFD700 (Gold) gradient
Style: Bold, energetic
Stroke: 12px
```

**Construction:**
1. Create circle path (200px diameter)
2. Break at 4 points, create arrow heads
3. Add gradient (optional)
4. Center, export

### Example 3: Achievement Button Icon (🏆)

**Concept:** Trophy cup

```
Shape: Classic trophy silhouette
Size: 190x220px in safe area
Color: #FFD700 (Gold)
Highlight: #FFED4E (lighter gold, +20%)
Style: Simple, iconic
```

**Construction:**
1. Cup body: 100x120px rounded trapezoid
2. Handles: Two 30x40px curved shapes
3. Base: 120x40px layered rectangles
4. Add highlight on cup top half
5. Center, export

---

## 🔄 Testing Your Icon

Before uploading to Roblox:

### Scale Test
1. Export at 256x256px
2. Scale down to 50x50px in image viewer
3. Check if recognizable
4. Check if details are visible

### Background Test
1. Place icon on dark background (#1E1E28)
2. Place icon on light background (#FFFFFF)
3. Verify good contrast in both cases

### Print Test (Optional)
1. Print at 1-inch size
2. View from 2 feet away
3. Should still be recognizable

---

## 📤 Uploading to Roblox

### Step-by-Step:

1. **Prepare File**
   - Format: PNG
   - Size: 256x256px
   - Background: Transparent
   - File size: < 1MB

2. **Upload to Roblox**
   ```
   1. Go to https://create.roblox.com/
   2. Navigate to "Development Items" → "Decals"
   3. Click "Upload Asset"
   4. Select your PNG file
   5. Add name and description
   6. Click "Upload"
   ```

3. **Get Asset ID**
   ```
   1. Wait for moderation (usually < 1 minute)
   2. Click on uploaded decal
   3. Copy Asset ID from URL
   4. Format: rbxassetid://[YOUR_ID_HERE]
   ```

4. **Update Constants.lua**
   ```lua
   NAV_BUTTONS = {
       BUTTONS = {
           ...
           {
               name = "YourButton", 
               assetId = "rbxassetid://YOUR_ID_HERE", 
               tooltip = "Description", 
               action = "actionname"
           },
       },
   }
   ```

---

## 🎨 Color Quick Reference

Copy-paste these hex codes:

```
# Primary Colors
Deep Space: #1E1E28
Dark Void: #282832
Star White: #FFFFFF

# Resource Colors
Ocean Blue (Water): #6496FF
Stone Gray (Minerals): #969696
Solar Gold (Energy): #FFC864
Forest Green (Biomass): #64C864

# Accent Colors
Emerald (Success): #2ECC71
Amber (Warning): #F39C12
Ruby (Error): #E74C3C
Amethyst (Special): #8E44AD
Gold (Premium): #FFD700
```

---

## 💡 Tips & Tricks

### Keep It Simple
- Icons are viewed at 50x50px - details get lost
- Use bold, chunky shapes
- Avoid thin lines (< 8px at 256x256 scale)

### Think Emoji-Style
- Your icons should feel like enhanced emojis
- Friendly, approachable, not too realistic
- Single concept per icon

### Use References
- Look at existing icons in the game
- Check emojis for inspiration
- Browse icon libraries (Flaticon, Noun Project) for ideas

### Test Early
- Scale down your work-in-progress frequently
- Don't spend hours on details that disappear at small size
- Show others - if they can't identify it in 2 seconds, simplify

---

## 🛠️ Common Issues & Fixes

| Problem | Solution |
|---------|----------|
| Icon too detailed | Simplify shapes, remove small elements |
| Hard to see at small size | Increase stroke width, use bolder shapes |
| Poor contrast | Check against dark background, increase saturation |
| Looks pixelated | Export at higher resolution, enable anti-aliasing |
| File too large | Reduce colors, flatten layers, optimize PNG |
| Rejected by Roblox | Remove text, avoid copyrighted symbols, check ToS |

---

**Ready to create?** Follow this guide and reference DESIGN_SYSTEM.md for colors!
