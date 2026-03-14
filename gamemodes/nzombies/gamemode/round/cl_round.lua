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

function nzRound:GetEndTime()
	return GetGlobalFloat( "gwEndTime", 0 )
end

local states = {
	[ROUND_INIT] = "OnRoundInit",
	[ROUND_PREP] = "OnRoundPreparation",
	[ROUND_PROG] = "OnRoundStart",
	[ROUND_GO] = "OnRoundEnd",
	[ROUND_CREATE] = "OnRoundCreative",
}

function nzRound:StateChange( old, new )
	if new == ROUND_WAITING then
		--nzRound:EnableSpecialFog( false )
		hook.Call( "OnRoundWating", nzRound )
	else
		hook.Call( states[new], nzRound )
	end
	hook.Call( "OnRoundChangeState", nzRound, new, old )
end

-- function nzRound:OnRoundPreperation()
-- 	if !self:IsSpecial() then
-- 		self:EnableSpecialFog(false)
-- 	end
-- end

-- Removed because it's done serverside now
-- function nzRound:OnRoundStart()
-- 	if self:IsSpecial() then
-- 		self:EnableSpecialFog(true)
-- 	else
-- 		self:EnableSpecialFog(false)
-- 	end
-- end

net.Receive("nz_hellhoundround", function()
	if net.ReadBool() then
		--hook.Call( "OnSpecialRoundStart" )
		nzSounds:Play("DogRound")
		--surface.PlaySound("nz/round/dog_start.wav")
	end
end)
