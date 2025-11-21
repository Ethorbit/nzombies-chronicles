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

-- Fixed by Ethorbit

-- Setup round module
nzTraps = nzTraps or AddNZModule("Traps")
nzLogic = nzLogic or AddNZModule("Logic")
nzTrapsAndLogic = nzTrapsAndLogic or {}

nzTraps.Registry = nzTraps.Registry or {}
nzLogic.Registry = nzLogic.Registry or {}

local function register (tbl, classname)
	table.insert(tbl, classname)
end

function nzTraps:Register(classname)
	if !table.HasValue(self.Registry, classname) then
		register(self.Registry, classname)
	end
end

function nzLogic:Register(classname)
	if !table.HasValue(self.Registry, classname) then
		register(self.Registry, classname)
	end
end

function nzTraps:GetAll()
	return table.Copy(self.Registry)
end

function nzLogic:GetAll()
	return table.Copy(self.Registry)
end

function nzTrapsAndLogic:GetAll()
	local tbl = nzTraps:GetAll()
	table.Add(tbl, nzLogic:GetAll())
	return tbl
end
