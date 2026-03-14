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


function nzQMenu.AddNewEntity( ent, icon, name )
	table.insert(nzQMenu.Data.Entities, {ent, icon, name})
end

-- QuickFunctions
PropMenuAddEntity = nzQMenu.AddNewEntity

PropMenuAddEntity("edit_fog", "entities/edit_fog.png", "Base Fog Editor")
PropMenuAddEntity("edit_fog_special", "entities/edit_fog.png", "Special Round Fog Editor")
PropMenuAddEntity("edit_sky", "entities/edit_sky.png", "Sky Editor")
PropMenuAddEntity("edit_sun", "entities/edit_sun.png", "Sun Editor")
PropMenuAddEntity("edit_color", "gmod/demo.png", "Color Correction Editor")
PropMenuAddEntity("nz_fire_effect", "icon16/fire.png", "Fire Effect")
PropMenuAddEntity("edit_dynlight", "icon16/lightbulb.png", "Dynamic Light")
PropMenuAddEntity("edit_spawn_radius", "vgui/achievements/hl2_break_miniteleporter", "Zombie Spawn Radius Editor")
--PropMenuAddEntity("edit_damage", "icon16/lightbulb.png", "Damage")
