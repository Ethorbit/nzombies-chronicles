--[[ LICENSE HEADER MANAGED BY add-license-header

Copyright (C) 2014-2015 Alig96
Copyright (C) 2015-2017 Zet0rz
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

local nothing = {
    "invis_wall",
    "invis_wall_zombie",
    "wall_block",
    "wall_block_zombie"
}

-- Controls purchasing entities that are visible, think of it as secondary :Use() functionality, but more flexible
-- and allows buying through invisible walls, wall_blocks, etc
hook.Add("KeyPress", "PlayerUsedSomething", function(ply, key)
    if (ply:GetNotDowned() and key == IN_USE) then
        local ent = util.TraceLine({
            start = ply:GetShootPos(),
            endpos = ply:GetShootPos() + ply:GetAimVector() * 90,
            filter = function(ent)
                if (ent != ply) then
                    if (IsValid(ent) and !nothing[ent:GetClass()] and ent:GetClass() == "easter_egg" or isfunction(ent.GetPrice) and ent:GetClass() != "power_box") then
                        if (!isnumber(ply.lastInvisUseTime) or isnumber(ply.lastInvisUseTime) and CurTime() > ply.lastInvisUseTime) then
                            ply.lastInvisUseTime = CurTime() + 0.3
                            
                            if ply:CanUse() then
                                ent:Use(ply, ply, USE_ON)
                            end
                        end
                    end
                end
            end,
            mask = MASK_SOLID || MASK_VISIBLE_AND_NPCS
        }).Entity
    end
end)

-- Block (NORMAL) use
hook.Add("PlayerUse", "NZNoUseWithSpecialWeps", function(ply, ent)
    return ply:CanUse()
end)
