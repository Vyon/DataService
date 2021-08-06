-- Services
local players = game:GetService('Players')

-- Locals
local modules = script.Parent.Modules

-- Modules
local data = require(modules.main)

players.PlayerAdded:Connect(function(player)
	local profile = data.Load(player)

	print(profile)
end)

players.PlayerAdded:Connect(function(player)
	data.Release(player)
end)