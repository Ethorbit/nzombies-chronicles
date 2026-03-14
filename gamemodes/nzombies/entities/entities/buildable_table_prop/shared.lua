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

AddCSLuaFile( )

ENT.Type = "anim"
 
ENT.PrintName		= "buildable_table_prop"
ENT.Author			= "Zet0r"
ENT.Contact			= "youtube.com/Zet0r"
ENT.Purpose			= "Scriptable prop for nZombies"
ENT.Instructions	= ""

ENT.NZEntity = true

function ENT:SetupDataTables()
	self:NetworkVar( "Entity", 0, "Workbench" )
end

function ENT:Initialize()
	if SERVER then
		--if !IsValid(self.Table) then self:Remove() end
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_VPHYSICS )
		--self:DrawShadow( false )
		self:SetUseType( SIMPLE_USE )
		self.RelayUse = self:GetWorkbench()
	end
end

function ENT:Use(arg1, arg2, arg3, arg4)
	local tbl = self:GetWorkbench()
	if IsValid(tbl) then
		tbl:Use(arg1, arg2, arg3, arg4) -- Relay info
	end
end

if CLIENT then
	function ENT:GetNZTargetText()
		local tbl = self:GetWorkbench()
		if IsValid(tbl) then
			return tbl:GetNZTargetText() -- Relay info
		end
	end
end
