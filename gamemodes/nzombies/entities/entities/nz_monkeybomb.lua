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

ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Monkey Bomb"
ENT.Author = "Zet0r"

ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.ExplosionSounds = {
	"nz/monkey/voice_explosion/explo_vox_00.wav",
	"nz/monkey/voice_explosion/explo_vox_01.wav",
	"nz/monkey/voice_explosion/explo_vox_02.wav",
	"nz/monkey/voice_explosion/explo_vox_03.wav",
	"nz/monkey/voice_explosion/explo_vox_04.wav",
	"nz/monkey/voice_explosion/explo_vox_05.wav",
	"nz/monkey/voice_explosion/explo_vox_06.wav",
	"nz/monkey/voice_explosion/explo_vox_07.wav",
	"nz/monkey/voice_explosion/explo_vox_08.wav",
	"nz/monkey/voice_explosion/explo_vox_09.wav",
	"nz/monkey/voice_explosion/explo_vox_10.wav",
	"nz/monkey/voice_explosion/explo_vox_11.wav",
}

if SERVER then
	AddCSLuaFile()
end

function ENT:Initialize()
	if SERVER then
		self:SetModel("models/nzprops/monkey_bomb.mdl") -- Change later
		self:PhysicsInitSphere(1, "metal_bouncy")
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
		self:SetSolid(SOLID_VPHYSICS)
		phys = self:GetPhysicsObject()

		if phys and phys:IsValid() then
			phys:Wake()
		end
	end
end


function ENT:PhysicsCollide(data, physobj)
	if SERVER then
		local vel = physobj:GetVelocity():Length()
		if vel > 100 then
			self:EmitSound("nz/monkey/voice_bounce/land_0"..math.random(0,3)..".wav", 75, 100)
		end

		local LastSpeed = math.max( data.OurOldVelocity:Length(), data.Speed )
		local NewVelocity = physobj:GetVelocity()
		NewVelocity:Normalize()

		LastSpeed = math.max( NewVelocity:Length(), LastSpeed )

		local TargetVelocity = NewVelocity * LastSpeed * 0.35

		physobj:SetVelocity( TargetVelocity )
		
		--if vel < 1000 then

		timer.Simple(0.5, function()
			if (!IsValid(self) or self.gonnablow) then return end
			self.gonnablow = true
			self:SetMoveType(MOVETYPE_NONE)
			self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
			self:ResetSequence("anim_play")
			self:SetExplosionTimer(8)
		end)

		--end
	end
end

function ENT:SetExplosionTimer( time )

	-- Make Zombies target this over players
	self:SetTargetPriority(TARGET_PRIORITY_SPECIAL)
	
	UpdateAllZombieTargets(self)

	SafeRemoveEntityDelayed( self, time +1 ) --fallback
	
	self:EmitSound("nz/monkey/music/song"..math.random(1,3)..".wav", 100)
	self.NextCymbal = CurTime()

	timer.Simple(time - 1.5, function()
		if IsValid(self) then
			local sound = self.ExplosionSounds[math.random(1,#self.ExplosionSounds)]
			self:EmitSound(sound, 85)
		end
	end)
	
	timer.Simple(time, function()
		if IsValid(self) then
			local pos = self:GetPos()
			local owner = self:GetOwner()

			util.BlastDamage(self, owner, pos, 400, 200)

			fx = EffectData()
			fx:SetOrigin(pos)
			fx:SetMagnitude(1)
			util.Effect("Explosion", fx)

			self:Remove()
		end
	end)
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:Think()
	if SERVER then
		if self.NextCymbal and self.NextCymbal < CurTime() then
			self:EmitSound("nz/monkey/cymbals/monk_cymb_m.wav")
			self.NextCymbal = CurTime() + 0.2
		end
	end
end
