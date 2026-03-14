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
	--util.AddNetworkString( "nzToolsSync" )
	util.AddNetworkString( "nzToolsUpdate" )
	
	local function ReceiveData(len, ply)
		if !IsValid(ply) then return end
		if !ply:IsInCreative() then return end -- Vulnerability fixed by Ethorbit
		local id = net.ReadString()
		local wep = ply:GetActiveWeapon()
		
		-- Call holster on the old tool
		if nzTools.ToolData[wep.ToolMode] then
			nzTools.ToolData[wep.ToolMode].OnHolster(wep, ply, ply.NZToolData)
		end
		
		ply:SetActiveNZTool( id )
		-- Only read the data if the tool has any - as shown by the bool
		if net.ReadBool() then
			ply:SetNZToolData( net.ReadTable() )
		end
		
		-- Then call equip on the new one
		if nzTools.ToolData[id] then
			nzTools.ToolData[id].OnEquip(wep, ply, ply.NZToolData)
		end
	end
	net.Receive( "nzToolsUpdate", ReceiveData )
end

if CLIENT then

	-- Client to server
	function nzTools:SendData( data, tool, savedata )
		if data then
			net.Start("nzToolsUpdate")
				net.WriteString(tool)
				-- Let the server know we're also sending a table of data
				net.WriteBool(true)
				net.WriteTable(data)
			net.SendToServer()
		else
			-- This tool doesn't have any data
			net.Start("nzToolsUpdate")
				net.WriteString(tool)
				net.WriteBool(false)
			net.SendToServer()
		end
		
		-- Always save on submit - if a special table of savedata is provided, use that
		if savedata then
			nzTools:SaveData( savedata, tool )
		else
			nzTools:SaveData( data, tool )
		end
	end
	
	function nzTools:SaveData( data, tool )
		self.SavedData[tool] = nil
		self.SavedData[tool] = data
	end
	
end
