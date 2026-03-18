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

	util.AddNetworkString( "nzRevivePlayerFull" )
	util.AddNetworkString( "nzRevivePlayerDowned" )
	util.AddNetworkString( "nzRevivePlayerRevived" )
	util.AddNetworkString( "nzRevivePlayerBeingRevived" )
	util.AddNetworkString( "nzRevivePlayerKilled" )


	function nzRevive:SendPlayerFullData(ply, receiver)
		local data = table.Copy(self.Players[ply:EntIndex()])

		net.Start( "nzRevivePlayerFull" )
			net.WriteInt(ply:EntIndex(), 13)
			net.WriteTable( data )
		return receiver and net.Send(receiver) or net.Broadcast()
	end

	function nzRevive:SendPlayerDowned(ply, receiver, attdata)
		print("Sent")
		attdata = attdata or {}
		net.Start( "nzRevivePlayerDowned" )
			net.WriteInt(ply:EntIndex(), 13)
			net.WriteTable(attdata)
		return receiver and net.Send(receiver) or net.Broadcast()
	end

	function nzRevive:SendPlayerRevived(ply, receiver)
		net.Start( "nzRevivePlayerRevived" )
			net.WriteInt(ply:EntIndex(), 13)
		return receiver and net.Send(receiver) or net.Broadcast()
	end

	function nzRevive:SendPlayerBeingRevived(ply, revivor, receiver)
		if (!IsValid(revivor)) then
			net.Start("NZWhosWhoReviving")
			net.WriteEntity(revivor)
			net.WriteBool(false)
			net.Broadcast()
		end
			
		net.Start( "nzRevivePlayerBeingRevived" )
			net.WriteInt(ply:EntIndex(), 13)
			if IsValid(revivor) then
				net.WriteBool(true)
				net.WriteInt(revivor:EntIndex(), 13)
			else -- No valid revivor means the player stopped being revived
				net.WriteBool(false)
			end
		return receiver and net.Send(receiver) or net.Broadcast()
	end

	function nzRevive:SendPlayerKilled(ply, receiver)
		net.Start( "nzRevivePlayerKilled" )
			net.WriteInt(ply:EntIndex(), 13)
		return receiver and net.Send(receiver) or net.Broadcast()
	end

	FullSyncModules["Revive"] = function(ply)
		for k,v in pairs(player.GetAll()) do
			if !v:GetNotDowned() then -- Player needs to be downed
				nzRevive:SendPlayerFullData(v, ply)
			end
		end
	end
end

if CLIENT then

	local function ReceivePlayerDowned()
		print("Gotten")
		local id = net.ReadInt(13)
		local attached = net.ReadTable()
		
		nzRevive.Players[id] = nzRevive.Players[id] or {}
		nzRevive.Players[id].DownTime = CurTime()
		
		for k,v in pairs(attached) do
			print(k,v)
			nzRevive.Players[id][k] = v
		end
		
		local ply = Entity(id)
		if IsValid(ply) and ply:IsPlayer() then
			--ply:AnimRestartGesture(GESTURE_SLOT_CUSTOM, ACT_HL2MP_SWIM_PISTOL)
			nzRevive:DownedHeadsUp(ply, "needs to be revived!")
		end
	end

	local function ReceivePlayerRevived()
		local id = net.ReadInt(13)
		nzRevive.Players[id] = nil
		local ply = Entity(id)
		if IsValid(ply) and ply:IsPlayer() then
			--ply:AnimResetGestureSlot(GESTURE_SLOT_CUSTOM)
			if ply == LocalPlayer() then nzRevive:ResetColorFade() end
			nzRevive:DownedHeadsUp(ply, "has been revived!")
		end
	end

	local function ReceivePlayerBeingRevived()
		local id = net.ReadInt(13)
		local bool = net.ReadBool()
		if bool then
			local revivor = Entity(net.ReadInt(13))
			nzRevive.Players[id] = nzRevive.Players[id] or {}
			if !nzRevive.Players[id].ReviveTime then
				nzRevive.Players[id].ReviveTime = CurTime()
				nzRevive.Players[id].RevivePlayer = revivor
				revivor.Reviving = Entity(id)
			end
		else
			local revivor = nzRevive.Players[id].RevivePlayer
			if IsValid(revivor) then revivor.Reviving = nil end
			
			nzRevive.Players[id] = nzRevive.Players[id] or {}
			nzRevive.Players[id].ReviveTime = nil
			nzRevive.Players[id].RevivePlayer = nil
		end
	end

	local function ReceivePlayerKilled()
		local id = net.ReadInt(13)
		if (nzRevive.Players and nzRevive.Players[id]) then
			local revivor = nzRevive.Players[id].RevivePlayer
			if IsValid(revivor) then revivor.Reviving = nil end
			
			nzRevive.Players[id] = nil
			local ply = Entity(id)
			if IsValid(ply) and ply:IsPlayer() then
				--ply:AnimResetGestureSlot(GESTURE_SLOT_CUSTOM)
				if ply == LocalPlayer() then nzRevive:ResetColorFade() end
				nzRevive:DownedHeadsUp(ply, "has died!")
			end
		end
	end

	local function ReceiveFullPlayerSync()
		local id = net.ReadInt(13)
		local data = net.ReadTable()
		nzRevive.Players[id] = data
		
		local ply = Entity(id)
		local revivor = data.RevivePlayer
		if IsValid(revivor) then revivor.Reviving = ply end
		
		if IsValid(ply) and ply:IsPlayer() then
			--ply:AnimRestartGesture(GESTURE_SLOT_CUSTOM, ACT_HL2MP_SWIM_PISTOL)
			nzRevive:DownedHeadsUp(ply, "has been downed!")
		end
	end

	-- Receivers
	net.Receive( "nzRevivePlayerDowned", ReceivePlayerDowned )
	net.Receive( "nzRevivePlayerRevived", ReceivePlayerRevived )
	net.Receive( "nzRevivePlayerBeingRevived", ReceivePlayerBeingRevived )
	net.Receive( "nzRevivePlayerKilled", ReceivePlayerKilled )
	net.Receive( "nzRevivePlayerFull", ReceiveFullPlayerSync )
end
