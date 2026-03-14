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

function nzDoors:OnPlayerBuyDoor( ply, door )
	
end

function nzDoors:OnAllDoorsLocked( )
	self:SendAllDoorsLocked()
end

function nzDoors:OnDoorUnlocked( door, link, rebuyable, ply )
	self:SendDoorOpened( door, rebuyable )
end

function nzDoors:OnMapDoorLinkCreated( door, flags, id )
	self:SendMapDoorCreation(door, flags, id)
end

function nzDoors:OnMapDoorLinkRemoved( door, id )
	self:SendMapDoorRemoval(door)
end

function nzDoors:OnPropDoorLinkCreated( ent, flags )
	self:SendPropDoorCreation( ent, flags )
end

function nzDoors:OnPropDoorLinkRemoved( ent )
	self:SendPropDoorRemoval( ent )
end
