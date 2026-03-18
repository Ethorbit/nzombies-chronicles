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

--

if SERVER then
	util.AddNetworkString("nz_SaveConfig")

	function nzInterfaces.ConfigSaverHandler( ply, data )
		if ply:IsNZAdmin() then
			nzMapping:SaveConfig( data.name )
		end
	end
end

if CLIENT then
	function nzInterfaces.ConfigSaver(name)
		local DermaPanel = vgui.Create( "DFrame" )
		DermaPanel:SetPos( 100, 100 )
		DermaPanel:SetSize( 300, 120 )
		DermaPanel:SetTitle( "Save config" )
		DermaPanel:SetVisible( true )
		DermaPanel:SetDraggable( true )
		DermaPanel:ShowCloseButton( true )
		DermaPanel:MakePopup()
		DermaPanel:Center()

		local WarnText = vgui.Create("DLabel", DermaPanel)
		WarnText:SetSize(280, 20)
		WarnText:SetPos(10, 50)
		WarnText:SetText("")
		WarnText:SetTextColor( Color(150,0,0) )

		local TextEntry = vgui.Create("DTextEntry", DermaPanel)
		TextEntry:SetPos(10, 30)
		TextEntry:SetSize(280, 20)
		TextEntry:SetText(name)
		TextEntry.OnChange = function(self)
			if string.find(self:GetValue(), ";") then
				WarnText:SetText("The name cannot contain ';'!")
			else
				WarnText:SetText("")
			end
		end

		local DermaButton = vgui.Create( "DButton", DermaPanel )
		DermaButton:SetText( "Save" )
		DermaButton:SetPos( 10, 80 )
		DermaButton:SetSize( 280, 30 )
		DermaButton.DoClick = function()
			local name = TextEntry:GetValue()
			nzInterfaces.SendRequests( "ConfigSaver", {name = name} )
		end
	end

	net.Receive("nz_SaveConfig", function()
		local name = net.ReadString()
		nzInterfaces.ConfigSaver(name)
	end)

end
