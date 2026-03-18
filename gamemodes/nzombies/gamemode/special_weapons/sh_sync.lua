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

if SERVER then
	util.AddNetworkString("nzUpdateMyWeapons")
	util.AddNetworkString("nzSendSpecialWeapon")

	-- Update their special weapons, auto called when their 
	-- special weapon returns as nil and they can't switch to it
	net.Receive("nzUpdateMyWeapons", function(len, ply) 
		if (!isnumber(ply.LastUpdatedWeapons) or CurTime() - ply.LastUpdatedWeapons > 4) then -- Some spam protection
			print(ply:Nick() .. " requested a Special Weapons update.")
			ply:UpdateSpecialWeapons()
			ply.LastUpdatedWeapons = CurTime()
		end
	end)

	function nzSpecialWeapons:SendSpecialWeaponAdded(ply, wep, id)
		timer.Simple(0.5, function()
			if IsValid(ply) then
				net.Start("nzSendSpecialWeapon")
					net.WriteString(id)
					net.WriteBool(true)
					net.WriteEntity(wep)
				net.Send(ply)
			end
		end)
	end
	
	function nzSpecialWeapons:SendSpecialWeaponRemoved(ply, id)
		timer.Simple(0.1, function()
			if IsValid(ply) then
				net.Start("nzSendSpecialWeapon")
					net.WriteString(id)
					net.WriteBool(false)
				net.Send(ply)
			end
		end)
	end
end

if CLIENT then
	local function ReceiveSpecialWeaponAdded()
		if !LocalPlayer().NZSpecialWeapons then LocalPlayer().NZSpecialWeapons = {} end
		local id = net.ReadString()
		local bool = net.ReadBool()
		
		if bool then
			local ent = net.ReadEntity()
			LocalPlayer().NZSpecialWeapons[id] = ent
		else
			LocalPlayer().NZSpecialWeapons[id] = nil
		end
	end
	net.Receive("nzSendSpecialWeapon", ReceiveSpecialWeaponAdded)
end
