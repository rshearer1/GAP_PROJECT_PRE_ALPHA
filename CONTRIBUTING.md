# Contributing to Grow a Planet

Thank you for your interest in contributing! This document provides guidelines and standards for contributing to the project.

## Table of Contents
1. [Getting Started](#getting-started)
2. [Code Standards](#code-standards)
3. [Development Workflow](#development-workflow)
4. [Pull Request Process](#pull-request-process)
5. [Commit Guidelines](#commit-guidelines)

## Getting Started

### Prerequisites
Make sure you've completed the setup in [SETUP.md](SETUP.md).

### Fork and Clone
1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/grow-a-planet.git`
3. Add upstream remote: `git remote add upstream https://github.com/ORIGINAL_OWNER/grow-a-planet.git`

### Install Dependencies
```bash
npm install
```

### Create a Branch
```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/your-bug-fix
```

## Code Standards

### TypeScript Style Guide

#### Naming Conventions

**Classes and Interfaces:** PascalCase
```typescript
class PlanetManager { }
interface PlanetState { }
```

**Functions and Variables:** camelCase
```typescript
const playerCount = 5;
function calculateResources() { }
```

**Constants:** UPPER_SNAKE_CASE
```typescript
const MAX_PLANETS = 100;
const DEFAULT_SIZE = 50;
```

**Private Members:** prefix with underscore (optional)
```typescript
class MyClass {
    private _internalValue: number;
    private cache: Map<string, any>;  // Or no underscore
}
```

**File Names:** PascalCase for classes, camelCase for utilities
```
PlanetManager.ts
GrowthModule.ts
utils.ts
constants.ts
```

#### Type Annotations

**Always specify types for:**
- Function parameters
- Function return types
- Class properties
- Complex objects

```typescript
// ✅ Good
function addResources(
    current: Resources, 
    amount: number
): Resources {
    return {
        water: current.water + amount,
        minerals: current.minerals + amount,
        energy: current.energy + amount,
        biomass: current.biomass
    };
}

// ❌ Bad
function addResources(current, amount) {
    return {
        water: current.water + amount,
        minerals: current.minerals + amount,
        energy: current.energy + amount,
        biomass: current.biomass
    };
}
```

**Prefer interfaces over type aliases for objects:**
```typescript
// ✅ Good
interface PlanetState {
    id: string;
    owner: number;
}

// ⚠️ Use type for unions/utilities
type ResourceType = "water" | "minerals" | "energy";
```

#### Code Organization

**One class per file:**
```typescript
// PlanetManager.ts
export class PlanetManager {
    // Implementation
}
```

**Group related functions:**
```typescript
// planetUtils.ts
export function createPlanet() { }
export function destroyPlanet() { }
export function updatePlanet() { }
```

**Use barrel exports:**
```typescript
// modules/index.ts
export { PlanetManager } from "./PlanetManager";
export { GrowthModule } from "./GrowthModule";
export { EcosystemModule } from "./EcosystemModule";
```

#### Comments and Documentation

**Use JSDoc for public APIs:**
```typescript
/**
 * Creates a new planet for the specified user
 * @param userId - The Roblox user ID
 * @param name - The name of the planet
 * @returns The newly created planet state
 */
function createPlanet(userId: number, name: string): PlanetState {
    // Implementation
}
```

**Inline comments for complex logic:**
```typescript
// Calculate exponential growth with diminishing returns
const growth = baseRate * Math.pow(level, 0.5);
```

**Avoid obvious comments:**
```typescript
// ❌ Bad
// Increment i
i++;

// ✅ Good (or no comment)
i++;
```

### Code Quality

#### Prefer const over let
```typescript
// ✅ Good
const maxSize = 100;
const resources = { water: 10 };

// ❌ Avoid
let maxSize = 100;  // Not reassigned
```

#### Use arrow functions
```typescript
// ✅ Preferred
const double = (x: number) => x * 2;
array.forEach((item) => print(item));

// ⚠️ Use regular functions for methods
class MyClass {
    myMethod() {  // Not arrow function
        // Implementation
    }
}
```

#### Destructuring
```typescript
// ✅ Good
const { water, minerals } = planet.resources;
const [first, second] = array;

// ❌ Less readable
const water = planet.resources.water;
const minerals = planet.resources.minerals;
```

#### Template literals
```typescript
// ✅ Good
const message = `Player ${name} has ${count} planets`;

// ❌ Old style
const message = "Player " + name + " has " + count + " planets";
```

#### Optional chaining and nullish coalescing
```typescript
// ✅ Good
const name = player?.Name ?? "Unknown";
const value = config?.setting?.value;

// ❌ Verbose
const name = player ? player.Name : "Unknown";
```

### Error Handling

**Use try-catch for errors:**
```typescript
try {
    const data = loadData();
    processData(data);
} catch (error) {
    warn("Failed to process data:", error);
    return defaultValue;
}
```

**Return error values when appropriate:**
```typescript
function validatePlanet(state: PlanetState): { valid: boolean; error?: string } {
    if (state.size < 0) {
        return { valid: false, error: "Size cannot be negative" };
    }
    return { valid: true };
}
```

### Performance

**Cache expensive calculations:**
```typescript
class PlanetManager {
    private cachedRates = new Map<number, ResourceRates>();
    
    getResourceRates(userId: number): ResourceRates {
        if (this.cachedRates.has(userId)) {
            return this.cachedRates.get(userId)!;
        }
        
        const rates = this.calculateRates(userId);
        this.cachedRates.set(userId, rates);
        return rates;
    }
}
```

**Use Map/Set for lookups:**
```typescript
// ✅ Fast O(1) lookup
const playerPlanets = new Map<number, PlanetState>();
playerPlanets.set(userId, planet);

// ❌ Slow O(n) lookup
const playerPlanets: PlanetState[] = [];
const planet = playerPlanets.find(p => p.owner === userId);
```

## Development Workflow

### 1. Start Development Server
```bash
npm run dev
```

### 2. Make Changes
- Edit TypeScript files in `src/`
- Watch for compilation errors
- Test in Roblox Studio (F5)

### 3. Test Your Changes
- Manual testing in Studio
- Check for console errors
- Test edge cases

### 4. Format Code
```bash
npm run format
```

### 5. Lint Code
```bash
npm run lint
```

### 6. Commit Changes
```bash
git add .
git commit -m "feat: add planet evolution system"
```

## Pull Request Process

### Before Submitting

- [ ] Code compiles without errors (`npm run build`)
- [ ] Code passes linting (`npm run lint`)
- [ ] Code is formatted (`npm run format`)
- [ ] Changes tested in Roblox Studio
- [ ] No console errors or warnings
- [ ] Documentation updated if needed

### PR Title Format

Use conventional commits:
```
feat: add new feature
fix: fix bug in planet manager
docs: update README
style: format code
refactor: restructure planet system
test: add tests for growth module
chore: update dependencies
```

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
How did you test these changes?

## Screenshots (if applicable)
Add screenshots for UI changes

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] No new warnings
```

### Review Process

1. Submit PR
2. Wait for automated checks
3. Request review from maintainers
4. Address feedback
5. Get approval
6. Merge!

## Commit Guidelines

### Commit Message Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting
- `refactor`: Code restructuring
- `test`: Tests
- `chore`: Maintenance

### Examples

```bash
git commit -m "feat(planets): add biome transition system"

git commit -m "fix(pets): resolve evolution calculation bug

Fixed an issue where pet evolution was calculating
bonuses incorrectly for legendary tier pets.

Closes #123"

git commit -m "docs: add migration guide for TypeScript"
```

### Commit Best Practices

- One logical change per commit
- Write clear, concise messages
- Reference issues when applicable
- Use present tense ("add" not "added")
- Keep subject line under 50 characters
- Add body for complex changes

## Project Structure Guidelines

### Where to Put New Files

**Client-side UI:**
```
src/client/ui/YourUI.ts
```

**Server-side logic:**
```
src/server/managers/YourManager.ts
```

**Shared modules:**
```
src/modules/YourModule.ts
```

**Types and constants:**
```
src/shared/types.ts
src/shared/constants.ts
```

### Imports Organization

Order imports as follows:
```typescript
// 1. External libraries
import { Players, Workspace } from "@rbxts/services";

// 2. Internal modules
import { PlanetManager } from "server/PlanetManager";
import { GrowthModule } from "modules/GrowthModule";

// 3. Types
import type { PlanetState, Resources } from "shared/types";

// 4. Constants
import { GAMEPLAY, BIOMES } from "shared/constants";
```

## Questions?

- Check [SETUP.md](SETUP.md) for environment setup
- See [ARCHITECTURE.md](ARCHITECTURE.md) for system design
- Read [MIGRATION.md](MIGRATION.md) for Lua→TypeScript help
- Ask in Discord or open an issue

---

Thank you for contributing! 🌍
