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


local function RegisterDefaultSpecialWeps()
	--Knives
	nzSpecialWeapons:AddKnife( "nz_quickknife_crowbar", false, 0.80 )
	nzSpecialWeapons:AddKnife( "nz_bowie_knife", true, 0.65, 2.5 )
	nzSpecialWeapons:AddKnife( "nz_one_inch_punch", true, 0.75, 1.5 )
	--Grenades
	nzSpecialWeapons:AddGrenade( "nz_cod4rm_claymore", 4, false, 0.5, false, 0.2, 1500 )	
	nzSpecialWeapons:AddGrenade( "nz_grenade", 4, false, 0.85, false, 0.4 ) -- ALWAYS pass false instead of nil or it'll assume default value
	--Special Grenades
	nzSpecialWeapons:AddSpecialGrenade( "nz_monkey_bomb", 3, false, 3, false, 0.4 )
	
	
	
	--Animations
	nzSpecialWeapons:AddDisplay( "nz_revive_morphine", false, function(wep)
		return !IsValid(wep.Owner:GetPlayerReviving())
	end)
	
	nzSpecialWeapons:AddDisplay( "nz_perk_bottle", false, function(wep)
		return SERVER and wep.nzDeployTime != nil and CurTime() > wep.nzDeployTime + 3.1
	end)
	
	nzSpecialWeapons:AddDisplay( "nz_packapunch_arms", false, function(wep)
		return SERVER and CurTime() > wep.nzDeployTime + 2.5
	end)
end

hook.Add("InitPostEntity", "nzRegisterSpecialWeps", RegisterDefaultSpecialWeps)
--hook.Add("OnReloaded", "nzRegisterSpecialWeps", RegisterDefaultSpecialWeps)
