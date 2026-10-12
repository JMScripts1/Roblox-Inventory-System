--!strict
-- Inventory & Shop System by Ruha.luau (github.com/JMScripts1)
-- MIT licensed, see LICENSE. Feel free to remove this header.
local Types = require(script.Parent.Types)

local ItemDefinitions: { [Types.ItemId]: Types.ItemDef } = {
	wooden_sword = {
		name = "Wooden Sword",
		kind = "Weapon",
		rarity = "Common",
		price = 50,
		currency = "Coins",
		maxStack = 1,
		icon = "rbxassetid://0",
		stats = { damage = 5 },
	},

	iron_sword = {
		name = "Iron Sword",
		kind = "Weapon",
		rarity = "Rare",
		price = 450,
		currency = "Coins",
		maxStack = 1,
		icon = "rbxassetid://0",
		stats = { damage = 10 },
	},

	dragon_blade = {
		name = "Dragon Blade",
		kind = "Weapon",
		rarity = "Legendary",
		price = 250,
		currency = "Gems",
		maxStack = 1,
		icon = "rbxassetid://0",
		stats = { damage = 50 },
	},

	leather_armor = {
		name = "Leather Armor",
		kind = "Armor",
		rarity = "Common",
		price = 80,
		currency = "Coins",
		maxStack = 1,
		icon = "rbxassetid://0",
		stats = { defense = 5 },
	},

	knight_armor = {
		name = "Knight Armor",
		kind = "Armor",
		rarity = "Epic",
		price = 1200,
		currency = "Coins",
		maxStack = 1,
		icon = "rbxassetid://0",
		stats = { defense = 20 },
	},

	silver_ring = {
		name = "Silver Ring",
		kind = "Accessory",
		rarity = "Uncommon",
		price = 150,
		currency = "Coins",
		maxStack = 1,
		icon = "rbxassetid://0",
		stats = { speed = 5 },
	},

	health_potion = {
		name = "Health Potion",
		kind = "Consumable",
		rarity = "Common",
		price = 25,
		currency = "Coins",
		maxStack = 20,
		icon = "rbxassetid://0",
		stats = { healthRestore = 50 },
	},

	mana_potion = {
		name = "Mana Potion",
		kind = "Consumable",
		rarity = "Common",
		price = 25,
		currency = "Coins",
		maxStack = 20,
		icon = "rbxassetid://0",
		stats = { manaRestore = 50 },
	},
}

-- a bad definition should stop the server on startup, not fail halfway through a purchase
for itemId, def in ItemDefinitions do
	assert(def.price >= 1 and def.price % 1 == 0, `{itemId}: price must be a positive integer`)
	assert(def.maxStack >= 1 and def.maxStack % 1 == 0, `{itemId}: maxStack must be a positive integer`)
	-- equipping moves the whole slot, so a stack of equipment would lose the rest
	assert(def.kind == "Consumable" or def.maxStack == 1, `{itemId}: equipment must have maxStack 1`)
end

-- freeze is shallow, so lock each def and its stats too
for _, def in ItemDefinitions do
	table.freeze(def)
	if def.stats then
		table.freeze(def.stats)
	end
end

return table.freeze(ItemDefinitions)
