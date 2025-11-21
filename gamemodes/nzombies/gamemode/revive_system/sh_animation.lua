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


local function HandlePlayerDowned(ply, vel)
	if !ply:GetNotDowned() then
		ply.CalcIdeal = ACT_HL2MP_SWIM_REVOLVER
		
		local len = vel:Length2D()
		if ( len <= 1 ) then
			ply.CalcIdeal = ACT_HL2MP_SWIM_PISTOL
		end
		
		return ply.CalcIdeal, ply.CalcSeqOverride
	end
end
hook.Add("CalcMainActivity", "nzPlayerDownedAnims", HandlePlayerDowned)

hook.Add("PrePlayerDraw", "nzPlayerDownedPos", function(ply)
	if (ply:GetPos() == ply.FixedRevPos) then return end
	ply.FixedRevPos = ply:GetPos() - Vector(0, 0, 25)
	if !ply:GetNotDowned() then
		ply:SetPos(ply.FixedRevPos)
	end
end)

local function PlayerDownedParameters(ply, vel, seqspeed)
	if !ply:GetNotDowned() then
		local len = vel:Length2D()
		local movement = 0

		if ( len > 1 ) then
			movement = ( len / seqspeed )
		elseif math.Round(ply:GetCycle(), 1) != 0.7 then
			movement = 5
		end

		local rate = math.min( movement, 1 )
		
		ply:SetPoseParameter("move_x", -1)
		ply:SetPlaybackRate( movement )
		
		if !ply.NZDownedAnim then
			ply.oldViewOffsetHere = ply:GetViewOffset()
			ply:SetViewOffset(Vector(0, 0, 30))
			--ply:SetHull(Vector(-16,-16,0), Vector(16,16,72))
			ply.NZDownedAnim = true
		end

		--ply:SetNetworkOrigin(ply:GetPos() - Vector(0,0,20))
		--
		return true
	elseif ply.NZDownedAnim then
		-- if (isvector(ply.oldViewOffsetHere)) then
		ply:SetViewOffset(Vector(0, 0, 64))
		-- end

		--ply:SetPos(ply:GetPos() + Vector(0,0,25))
		ply:ResetHull()
		ply.NZDownedAnim = false
	end
end
hook.Add("UpdateAnimation", "nzPlayerDownedAnims", PlayerDownedParameters)

if CLIENT then
	local function RenderDownedPlayers(ply)
		if !ply:GetNotDowned() then
			ply:SetRenderOrigin(ply:GetPos() - Vector(0,0,50))
			local ang = ply:GetAngles()
			ply:SetRenderAngles(Angle(-30,ang[2],ang[3]))
			ply:InvalidateBoneCache()
			
			local wep = ply:GetActiveWeapon()
			if IsValid(wep) then wep:InvalidateBoneCache() end
		end
	end
	hook.Add("PrePlayerDraw", "nzPlayerDownedAnims", RenderDownedPlayers)
end
