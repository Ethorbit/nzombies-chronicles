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

ENT.Type = "anim"

AccessorFuncDT(ENT, "Viewable", "Int", 0)
AccessorFuncDT(ENT, "Hint", "String", 0)
AccessorFuncDT(ENT, "Range", "Float", 0)
AccessorFuncDT(ENT, "Translated", "Bool", 0)

function ENT:GetHint()
	local hint = self:GetDTString(0)

	--if self:GetTranslated() then return translate.Get(hint) end

	return hint
end
