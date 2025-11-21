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

--

function nzTools:CreateTool(id, serverdata, clientdata)
	if SERVER then
		self.ToolData[id] = serverdata
	else
		self.ToolData[id] = clientdata
	end
end

function nzTools:EnableProperties(id, label, icon, order, spacer, filterfunc, datafunc)
	properties.Add( "nztool_"..id, {
		MenuLabel = label,
		Order = order,
		PrependSpacer = spacer,
		MenuIcon = icon,

		Filter = filterfunc,

		Action = function( self, ent )
			local frame = vgui.Create("DFrame")
			frame:SetPos( 100, 100 )
			frame:SetSize( 300, 280 )
			frame:SetTitle( label )
			frame:SetVisible( true )
			frame:SetDraggable( true )
			frame:ShowCloseButton( true )
			frame:MakePopup()
			frame:Center()
			
			local entdata = datafunc(ent)
			if !entdata then entdata = {} end
			
			local panel = nzTools.ToolData[id].interface(frame, entdata, true)
			panel:SetPos(10, 40)
			
			local data2 = panel.CompileData()
			panel.UpdateData = function(data)
				data2 = data
			end
			
			local submit = vgui.Create("DButton", frame)
			submit:SetText("Submit")
			submit:SetPos(50, 245)
			submit:SetSize(200, 25)
			submit.DoClick = function(self2)
				self:MsgStart()
					net.WriteEntity( ent )
					net.WriteTable( data2 )
				self:MsgEnd()
			end
		end,

		Receive = function( self, length, ply )
			local ent = net.ReadEntity()
			local data = net.ReadTable()

			if ( !IsValid( ent ) or !IsValid(ply) ) then return false end
			if !nzRound:InState( ROUND_CREATE ) then return false end
			if ( !ply:IsInCreative() ) then return false end
			if ( ent:IsPlayer() ) then return false end
			if ( !self:Filter( ent, ply ) ) then return false end
			
			local trace = ply:GetEyeTrace()
			trace.Entity = ent
			nzTools.ToolData[id].PrimaryAttack(nil, ply, trace, data)
		end
	} )
end

function nzTools:Get(id)
	return self.ToolData[id]
end

function nzTools:GetList()
	local tbl = {}

	for k,v in pairs(self.ToolData) do
		tbl[k] = v.displayname
	end

	return tbl
end

nzTools:CreateTool("default", {
	displayname = "Multitool",
	desc = "Hold Q to pick a tool to use",
	condition = function(wep, ply)
		return false
	end,

	PrimaryAttack = function(wep, ply, tr, data)
	end,

	SecondaryAttack = function(wep, ply, tr, data)
	end,
	Reload = function(wep, ply, tr, data)
		-- Nothing
	end,
	OnEquip = function(wep, ply, data)

	end,
	OnHolster = function(wep, ply, data)

	end
}, {
	displayname = "Multitool",
	desc = "Hold Q to pick a tool to use",
	condition = function(wep, ply)
		return false
	end,
	interface = function(frame, data)
		local text = vgui.Create("DLabel", frame)
		text:SetText("Select a tool in the list to the left.")
		text:SetFont("Trebuchet18")
		text:SetTextColor( Color(50, 50, 50) )
		text:SizeToContents()
		text:Center()

		return text
	end,
	-- defaultdata = {}
})
