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

-- Setup round module
nzMapping = nzMapping or AddNZModule("Mapping")

-- Variables
nzMapping.Settings = nzMapping.Settings or {}
nzMapping.MarkedProps = nzMapping.MarkedProps or {}
nzMapping.ScriptHooks = nzMapping.ScriptHooks or {}

-- Once more gamemode entities are added, add the gamemodes to this list
nzMapping.GamemodeExtensions = nzMapping.GamemodeExtensions or {
	["Zombie Survival"] = false,
}

-- Prevent undo without being in creative
-- This can be circumvented with "alias", but it's more for accidental undos than exploit fixing
if CLIENT then
	hook.Add("PlayerBindPress", "nzUndoHandling", function(ply, bind, pressed)
		if string.find(bind, "undo") then
			if !ply:IsInCreative() then
				return true
			end
		end
	end)
end
