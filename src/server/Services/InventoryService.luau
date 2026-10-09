--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Types = require(ReplicatedStorage.Shared.Types)
local ItemDefinitions = require(ReplicatedStorage.Shared.ItemDefinitions)
local DataService = require(script.Parent.DataService)

local equippedChanged = Instance.new("BindableEvent")

local InventoryService = {}
InventoryService.EquippedChanged = equippedChanged.Event :: RBXScriptSignal<Player, Types.EquipSlot, Types.ItemId?>

local function freeSpace(inv: { [string]: Types.Slot }, itemId: string, maxStack: number): number
	local space = 0
	for i = 1, Config.MAX_SLOTS do
		local slot = inv[tostring(i)]
		if not slot then
			space += maxStack
		elseif slot.itemId == itemId then
			space += maxStack - slot.count
		end
	end
	return space
end

function InventoryService.count(plr: Player, itemId: string): number
	local data = DataService.get(plr)
	if not data then
		return 0
	end

	local total = 0
	for _, slot in data.Inventory do
		if slot.itemId == itemId then
			total += slot.count
		end
	end
	return total
end

function InventoryService.has(plr: Player, itemId: string, amount: number): boolean
	return InventoryService.count(plr, itemId) >= amount
end

function InventoryService.add(plr: Player, itemId: string, amount: number): boolean
	-- a negative amount would quietly subtract from stacks
	assert(amount > 0 and amount % 1 == 0, "amount must be a positive integer")
	local data = DataService.get(plr)
	if not data then
		return false
	end

	local inv = data.Inventory
	local def = ItemDefinitions[itemId]
	if freeSpace(inv, itemId, def.maxStack) < amount then
		return false
	end

	local remaining = amount

	for i = 1, Config.MAX_SLOTS do
		local slot = inv[tostring(i)]
		if slot and slot.itemId == itemId then
			local added = math.min(remaining, def.maxStack - slot.count)
			slot.count += added
			remaining -= added
		end
	end

	for i = 1, Config.MAX_SLOTS do
		if remaining == 0 then
			break
		end
		local key = tostring(i)
		if not inv[key] then
			local added = math.min(remaining, def.maxStack)
			inv[key] = { itemId = itemId, count = added }
			remaining -= added
		end
	end

	return true
end

function InventoryService.remove(plr: Player, itemId: string, amount: number): boolean
	-- a negative amount would add items instead (dupe)
	assert(amount > 0 and amount % 1 == 0, "amount must be a positive integer")
	local data = DataService.get(plr)
	if not data or not InventoryService.has(plr, itemId, amount) then
		return false
	end

	local inv = data.Inventory
	local remaining = amount

	for i = Config.MAX_SLOTS, 1, -1 do
		local key = tostring(i)
		local slot = inv[key]
		if slot and slot.itemId == itemId then
			local taken = math.min(remaining, slot.count)
			slot.count -= taken
			remaining -= taken
			if slot.count == 0 then
				inv[key] = nil
			end
			if remaining == 0 then
				break
			end
		end
	end

	return true
end

function InventoryService.equip(plr: Player, slotKey: string): boolean
	local data = DataService.get(plr)
	if not data then
		return false
	end

	local slot = data.Inventory[slotKey]
	if not slot then
		return false
	end

	local def = ItemDefinitions[slot.itemId]
	if def.kind == "Consumable" then
		return false
	end

	local equipSlot: Types.EquipSlot = def.kind
	local old = data.Equipped[equipSlot]
	data.Equipped[equipSlot] = slot.itemId

	if old then
		data.Inventory[slotKey] = { itemId = old, count = 1 }
	else
		data.Inventory[slotKey] = nil
	end

	equippedChanged:Fire(plr, equipSlot, slot.itemId)

	return true
end

function InventoryService.unequip(plr: Player, equipSlot: Types.EquipSlot): boolean
	local data = DataService.get(plr)
	if not data then
		return false
	end

	local itemId = data.Equipped[equipSlot]
	if not itemId then
		return false
	end

	if not InventoryService.add(plr, itemId, 1) then
		return false
	end
	data.Equipped[equipSlot] = nil
	equippedChanged:Fire(plr, equipSlot, nil)

	return true
end

return InventoryService
