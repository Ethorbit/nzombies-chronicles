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

NZ_DEBUG_LOGLEVEL_MAX = 3
NZ_DEBUG_LOGLEVEL_INFO = 2
NZ_DEBUG_LOGLEVEL_ERROR = 1

CreateConVar("nz_log_level", "0", FCVAR_ARCHIVE, "The nz log level.")

-- Usage: Provide a loglevel and a comma seperated list of values
function DebugPrint(logLevel, ...)
	local requiredLvl = GetConVar("nz_log_level"):GetInt() or 0
	if  requiredLvl >= logLevel then
		local arg = {...}
		local result = ""
		for i=1, #arg do
			if istable(arg[i]) then
				PrintTable(arg[i])
			else
				result = result .. tostring(arg[i]) .. "\t"
			end
		end
		print(result)
	end

end
