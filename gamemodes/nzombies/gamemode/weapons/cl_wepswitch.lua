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

local plyMeta = FindMetaTable( "Player" )
AccessorFunc( plyMeta, "iLastWeaponSlot", "LastWeaponSlot", FORCE_NUMBER)
AccessorFunc( plyMeta, "iCurrentWeaponSlot", "CurrentWeaponSlot", FORCE_NUMBER)
function plyMeta:SelectWeapon( class )
	if ( !self:HasWeapon( class ) ) then return end
	self.DoWeaponSwitch = self:GetWeapon( class )
	--print(self.DoWeaponSwitch)
end

function GM:CreateMove( cmd )
	local ply = LocalPlayer()
	if ( IsValid( ply.DoWeaponSwitch ) ) then
		cmd:SelectWeapon( ply.DoWeaponSwitch )

		if ( LocalPlayer():GetActiveWeapon() == ply.DoWeaponSwitch ) then
			ply:SetCurrentWeaponSlot(ply:GetActiveWeapon():GetNWInt("SwitchSlot", 1))
			ply.DoWeaponSwitch = nil
		end
	end
end

function GM:PlayerBindPress( ply, bind, pressed )
	if IsValid(ply) and nzRound:InProgress() or nzRound:InState(ROUND_GO) then
        local activeWep = ply:GetActiveWeapon()
        if !ply:GetCurrentWeaponSlot() and IsValid(activeWep) and activeWep.GetNWInt then ply:SetCurrentWeaponSlot(activeWep:GetNWInt("SwitchSlot", 1)) end
		local slot
		local curslot = ply:GetCurrentWeaponSlot() or 1
		if ( string.find( bind, "slot1" ) ) then slot = 1 end
		if ( string.find( bind, "slot2" ) ) then slot = 2 end
		if ( string.find( bind, "slot3" ) ) then slot = 3 end
		if ( string.find( bind, "invnext" ) ) then 
			slot = curslot + 1
			if (ply:HasPerk("mulekick") and slot > 3) or (!ply:HasPerk("mulekick") and slot > 2) then
				slot = 1
			end
		end
		if ( string.find( bind, "invprev" ) ) then 
			slot = curslot - 1
			if slot < 1 then
				slot = ply:HasPerk("mulekick") and 3 or 2
			end
		end
		if !nzRound:InState(ROUND_CREATE) and (bind == "+menu" and pressed ) then slot = ply:GetLastWeaponSlot() or 1 end
		if slot then
			ply:SetLastWeaponSlot( ply:GetActiveWeapon():GetNWInt( "SwitchSlot", 1) )
			if slot == 3 then
				for k,v in pairs( ply:GetWeapons() ) do
					if v:GetNWInt( "SwitchSlot" ) == slot then
						ply:SelectWeapon( v:GetClass() )
						return true
					end
				end
				slot = 1
				for k,v in pairs( ply:GetWeapons() ) do
					if v:GetNWInt( "SwitchSlot" ) == slot then
						ply:SelectWeapon( v:GetClass() )
						return true
					end
				end
			else
				for k,v in pairs( ply:GetWeapons() ) do
					if v:GetNWInt( "SwitchSlot" ) == slot then
						ply:SelectWeapon( v:GetClass() )
						return true
					end
				end
			end
		end
		if ( string.find( bind, "slot" ) ) then return true end
	end
end
