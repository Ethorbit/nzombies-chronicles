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

local function powerOff(trap)
	if (IsValid(trap)) then
		timer.Destroy("nz.activatable.timer." .. trap:EntIndex()) 
		timer.Destroy("nz.activatable.cooldown.timer." .. trap:EntIndex()) 
		trap:PowerOff()
	end
end

local function TurnOffAllTraps(force)
	for _,v in pairs(nzTrapsAndLogic:GetAll()) do
		for _,trap in pairs(ents.FindByClass(v)) do
			if (force or trap:GetElectricityNeeded()) then
				powerOff(trap)
			end
		end	
	end
end

-- Run trap functionality based on power
hook.Add("ElectricityOn", "ActivateableElctricityOn", function()	
	for _,v in pairs(ents.FindByClass("nz_button")) do
		v:Ready()
	end	
end)

hook.Add("ElectricityOff", "ActivateableElectricityOff", function()
	for _,v in pairs(ents.FindByClass("nz_button")) do
		if (IsValid(v) and v:GetElectricityNeeded()) then
			powerOff(v)
		end
	end	

	TurnOffAllTraps()
end)

-- Turn off all traps when the game ends
hook.Add("OnRoundEnd", "ActivateableTurnOffEndRound", function()
	TurnOffAllTraps(true)
		for _,v in pairs(ents.FindByClass("nz_button")) do
		if (IsValid(v)) then
			powerOff(v)
		end
	end
end)

if SERVER then
	-- Force turn off traps when switching from Creative Mode
	local oldState -- because it's never actually passed to RoundChangeState :/
	hook.Add("OnRoundChangeState", "ActivateableForcePreview", function(_, new)
		if (new == 0 and nzRound and nzRound:InState(ROUND_CREATE)) then
			oldState = 0
		end

		if (new != 0 and oldState == 0) then --They are still possibly on from Creative Previews, turn them off
			oldState = 1
			for _,v in pairs(nzTrapsAndLogic:GetAll()) do
				for _,trap in pairs(ents.FindByClass(v)) do
					powerOff(trap)
				end	
			end
		end
	end)
end
