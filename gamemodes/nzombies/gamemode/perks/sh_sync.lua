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

-- Client Server Syncing

if SERVER then

	-- Server to client (Server)
	util.AddNetworkString( "nz.Perks.Sync" )
	util.AddNetworkString( "nz.Perks.FullSync" )
	
	function nzPerks:SendSync(ply, receiver)
		if !ply then nzPerks:SendFullSync(receiver) return end -- No valid player set, just do a full sync
		if !nzPerks.Players[ply] then nzPerks.Players[ply] = {} end -- Create table should it not exist (for some reason)
		
		local data = table.Copy(nzPerks.Players[ply])
		
		net.Start( "nz.Perks.Sync" )
			net.WriteEntity( ply )
			net.WriteTable( data )
		return receiver and net.Send(receiver) or net.Broadcast()
	end
	
	function nzPerks:SendFullSync(receiver)
		local data = table.Copy(nzPerks.Players)
		
		net.Start( "nz.Perks.FullSync" )
			net.WriteTable( data )
		return receiver and net.Send(receiver) or net.Broadcast()
	end
	
	FullSyncModules["Perks"] = function(ply)
		nzPerks:SendFullSync(ply)
	end

end

if CLIENT then
	
	-- Server to client (Client)
	local function ReceiveSync( length )
		print("Received Player Perks Sync")
		local ply = net.ReadEntity()
		nzPerks.Players[ply] = net.ReadTable()

		local myperks = nzPerks.Players[LocalPlayer()]
		if (istable(myperks)) then
			local gotstam = false
			for _,v in pairs(myperks) do
				if (v == "staminup") then
					gotstam = true
				break end
			end

			local new_walk_speed = gotstam and LocalPlayer():GetWalkSpeed("staminup") or LocalPlayer():GetWalkSpeed("default")
			local new_run_speed = gotstam and LocalPlayer():GetRunSpeed("staminup") or LocalPlayer():GetRunSpeed("default")

			if new_walk_speed then
				LocalPlayer():SetWalkSpeed(new_walk_speed)
			end

			if new_run_speed then
				LocalPlayer():SetRunSpeed(new_run_speed)
				LocalPlayer():SetMaxRunSpeed(new_run_speed)
			end

			if (gotstam) then
				LocalPlayer():SetStamina(200)
				LocalPlayer():SetMaxStamina(200)
			else
				LocalPlayer():SetStamina(100)
				LocalPlayer():SetMaxStamina(100)
			end
		end

		--PrintTable(nzPerks.Players)
	end
	
	local function ReceiveFullSync( length )
		print("Received Full Perks Sync")
		nzPerks.Players = net.ReadTable()
		PrintTable(nzPerks.Players)
	end
	
	-- Receivers 
	net.Receive( "nz.Perks.Sync", ReceiveSync )
	net.Receive( "nz.Perks.FullSync", ReceiveFullSync )
end
