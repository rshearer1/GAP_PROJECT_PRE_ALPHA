# 🌍 Grow a Planet

An engaging Roblox experience where players nurture their own planet from a barren rock to a thriving civilization. Collect resources, evolve pets, unlock upgrades, and build a unique world in this casual yet deep simulation game.

Built with **TypeScript** using [roblox-ts](https://roblox-ts.com/) for type-safe development.

![Planet Growth Stages](https://via.placeholder.com/800x200.png?text=Planet+Evolution+Stages)

## ✨ Features

- 🌱 **Planet Evolution**: Transform your barren planet through multiple stages of development
- 🐉 **Cosmic Pets**: Collect and evolve unique space creatures that help your planet grow
- 🏙️ **City Building**: Develop civilizations and watch them thrive
- 🌋 **Dynamic Events**: Handle natural disasters and alien encounters
- 🤝 **Social Features**: Trade pets and resources with friends
- 🎮 **Cross-Platform**: Full support for both desktop and mobile devices

## 🚀 Development Setup

### Prerequisites

- [Node.js](https://nodejs.org/) (v18 or higher) - for npm and roblox-ts
- [Roblox Studio](https://www.roblox.com/create) - latest version
- [Rojo](https://rojo.space/docs/installation/) - for syncing code to Studio

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/grow-a-planet.git
cd grow-a-planet
```

2. Install npm dependencies:
```bash
npm install
```

This installs:
- `roblox-ts` - TypeScript to Luau compiler
- `@rbxts/types` - Roblox type definitions
- `@rbxts/services` - Roblox services
- Development tools (ESLint, Prettier)

3. Start development server:
```bash
npm run dev
```

This starts both the TypeScript compiler and Rojo server in watch mode.

4. Connect to Rojo from within Roblox Studio:
- Open Roblox Studio
- Install the Rojo plugin if you haven't already
- Click the Rojo button in Studio
- Click "Connect"

For detailed setup instructions, see [SETUP.md](SETUP.md).

### Project Structure

```
grow-a-planet/
├── src/
│   ├── client/         # Client-side TypeScript
│   │   ├── init.client.ts
│   │   └── ui/
│   ├── server/         # Server-side TypeScript
│   │   ├── init.server.ts
│   │   └── managers/
│   ├── modules/        # Shared game modules
│   └── shared/         # Shared types & constants
│       ├── types.ts
│       └── constants.ts
├── out/                # Compiled Lua output (auto-generated)
├── docs/               # Documentation
│   ├── REFERENCE.md    # Game design document
│   └── TECHNICAL.md    # Technical specification
├── assets/             # Models, meshes, etc.
├── tsconfig.json       # TypeScript configuration
├── package.json        # npm dependencies
└── rojo.json          # Rojo project file
```

## 📖 Documentation

- **[Setup Guide](SETUP.md)** - Complete development environment setup
- **[Architecture](ARCHITECTURE.md)** - System design and data flow
- **[Migration Guide](MIGRATION.md)** - Converting Lua to TypeScript
- **[Contributing](CONTRIBUTING.md)** - Code standards and workflow
- **[Game Reference](docs/REFERENCE.md)** - Game design document
- **[Technical Spec](docs/TECHNICAL.md)** - Module implementation details

## 🔧 Development Workflow

### Development Mode
```bash
npm run dev
```
Starts TypeScript compiler and Rojo server in watch mode. Changes auto-compile and sync to Studio.

### TypeScript Compilation
```bash
npm run build    # Compile once
npm run watch    # Watch mode
```

### Code Quality
```bash
npm run lint     # Check for issues
npm run format   # Format code
```

### Testing
- Run game in Studio (F5)
- Check Output window for logs
- Test with multiple clients

### Building for Release
```bash
npm run build              # Compile TypeScript
rojo build -o GrowPlanet.rbxlx  # Build place file
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed workflow and code standards.

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🎮 Play the Game

Visit [Grow a Planet on Roblox](https://www.roblox.com/games/yourgameid/Grow-a-Planet) to play!

## 🌟 Support

- Join our [Discord server](https://discord.gg/yourdiscord)
- Follow development on our [DevForum post](https://devforum.roblox.com/t/grow-a-planet)
- Report bugs through [GitHub Issues](https://github.com/yourusername/grow-a-planet/issues)

---
Made with ❤️ for the Roblox community