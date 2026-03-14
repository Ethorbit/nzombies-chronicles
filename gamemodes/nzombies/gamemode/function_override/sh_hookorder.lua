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

-- Add to this table as more conflicting hook names are found
local hooks = {
	"PlayerUse",
}

-- This rehooks all hooks marked in the above table, making nZ-hooks run first to avoid conflicts
hook.Add("InitPostEntity", "nzReorderHooks", function()
	timer.Simple(3, function()
		local tbl = hook.GetTable()
		for k,v in pairs(hooks) do
			local funcs = tbl[v]
			if funcs then
				local nzfuncs = {}
				local nonfuncs = {}
				
				for k2,v2 in pairs(funcs) do -- Loop through all hooks
					if string.sub(k2, 1, 2) == "nz" then -- Store which ones are nZ and which are not
						nzfuncs[k2] = v2
					else
						nonfuncs[k2] = v2
					end
					hook.Remove(v, k2) -- Unhook
				end
				
				-- Now rehook all hooks so the pairs iterator loops through nZ first
				for k2,v2 in pairs(nzfuncs) do
					hook.Add(v, "_"..k2, v2) -- Prepend _ to make it alphabetically first
				end
				for k2,v2 in pairs(nonfuncs) do
					hook.Add(v, "addon_"..k2, v2) -- Prepend "addon_" to make sure, doesn't actually change anything
				end
			end
		end
	end)
end)
