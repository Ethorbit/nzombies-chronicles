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

AddCSLuaFile( )

ENT.Type = "anim"

ENT.PrintName		= "wunderfizz_windup"
ENT.Author			= "Zet0r"
ENT.Contact			= "youtube.com/Zet0r"
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.NZEntity = true

--[[local perk_materials = {
	["jugg"] = "models/perk_bottle/c_perk_bottle_jugg",
	["speed"] = "models/perk_bottle/c_perk_bottle_speed",
	["dtap"] = "models/perk_bottle/c_perk_bottle_dtap",
	["revive"] = "models/perk_bottle/c_perk_bottle_revive",
	["dtap2"] = "models/perk_bottle/c_perk_bottle_dtap2",
	["staminup"] = "models/perk_bottle/c_perk_bottle_stamin",
	["phd"] = "models/perk_bottle/c_perk_bottle_phd",
	["deadshot"] = "models/perk_bottle/c_perk_bottle_deadshot",
	["mulekick"] = "models/perk_bottle/c_perk_bottle_mulekick",
	["cherry"] = "models/perk_bottle/c_perk_bottle_cherry",
	["tombstone"] = "models/perk_bottle/c_perk_bottle_tombstone",
	["whoswho"] = "models/perk_bottle/c_perk_bottle_whoswho",
	["vulture"] = "models/perk_bottle/c_perk_bottle_vulture",
	["teddy"] = "models/perk_bottle/c_perk_bottle_teddy",
}]]

local teddymat = "models/perk_bottle/c_perk_bottle_teddy"

function ENT:SetupDataTables()
	self:NetworkVar( "Bool", 0, "Winding" )
end

function ENT:RandomizeSkin()
	local skin
	if nzMapping.Settings.wunderfizzperks then
		skin = nzPerks:Get(table.Random(table.GetKeys(nzMapping.Settings.wunderfizzperks))).material
	else
		skin = nzPerks:Get(table.Random(table.GetKeys(nzPerks:GetList()))).material
	end
	
	if skin then
		self:SetMaterial(skin)
	end
end

function ENT:Initialize()

	self:SetMoveType(MOVETYPE_NONE)
	
	self:SetSolid( SOLID_OBB )
	self:DrawShadow( false )

	self:SetModel("models/alig96/perks/perkacola/perkacola.mdl")
	self:RandomizeSkin()
	local machine = self.WMachine

	if SERVER then
		self:SetWinding(true)
		//Stop winding up
		timer.Simple(5, function()
			self:SetWinding(false)
			
			if self.Perk == "teddy" then
				self:SetMaterial(teddymat)
				machine:SetIsTeddy(true)
				machine:GetUser():GivePoints(machine:GetPrice())
				timer.Simple(5, function() 
					if IsValid(self) and IsValid(machine) then
						self:Remove()
						machine:MoveLocation()
					end
				end)
			else
				self:SetMaterial(nzPerks:Get(self.Perk).material)
			end
			machine:SetPerkID(self.Perk)
		end)
		-- If we time out, remove the object
		timer.Simple(25, function() if IsValid(self) then self:Remove() end end)
	end
end

function ENT:WindUp( )
	self:RandomizeSkin()
end

function ENT:TeddyFlyUp( )
	
end

function ENT:Think()
	if SERVER then
		if self:GetWinding() then
			self:WindUp()
		end
	end
end

function ENT:OnRemove()
	if IsValid(self.WMachine) then
		self.WMachine:SetBeingUsed(false)
		self.WMachine.Bottle = nil
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
		if self:GetWinding() then
			if !self:GetRenderAngles() then self:SetRenderAngles(self:GetAngles() + Angle(20,0,0)) end
			self:SetRenderAngles(self:GetRenderAngles()+(Angle(0,50,0)*FrameTime()))
		elseif !self.Stopped then
			self:SetRenderAngles(self:GetNetworkAngles())
			self.LightningAura = nil -- Kill the aura effect
			self.Stopped = true
		end
	end
end
