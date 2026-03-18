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

nzWeps.RoundResupply = {}

function nzWeps:AddAmmoToRoundResupply(ammo, count, max)
	nzWeps.RoundResupply[ammo] = {count = count, max = max}
end

function nzWeps:DoRoundResupply()
	for k,v in pairs(player.GetAllPlaying()) do
		for k2,v2 in pairs(nzWeps.RoundResupply) do
			local give = math.Clamp(v2.max - v:GetAmmoCount(k2), 0, v2.count)
			v:GiveAmmo(give, k2, true)
		end
	end
end

-- Standard grenades
nzWeps:AddAmmoToRoundResupply(GetNZAmmoID( "grenade" ) or "nz_grenade", 2, 4)
