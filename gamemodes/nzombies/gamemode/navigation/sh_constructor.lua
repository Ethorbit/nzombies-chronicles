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

-- Main Tables
nzNav = nzNav or AddNZModule("Nav")
nzNav.Locks = nzNav.Locks or {}

function IsNavApplicable(ent)
	-- All classes that can be linked with navigation
	if !IsValid(ent) then return false end
	if (ent:IsDoor() or ent:IsBuyableProp() or ent:IsButton()) and ent:GetDoorData().link then
		return true
	else
		return false
	end
end

function nzNav.FlushAllNavModifications()
	nzNav.Locks = {}
end
