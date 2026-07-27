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
	util.AddNetworkString( "nzPowerUps.Sync" )
	util.AddNetworkString( "nzPowerUps.SyncPlayer" )
	util.AddNetworkString( "nzPowerUps.SyncPlayerFull" )
	util.AddNetworkString( "nzPowerUps.Nuke" ) -- See the nuke function in sv_powerups
	
	function nzPowerUps:SendSync(receiver)
		local data = table.Copy(self.ActivePowerUps)
		
		net.Start( "nzPowerUps.Sync" )
			net.WriteTable( data )
		return IsValid(receiver) and net.Send(receiver) or net.Broadcast()
	end
	
	function nzPowerUps:SendPlayerSync(ply, receiver)
		if !self.ActivePlayerPowerUps[ply] then self.ActivePlayerPowerUps[ply] = {} end
		local data = table.Copy(self.ActivePlayerPowerUps[ply])
		
		net.Start( "nzPowerUps.SyncPlayer" )
			net.WriteEntity(ply)
			net.WriteTable( data )
		return IsValid(receiver) and net.Send(receiver) or net.Broadcast()
	end
	
	function nzPowerUps:SendPlayerSyncFull(receiver)
		local data = table.Copy(self.ActivePlayerPowerUps)
		
		net.Start( "nzPowerUps.SyncPlayerFull" )
			net.WriteTable( data )
		return IsValid(receiver) and net.Send(receiver) or net.Broadcast()
	end
	
	FullSyncModules["PowerUps"] = function(ply)
		nzPowerUps:SendSync(ply)
		nzPowerUps:SendPlayerSyncFull(ply)
	end

end

if CLIENT then
	
	-- Server to client (Client)
	local function ReceivePowerupSync( length )
		--print("Received PowerUps Sync")
		nzPowerUps.ActivePowerUps = net.ReadTable()
		--PrintTable(nzPowerUps.ActivePowerUps)
	end
	
	local function ReceivePowerupPlayerSync( length )
		--print("Received PowerUps Player Sync")
		local ply = net.ReadEntity()
		nzPowerUps.ActivePlayerPowerUps[ply] = net.ReadTable()
		--PrintTable(nzPowerUps.ActivePlayerPowerUps)
	end
	
	local function ReceivePowerupPlayerSyncFull( length )
		--print("Received PowerUps Full Player Sync")
		nzPowerUps.ActivePlayerPowerUps = net.ReadTable()
		--PrintTable(nzPowerUps.ActivePlayerPowerUps)
	end
	
	local function ReceiveNukeEffect()
		local fade = 0
		local rising = true
		hook.Add("RenderScreenspaceEffects", "DrawNukeEffect", function()
			if rising then
				fade = fade + 2000*FrameTime()
				if fade >= 1000 then 
					fade = 255
					rising = false
				end
			else
				fade = fade - 300*FrameTime()
				if fade <= 0 then
					hook.Remove("RenderScreenspaceEffects", "DrawNukeEffect")
				end
			end
			surface.SetDrawColor(255,255,255,fade)
			surface.DrawRect(-ScrW(),-ScrH(),ScrW()*2,ScrH()*2)
		end)
	end
	
	-- Receivers 
	net.Receive( "nzPowerUps.Sync", ReceivePowerupSync )
	net.Receive( "nzPowerUps.SyncPlayer", ReceivePowerupPlayerSync )
	net.Receive( "nzPowerUps.SyncPlayerFull", ReceivePowerupPlayerSyncFull )
	net.Receive( "nzPowerUps.Nuke", ReceiveNukeEffect )
end
