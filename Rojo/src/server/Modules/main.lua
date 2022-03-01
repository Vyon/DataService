-- Services
local players = game:GetService('Players')
local replicated_storage = game:GetService('ReplicatedStorage')

-- Cache
local cache = _G.Cache.Create('Data')

-- Main Module
local datastore = {}

-- Public Functions
function datastore.Fetch(puid: number)
	local tries = 0

	while not cache(puid) do
		tries += 1

		if (tries > 5) then
			warn('[Datastore.Fetch]: Failed to collect player data.')

			return
		end

		task.wait(1)
	end

	return cache(puid)
end

function datastore.Load(player: Instance, profile_store: table)
	assert(typeof(profile_store) == 'table', 'ProfileStore wasn\'t a table!')

	local puid = player.UserId
	local key = tostring(puid)
	local profile = profile_store:LoadProfileAsync(key, 'ForceLoad')

	if (profile) then
        profile:Reconcile() --> Save profile data

		-- Profile is no longer in use do this
        profile:ListenToRelease(function()
            player:Kick('\nFailed to load saved data.\n' .. os.date('Time: %I:%M %p\nDate: %x'))
        end)

		-- Is the player still in the game??
        if (player:IsDescendantOf(players)) then
            cache:Add(puid, profile) --> Add player to the data cache

            return profile
        else
            profile:Release() -- Remove session lock
        end
    else
        player:Kick('\nFailed to create player data.')
    end
end

return datastore
