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

AddCSLuaFile()

ENT.Type = "anim"
 
ENT.PrintName		= "nz_trigger"
ENT.Author			= "Ethorbit"
ENT.Contact			= ""
ENT.Purpose			= "A parentable trigger entity for nZombies"
ENT.Instructions	= "This is an entity for DEVELOPERS to help them accomplish some tasks."
ENT.NZEntity = true

CreateConVar("nz_preview_triggers", 0, {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_CHEAT})

function ENT:SetupDataTables()
	self:NetworkVar("Vector", 0, "MaxBound")
end

function ENT:GetAllowPreview()
	return self.allowpreviewconvar and self.allowpreviewconvar:GetBool()
end	

function ENT:Initialize()
	self.tTriggerCallbacks = {}

	self:DrawShadow(false)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	self:SetSolid(SOLID_VPHYSICS)
	
	self:SetRenderMode(RENDERMODE_TRANSCOLOR)

	if self.SetRenderBounds then
		self:SetRenderBounds(Vector(0,0,0), self:GetMaxBound())
	end

	if SERVER then
		self:AddSolidFlags(FSOLID_NOT_SOLID)
		self:SetTrigger(true)
		self:UseTriggerBounds(true)

		self:PhysicsInitBox(Vector(0,0,0), self:GetMaxBound())
		self:SetSolid(SOLID_VPHYSICS)
	end
	
	self:SetCustomCollisionCheck(true)

	self.allowpreviewconvar = GetConVar("nz_preview_triggers")
end

function ENT:RunCallbacks(event, ...) -- Run all our registered callbacks
	for _,func in pairs(self.tTriggerCallbacks) do
		if func then 
			func(event, ...)
		end
	end
end

function ENT:ListenToTriggerEvent(callback) -- Call this where you create this trigger entity at so you can do things when something touches it
	self.tTriggerCallbacks[#self.tTriggerCallbacks + 1] = callback
end

function ENT:Touch(ent)
	self:RunCallbacks("Touch", ent)
end

function ENT:StartTouch(ent)
	self:RunCallbacks("StartTouch", ent)
end

function ENT:EndTouch(ent)
	self:RunCallbacks("EndTouch", ent)
end

local mat = Material("color")
local white = Color(255,255,0,10)

if CLIENT then
	function ENT:Draw()
		if self:GetAllowPreview() then
			cam.Start3D()
				render.SetMaterial(mat)
				render.DrawBox(self:GetPos(), self:GetAngles(), Vector(0,0,0), self:GetMaxBound(), white, true)
			cam.End3D()
		end
	end
end

hook.Add("PhysgunPickup", "nzTriggerNoPickup", function(ply, wall)
	if wall:GetClass() == "nz_trigger" then return false end
end)
