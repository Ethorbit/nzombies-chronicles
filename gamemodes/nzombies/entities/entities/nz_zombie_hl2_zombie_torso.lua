-- I made this as a tribute to the (no longer existing) Half-Life 2: Deathmatch Zombies (@ Phoneburnia) community
-- It may not exist any more, but it was my childhood, and fighting waves of HL2 zombies with teammates was a very fun
-- and unforgettable experience, I'm not letting that get lost to time.

AddCSLuaFile()

nzRound:AddZombieType("HL2 Zombie Torso", "nz_zombie_hl2_zombie_torso", {
    -- Set to false to disable the spawning of this zombie
    Valid = true,
    -- Allow you to scale damage on a per-hitgroup basis
    ScaleDMG = function(zombie, hitgroup, dmginfo)
        -- Headshots for double damage
        --if hitgroup == HITGROUP_HEAD then dmginfo:ScaleDamage(2) end
    end,
    -- Function runs whenever the zombie is damaged (NOT when killed)
    OnHit = function(zombie, dmginfo, hitgroup)
        local attacker = dmginfo:GetAttacker()
        -- If player is playing and is not downed, give points
        if attacker:IsPlayer() and attacker:GetNotDowned() then
            attacker:GivePoints(10)
        end
    end,
    -- Function is run whenever the zombie is killed
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

ENT.Base = "nz_hl2_zombiebase"
ENT.PrintName = "HL2 Zombie Crawler"
ENT.Category = "Brainz"
ENT.Author = "Ethorbit"

ENT.DamageLow = 50
ENT.DamageHigh = 50
ENT.AttackRange = 75

ENT.BlockHardcodedSwingSound = true

ENT.ZombieSounds = {
	["FootstepLeft"] = "Zombie.FootstepLeft",
	["FootstepRight"] = "Zombie.FootstepRight",
	["NewTarget"] = "Zombie.Alert"
}

ENT.Models = {
	"models/zombie/classic_torso.mdl",
}

local AttackSequences = {
	{seq = "attack", attackmisssounds = {"Zombie.AttackMiss"}, dmgtimes = {0.5}},
}

local AttackSounds = {
	"Zombie.Attack",
}

local JumpSequences = {
	--{seq = "climbloop", speed = 15, time = 2.7},
}

ENT.ActStages = {
	[1] = {
		act = ACT_WALK,
		minspeed = 5,
		attackanims = AttackSequences,
		-- no attackhitsounds, just use ENT.AttackHitSounds for all act stages
		sounds = {},
		barricadejumps = JumpSequences,
	},
	[2] = {
		act = ACT_RUN,
		minspeed = 75,
		attackanims = AttackSequences,
		sounds = {},
		barricadejumps = JumpSequences,
	}
}

ENT.RedEyes = false -- We have no eyes, we have a headcrab lol

ENT.ElectrocutionSequences = {
	"releasecrab",
}

ENT.EmergeSequences = {
}

ENT.AttackHitSounds = {
	"nzr/zombies/attack/player_hit_0.wav",
	"nzr/zombies/attack/player_hit_1.wav",
	"nzr/zombies/attack/player_hit_2.wav",
	"nzr/zombies/attack/player_hit_3.wav",
	"nzr/zombies/attack/player_hit_4.wav",
	"nzr/zombies/attack/player_hit_5.wav"
}

ENT.AttackMissSounds = {

}

ENT.PainSounds = {
	"nzr/zombies/death/nz_flesh_impact_0.wav",
	"nzr/zombies/death/nz_flesh_impact_1.wav",
	"nzr/zombies/death/nz_flesh_impact_2.wav",
	"nzr/zombies/death/nz_flesh_impact_3.wav",
	"nzr/zombies/death/nz_flesh_impact_4.wav"
}
ENT.DeathSounds = {
	"Zombie.Die"
}

DEFINE_BASECLASS(ENT.Base)

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "EmergeSequenceIndex")
	self:NetworkVar("Bool", 1, "HeadcrabDetached")

    BaseClass.SetupDataTables(self)
end

function ENT:OnInitialize()
	if SERVER then
		BaseClass.OnInitialize(self)
	end

	self:SetCrawler(true)
	self:SetDropsHeadcrab(true)
	self:SetHeadcrabClass("nz_zombie_hl2_headcrab")
end

function ENT:PlayZombieSound(alias, loop)
	local snd = self.ZombieSounds[alias]
	if !snd then return end

	if loop then
		self:StartLoopingSound(snd)
	else
		self:EmitSound(snd)
	end
end

function ENT:StopZombieSound(alias)
	local snd = self.ZombieSounds[alias]
	if !snd then return end
	self:StopSound(snd)
end

function ENT:StopZombieSounds()
	for _,sound in pairs(self.ZombieSounds) do
		if sound then
			self:StopSound(sound)
		end
	end
end

function ENT:OnNewTarget()
	self:PlayZombieSound("NewTarget")
end

function ENT:StatsInitialize()
	if SERVER then
		if nzRound:GetNumber() == -1 then
			local hp = math.random(100, 1500)
			self:SetHealth(hp)
			self:SetMaxHealth(hp)
		else
			local hp = nzRound:GetZombieHealth() or 75
			self:SetHealth(hp)
			self:SetMaxHealth(hp)
		end

		--Preselect the emerge sequnces for clientside use
		self:SetEmergeSequenceIndex(math.random(#self.EmergeSequences))
	end
end

function ENT:GetRunSpeed()
	return 50
end

function ENT:SpecialInit()
end

function ENT:OnKilled(dmgInfo)
	self:StopZombieSounds()

	BaseClass.OnKilled(self, dmgInfo)
end

function ENT:OnThink()
	BaseClass.OnThink(self)

	if self:GetBodygroup(1) != 1 then
		self:SetBodygroup(1, 1)
	end
end

function ENT:OnSpawn()
end

function ENT:OnRemove()
	BaseClass.OnRemove(self)
	self:StopZombieSounds()
end

function ENT:OnSpawn()
	BaseClass.OnSpawn(self)

	self:SetRunSpeed(50)
	self.loco:SetDesiredSpeed(50)
end

function ENT:Zombie_Footstep()
	self:SetLastFootstepSound(CurTime())
	self.PlayedRightFootstep = !self.PlayedRightFootstep
	self:PlayZombieSound(self.PlayedRightFootstep and "FootstepLeft" or "FootstepRight")
end

function ENT:BodyUpdate()
	self.CalcIdeal = ACT_IDLE

	local velocity = self:GetVelocity()
	local len2d = velocity:Length2D()

	if len2d <= 0 then
		self.CalcIdeal = ACT_IDLE
	else
		self.CalcIdeal = ACT_WALK
	end

	if self:IsJumping() and self:WaterLevel() <= 0 then
		self.CalcIdeal = ACT_JUMP
	end

	if len2d <= 0 then
		self.CalcIdeal = ACT_IDLE
	end

	--if self:GetRoaring() then return end

	if self.CalcIdeal == ACT_WALK and CurTime() > self:GetLastFootstepSound() + 0.4 then
		self:Zombie_Footstep()
	end

	if !self:GetSpecialAnimation() and !self:IsAttacking() then
		if self:GetActivity() != self.CalcIdeal and !self:GetStop() then self:StartActivitySeq(self.CalcIdeal) end

		if self.ActStages[self:GetActStage()] and !self.FrozenTime then
			self:BodyMoveXY()
		end
	end

	if self.FrozenTime then
		if self.FrozenTime < CurTime() then
			self.FrozenTime = nil
			self:SetStop(false)
		end
		self:BodyMoveXY()
		--self:FrameAdvance()
	else
		self:FrameAdvance()
	end

end
