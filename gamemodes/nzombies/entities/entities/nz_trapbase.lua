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

-- Use this class as base when creating traps

AddCSLuaFile( )

ENT.Type = "anim"
ENT.Base = "nz_activatable"

ENT.PrintName = "nz_trapbase"

ENT.Trap = true

DEFINE_BASECLASS("nz_activatable")

function ENT:SetupDataTables()
	BaseClass.SetupDataTables( self )

	self:SetRemoteActivated(true)

	self.bIsLinked = nil

	self:NetworkVarNotify("NZName", function()
		self.bIsLinked = nil
	end)
end

function ENT:IsLinked()
	if (self.bIsLinked != nil) then 
		return self.bIsLinked 
	end
	
	local linked = false
	
	if (#self:GetNZName() <= 0) then return false end
	for _,class in pairs(nzLogic:GetAll()) do
		for _,logic_ent in pairs(ents.FindByClass(class)) do
			if logic_ent.GetLinkedEnts then
				if (logic_ent:GetLinkedNZName1() == self:GetNZName() or logic_ent:GetLinkedNZName2() == self:GetNZName() or logic_ent:GetLinkedNZName3() == self:GetNZName()) then
					linked = true
					break
				end
			end
		end
	end

	for _,tp in pairs(ents.FindByClass("nz_teleporter")) do
		if tp.GetTrap and tp:GetTrap() == self:GetNZName() then
			linked = true
			break
		end
	end

	self.bIsLinked = linked
	return linked
end

-- IMPLEMENT ME
function ENT:OnActivation() end

function ENT:OnDeactivation() end

function ENT:OnReady() end
