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

ENT.PrintName		= "invis_wall_zombie"
ENT.Author			= "Ethorbit"
ENT.Contact			= ""
ENT.Purpose			= "Block everything except zombies"
ENT.Instructions	= ""

ENT.NZEntity = true

function ENT:SetupDataTables()
	-- Min bound is for now just the position
	--self:NetworkVar("Vector", 0, "MinBound")
	self:NetworkVar("Vector", 0, "MaxBound")
end

function ENT:Initialize()
	--self:SetMoveType( MOVETYPE_NONE )
	self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
	self:DrawShadow( false )
	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
	if self.SetRenderBounds then
		self:SetRenderBounds(Vector(0,0,0), self:GetMaxBound())
	end
	self:SetCustomCollisionCheck(true)
	self:SetCollisionGroup(COLLISION_GROUP_PLAYER_MOVEMENT)

	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end

	--self:SetCollisionGroup(COLLISION_GROUP_PLAYER_MOVEMENT)
	--self:SetFilter(true, true)
end

local ignoreClasses = {
	"invis_wall",
	"invis_wall_zombie",
	"wall_block",
	"wall_block_zombie"
}

function ENT:Use(Activator, Caller, UseType, Integer)
	local ent
	local tr = util.TraceLine({
		start = Activator:EyePos(),
		endpos = Activator:EyePos() + Activator:GetAimVector()*150,
		filter = function(ent2) if ent2 != Activator and !table.HasValue(ignoreClasses, ent2:GetClass()) then ent = ent2 end end,
		ignoreworld = true
	})

	if IsValid(ent) and !isnumber(Activator.lastInvisUseTime) or IsValid(ent) and isnumber(Activator.lastInvisUseTime) and CurTime() > Activator.lastInvisUseTime
	and ent:GetClass() != "invis_wall"
	and ent:GetClass() != "invis_wall_zombie"
	and ent:GetClass() != "wall_block"
	and ent:GetClass() != "wall_block_zombie"
	and ent:GetClass() != "power_box" then
		if (ent:GetClass() == "perk_machine" and nzPerks) then
			local data = nzPerks:Get(ent:GetPerkID())
			if (data.name == "Pack-a-Punch") then return end
		end

		Activator.lastInvisUseTime = CurTime() + 1
		ent:Use(Activator, Caller, UseType, Integer)
	end
end

function ENT:Touch(ent) -- Let zombies walk through us like it's nothing
	--if (IsValid(ent) and nzConfig.ValidEnemies[ent:GetClass()]) then
    if ((ent.Type == "nextbot" or ent:IsNPC()) and ent:Health() > 0) then 
		if (ent:GetCollisionGroup() == COLLISION_GROUP_DEBRIS_TRIGGER) then return end -- They already have this
		ent.prevCollision = ent:GetCollisionGroup()
		ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	end

	ent.touchingzombiewall = true
	timer.Simple(0.1, function()
		if !IsValid(ent) then return end
		ent.touchingzombiewall = false
	end)

	timer.Simple(0.3, function() -- Make sure they have their original collision again when they are passed
		if !IsValid(ent) then return end
		if (!ent.touchingzombiewall) then
			if (!ent.prevCollision) then return end
			ent:SetCollisionGroup(ent.prevCollision)
			print(ent.prevCollision)
		end
	end)
end

local mat = Material("color")
local white = Color(0,0,0,200)

if CLIENT then

	if not ConVarExists("nz_creative_preview") then CreateClientConVar("nz_creative_preview", "0") end

	function ENT:Draw()
		if ConVarExists("nz_creative_preview") and !GetConVar("nz_creative_preview"):GetBool() and nzRound:InState( ROUND_CREATE ) then
			cam.Start3D()
				render.SetMaterial(mat)
				render.DrawBox(self:GetPos(), self:GetAngles(), Vector(0,0,0), self:GetMaxBound(), white, true)
			cam.End3D()
		end
	end
end

-- Causes collisions to completely disappear, not just traces :(
--[[function ENT:TestCollision(start, delta, hulltrace, bounds)
	return nil -- Traces pass through it!
end]]

hook.Add("PhysgunPickup", "nzInvisWallZombieNotPickup", function(ply, wall)
	if wall:GetClass() == "invis_wall_zombie" or wall:GetClass() == "invis_wall" or wall:GetClass() == "invis_damage_wall" then return false end
end)
