# 🎰 Temp's Casino & Entertainment Hub

A comprehensive casino and entertainment system for FiveM servers featuring blackjack, dynamic AI NPCs, and an integrated shop system.

## 📋 Features
- 🎲 Realistic Blackjack Game with card emojis
- 🤖 Dynamic AI System with multiple behaviors
- 🏪 Integrated Shop with budtender
- 💃 Static Dancers
- 📺 Props System

## ⚙️ Configuration Guide

### AI System Configuration (`config.lua`)
```lua
Config.AI = {
    SpawnLocation = vector4(1992.083, 3055.646, 46.215, 187.6515), -- AI spawn point
    MaxPeds = 5,          -- Maximum number of AI peds at once
    SpawnDistance = 30.0, -- Distance to activate spawning
    DespawnDistance = 50.0, -- Distance to remove AI
    SpawnInterval = 480000, -- Spawn check interval (8 minutes)
    SpawnChance = 75,     -- Chance to spawn (%)
    CheckInterval = 1000,  -- How often to check for spawns
    BarRadius = 20.0,     -- Area radius for AI activity
    
    -- Customize AI behavior chances
    Behaviors = {
        {name = "friendly", chance = 40},
        {name = "aggressive", chance = 20},
        {name = "dancer", chance = 40}
    }
}
```

### Static NPCs Configuration
```lua
Config.Dancers = {
    {
        model = "a_f_y_hippie_01",
        coords = vector4(x, y, z, heading),
        animation = {
            dict = "mini@strip_club@private_dance@part1",
            name = "priv_dance_p1"
        }
    }
}

Config.Budtender = {
    model = "a_f_y_hippie_01",
    coords = vector4(x, y, z, heading),
    animation = {
        dict = "amb@world_human_aa_smoke@male@idle_a",
        name = "idle_c"
    }
}
```

### Shop Configuration
```lua
Config.ShopItems = {
    {
        name = "item_name",
        price = 10,
        label = "Display Name",
        icon = "fas fa-icon",
        description = "Item description"
    }
}
```

### Props Configuration
```lua
Config.Props = {
    {
        model = "prop_tv_flat_01",
        coords = vector4(x, y, z, heading)
    }
}
```

## 🎲 Blackjack Features
- Custom betting amounts (minimum $50)
- Realistic card gameplay with emojis
- Double down option
- Detailed match results
- Vegas rules (dealer hits on 16, stands on 17)

## 🤖 AI System Features
- Dynamic NPC spawning based on player proximity
- Three behavior types:
  - Friendly NPCs that interact with players
  - Aggressive NPCs that might attack
  - Dancers that alternate between dancing and following
- Smart spawn system with configurable intervals
- Automatic cleanup when players leave area

## 🏪 Shop System
- Integrated with ox_target
- Animated budtender NPC
- Purchasable items:
  - Joints
  - Tosti (sandwiches)
  - Magic Mushrooms
  - XTC
  - Whiskey
- Color-coded items
- Purchase confirmation dialog

## 📥 Installation
1. Place in your resources folder
2. Add to server.cfg:


## 📋 Dependencies
- QB-Core Framework
- ox_lib
- ox_target

## ⚠️ Important Notes
- Ensure all dependencies are up to date
- Configure item names to match your server's inventory system
- Adjust coordinates to fit your casino location
- Test AI spawn points to ensure proper pathing

## 🔧 Performance Tips
- Adjust `CheckInterval` based on server performance
- Modify `MaxPeds` to control AI density
- Adjust `SpawnInterval` to balance NPC presence
- Configure `SpawnChance` to control spawn frequency

## 🎮 Controls
- Use ox_target to interact with the budtender
- Standard blackjack controls through UI menus
- Automatic AI interaction in bar area

## 💾 Version
Current Version: 1.0.0