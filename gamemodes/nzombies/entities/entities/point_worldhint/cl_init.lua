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

include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
end

local GripMaterial = Material( "sprites/grip" )
function ENT:Draw()
	if !nzRound:InState( ROUND_CREATE ) then return end
	render.SetMaterial( GripMaterial )
	render.DrawSprite( self:GetPos(), 16, 16, color_white )
	--self:DrawHint()
end

function ENT:DrawHint()
	-- Only if set to ALL or HUMANS
	if self:GetViewable() == 0 or self:GetViewable() == 4 then
		local pos = self:GetPos()
		local eyepos = EyePos()
		local range = self:GetRange()

		if range <= 0 then
			DrawWorldHint(self:GetHint(), pos)
		else
			local dist = pos:Distance(eyepos)
			if dist <= range then
				--[[local fadeoff = range * 0.75
				if dist >= fadeoff then
					DrawWorldHint(self:GetHint(), pos, 1 - (dist - fadeoff) / range)
				else]]
					DrawWorldHint(self:GetHint(), pos)
				--end
			end
		end
	end
end
