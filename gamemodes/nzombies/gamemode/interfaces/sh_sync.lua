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

//Client Server Syncing

if SERVER then

	//Server to client (Server)
	util.AddNetworkString( "nz.Interfaces.Send" )

	function nzInterfaces.SendInterface(ply, interface, data)
		net.Start( "nz.Interfaces.Send" )
			net.WriteString( interface )
			net.WriteTable( data )
		net.Send(ply)
	end

	//Client to Server (Server)
	util.AddNetworkString( "nz.Interfaces.Requests" )

	function nzInterfaces.ReceiveRequests( len, ply )
		local interface = net.ReadString()
		local data = net.ReadTable()

		nzInterfaces[interface.."Handler"](ply, data)
	end

	//Receivers
	net.Receive( "nz.Interfaces.Requests", nzInterfaces.ReceiveRequests )

end

if CLIENT then

	//Server to client (Client)
	function nzInterfaces.ReceiveSync( length )
		local interface = net.ReadString()
		local data = net.ReadTable()

		nzInterfaces[interface](data)
	end

	//Receivers
	net.Receive( "nz.Interfaces.Send", nzInterfaces.ReceiveSync )

	//Client to Server (Client)
	function nzInterfaces.SendRequests( interface, data )
		net.Start( "nz.Interfaces.Requests" )
			net.WriteString( interface )
			net.WriteTable( data )
		net.SendToServer()
	end
end
