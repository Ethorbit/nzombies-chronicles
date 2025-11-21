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

-- Client Server Syncing

if SERVER then

	-- Server to client (Server)
	util.AddNetworkString( "nz.nzElec.Sync" )
	util.AddNetworkString( "nz.nzElec.Sound" )
	
	function nzElec:SendSync(ply)
		net.Start( "nz.nzElec.Sync" )
			net.WriteBool(self.Active)
		return IsValid(ply) and net.Send(ply) or net.Broadcast()
	end
	
	FullSyncModules["Elec"] = function(ply)
		nzElec:SendSync(ply)
	end

end

if CLIENT then
	
	-- Server to client (Client)
	local function ReceiveSync( length )
		local active = net.ReadBool()
		nzElec.Active = active
	end
	
	local function RecievePowerSound()
		local on = net.ReadBool()
		print(on)
		if on then
			surface.PlaySound("nz/machines/power_up.wav")
		else
			surface.PlaySound("nz/machines/power_down.wav")
		end
	end
	
	-- Receivers 
	net.Receive( "nz.nzElec.Sync", ReceiveSync )
	net.Receive( "nz.nzElec.Sound", RecievePowerSound )


end
