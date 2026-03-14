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

-- Client Server Syncing


if SERVER then

	-- Server to client (Server)
	util.AddNetworkString( "nzWeps.Sync" )

	function nzWeps:SendSync( ply, weapon, modifier, revert )
		net.Start( "nzWeps.Sync" )
		net.WriteEntity ( ply )
		net.WriteString( weapon:GetClass() )
		net.WriteEntity( weapon )
		net.WriteString( modifier )
		net.WriteBool( revert )
		return net.Broadcast()
	end

end

if CLIENT then

	-- Server to client (Client)
	local function ReceiveSync( length )
		local owner = net.ReadEntity()
		local wepClass = net.ReadString()
		local wep = net.ReadEntity()
		local modifier = net.ReadString()
		local revert = net.ReadBool()

		if (!IsValid(wep) and (modifier == "pap" or modifier == "repap")) then
			timer.Create("fixingstupidpapcamo", 0, 2000, function()
				if (IsValid(owner)) then
					wep = owner:GetWeapon(wepClass)
				end

				if IsValid(wep) and modifier then
					if revert then
						wep:RevertNZModifier(modifier)
					else
						wep:ApplyNZModifier(modifier)
					end

					timer.Destroy("fixingstupidpapcamo")
				end
			end)
		else
			if !IsValid(wep) or !modifier then return end
		
			if revert then
				wep:RevertNZModifier(modifier)
			else
				wep:ApplyNZModifier(modifier)
			end	
		end
	end

	-- Receivers
	net.Receive( "nzWeps.Sync", ReceiveSync )
end
