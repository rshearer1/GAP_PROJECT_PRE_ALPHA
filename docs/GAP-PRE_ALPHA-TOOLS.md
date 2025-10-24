📁 GAP-PRE_ALPHA-TOOLS

Tools and references to help Claude code procedurally generated Roblox worlds efficiently.

--[[
===============================================================================
🧠 GAP AI TRAINING BOOT PROMPT
===============================================================================
This file initializes AI compliance for the GAP-PRE_ALPHA-TOOLS system.

📘 Purpose:
Whenever an AI assistant (Claude, GPT, etc.) interacts with this project,
it must first locate and internalize the file:

    📄 GAP_AI_TRAINING_PROMPT.md

That file contains the full rulebook, module links, and behavior standards
for world generation, refactoring, and architecture.

===============================================================================
⚙️ AI INSTRUCTIONS
===============================================================================
> You are now entering GAP-PRE_ALPHA-TOOLS mode.
>
> 1️⃣ Locate and fully read the file: `GAP_AI_TRAINING_PROMPT.md`
>     - Absorb every section (modules, links, rules, frameworks).
>     - Internalize all function names, code structure, and conventions.
>     - Treat its contents as your single source of truth.
>
> 2️⃣ Operate under **STRICT COMPLIANCE MODE**:
>     - Use only the approved modules listed in that file.
>     - Follow the naming, structure, and project layout exactly.
>     - Never invent new APIs or frameworks.
>     - Always require() from valid paths as defined by Rojo.
>
> 3️⃣ When editing or generating code:
>     - Refactor safely: preserve logic, improve structure only.
>     - Comment every function clearly.
>     - Clean up using Janitor.
>     - Use WorldSpec.lua for all configuration data.
>     - Use DebugVisualizer.lua for placement previews.
>     - Follow output format defined in the prompt (summary + checklist).
>
> 4️⃣ If uncertain about a rule:
>     - Add a “-- TODO: clarify rule from GAP_AI_TRAINING_PROMPT.md” note.
>     - Do not make assumptions.
>
> 5️⃣ Periodically re-read `GAP_AI_TRAINING_PROMPT.md`
>     to stay aligned with the latest framework updates.
>
===============================================================================
💡 Quick Context Command (for Claude):
> “Refer to the GAP_AI_TRAINING_PROMPT.md file and operate in STRICT SAFE
>  COMPLIANCE MODE for all further code generation and refactoring.”
===============================================================================
]]



🔖 MASTER PROMPT: Refactor Mode

You are operating inside an existing Roblox Studio + Visual Studio + Rojo project that follows the GAP-PRE_ALPHA-TOOLS architecture.

Your task is to bring legacy code up to full compliance with the GAP-PRE_ALPHA-TOOLS standards without changing functionality.

⚙️ Your priorities:

Do not break existing systems — all outputs must remain functionally equivalent.

Refactor only for structure, consistency, clarity, and performance within the GAP-PRE_ALPHA-TOOLS framework.

Follow all strict compliance rules (module usage, naming, organization, documentation, etc.).

Keep all original behaviors intact — only clean up, modularize, and standardize code.

Where unsure, comment instead of assuming — e.g. -- TODO: Verify this matches new math utility.

Use safe modern equivalents (e.g. replace manual loops with utility functions if already provided).

Never delete or rename core files — only re-organize internally as needed.

Always summarize what was changed, why, and how you verified safety.

🧩 Refactor Output Format:
✅ Summary:
- What was cleaned up or standardized
- Which modules were used from GAP-PRE_ALPHA-TOOLS
- Any areas that need manual verification

✅ Refactored Code:
-- Clean, compliant, functionally identical code

✅ Safety Notes:
[x] No functional changes
[x] All utilities properly referenced
[x] Comments preserved or clarified
[x] Module structure intact
[x] Tested paths safe for Rojo sync


You are now in STRICT SAFE REFACTOR MODE.

🧭 Step-by-Step Workflow
Step	Action	What You Tell Claude
1	Load a file (e.g., SpawnManager.lua)	“Refactor this file to match GAP-PRE_ALPHA-TOOLS rules while keeping functionality identical.”
2	Claude audits it first	“Summarize problems and potential cleanups first — don’t edit yet.”
3	You approve the plan	“Good, now proceed with cleanup safely.”
4	Claude refactors and outputs code + safety checklist	Review the diff before committing.
5	Use Git or VSCode diff to test	Keep automated backups of old files.
6	Claude iterates based on errors or broken references	“You broke X dependency; revert that change and note it.”
🧰 Recommended Enhancements for Refactor Mode
Tool	Why It Helps
Rojo Sync Preview	Shows live file structure — helps Claude reference accurate module paths.
Selene / StyLua	Enforce formatting rules automatically after Claude refactors.
Git Branch “claude_refactor”	Keeps AI edits separate from production branch until tested.
Static Analyzer (Rojo + Luau LSP)	Detects type or reference issues before running.
Custom VERIFY.md	A log of what Claude has changed; helps track refactor safety.
⚖️ Optional: Mixed Refactor/Enhance Mode

If you do want Claude to modernize old code slightly (e.g., use Promises or Maid cleanup), append this to your prompt:

“You may modernize the code if — and only if — the behavior remains functionally identical.
Before replacing legacy code (e.g. event connections, loops), explain what you intend to do and wait for my confirmation.”

🧠 TL;DR Summary
Objective	Strategy
Keep functionality intact	“Strict Safe Refactor Mode”
Enforce standards	Use your README + GAP rules at top of every prompt
Prevent breakage	Audit → Approve → Refactor cycle
Track changes	Claude outputs summary + checklist
Integrate safely	Use Rojo sync + Git branch for testing




🧠 Overview

These modules, frameworks, and helper scripts provide Claude with everything it needs to generate complex, modular Roblox environments (spawn areas, terrain, buildings, etc.) in a clean, structured way.

Use these resources together within Visual Studio Code + Rojo + Roblox Studio for seamless sync and iteration.

⚙️ Core Modules
#	Module	Link	Purpose
1	Geometry module – roblox-geometry	stravant/roblox-geometry
	Geometry analysis functions (e.g. getGeometry(part) → vertices, edges, faces). Useful for aligning buildings on terrain or snapping structures.
2	NevermoreEngine (by Quenty)	Quenty/NevermoreEngine
	Modular game framework (Maid, Promise, Signal, etc). Keeps generated worlds organized into clean services/modules.
3	MathPlus	iSophes/mathplus
	Advanced math functions (noise, rounding, randomization). Ideal for procedural variation and grid placement.
4	Basic Geometry Library	DevForum: Basic Geometry Library
	Adds geometry/trig utilities (areas, perimeters, arcs). Useful for circular zones, spawn radii, etc.
5	QuickMaths Module	DevForum: QuickMaths
	Simplifies smaller math operations for lightweight geometry or placement scripts.
🧱 Additional Helpful Libraries
Tool	Description	Why It Helps
RbxGeometry (community)	Procedural shape/mesh creation functions.	Lets Claude generate parts, buildings, and terrain directly.
Terrain APIs	Built-in Workspace.Terrain:FillBlock, FillCylinder, etc.	Shape terrain for spawn zones, hills, or roads.
t (TestEZ)	Lightweight testing module.	Allows Claude to validate generated scripts automatically.
Janitor (Validark)	Cleanup utility for Instances.	Keeps workspace clean during world regeneration.
Knit or Nevermore	Frameworks for modular architecture.	Enables large-scale structured generation systems.
SimplexNoise.lua	Noise generator (Perlin/Simplex).	Generates natural terrain and randomized building layouts.
RaycastUtils.lua	Placement helpers for uneven terrain.	Aligns assets to surfaces realistically.
🧩 Custom Modules (Starter Scripts)
SpawnBuilder.lua
local SpawnBuilder = {}

function SpawnBuilder.createSpawnArea(position, size)
	local base = Instance.new("Part")
	base.Anchored = true
	base.Size = size
	base.Position = position
	base.Color = Color3.fromRGB(100, 200, 100)
	base.Name = "SpawnPlatform"
	base.Parent = workspace

	local spawn = Instance.new("SpawnLocation")
	spawn.Position = position + Vector3.new(0, size.Y/2 + 2, 0)
	spawn.Anchored = true
	spawn.Parent = workspace

	return spawn
end

return SpawnBuilder

BuildingGenerator.lua
local BuildingGenerator = {}

function BuildingGenerator.createSimpleBuilding(position, width, height, depth)
	local model = Instance.new("Model")
	model.Name = "Building"

	local base = Instance.new("Part")
	base.Size = Vector3.new(width, height, depth)
	base.Position = position + Vector3.new(0, height/2, 0)
	base.Color = Color3.fromRGB(150, 150, 150)
	base.Anchored = true
	base.Parent = model

	model.Parent = workspace
	return model
end

return BuildingGenerator

🧰 VS Code Setup
Extension	Purpose
Rojo	Sync VSCode ↔ Roblox Studio
Selene	Luau linter
Luau Language Server	Autocomplete + type hints
Git Graph	Visualize commits/versioning
🧭 WorldSpec Configuration Example

Create a file src/WorldSpec.lua to define how your world should generate:

return {
  worldSize = Vector3.new(1000, 0, 1000),
  spawnArea = {
    position = Vector3.new(0, 0, 0),
    size = Vector3.new(50, 2, 50),
    decoration = "grass"
  },
  buildingZones = {
    { center = Vector3.new(100, 0, 100), count = 10, spacing = 50, type = "residential" },
    { center = Vector3.new(-100, 0, 100), count = 5, spacing = 80, type = "industrial" }
  }
}


Claude can reference this file when deciding layout parameters.

🧮 Utility Modules
WorldUtils.lua
local WorldUtils = {}

function WorldUtils.randomColor()
	return Color3.fromHSV(math.random(), 0.7, 1)
end

function WorldUtils.gridPosition(index, spacing, origin)
	local x = (index % 10) * spacing
	local z = math.floor(index / 10) * spacing
	return origin + Vector3.new(x, 0, z)
end

return WorldUtils

🏗️ Prefabs / Assets

Organize re-usable assets:

ReplicatedStorage/
  ├─ Assets/
  │  ├─ Buildings/
  │  │  ├─ HouseModel.rbxm
  │  │  ├─ TowerModel.rbxm
  │  ├─ Nature/
  │  │  ├─ TreeA.rbxm
  │  │  ├─ BushA.rbxm


Claude can clone assets like:

local asset = ReplicatedStorage.Assets.Buildings.HouseModel:Clone()
asset.Parent = workspace

🔢 Noise / Variation

Use a noise module such as:

SimplexNoise.lua

Perlin.lua gist

Example:

local noise = require(game.ReplicatedStorage.SimplexNoise)
local height = 10 + noise:GetValue(x/100, z/100) * 20

🔌 Debug / Developer Tools
DevConsole.lua
local Commands = {}

function Commands.regenWorld()
	local generator = require(script.Parent.WorldGenerator)
	generator.generate()
end

game.ReplicatedStorage:WaitForChild("RemoteEvent").OnServerEvent:Connect(function(player, cmd)
	if Commands[cmd] then Commands[cmd]() end
end)

DebugVisualizer.lua
local Debug = {}

function Debug.marker(position, color)
	local part = Instance.new("Part")
	part.Anchored = true
	part.Color = color or Color3.new(1, 0, 0)
	part.Size = Vector3.new(1,1,1)
	part.Position = position
	part.Name = "DebugMarker"
	part.Parent = workspace
end

return Debug

💾 Persistence (Optional)

Use DataStore2 by Kampfkarren

or a simple wrapper to store world state between sessions.

📘 AI API Docs Example (AI_API_DOCS.md)
# Available Modules
- **Geometry**: Geometry.getGeometry(part)
- **WorldUtils**: randomColor(), gridPosition()
- **SpawnBuilder**: createSpawnArea(pos, size)
- **BuildingGenerator**: createSimpleBuilding(pos, w, h, d)
- **Noise**: GetValue(x, z)
- **Nevermore**: modular architecture / service management

🧩 TL;DR
Area	Tool	Why it Helps
Config	WorldSpec.lua	Defines generation rules
Utils	WorldUtils.lua	Layout + math helpers
Assets	Prefab library	Ready-made assets
Terrain	SimplexNoise	Adds realistic variation
Debug	DevConsole / Visualizer	Easier testing
Save	DataStore2	Persist generated worlds
Docs	AI_API_DOCS.md	Gives Claude full context
