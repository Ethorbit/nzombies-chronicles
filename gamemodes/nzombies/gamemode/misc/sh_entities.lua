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

-- Entity misc functions created by Ethorbit,
-- for functions that edit a specific entity or
-- group of entities that don't really belong in
-- the ENTITY meta table.

-- Move spawns, added because Map Scripts for maps like nz_winds need
-- the ability to change the player spawn position dynamically
-- to function as intended.
function nzMisc:MovePlayerSpawns(spawn_positions)
    local previous_spawns = ents.FindByClass("player_spawns")

    for _,spawn_position in pairs(spawn_positions) do
    local new_spawn = ents.Create("player_spawns")
    new_spawn:SetPos(spawn_position)
    new_spawn:Spawn()
    end

    for _,previous_spawn in pairs(previous_spawns) do
     previous_spawn:Remove()
    end

    nzRound:ResetPlayerSpawns()
end 
