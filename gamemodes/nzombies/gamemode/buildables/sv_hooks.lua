--[[ LICENSE HEADER MANAGED BY add-license-header

Copyright (C) 2014-2015 Alig96
Copyright (C) 2015-2017 Zet0rz
Copyright (C) 2016-2017 lolleko
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


-- Reset all parts since the game is over
hook.Add("OnRoundEnd", "ResetBuildableStuff", function()
    nzParts:ResetAll()
    nzBenches:ResetAll()
    nzParts.Network:RemoveAll()
end)

-- Ensure only 1 part model of each exists at a time
hook.Add("OnGameBegin", "StartBuildableStuff", function() -- Make sure only 1 buildable of the same model can exist, they only existed prior for Creative Mode
    for _,v in pairs(ents.FindByClass("nz_workbench_prop")) do
        v:Enable()
    end
   
    nzParts:ResetAll()
    nzBenches:ResetAll()
    nzParts:KeepOneOfEach()
    nzParts.Network:RemoveAll()
end)

-- On player downed
hook.Add("PlayerDowned", "nzDropWorkbenchItems", function(ply)
    if IsValid(ply) and ply:IsPlayer() then 
	    ply:DropParts(ply:GetParts()) 
    end
end)

-- Players disconnecting/dropping out need to reset the item so it isn't lost forever
hook.Add("OnPlayerDropOut", "nzResetWorkbenchItems", function(ply)
	ply:DropParts(ply:GetParts(), true)
end)

-- Give shared parts to new players
local function InitParts(ply)
    timer.Simple(1, function()
        nzParts.Network:InitForPlayer(ply)
    end)
end
hook.Add("PlayerSpawn", "nzShareNewWorkbenchItems", InitParts)
hook.Add("PlayerAuthed", "nzInitWorkbenchItems", InitParts)
