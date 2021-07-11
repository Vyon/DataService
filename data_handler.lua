-- Services
local players = game:GetService('Players')

-- Modules
local ps = require(script.Parent.ps)
local Settings = require(script.Parent.settings)

-- Data Store Stuff
local store = ps.GetProfileStore(Settings.store_name, Settings.store_base)

-- Variables
local data = {}
local Cache = {}

-- Module Functions
function data.Load(player)
	local profile = store:LoadProfileAsync(tostring(player.UserId), 'ForceLoad') -- Forceloads a player's data
		
	if (profile) then -- Checks if the profile exists
		profile:Reconcile() -- Saves Data
		profile:ListenToRelease(function() -- Will listen for profile release
			Cache[player] = nil -- When released sets the players data in the cache to nil
			player:Kick('\nUnable to load data, please rejoin.')
		end)
		if (players[player.Name]) then -- Checks if the player is still a child of 'Players'
			Cache[player] = profile.Data -- Adds the player and their data to the cache
			return Cache[player]
		else
			profile:Release() -- Removes session lock and saves data
		end
	else
		player:Kick('\nFailure to load data.\n' .. os.date('Time: %I:%M %p\nDate: %x'))
	end
end

function data.Fetch(player)
	if (Cache[player]) then -- Checks if the player is nil
		return Cache[player]
	else
		warn(player.Name, 'is not in the cache.')
	end
end

function data.Release(player)
	local profile = Cache[player]
	if (profile) then
		profile:Release()
	end
end

return data