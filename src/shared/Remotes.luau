--!strict
-- Inventory & Shop System by Ruha.luau (github.com/JMScripts1)
-- MIT licensed, see LICENSE. Feel free to remove this header.
local RunService = game:GetService("RunService")

local Remotes = {}

local function getRemote(name: string): RemoteEvent
	if RunService:IsServer() then
		local remote = Instance.new("RemoteEvent")

		remote.Name = name
		remote.Parent = script

		return remote
	else
		return script:WaitForChild(name) :: RemoteEvent
	end
end

Remotes.PurchaseItem = getRemote("PurchaseItem")
Remotes.SellItem = getRemote("SellItem")
Remotes.InventoryUpdate = getRemote("InventoryUpdate")

return Remotes
