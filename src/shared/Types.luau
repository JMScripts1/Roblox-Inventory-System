--!strict
-- Inventory & Shop System by Ruha.luau (github.com/JMScripts1)
-- MIT licensed, see LICENSE. Feel free to remove this header.
export type ItemId = string
export type Rarity = "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary"
export type Currency = "Coins" | "Gems"
export type ItemKind = "Weapon" | "Armor" | "Accessory" | "Consumable"
export type EquipSlot = "Weapon" | "Armor" | "Accessory"

export type ItemDef = {
	name: string,
	kind: ItemKind,
	rarity: Rarity,
	price: number,
	currency: Currency,
	maxStack: number,
	icon: string,
	stats: { [string]: number }?,
}

export type Slot = {
	itemId: ItemId,
	count: number,
}

return {}
