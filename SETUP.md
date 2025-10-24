# Development Setup Guide

## Prerequisites

Before you begin, ensure you have the following installed:

### Required
- **[Node.js](https://nodejs.org/)** (v18 or higher)
  - Includes npm for package management
  - Verify: `node --version` and `npm --version`

- **[Roblox Studio](https://www.roblox.com/create)**
  - Latest version from roblox.com
  - Required for testing and publishing

- **[Rojo](https://rojo.space/docs/installation/)**
  - Syncs code from filesystem to Roblox Studio
  - Install via: `cargo install rojo` or download binary
  - Verify: `rojo --version`

- **[Wally](https://wally.run/install)**
  - Package manager for Roblox
  - Used to install Knit and other dependencies
  - Install via: `cargo install wally` or download binary
  - Verify: `wally --version`

- **[roblox-ts](https://roblox-ts.com/)**
  - TypeScript-to-Luau compiler
  - Installed via npm (see below)

### Framework
- **[Knit](https://github.com/Sleitnick/Knit)**
  - Lightweight game framework for Roblox
  - Installed via Wally (see below)
  - Provides Service/Controller architecture

### Optional but Recommended
- **[Git](https://git-scm.com/)**
  - Version control
  - Verify: `git --version`

- **[Visual Studio Code](https://code.visualstudio.com/)**
  - Recommended editor
  - Extensions: ESLint, Prettier, roblox-ts

## Initial Setup

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/grow-a-planet.git
cd grow-a-planet
```

### 2. Install npm Dependencies
```bash
npm install
```

This will install:
- `roblox-ts` - TypeScript compiler
- `@rbxts/types` - Roblox type definitions
- `@rbxts/services` - Roblox services
- `@rbxts/knit` - Knit framework for TypeScript
- `@rbxts/promise` - Promise library
- Development tools (ESLint, Prettier)

### 3. Install Wally Dependencies
```bash
wally install
```

This will install:
- `Knit` - Game framework (Services/Controllers)
- `Promise` - Async handling
- `Signal` - Event handling
- Other Roblox packages

**Note:** Wally installs packages to `Packages/` folder which is synced to ReplicatedStorage via Rojo.

### 4. Install Rojo Plugin
1. Open Roblox Studio
2. Go to the Plugin Marketplace
3. Search for "Rojo"
4. Install the official Rojo plugin

### 5. Verify Installation
```bash
# Check all tools are installed
node --version        # Should be v18+
npm --version         # Should be 9+
wally --version       # Should be 0.3+
rojo --version        # Should be 7.x
npx rbxtsc --version  # Should be 2.x
```

## Development Workflow

### Starting Development

#### Option 1: Automatic (Recommended)
Start both TypeScript compiler and Rojo in watch mode:
```bash
npm run dev
```

This runs:
- TypeScript compiler in watch mode (compiles .ts → .lua)
- Rojo server (syncs to Roblox Studio)

#### Option 2: Manual
In separate terminals:

**Terminal 1 - TypeScript Compiler:**
```bash
npm run watch
```

**Terminal 2 - Rojo Server:**
```bash
rojo serve
```

### Connecting to Roblox Studio

1. **Start the Rojo server** (via `npm run dev` or `rojo serve`)
2. **Open Roblox Studio**
3. **Click the Rojo plugin button** in the toolbar
4. **Click "Connect"**
5. Studio will sync with your local files

You should see output like:
```
Rojo server listening:
  Address: localhost
  Port:    34872
```

### Making Changes

1. **Edit TypeScript files** in `src/`
   - Changes auto-compile to Lua in `out/`
   
2. **Rojo auto-syncs** to Roblox Studio
   - See changes instantly in Studio

3. **Test in Studio**
   - Press F5 to run the game
   - Check Output window for logs

### Building for Production

Compile TypeScript to Lua:
```bash
npm run build
```

Build a Roblox place file:
```bash
rojo build -o GrowPlanet.rbxlx
```

## Project Structure

```
grow-a-planet/
├── src/
│   ├── client/                    # Client-side TypeScript
│   │   ├── init.client.ts         # Client entry point (starts Knit)
│   │   └── controllers/           # Knit Controllers
│   │       ├── PlanetController.ts
│   │       └── PetController.ts
│   ├── server/                    # Server-side TypeScript
│   │   ├── init.server.ts         # Server entry point (starts Knit)
│   │   └── services/              # Knit Services
│   │       ├── PlanetService.ts
│   │       ├── PetService.ts
│   │       └── DataService.ts
│   ├── modules/                   # Shared game logic
│   │   ├── GrowthModule.ts
│   │   └── EcosystemModule.ts
│   └── shared/                    # Shared types & constants
│       ├── types.ts
│       └── constants.ts
├── out/                           # Compiled Lua (auto-generated)
├── Packages/                      # Wally packages (auto-generated)
│   ├── _Index/
│   └── Knit/
├── docs/                          # Documentation
│   ├── REFERENCE.md              # Game design document
│   └── TECHNICAL.md              # Technical specification
├── assets/                        # Models, meshes, etc.
├── tsconfig.json                  # TypeScript config
├── wally.toml                     # Wally dependencies
├── package.json                   # npm dependencies
└── rojo.json                      # Rojo project config
```

## Common Tasks

### Adding a New Service (Server)
1. Create file in `src/server/services/MyService.ts`
2. Use Knit's CreateService pattern

Example:
```typescript
// src/server/services/MyService.ts
import { KnitServer as Knit } from "@rbxts/knit";

const MyService = Knit.CreateService({
    Name: "MyService",
    
    // Client-exposed methods
    Client: {
        DoSomething(player: Player) {
            return this.Server.serverMethod();
        }
    },
    
    // Server-only methods
    serverMethod() {
        print("Hello from server!");
        return true;
    }
});

export = MyService;
```

### Adding a New Controller (Client)
1. Create file in `src/client/controllers/MyController.ts`
2. Use Knit's CreateController pattern

Example:
```typescript
// src/client/controllers/MyController.ts
import { KnitClient as Knit } from "@rbxts/knit";

const MyController = Knit.CreateController({
    Name: "MyController",
    
    KnitStart() {
        // Get server service
        const MyService = Knit.GetService("MyService");
        
        // Call server method
        MyService.DoSomething().then((result) => {
            print("Got result:", result);
        });
    }
});

export = MyController;
```

### Adding a New Module
1. Create file in `src/modules/MyModule.ts`
2. Write pure functions or utility classes
3. Export your module

Example:
```typescript
// src/modules/MyModule.ts
export namespace MyModule {
    export function doSomething(value: number): number {
        return value * 2;
    }
}

// Usage in Service or Controller
import { MyModule } from "modules/MyModule";
const result = MyModule.doSomething(5);
```

### Installing Roblox Packages

**Via npm (for TypeScript packages):**
```bash
npm install @rbxts/roact
npm install @rbxts/rodux
```

**Via Wally (for Lua packages):**
```bash
# Add to wally.toml
[dependencies]
MyPackage = "owner/package@version"

# Then install
wally install
```

### Code Formatting
Format all TypeScript files:
```bash
npm run format
```

### Linting
Check for code issues:
```bash
npm run lint
```

## Troubleshooting

### "Cannot find module '@rbxts/...'"
**Solution:** Install dependencies
```bash
npm install
```

### TypeScript not compiling
**Solution:** Check for errors
```bash
npm run build
```

### Rojo not connecting
**Solution:**
1. Make sure Rojo server is running
2. Check the port in Rojo plugin matches `rojo.json`
3. Restart Roblox Studio

### Changes not appearing in Studio
**Solution:**
1. Check TypeScript compiled successfully (no errors)
2. Verify Rojo is connected (green indicator)
3. Try disconnecting and reconnecting Rojo

### "Module not found" in Studio
**Solution:**
- Ensure file paths match the structure in `rojo.json`
- Check that Rojo synced the files
- Look in ReplicatedStorage/ServerScriptService for your modules

## Best Practices

### File Naming
- Use PascalCase for classes: `PlanetManager.ts`
- Use camelCase for utilities: `utils.ts`
- Use `.client.ts` for client scripts
- Use `.server.ts` for server scripts

### Type Safety
- Always define types for function parameters
- Use interfaces for complex objects
- Avoid `any` type when possible

### Organization
- Keep client code in `src/client/`
- Keep server code in `src/server/`
- Put shared code in `src/modules/` or `src/shared/`
- Use barrel exports (`index.ts`) for cleaner imports

### Testing
- Test frequently in Roblox Studio (F5)
- Use `print()` for debugging
- Check Output window for errors

## VS Code Setup (Recommended)

### Recommended Extensions
1. **ESLint** - Code linting
2. **Prettier** - Code formatting
3. **roblox-ts** - Syntax highlighting & IntelliSense

### VS Code Settings
Add to `.vscode/settings.json`:
```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "typescript.tsdk": "node_modules/typescript/lib"
}
```

## Next Steps

- Read [ARCHITECTURE.md](ARCHITECTURE.md) for system design
- Review [TECHNICAL.md](docs/TECHNICAL.md) for module details
- Check [MIGRATION.md](MIGRATION.md) for Lua→TypeScript patterns
- See [CONTRIBUTING.md](CONTRIBUTING.md) for code standards

## Getting Help

- **Documentation:** Check the `docs/` folder
- **Issues:** Report bugs on GitHub Issues
- **Discord:** Join our development server
- **roblox-ts Docs:** https://roblox-ts.com/

---

Happy coding! 🚀
