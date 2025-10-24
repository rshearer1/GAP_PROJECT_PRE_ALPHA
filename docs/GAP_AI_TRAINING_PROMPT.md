🧠 GAP-PRE_ALPHA-TOOLS — AI TRAINING + REFACTOR STANDARD

Purpose:
This document defines the full toolchain, API access, and behavior rules for Claude when working inside this Roblox project.
Claude must strictly follow every rule, module structure, and pattern described here.

🧩 Core Context

This Roblox project uses Visual Studio Code + Rojo + Roblox Studio.

All code generation and refactoring by Claude must comply with these tool and library definitions:

#	Module Name	Link	Purpose
1	Geometry module – roblox-geometry	https://github.com/stravant/roblox-geometry
	Provides geometry analysis (vertices, faces, edges). Used for aligning and snapping building parts to terrain or surfaces.
2	NevermoreEngine (Framework)	https://github.com/Quenty/NevermoreEngine
	Modular game framework with Maid, Promise, Signal, etc. Use this to structure all code and services.
3	MathPlus	https://github.com/iSophes/mathplus
	Math extension library with noise, rounding, and procedural helpers. Use for layout, variation, and terrain.
4	Basic Geometry Library	https://devforum.roblox.com/t/basic-geometry-library/1568630
	Community geometry utilities (areas, arcs, trigonometry). Useful for circular or radial placement.
5	QuickMaths (community)	https://devforum.roblox.com/t/maths-module-that-does-all-the-maths-for-you-quickmaths/2448926
	Lightweight math helper for simpler operations.
6	RbxGeometry (community)	https://github.com/CloneTrooper1019/RbxGeometry
	Utility for creating procedural shapes and meshes.
7	Terrain APIs	Built-in (Workspace.Terrain)	For shaping terrain (FillBlock, FillCylinder, etc.)
8	Janitor (by Validark)	https://github.com/Validark/Janitor
	Cleans up instances after world regeneration.
9	SimplexNoise.lua	https://github.com/Roblox/Core-Scripts/blob/master/CoreScriptsRoot/Modules/SimplexNoise.lua
	Noise-based terrain and variation.
10	DataStore2	https://github.com/Kampfkarren/Roblox/tree/master/DataStore2
	For saving generated world data between sessions.
🧱 Local Helper Modules (In-Repo)

These exist in your /src/Modules/ folder:

SpawnBuilder.lua → creates and colors spawn platforms.

BuildingGenerator.lua → constructs simple building models.

WorldUtils.lua → general-purpose helpers (grid layout, colors).

DebugVisualizer.lua → creates placement markers for debugging.

WorldSpec.lua → defines world structure (size, spawn position, building zones).

DevConsole.lua → provides regeneration commands.

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
