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

-- A prop built onto a Bench
AddCSLuaFile()

ENT.Type = "anim"
ENT.Author = "Ethorbit"
ENT.NZEntity = true

function ENT:Initialize()
    self:SetSolid(SOLID_NONE)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(false)
    end
   
    if SERVER then
        self:SetUseType(SIMPLE_USE)
    end
end

function ENT:SetBenchInteraction(bool) -- Use Bench and see Bench text via this entity, not recommended with big props
    if bool then
        self.StartTimedUse = function(ply) 
            if IsValid(self:GetOwner()) then
                self:GetOwner():StartTimedUse(ply)
            end
        end
        
        self.StopTimedUse = function(ply) 
            if IsValid(self:GetOwner()) then
                self:GetOwner():StopTimedUse(ply)
            end
        end
        
        self.FinishTimedUse = function(ply) 
            if IsValid(self:GetOwner()) then
                self:GetOwner():FinishTimedUse(ply)
            end
        end

        -- COOL CONCEPT BUT AS WE KNOW GMOD IS SHIT so this won't work, 
        -- nZombies uses a line trace for text that will NEVER hit this entity without causing other issues
        -- self.GetNZTargetText = function() -- Show Bench's text instead
        --     if IsValid(self:GetOwner()) then
        --         return self:GetOwner():GetNZTargetText()
        --     end
        -- end
    else
        self.StartTimedUse = nil
        self.StopTimedUse = nil
        self.FinishTimedUse = nil
        self.GetNZTargetText = nil
    end
end
