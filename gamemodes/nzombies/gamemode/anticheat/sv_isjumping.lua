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

-- Garry's Mod has NO IsJumping() function
-- so this needs to be done..
local PLAYER = FindMetaTable("Player")
AccessorFunc(PLAYER, "bIsJumping", "IsJumping", FORCE_BOOL)

hook.Add("DoAnimationEvent", "IsJumpingHook", function(ply, event)
    if (event == PLAYERANIMEVENT_JUMP) then
        ply:SetIsJumping(true)
        timer.Simple(0.6, function()
            if !IsValid(ply) then return end
            ply:SetIsJumping(false)
        end)
    end
end)
