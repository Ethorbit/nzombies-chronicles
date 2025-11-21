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

-- We remake the Traitor Button so it can be given a price and triggered in nZombies
-- If it has no price, it will not be usable - A price of 0 will make it usable for free

ENT.Type = "anim"
ENT.Base = "base_anim"

function ENT:SetupDataTables()
   self:NetworkVar("Float", 0, "Delay")
   self:NetworkVar("Float", 1, "NextUseTime")
   self:NetworkVar("Bool", 0, "TTTLocked")
   self:NetworkVar("String", 0, "Description")
   self:NetworkVar("Int", 0, "UsableRange", {KeyName = "UsableRange"})
end

function ENT:IsUsable()
   return (not self:GetTTTLocked()) and self:GetNextUseTime() < CurTime() and self:GetDoorData()
end

if CLIENT then
	local mat = Material( "icon16/exclamation.png" )
	function ENT:Draw()
		if !nzRound:InState( ROUND_CREATE ) then return end

		render.SetMaterial( mat )
		render.DrawSprite( self:GetPos(), 4, 4, color_white )
	end
	
	-- Handling of buttons (copied from TTT Code)
	
	
end
