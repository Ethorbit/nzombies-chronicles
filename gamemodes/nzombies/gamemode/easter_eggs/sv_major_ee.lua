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

nzEE.Major.Steps = nzEE.Major.Steps or {}
nzEE.Major.CurrentStep = nzEE.Major.CurrentStep or 1

function nzEE.Major:AddStep(func, step)
	if step and tonumber(step) then
		nzEE.Major.Steps[step] = func
	else
		table.insert(nzEE.Major.Steps, func)
	end
end

function nzEE.Major:SetCurrentStep(step)
	nzEE.Major.CurrentStep = step
end

function nzEE.Major:CompleteStep(step, ...)
	if nzEE.Major.CurrentStep == step then
		if nzEE.Major.Steps[step] then
			print("Completed step "..step)
			local args = {...}
			nzEE.Major.Steps[step](args) -- Varargs passable if you call Complete Step with more stuff
		end
		nzEE.Major.CurrentStep = nzEE.Major.CurrentStep + 1
	end
end

util.AddNetworkString("nzMajorEEEndScreen")

function nzEE.Major:Reset()
	nzEE.Major.CurrentStep = 1
end

function nzEE.Major:Cleanup()
	nzEE.Major.CurrentStep = 1
	nzEE.Major.Steps = {}
end
