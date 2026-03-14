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

nzConfig.AddValidEnemy("nz_zombie_special_burning", {
    Valid = true,
    ScaleDMG = function(zombie, hitgroup, dmginfo)
        --if hitgroup == HITGROUP_HEAD then dmginfo:ScaleDamage(2) end
    end,
    OnHit = function(zombie, dmginfo, hitgroup)
        local attacker = dmginfo:GetAttacker()
        if attacker:IsPlayer() and attacker:GetNotDowned() then
            attacker:GivePoints(10)
        end
    end,
    OnKilled = function(zombie, dmginfo, hitgroup)
        local attacker = dmginfo:GetAttacker()
        if attacker:IsPlayer() and attacker:GetNotDowned() then
            if dmginfo:GetDamageType() == DMG_CLUB then
                attacker:GivePoints(130)
            elseif hitgroup == HITGROUP_HEAD then
                attacker:GivePoints(100)
            else
                attacker:GivePoints(50)
            end
        end
    end
})

ENT.Base = "nz_zombie_walker"
ENT.PrintName = "Burning Walker"
ENT.Category = "Brainz"
ENT.Author = "Lolle"

function ENT:StatsInitialize()
    if SERVER then
        if nzRound:GetNumber() == -1 then
            self:SetRunSpeed( math.random(20, 260) )

            local hp = math.random(75, 1000)
            self:SetHealth(hp)
            self:SetMaxHealth(hp)
        else
            local speeds = nzRound:GetZombieSpeeds()
            if speeds then
                self:SetRunSpeed( nzMisc.WeightedRandom(speeds) - 20 ) -- A bit slower here
            end

            local hp = nzRound:GetZombieHealth() or 75 
            self:SetHealth(hp)
            self:SetMaxHealth(hp)
        end
        self:Flames( true )

        self:SetEmergeSequenceIndex(math.random(#self.EmergeSequences))
    end
end

function ENT:OnTargetInAttackRange()
    local atkData = {}
    atkData.dmglow = 20
    atkData.dmghigh = 30
    atkData.dmgforce = Vector( 0, 0, 0 )
    self:Attack( atkData )
    self:TimedEvent( 0.45, function()
        if self:IsValidTarget( self:GetTarget() ) and self:TargetInRange( self.AttackRange + 10 ) then
            self:Explode( math.random( 50, 100 ) )
        end
    end)
end

function ENT:OnZombieDeath(dmgInfo)
    self:Explode( math.random( 25, 50 ))
    self:EmitSound(self.DeathSounds[ math.random( #self.DeathSounds ) ], 50, math.random(75, 130))
    self:BecomeRagdoll(dmgInfo)
end
