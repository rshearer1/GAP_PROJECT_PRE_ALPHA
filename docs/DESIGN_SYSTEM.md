# 🎨 Grow-a-Planet Design System

**Version:** 1.0  
**Last Updated:** October 28, 2025  
**Purpose:** Comprehensive visual design guide for all UI elements, logos, icons, and branding

---

## 📐 Design Philosophy

**Grow-a-Planet** is a space-themed idle simulation game. The design system emphasizes:

- **Cosmic Wonder** - Deep space colors with vibrant planetary accents
- **Clarity** - Clean, readable UI with good contrast
- **Playfulness** - Use of emojis and friendly iconography
- **Progression** - Visual feedback that reinforces player growth
- **Consistency** - Unified color palette and spacing across all UI

---

## 🎨 Core Color Palette

### Primary Colors (Background & Structure)

| Color Name | Hex Code | RGB | Usage |
|------------|----------|-----|-------|
| **Deep Space** | `#1E1E28` | `30, 30, 40` | Main UI backgrounds, panels |
| **Dark Void** | `#282832` | `40, 40, 50` | Secondary panels, info sections |
| **Cosmic Gray** | `#34495E` | `52, 73, 94` | Buttons, minimize controls |
| **Star White** | `#FFFFFF` | `255, 255, 255` | Primary text, titles |

### Resource Colors

| Resource | Color Name | Hex Code | RGB | Emoji |
|----------|-----------|----------|-----|-------|
| **Water** | Ocean Blue | `#6496FF` | `100, 150, 255` | 💧 |
| **Minerals** | Stone Gray | `#969696` | `150, 150, 150` | ⛰️ |
| **Energy** | Solar Gold | `#FFC864` | `255, 200, 100` | ⚡ |
| **Biomass** | Forest Green | `#64C864` | `100, 200, 100` | 🌱 |

### Biome Colors

| Biome | Hex Code | RGB | Level Req |
|-------|----------|-----|-----------|
| **Barren** | `#78645A` | `120, 100, 80` | 1+ |
| **Rocky** | `#96785A` | `150, 120, 90` | 3+ |
| **Oceanic** | `#3278C8` | `50, 120, 200` | 7+ |
| **Forest** | `#50A050` | `80, 160, 80` | 12+ |

### Accent Colors (Interactive Elements)

| Purpose | Color Name | Hex Code | RGB | Usage |
|---------|-----------|----------|-----|-------|
| **Success** | Emerald | `#2ECC71` | `46, 204, 113` | Affordable items, confirmations |
| **Warning** | Amber | `#F39C12` | `243, 156, 18` | Cautions, thresholds |
| **Error** | Ruby | `#E74C3C` | `231, 76, 60` | Cannot afford, errors |
| **Info** | Amethyst | `#8E44AD` | `142, 68, 173` | Pet bonuses, special stats |
| **Premium** | Gold | `#FFD700` | `255, 215, 0` | VIP, legendary items |

---

## 🖼️ Logo & Icon Design Standards

### Navigation Button Icons (Current Assets)

Based on existing uploaded assets:

1. **Star Map Button** (`rbxassetid://109076471250268`)
   - Icon: ⭐ Yellow/gold star
   - Style: Simple, geometric star shape
   - Color: Warm gold (`#FFD700` - `#FFC864`)

2. **Solar System Button** (`rbxassetid://90313785520046`)
   - Icon: 🌌 Purple swirl/galaxy portal
   - Style: Circular swirl with cosmic energy
   - Color: Deep purple (`#8E44AD` - `#9B59B6`)

3. **Shop Button** (`rbxassetid://140353244803526`)
   - Icon: 🛒 Green shopping basket/cart
   - Style: Simple basket silhouette
   - Color: Emerald green (`#2ECC71` - `#27AE60`)

4. **Settings Button** (`rbxassetid://80743411284468`)
   - Icon: ⚙️ Gray mechanical gear
   - Style: Classic gear/cog
   - Color: Cool gray (`#969696` - `#7F8C8D`)

### Design Rules for All Future Icons

**✅ DO:**
- Use **solid, simple shapes** with minimal detail
- Keep **stroke width consistent** (3-5px for 50x50px icons)
- Use **single color + optional highlight/shadow** for depth
- Design at **256x256px** minimum, then scale down
- Leave **10-15% padding** around the icon edge
- Use **emoji-inspired** friendly shapes (rounded, approachable)
- Match the **thematic color** of the feature (resources, biomes, etc.)

**❌ DON'T:**
- Use gradients (unless subtle, 2-color max)
- Add text/labels inside icons
- Use thin lines that disappear at small sizes
- Mix different art styles
- Use more than 3 colors per icon
- Create overly detailed/realistic images

### Icon Template Specifications

```
Canvas Size: 256x256px
Safe Area: 230x230px (13px padding on all sides)
Export Format: PNG (transparent background)
Color Depth: 32-bit RGBA
Recommended DPI: 72-96 (for Roblox upload)
```

### Future Icon Needs

| Button | Icon Concept | Primary Color | Emoji Reference |
|--------|-------------|---------------|-----------------|
| **Pets** | Paw print or cute creature | Amethyst (`#8E44AD`) | 🐾 |
| **Rebirth** | Phoenix or cycle arrows | Ruby/Gold (`#E74C3C`) | 🔄 |
| **Achievements** | Trophy or medal | Gold (`#FFD700`) | 🏆 |
| **Quests** | Scroll or quest marker | Amber (`#F39C12`) | 📜 |
| **Inventory** | Backpack or chest | Ocean Blue (`#6496FF`) | 🎒 |
| **Profile** | User silhouette | Star White (`#FFFFFF`) | 👤 |

---

## 📏 UI Component Standards

### Typography

| Element | Font | Size | Weight | Color |
|---------|------|------|--------|-------|
| **Panel Titles** | GothamBold | 18 | Bold | Star White |
| **Level Display** | GothamBold | 18 | Bold | Star White |
| **Resource Labels** | Gotham | 13 | Regular | Star White |
| **Biome Text** | Gotham | 12 | Regular | Star White |
| **XP Progress** | Gotham | 10 | Regular | Stone Gray |
| **Button Text** | GothamBold | 14 | Bold | Star White |
| **Tooltips** | Gotham | 11 | Regular | Star White |

### Spacing & Layout

```lua
CORNER_RADIUS = UDim.new(0, 8)      -- Rounded corners (8px)
PADDING = UDim.new(0, 10)           -- Standard padding (10px)
BUTTON_SPACING = 30                 -- Vertical spacing between nav buttons
LIST_ITEM_SPACING = 8               -- Spacing in scrolling lists
```

### Button Sizes

| Button Type | Size (UDim2) | Usage |
|------------|--------------|-------|
| **Nav Buttons** | `0, 50, 0, 50` | Right-side navigation icons |
| **Minimize Button** | `0, 25, 0, 25` | Panel minimize/maximize |
| **Action Buttons** | `0, 100, 0, 35` | Purchase, confirm, cancel |

### Panel Structure

All major UI panels should follow this structure:

```lua
Frame (Main Panel)
├── UICorner (CornerRadius = 8px)
├── Title TextLabel (GothamBold, 18px)
├── Content ScrollingFrame or Frame
│   └── UIListLayout (Padding = 8px)
└── Close/Minimize Button (top-right)
```

---

## 🎭 UI Animation Guidelines

### Hover Effects
- **Color Shift**: Lighten by 10-15% on hover
- **Scale**: Slightly grow to 1.05x scale
- **Duration**: 0.1-0.15 seconds

### Click Feedback
- **Press**: Scale down to 0.95x
- **Release**: Spring back to 1.0x or 1.02x
- **Duration**: 0.1 seconds

### Panel Transitions
- **Fade In**: Transparency 1 → 0 over 0.3 seconds
- **Slide In**: Position offset + fade (0.4 seconds)
- **Expand/Collapse**: Size tween with EasingStyle.Quad

### Resource Updates
- **Number Changes**: Color flash (green for gain, red for loss)
- **Progress Bars**: Smooth fill animation (0.5 seconds)

---

## 🌟 Special Effects

### Planet Visuals
- **Rotation**: Slow spin (0.5 RPM) on Y-axis
- **Glow**: PointLight with biome color (range 15-25 studs)
- **Material**: SmoothPlastic or Neon (for evolved planets)

### Particle Effects
- **Level Up**: Sparkle burst (50 particles, 2-second duration)
- **Resource Gain**: Small upward floating numbers
- **Planet Upgrade**: Radial wave effect

---

## 🎨 Emoji Icon Reference

Standard emojis used throughout the UI:

| Feature | Emoji | Unicode |
|---------|-------|---------|
| Water | 💧 | U+1F4A7 |
| Minerals | ⛰️ | U+26F0 |
| Energy | ⚡ | U+26A1 |
| Biomass | 🌱 | U+1F331 |
| Pets | 🐾 | U+1F43E |
| Shop | 🛒 | U+1F6D2 |
| Stars | ⭐ | U+2B50 |
| Galaxy | 🌌 | U+1F30C |
| Settings | ⚙️ | U+2699 |
| Level Up | 🎯 | U+1F3AF |
| Rebirth | 🔄 | U+1F504 |
| Trophy | 🏆 | U+1F3C6 |

---

## 📱 Responsive UI Design (Critical)

### Platform Targets
- **PC**: 1920x1080 (desktop/laptop)
- **Mobile**: 375x667 to 414x896 (phones/tablets)
- **Console**: 1920x1080 (Xbox, PlayStation)
- **Minimum**: 800x600 (legacy/small screens)

### ✅ Responsive Design Rules

**ALWAYS follow these rules for cross-platform consistency:**

1. **Use Scale Instead of Offset**
   ```lua
   -- ❌ BAD (fixed pixels, breaks on different screens)
   frame.Size = UDim2.new(0, 300, 0, 200)
   frame.Position = UDim2.new(0, 50, 0, 100)
   
   -- ✅ GOOD (responsive, scales with screen)
   frame.Size = UDim2.new(0.25, 0, 0.3, 0)  -- 25% width, 30% height
   frame.Position = UDim2.new(0.5, 0, 0.5, 0)  -- Centered
   frame.AnchorPoint = Vector2.new(0.5, 0.5)  -- Anchor from center
   ```

2. **Center with AnchorPoint**
   ```lua
   -- ✅ ALWAYS set AnchorPoint for centered elements
   frame.AnchorPoint = Vector2.new(0.5, 0.5)  -- Center anchor
   frame.Position = UDim2.new(0.5, 0, 0.5, 0)  -- Center position
   ```

3. **Maintain Aspect Ratios**
   ```lua
   -- ✅ Add UIAspectRatioConstraint to preserve proportions
   local aspectRatio = Instance.new("UIAspectRatioConstraint")
   aspectRatio.AspectRatio = 1.5  -- Width/Height ratio (e.g., 300/200)
   aspectRatio.Parent = frame
   ```

4. **Group UI Elements**
   ```lua
   -- ✅ Use parent frames to scale children together
   local container = Instance.new("Frame")
   container.Size = UDim2.new(0.4, 0, 0.6, 0)  -- Scale-based
   container.AnchorPoint = Vector2.new(0.5, 0.5)
   container.Position = UDim2.new(0.5, 0, 0.5, 0)
   
   -- Children maintain relative positions within container
   local child = Instance.new("TextButton")
   child.Size = UDim2.new(0.8, 0, 0.2, 0)  -- 80% of parent width
   child.Position = UDim2.new(0.5, 0, 0.1, 0)
   child.AnchorPoint = Vector2.new(0.5, 0)
   child.Parent = container
   ```

5. **Use UISizeConstraint for Min/Max Limits**
   ```lua
   -- ✅ Prevent UI from becoming too small or too large
   local sizeConstraint = Instance.new("UISizeConstraint")
   sizeConstraint.MinSize = Vector2.new(200, 150)  -- Minimum size
   sizeConstraint.MaxSize = Vector2.new(600, 400)  -- Maximum size
   sizeConstraint.Parent = frame
   ```

6. **TextScaled for Dynamic Text**
   ```lua
   -- ✅ Use TextScaled for responsive text sizing
   label.TextScaled = true
   label.TextSize = 14  -- Fallback size
   
   -- ✅ Add UITextSizeConstraint to limit scaling
   local textConstraint = Instance.new("UITextSizeConstraint")
   textConstraint.MinTextSize = 10
   textConstraint.MaxTextSize = 24
   textConstraint.Parent = label
   ```

### 🎯 Responsive Implementation Template

```lua
-- Example: Centered panel that scales across all devices
local function createResponsivePanel()
    local panel = Instance.new("Frame")
    panel.Name = "ResponsivePanel"
    
    -- Use scale for size (30% of screen width, 40% of height)
    panel.Size = UDim2.new(0.3, 0, 0.4, 0)
    
    -- Center with AnchorPoint
    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    -- Maintain aspect ratio
    local aspectRatio = Instance.new("UIAspectRatioConstraint")
    aspectRatio.AspectRatio = 0.75  -- 3:4 ratio
    aspectRatio.Parent = panel
    
    -- Prevent from getting too small/large
    local sizeConstraint = Instance.new("UISizeConstraint")
    sizeConstraint.MinSize = Vector2.new(250, 300)
    sizeConstraint.MaxSize = Vector2.new(500, 600)
    sizeConstraint.Parent = panel
    
    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.05, 0)  -- 5% of frame size
    corner.Parent = panel
    
    return panel
end
```

### 📐 Conversion Guide (Offset to Scale)

**For 1920x1080 base resolution:**

| Offset (px) | Scale Equivalent | Calculation |
|-------------|------------------|-------------|
| 300px width | 0.156 | 300 / 1920 |
| 200px height | 0.185 | 200 / 1080 |
| 50px width | 0.026 | 50 / 1920 |
| 100px height | 0.093 | 100 / 1080 |

**Quick formula:**
```lua
scaleX = pixelsX / 1920
scaleY = pixelsY / 1080
```

### 🛠️ Recommended Plugins

- **AutoScale Lite** - Converts Offset to Scale automatically
- **UI Designer** - Visual layout tools with constraints
- **Scale Converter** - Batch convert existing UI

⚠️ **Note**: Plugins help with initial conversion, but manual fine-tuning is always necessary for perfect results.

### 📏 Responsive Layout Patterns

#### Pattern 1: Full-Screen Overlay
```lua
-- Darkened background overlay
local overlay = Instance.new("Frame")
overlay.Size = UDim2.new(1, 0, 1, 0)  -- 100% screen coverage
overlay.Position = UDim2.new(0, 0, 0, 0)
overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
overlay.BackgroundTransparency = 0.5
```

#### Pattern 2: Corner-Anchored UI
```lua
-- Top-left corner (like mini-map)
local miniMap = Instance.new("Frame")
miniMap.Size = UDim2.new(0.15, 0, 0.2, 0)  -- 15% width, 20% height
miniMap.Position = UDim2.new(0, 10, 0, 10)  -- Small offset from corner
miniMap.AnchorPoint = Vector2.new(0, 0)  -- Top-left anchor
```

#### Pattern 3: Bottom-Center HUD
```lua
-- Bottom-center action bar
local actionBar = Instance.new("Frame")
actionBar.Size = UDim2.new(0.6, 0, 0.1, 0)  -- 60% width, 10% height
actionBar.Position = UDim2.new(0.5, 0, 0.95, 0)  -- Bottom-center
actionBar.AnchorPoint = Vector2.new(0.5, 1)  -- Anchor bottom-center
```

#### Pattern 4: Right-Side Navigation (Current Nav Buttons)
```lua
-- Vertical button stack on right edge
local navContainer = Instance.new("Frame")
navContainer.Size = UDim2.new(0.05, 0, 0.4, 0)  -- 5% width, 40% height
navContainer.Position = UDim2.new(0.98, 0, 0.5, 0)  -- Right side, centered vertically
navContainer.AnchorPoint = Vector2.new(1, 0.5)  -- Anchor right-center
navContainer.BackgroundTransparency = 1

-- Add UIListLayout for automatic stacking
local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0.05, 0)  -- 5% spacing
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
listLayout.Parent = navContainer
```

### 🎮 Console-Specific Considerations

**Controller Navigation:**
- Use `GuiService:SetSelectedObject()` for default selection
- Implement `SelectionImageObject` for highlight feedback
- Group related buttons with `NextSelectionDown/Up/Left/Right`

**Safe Zone:**
- TVs cut off edges - keep important UI 5-10% from screen edges
- Use `GuiService:GetSafeZoneOffsets()` for automatic detection

**Text Size:**
- Minimum 18px for readability on TVs from couch distance
- Use `TextScaled = true` with `UITextSizeConstraint`

### ✅ Responsive UI Checklist

Before finalizing any UI element:

- [ ] Uses **Scale** instead of Offset for size and position
- [ ] Has **AnchorPoint** set appropriately (0.5, 0.5 for centered)
- [ ] Includes **UIAspectRatioConstraint** if aspect ratio matters
- [ ] Has **UISizeConstraint** to prevent extreme sizes
- [ ] Text uses **TextScaled** with **UITextSizeConstraint**
- [ ] Tested on **mobile** (small screen)
- [ ] Tested on **PC** (1920x1080)
- [ ] Tested on **console** (safe zone compliance)
- [ ] Parent frames group **related elements** for unified scaling
- [ ] No hardcoded pixel values in critical positioning

---

## 🔧 Implementation Checklist

When creating new UI elements:

- [ ] Use color palette from this document
- [ ] Apply standard corner radius (8px)
- [ ] Add UICorner to frames
- [ ] Use Gotham/GothamBold fonts
- [ ] Include appropriate emoji icons
- [ ] Add hover/click animations
- [ ] Test readability on dark backgrounds
- [ ] Ensure contrast ratio > 4.5:1 for text
- [ ] Follow naming conventions (PascalCase for instances)
- [ ] Document any new patterns in this file

---

## 🎯 Design Priorities

1. **Readability** - Text must be clear against backgrounds
2. **Consistency** - Reuse patterns and components
3. **Feedback** - Always show state changes visually
4. **Performance** - Limit particle count, optimize tweens
5. **Accessibility** - High contrast, clear labels, no flashing

---

## 📝 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Oct 28, 2025 | Initial design system based on existing UI |

---

## 🤝 Contributor Guidelines

When adding new visual elements:

1. **Check this document first** - Reuse existing colors/patterns
2. **Document new patterns** - Add to this file if creating something new
3. **Test in Studio** - Verify appearance in Roblox Studio lighting
4. **Get feedback** - Share screenshots before finalizing
5. **Update Constants.lua** - Add new colors/sizes to shared constants

---

**Questions or suggestions?** Update this document as the design evolves!
