--[[
    Types.lua
    Type definitions and data structures for Grow a Planet
    
    This module defines all shared types used across client and server.
    Keep this synchronized with game logic changes.
]]

export type BiomeType = "Barren" | "Rocky" | "Oceanic" | "Forest"

export type Resources = {
    water: number,
    minerals: number,
    energy: number,
    biomass: number,
}

export type PlanetState = {
    userId: number,
    level: number,
    experience: number,
    biome: BiomeType,
    size: number,
    temperature: number,
    atmosphere: number,
    resources: Resources,
    lastUpdated: number,
}

export type UpgradeConfig = {
    id: string,
    name: string,
    description: string,
    cost: Resources,
    unlockLevel: number,
    maxLevel: number,
    effectType: "ResourceRate" | "ResourceCap" | "Biome" | "Size",
    effectValue: number,
}

export type PetData = {
    id: string,
    name: string,
    rarity: "Common" | "Rare" | "Epic" | "Legendary" | "Mythical",
    level: number,
    experience: number,
    resourceBonus: number,
    specialAbility: string?,
}

return {}
