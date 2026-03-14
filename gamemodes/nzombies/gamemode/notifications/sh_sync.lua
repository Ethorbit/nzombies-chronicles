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
	util.AddNetworkString( "nz.Notifications.Request" )
	
	function nzNotifications:SendRequest(header, data)
		net.Start( "nz.Notifications.Request" )
			net.WriteString( header )
			net.WriteTable( data )
		net.Broadcast()
	end

end

if CLIENT then
	
	-- Server to client (Client)
	local function ReceiveRequest( length )
		--print("Received Notifications Request")
		local header = net.ReadString()
		local data = net.ReadTable()
		
		if header == "sound" then
			nzNotifications:AddSoundToQueue(data)
		end
	end
	
	-- Receivers 
	net.Receive( "nz.Notifications.Request", ReceiveRequest )
end
