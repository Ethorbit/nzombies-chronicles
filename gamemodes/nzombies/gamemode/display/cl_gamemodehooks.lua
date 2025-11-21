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

function GM:ContextMenuOpen()
	return nzRound:InState( ROUND_CREATE ) and LocalPlayer():IsAdmin()
end

function GM:PopulateMenuBar(panel)
	panel:Remove()
	return false
end

function GM:OnUndo( name, strCustomString )
	if ( !strCustomString ) then
		notification.AddLegacy( "Undone "..name, NOTIFY_UNDO, 2 )
	else	
		notification.AddLegacy( strCustomString, NOTIFY_UNDO, 2 )
	end
	surface.PlaySound( "buttons/button15.wav" )
end
