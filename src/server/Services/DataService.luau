--!strict
-- Inventory & Shop System by Ruha.luau (github.com/JMScripts1)
-- MIT licensed, see LICENSE. Feel free to remove this header.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileStore = require(script.Parent.Parent.Packages.ProfileStore)
local Types = require(ReplicatedStorage.Shared.Types)

local PROFILE_TEMPLATE = {
	Inventory = {} :: { [string]: Types.Slot },
	Equipped = {} :: { [Types.EquipSlot]: Types.ItemId },
	Currency = {
		Coins = 1000,
		Gems = 100,
	},
}

-- renaming this store wipes everyone's data (new store = empty)
local store = ProfileStore.New("PlayerData", PROFILE_TEMPLATE)

local _profiles: { [Player]: typeof(store:StartSessionAsync("", {})) } = {}

local DataService = {}

local function onPlayerAdded(plr: Player)
	local profile = store:StartSessionAsync(tostring(plr.UserId), {
		Cancel = function()
			return plr.Parent ~= Players
		end,
	})
	if not profile then
		plr:Kick("Couldn't load your data, please rejoin")
		return
	end

	profile:AddUserId(plr.UserId)
	profile:Reconcile()
	profile.OnSessionEnd:Connect(function()
		_profiles[plr] = nil
		plr:Kick("Your data session ended, please rejoin")
	end)

	-- StartSessionAsync yields, so the player may have left while it loaded
	if plr.Parent == Players then
		_profiles[plr] = profile
	else
		profile:EndSession()
	end
end

local function onPlayerRemoving(plr: Player)
	local profile = _profiles[plr]
	if profile then
		profile:EndSession()
	end
end

function DataService.get(plr: Player): typeof(PROFILE_TEMPLATE)?
	local profile = _profiles[plr]
	if profile then
		return profile.Data
	else
		return nil
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

for _, plr in Players:GetPlayers() do
	task.spawn(onPlayerAdded, plr)
end

return DataService
