--[[ LICENSE HEADER MANAGED BY add-license-header

Copyright (C) 2014-2015 Alig96
Copyright (C) 2015-2022 Zet0rz
Copyright (C) 2020-2025 Ethorbit

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
--]]

if SERVER then
    util.AddNetworkString("nz_PlayerInit")
    net.Receive("nz_PlayerInit", function(len, ply)
                -- Vulnerability fixed by Ethorbit
        if ply.NZFullyInitialized then return end
        ply.NZFullyInitialized = true

        hook.Call("PlayerFullyInitialized", nil, ply)
    end)
    
    hook.Add("PlayerInitialSpawn", "nzCheckIfInSteamGroup", function(ply)
        ply.nz_InSteamGroup = false -- No you don't get special stuff just for being in a group!
        -- I consder this a backdoor due to its secretive nature and injecting weapons into the box based on the return of an HTTP Request.
        -- Sorry, but I had to comment this out for the good of preserving the COD Zombies experience. We are open to friendlier alternatives.
    --  -- I ask of you that you do not remove the below part. This part was made as a reward for being part of my Steam Group.
    --  -- Since this reward is to be used universally on all servers, I ask of you that you do not remove it. Thank you :)
    --  http.Fetch( "http://steamcommunity.com/groups/the_banter_brigade/memberslistxml/?xml=1",
    --      function(body) -- On Success
    --          local playerIDStartIndex = ply:SteamID64() and string.find( tostring(body), "<steamID64>"..ply:SteamID64().."</steamID64>" ) or print("Can't get SteamID64 in single player. Weaponized YTi-L4 is unavailable.")
    --          if playerIDStartIndex == nil then return else
    --              ply.nz_InSteamGroup = true
    --              ply:PrintMessage(HUD_PRINTCONSOLE, "Thank you for being part of the Banter Brigade Steam Group. YTi-L4 is accessible to you in the box.")
    --          end
    --      end,
    --      function() -- On fail
    --          print("Couldn't get it the data from the Banter Brigade Steam Group. Weaponized YTi-L4 is unavailable")
    --      end
    --  )
    end)
    
    hook.Add("PlayerFullyInitialized", "SetPlayerClassInit", function(ply)
        player_manager.SetPlayerClass( ply, "player_ingame" )
    end)
else
    hook.Add("InitPostEntity", "PlayerFullyInitialized", function()
        net.Start("nz_PlayerInit")
        net.SendToServer()
    end)

end
