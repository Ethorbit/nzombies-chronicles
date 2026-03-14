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

-- Setup Doors module
nzSpecialWeapons = nzSpecialWeapons or AddNZModule("SpecialWeapons")

--nzSpecialWeapons.Categories = nzSpecialWeapons.Categories or {}

nzSpecialWeapons.Keys = nzSpecialWeapons.Keys or {
	["knife"] = KEY_V,
	["grenade"] = KEY_G,
	["specialgrenade"] = KEY_B,
}

function nzSpecialWeapons:RegisterSpecialWeaponCategory(id, defaultkey)
	if !self.Keys[id] then
		if defaultkey and CLIENT then CreateClientConVar("nz_key_"..string.lower(id), defaultkey, true, true, "Sets the key that equips "..id..". Uses numbers from gmod's KEY_ enums: http://wiki.garrysmod.com/page/Enums/KEY") end
		self.Keys[id] = defaultkey -- To use as default
	end		
end
