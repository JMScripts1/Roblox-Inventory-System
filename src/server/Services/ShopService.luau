--!strict
-- Inventory & Shop System by Ruha.luau (github.com/JMScripts1)
-- MIT licensed, see LICENSE. Feel free to remove this header.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyService = require(script.Parent.CurrencyService)
local ItemDefinitions = require(ReplicatedStorage.Shared.ItemDefinitions)
local InventoryService = require(script.Parent.InventoryService)
local ShopService = {}

function ShopService.purchase(plr: Player, itemId: string): boolean
	local def = ItemDefinitions[itemId]

	if not def or CurrencyService.get(plr, def.currency) < def.price then
		return false
	end

	if not InventoryService.add(plr, itemId, 1) then
		return false
	end

	CurrencyService.spend(plr, def.currency, def.price)
	return true
end

return ShopService
