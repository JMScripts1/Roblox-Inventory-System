--!strict
-- Inventory & Shop System by Ruha.luau (github.com/JMScripts1)
-- MIT licensed, see LICENSE. Feel free to remove this header.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local ItemDefinitions = require(ReplicatedStorage.Shared.ItemDefinitions)
local CurrencyService = require(script.Parent.CurrencyService)
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

function ShopService.sell(plr: Player, itemId: string): boolean
	local def = ItemDefinitions[itemId]

	if not def then
		return false
	end

	if not InventoryService.remove(plr, itemId, 1) then
		return false
	end
	local payment = math.floor(def.price * Config.SELL_RATIO)
	CurrencyService.add(plr, def.currency, payment)

	return true
end

return ShopService
