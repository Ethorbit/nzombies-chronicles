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

-- I made this as a tribute to the (no longer existing) Half-Life 2: Deathmatch Zombies (@ Phoneburnia) community
-- It may not exist any more, but it was my childhood, and fighting waves of HL2 zombies with teammates was a very fun
-- and unforgettable experience, I'm not letting that get lost to time.

AddCSLuaFile()

nzRound:AddZombieType("HL2 Headcrab Fast", "nz_zombie_hl2_headcrab_fast", {
    -- Set to false to disable the spawning of this zombie
    Valid = true,
    SpecialSpawn = true,
    -- Allow you to scale damage on a per-hitgroup basis
    ScaleDMG = function(zombie, hitgroup, dmginfo)
    end,
    -- Function runs whenever the zombie is damaged (NOT when killed)
    OnHit = function(zombie, dmginfo, hitgroup)
    end,
    -- Function is run whenever the zombie is killed
    OnKilled = function(zombie, dmginfo, hitgroup)
        local attacker = dmginfo:GetAttacker()
        if attacker:IsPlayer() and attacker:GetNotDowned() then
            attacker:GivePoints(10)
        end
    end
})

ENT.Base = "nz_hl2_headcrab_base"
ENT.PrintName = "PB Fast Headcrab"
ENT.Category = "Brainz"
ENT.Author = "Ethorbit"

ENT.DamageLow = 25
ENT.DamageHigh = 25

ENT.HeadcrabSpeed = 150

ENT.BlockHardcodedSwingSound = true
ENT.BlodHardcodedAttackSound = true
ENT.BlodHardcodedAttackMissSound = true
ENT.PauseOnAttack = false

ENT.Models = {
	"models/headcrab.mdl",
}

ENT.AttackMissSounds = {

}


local AttackSequences = {
--	{seq = "attack", dmgtimes = {0, 0}},
}

local AttackSounds = {
   -- "NPC_Headcrab.Attack",
}

local JumpSequences = {
	{seq = "attack", speed = 15, time = 2.7},
}

ENT.ActStages = {
	[2] = {
		act = ACT_RUN,
		minspeed = 0,
		attackanims = AttackSequences,
		sounds = {},
		barricadejumps = JumpSequences,
	}
}

ENT.RedEyes = false -- We have no eyes, we are a headcrab lol

ENT.ElectrocutionSequences = {
	"Drown",
}

ENT.EmergeSequences = {
	"cannisterDeploy_Middle",
}

ENT.PainSounds = {
	"nzr/zombies/death/nz_flesh_impact_0.wav",
	"nzr/zombies/death/nz_flesh_impact_1.wav",
	"nzr/zombies/death/nz_flesh_impact_2.wav",
	"nzr/zombies/death/nz_flesh_impact_3.wav",
	"nzr/zombies/death/nz_flesh_impact_4.wav"
}
ENT.DeathSounds = {
	"NPC_FastHeadcrab.Die"
}

DEFINE_BASECLASS(ENT.Base)

function ENT:OnInitialize()
	BaseClass.OnInitialize(self)

	if !self:GetDetachedFromZombie() then
		self:SetLastLeap(CurTime() + 2)
	end

	self:SetLeapDelayMin(1.5)
	self:SetLeapDelayMax(1.5)
	self:SetLeapDamage(5.0)
	self:SetLeapDamageRadius(80.0)
end	

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "EmergeSequenceIndex")

    BaseClass.SetupDataTables(self)
end

function ENT:StatsInitialize()
	if SERVER then
		self:SetRunSpeed(150)
		self:SetHealth(25)
		self:SetMaxHealth(25)

		--Preselect the emerge sequnces for clientside use
		self:SetEmergeSequenceIndex(math.random(#self.EmergeSequences))
	end
end

function ENT:OnPreHL2Leap()
	self:EmitSound("NPC_FastHeadcrab.Attack")
end
