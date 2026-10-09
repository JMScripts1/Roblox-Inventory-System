# Inventory & Shop System

A server-authoritative inventory and shop system for Roblox, written in strictly typed Luau. Built to be dropped into an existing game: items, tunables, and visuals are each configured in one place, and other systems talk to it through a small public API.

> **Status:** in active development. The sections below describe the finished system; see [Roadmap](#roadmap) for what is complete.

<!-- showcase video / gif goes here -->

## Features

- 24-slot grid inventory with drag-and-drop move and swap
- Stackable consumables with per-item stack limits; equipment never stacks
- Equipment slots for Weapon, Armor, and Accessory
- Two currencies: Coins (earned) and Gems (premium)
- Merchant shop with buy and sell-back
- Five rarity tiers, each with its own color
- Hover tooltips showing stats and rarity
- Persistent player data through [ProfileStore](https://github.com/MadStudioRoblox/ProfileStore)

## Integrating it into your game

Everything a game needs to change lives in three modules. None of them require touching gameplay or networking code.

| Module | What it controls |
|---|---|
| `ItemDefinitions` | Every item in the game |
| `Config` | Slot count, sell ratio, currencies, rarities and their colors |
| `Theme` | UI colors, fonts, and corner radius |

Adding an item is a single table entry:

```lua
steel_sword = {
	name = "Steel Sword",
	kind = "Weapon",
	rarity = "Rare",
	price = 450,
	currency = "Coins",
	maxStack = 1,
	icon = "rbxassetid://0",
	stats = { damage = 18 },
},
```

It appears in the shop, the inventory, and tooltips with no other changes.

## Public API

Other server systems can read and change inventories directly:

```lua
InventoryService.add(player, itemId, amount)     -- false if it doesn't all fit; adds nothing
InventoryService.remove(player, itemId, amount)  -- false if they don't have enough; removes nothing
InventoryService.has(player, itemId, amount)
InventoryService.count(player, itemId)
InventoryService.equip(player, slot)
InventoryService.unequip(player, equipSlot)      -- false if the inventory is full

CurrencyService.add(player, currency, amount)
CurrencyService.spend(player, currency, amount)
```

`add` and `remove` are all-or-nothing, so a failed call never leaves an inventory half-changed.

A signal fires whenever a player equips or unequips an item, so a combat or stats system can react without polling:

```lua
InventoryService.EquippedChanged:Connect(function(player, equipSlot, itemId)
	-- itemId is nil when the slot was emptied
end)
```

## Architecture

The client never decides game state. It sends an intent ("buy this item", "move slot 3 to slot 7"), and the server validates and applies it.

Every request goes through the same checks, in order:

1. Rate limit per player, per action
2. Type check every argument
3. Range and existence check (slot bounds, item exists, no NaN or infinity)
4. Permission check (ownership, funds, free space)
5. Apply
6. Send the client only what changed

Player data is stored as item ids, counts, and slot positions. Definitions are never saved, so changing an item's stats or price applies to every existing player.

```
src/
  shared/      definitions, config, theme, types
  server/      DataService, InventoryService, CurrencyService, ShopService
  client/      InventoryController, ShopController, UI components
```

## Running locally

Requires [Rokit](https://github.com/rojo-rbx/rokit) and the [Rojo](https://rojo.space) Studio plugin.

```bash
rokit install
rojo serve
```

Then connect from the Rojo plugin in Studio. The place must be published, with **Enable Studio Access to API Services** turned on under Game Settings → Security, for data to save in Studio.

## Tooling

- **Rojo** for syncing files into Studio
- **luau-lsp** for type checking, with `--!strict` in every module
- **StyLua** for formatting
- **Selene** for linting

## Roadmap

- [x] Data layer and profile template
- [x] Inventory service and public API
- [ ] Shop buy and sell with full validation
- [ ] Placeholder UI
- [ ] Edge cases: persistence, insufficient funds, full inventory, request spam, malformed requests
- [ ] Final UI with themed styling, transitions, tooltips, and drag and drop
