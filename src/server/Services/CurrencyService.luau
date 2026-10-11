--!strict
-- Inventory & Shop System by Ruha.luau (github.com/JMScripts1)
-- MIT licensed, see LICENSE. Feel free to remove this header.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage.Shared.Types)
local DataService = require(script.Parent.DataService)

local CurrencyService = {}

function CurrencyService.get(plr: Player, currency: Types.Currency): number
	local data = DataService.get(plr)
	if not data then
		return 0
	end

	return data.Currency[currency]
end

function CurrencyService.add(plr: Player, currency: Types.Currency, amount: number): boolean
	-- so you cant add 0.5 or negative money.
	assert(amount > 0 and amount % 1 == 0, "amount must be a positive integer")
	local data = DataService.get(plr)
	if not data then
		return false
	end

	data.Currency[currency] += amount
	return true
end

function CurrencyService.spend(plr: Player, currency: Types.Currency, amount: number): boolean
	-- So you cant spend negative money, or .5
	assert(amount > 0 and amount % 1 == 0, "amount must be a positive integer")
	local data = DataService.get(plr)

	if not data then
		return false
	end
	if data.Currency[currency] < amount then
		return false
	end

	data.Currency[currency] -= amount
	return true
end
return CurrencyService
