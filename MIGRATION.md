# Lua to TypeScript Migration Guide

This guide helps you convert existing Lua code to TypeScript for use with roblox-ts.

## Table of Contents
1. [Key Differences](#key-differences)
2. [Type System](#type-system)
3. [Common Patterns](#common-patterns)
4. [Module System](#module-system)
5. [Roblox Services](#roblox-services)
6. [Common Pitfalls](#common-pitfalls)

## Key Differences

### Variables and Constants

**Lua:**
```lua
local x = 5
local y = "hello"
local readonly = 10
```

**TypeScript:**
```typescript
let x = 5;              // Mutable
const y = "hello";      // Immutable (preferred)
const readonly = 10;    // Immutable
```

### Functions

**Lua:**
```lua
local function add(a, b)
    return a + b
end

-- Or
local multiply = function(a, b)
    return a * b
end
```

**TypeScript:**
```typescript
function add(a: number, b: number): number {
    return a + b;
}

// Arrow function (preferred)
const multiply = (a: number, b: number): number => {
    return a * b;
};

// Concise arrow function
const multiply = (a: number, b: number) => a * b;
```

### Tables vs Objects/Arrays

**Lua:**
```lua
-- Array-like
local fruits = {"apple", "banana", "orange"}
print(fruits[1])  -- "apple" (1-indexed)

-- Dictionary-like
local person = {
    name = "John",
    age = 30
}
print(person.name)  -- "John"
```

**TypeScript:**
```typescript
// Array (0-indexed!)
const fruits = ["apple", "banana", "orange"];
print(fruits[0]);  // "apple"

// Object
const person = {
    name: "John",
    age: 30
};
print(person.name);  // "John"

// With types
interface Person {
    name: string;
    age: number;
}

const person: Person = {
    name: "John",
    age: 30
};
```

### Classes and OOP

**Lua:**
```lua
local MyClass = {}
MyClass.__index = MyClass

function MyClass.new(name)
    local self = setmetatable({}, MyClass)
    self.name = name
    return self
end

function MyClass:greet()
    print("Hello, " .. self.name)
end

local instance = MyClass.new("Alice")
instance:greet()
```

**TypeScript:**
```typescript
class MyClass {
    private name: string;
    
    constructor(name: string) {
        this.name = name;
    }
    
    greet() {
        print(`Hello, ${this.name}`);
    }
}

const instance = new MyClass("Alice");
instance.greet();
```

## Type System

### Basic Types

**TypeScript:**
```typescript
// Primitives
const num: number = 42;
const str: string = "hello";
const bool: boolean = true;
const nothing: void = undefined;

// Arrays
const numbers: number[] = [1, 2, 3];
const strings: Array<string> = ["a", "b", "c"];

// Tuples
const tuple: [string, number] = ["age", 30];

// Union types
const value: string | number = "hello";  // Can be either

// Literal types
type Direction = "north" | "south" | "east" | "west";
const dir: Direction = "north";
```

### Interfaces

**Lua:**
```lua
-- No native interface support
-- Documentation only
--[=[
    @interface PlanetData
    @field id string
    @field name string
    @field size number
]=]
```

**TypeScript:**
```typescript
interface PlanetData {
    id: string;
    name: string;
    size: number;
    owner?: string;  // Optional property
}

// Usage
const planet: PlanetData = {
    id: "planet-1",
    name: "Earth",
    size: 100
};
```

### Type Aliases

**TypeScript:**
```typescript
// Simple alias
type UserId = number;
type ResourceType = "water" | "minerals" | "energy";

// Complex type
type Resources = {
    [key in ResourceType]: number;
};

// Function type
type Callback = (success: boolean) => void;
```

### Generics

**Lua:**
```lua
-- No generics, uses any type
local function first(array)
    return array[1]
end
```

**TypeScript:**
```typescript
// Generic function
function first<T>(array: T[]): T | undefined {
    return array[0];
}

const num = first([1, 2, 3]);      // Type: number | undefined
const str = first(["a", "b"]);     // Type: string | undefined

// Generic class
class Container<T> {
    private value: T;
    
    constructor(value: T) {
        this.value = value;
    }
    
    getValue(): T {
        return this.value;
    }
}

const numContainer = new Container(42);
const strContainer = new Container("hello");
```

## Common Patterns

### Null Checking

**Lua:**
```lua
local function getName(player)
    if player then
        return player.Name
    end
    return "Unknown"
end
```

**TypeScript:**
```typescript
function getName(player?: Player): string {
    // Optional chaining
    return player?.Name ?? "Unknown";
}

// Or with traditional if
function getName(player?: Player): string {
    if (player) {
        return player.Name;
    }
    return "Unknown";
}
```

### Iteration

**Lua:**
```lua
-- Array iteration
for i, value in ipairs(array) do
    print(i, value)
end

-- Dictionary iteration
for key, value in pairs(dict) do
    print(key, value)
end
```

**TypeScript:**
```typescript
// Array iteration
for (const [index, value] of array) {
    print(index, value);
}

// Simpler array iteration
array.forEach((value, index) => {
    print(index, value);
});

// Object iteration
for (const [key, value] of Object.entries(dict)) {
    print(key, value);
}
```

### String Interpolation

**Lua:**
```lua
local name = "World"
local greeting = "Hello, " .. name .. "!"
```

**TypeScript:**
```typescript
const name = "World";
const greeting = `Hello, ${name}!`;  // Template literals
```

### Error Handling

**Lua:**
```lua
local success, result = pcall(function()
    -- Risky operation
    return doSomething()
end)

if success then
    print("Success:", result)
else
    warn("Error:", result)
end
```

**TypeScript:**
```typescript
try {
    const result = doSomething();
    print("Success:", result);
} catch (error) {
    warn("Error:", error);
}

// Or use pcall for Roblox compatibility
const [success, result] = pcall(() => {
    return doSomething();
});

if (success) {
    print("Success:", result);
} else {
    warn("Error:", result);
}
```

## Module System

### Exporting

**Lua:**
```lua
-- MyModule.lua
local MyModule = {}

function MyModule.doSomething()
    print("Doing something")
end

function MyModule.doAnother()
    print("Doing another")
end

return MyModule
```

**TypeScript:**
```typescript
// MyModule.ts

// Named exports
export function doSomething() {
    print("Doing something");
}

export function doAnother() {
    print("Doing another");
}

// Or export all at once
export {
    doSomething,
    doAnother
};

// Default export (one per file)
export default class MyModule {
    doSomething() {
        print("Doing something");
    }
}
```

### Importing

**Lua:**
```lua
local MyModule = require(script.Parent.MyModule)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedModule = require(ReplicatedStorage.Shared.MyModule)
```

**TypeScript:**
```typescript
// Named imports
import { doSomething, doAnother } from "./MyModule";

// Default import
import MyModule from "./MyModule";

// Import all
import * as MyModule from "./MyModule";

// Roblox services
import { ReplicatedStorage } from "@rbxts/services";

// Import types only
import type { PlanetData } from "./types";
```

## Roblox Services

### Getting Services

**Lua:**
```lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
```

**TypeScript:**
```typescript
import { 
    Players, 
    ReplicatedStorage, 
    TweenService 
} from "@rbxts/services";

// Now use directly
Players.PlayerAdded.Connect((player) => {
    print(`${player.Name} joined!`);
});
```

### Working with Instances

**Lua:**
```lua
local part = Instance.new("Part")
part.Name = "MyPart"
part.Size = Vector3.new(10, 10, 10)
part.Position = Vector3.new(0, 10, 0)
part.Parent = workspace

-- FindFirstChild
local child = workspace:FindFirstChild("MyPart")
if child then
    print("Found:", child.Name)
end
```

**TypeScript:**
```typescript
const part = new Instance("Part");
part.Name = "MyPart";
part.Size = new Vector3(10, 10, 10);
part.Position = new Vector3(0, 10, 0);
part.Parent = Workspace;

// FindFirstChild with type
const child = Workspace.FindFirstChild("MyPart") as Part | undefined;
if (child) {
    print("Found:", child.Name);
}

// WaitForChild
const guaranteed = Workspace.WaitForChild("MyPart") as Part;
```

### Events and Signals

**Lua:**
```lua
local connection = part.Touched:Connect(function(otherPart)
    print("Touched:", otherPart.Name)
end)

-- Disconnect later
connection:Disconnect()
```

**TypeScript:**
```typescript
const connection = part.Touched.Connect((otherPart) => {
    print("Touched:", otherPart.Name);
});

// Disconnect later
connection.Disconnect();
```

### RemoteEvents

**Lua:**
```lua
-- Server
local event = Instance.new("RemoteEvent")
event.Name = "MyEvent"
event.Parent = ReplicatedStorage

event.OnServerEvent:Connect(function(player, data)
    print(player.Name, "sent:", data)
end)

-- Client
local event = ReplicatedStorage:WaitForChild("MyEvent")
event:FireServer({ message = "Hello!" })
```

**TypeScript:**
```typescript
// Server
import { Players, ReplicatedStorage } from "@rbxts/services";

const event = new Instance("RemoteEvent");
event.Name = "MyEvent";
event.Parent = ReplicatedStorage;

event.OnServerEvent.Connect((player, data) => {
    print(player.Name, "sent:", data);
});

// Client
import { ReplicatedStorage } from "@rbxts/services";

const event = ReplicatedStorage.WaitForChild("MyEvent") as RemoteEvent;
event.FireServer({ message: "Hello!" });
```

## Common Pitfalls

### 1. Array Indexing

**❌ Wrong (Lua style):**
```typescript
const arr = [1, 2, 3];
print(arr[1]);  // Prints 2, not 1!
```

**✅ Correct:**
```typescript
const arr = [1, 2, 3];
print(arr[0]);  // Prints 1 (0-indexed)
```

### 2. Table vs Map

**❌ Wrong:**
```typescript
// Don't use objects as dynamic maps
const map: { [key: string]: number } = {};
map["key1"] = 1;
```

**✅ Correct:**
```typescript
// Use Map for dynamic key-value pairs
const map = new Map<string, number>();
map.set("key1", 1);
print(map.get("key1"));  // 1
```

### 3. String Concatenation

**❌ Less ideal:**
```typescript
const name = "World";
const msg = "Hello, " + name + "!";
```

**✅ Preferred:**
```typescript
const name = "World";
const msg = `Hello, ${name}!`;  // Template literals
```

### 4. Type Assertions

**❌ Unsafe:**
```typescript
const value: any = getSomeValue();
value.doSomething();  // No type checking!
```

**✅ Better:**
```typescript
const value = getSomeValue();
if (typeIs(value, "Instance")) {
    value.Destroy();  // Type-safe
}
```

### 5. Nil vs Undefined

**Lua uses `nil`, TypeScript uses `undefined`:**
```typescript
// Check for undefined
if (value !== undefined) {
    // value exists
}

// Optional chaining
const name = player?.Name;  // undefined if player is undefined
```

## Migration Checklist

When converting a Lua file:

- [ ] Change file extension to `.ts`
- [ ] Add type annotations to functions
- [ ] Define interfaces for data structures
- [ ] Convert `local` to `const` or `let`
- [ ] Change `function` to arrow functions where appropriate
- [ ] Update array indexing from 1 to 0
- [ ] Replace `..` concatenation with template literals
- [ ] Import Roblox services from `@rbxts/services`
- [ ] Add proper exports/imports
- [ ] Update module.exports to export statements
- [ ] Test thoroughly!

## Example Migration

### Before (Lua):

```lua
-- PlanetManager.lua
local PlanetManager = {}

function PlanetManager.new()
    local self = {}
    self.planets = {}
    
    function self:createPlanet(userId, name)
        local planet = {
            id = HttpService:GenerateGUID(),
            owner = userId,
            name = name,
            size = 100
        }
        self.planets[userId] = planet
        return planet
    end
    
    return self
end

return PlanetManager
```

### After (TypeScript):

```typescript
// PlanetManager.ts
import { HttpService } from "@rbxts/services";

interface Planet {
    id: string;
    owner: number;
    name: string;
    size: number;
}

export class PlanetManager {
    private planets = new Map<number, Planet>();
    
    createPlanet(userId: number, name: string): Planet {
        const planet: Planet = {
            id: HttpService.GenerateGUID(false),
            owner: userId,
            name: name,
            size: 100
        };
        
        this.planets.set(userId, planet);
        return planet;
    }
    
    getPlanet(userId: number): Planet | undefined {
        return this.planets.get(userId);
    }
}
```

## Resources

- [roblox-ts Documentation](https://roblox-ts.com/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/intro.html)
- [@rbxts/types Documentation](https://github.com/roblox-ts/types)

---

Need help? Check [SETUP.md](SETUP.md) for development environment setup.
