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

-- The deadly blade of an nz_trap_propeller
AddCSLuaFile()

ENT.Author = "Ethorbit"
ENT.Type = "anim"

ENT.SliceSounds = {
    "ambient/machines/slicer1.wav", 
    "ambient/machines/slicer2.wav", 
    "ambient/machines/slicer3.wav", 
    "ambient/machines/slicer4.wav"
}

ENT.NZEntity = true

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/props_c17/trappropeller_blade.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetTrigger(true)
        self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
        self:SetLagCompensated(false)
        self.Parent = self:GetParent()
    end

    self.OriginalAngles = self:GetAngles()
end

function ENT:GetActive() -- Our parent is the NZ trap, this is just the attached blade
    return (self.Parent and self.Parent.GetActive and self.Parent:GetActive())
end

function ENT:Touch(ent) 
    if (!self:GetActive()) then return end

    local dmg = DamageInfo()
    dmg:SetAttacker(self)
    dmg:SetInflictor(self)
    dmg:SetDamage(ent:Health() * 2)
    
    if ent:IsPlayer() and (!ent:IsSpectating() or ent:IsInCreative()) and ent:GetNotDowned() then
        ent:TakeDamageInfo(dmg)
        self:SlicedEnemy(ent)
    end

    if ent:IsValidZombie() and ent:Health() > 0 and !ent.NZBossType and !ent.NZBoss then
        ent:Kill(dmg)
        self:SlicedEnemy(ent)
    end
end

function ENT:SlicedEnemy(ent) -- We killed an enemy
    self:EmitSound(self.SliceSounds[math.random(#self.SliceSounds)])
end

if SERVER then 
    -- I wanted rotate to look smooth (and match both client and server for proper slicing) 
    -- and don't want to fight the engine for an optimized solution...

    -- Basically rotating serverside in a Think hook looks choppy because it's too slow (even with self:NextThink(CurTime()))
    hook.Add("Tick", "NZ_BladeTrapRotations", function()
        for _,v in pairs(ents.FindByClass("propellertrap_blade")) do
            v:Rotate()
        end
    end)
end

function ENT:Rotate()
    if (!self:GetActive()) then 
        self.bRotating = false
    return end

    self.bRotating = true

    local a = self:GetAngles()
    a:RotateAroundAxis(self:GetUp(), (engine.TickInterval() / 33) * 18000)
    self:SetAngles(a)
end

function ENT:IsRotating()
    return self.bRotating
end

function ENT:ResetAngles() -- Resets the blade angles to what it was when this entity was created
    if self.OriginalAngles then
        self:SetAngles(self.OriginalAngles)
    end
end
