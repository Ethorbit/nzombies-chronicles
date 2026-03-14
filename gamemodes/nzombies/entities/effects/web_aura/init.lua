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


local mats = {
	Material( "decals/glass/shot1" ),
	Material( "decals/glass/shot2" ),
	Material( "decals/glass/shot3" ),
	Material( "decals/glass/shot4" ),
	Material( "decals/glass/shot5" ),
	nil
}

--[[---------------------------------------------------------
   Init( data table )
-----------------------------------------------------------]]
function EFFECT:Init( data )
	if (IsValid(self) and IsValid(self.Parent)) then
		self.Size = data:GetScale() or 1
		self.Parent = data:GetEntity()
		self.Frequency = data:GetMagnitude() or 2
		self.Pos = self.Parent:GetPos()
		if self.Parent.WebAura then -- Already have an aura
			if data:GetScale() then
				self.Parent.WebAura = CurTime() + data:GetScale() -- Extend to new time
			else
				self.Parent.WebAura = CurTime() + 20
			end
			self.KILL = true -- and make sure to kill this effect
		else
			if data:GetScale() then
				self.Parent.WebAura = CurTime() + data:GetScale()
			else
				self.Parent.WebAura = CurTime() + 20 -- Default time for this effect
			end

			self:SetRenderBoundsWS( self.Pos, self.Pos, Vector(100,100,100) )
			self.MoveSpeed = 50
			
			self.NextParticle = CurTime()
			
			self.Emitter = ParticleEmitter( self.Pos )
		end
	end
end

--[[---------------------------------------------------------
   THINK
-----------------------------------------------------------]]

function EFFECT:Think( )
	if (IsValid(self)) then
		if self.KILL then return false end
		
		if self.NextParticle != nil and CurTime() >= self.NextParticle then
			local diroffset = Vector(math.Rand(-1,1), math.Rand(-1,1),0):GetNormalized()*5
			local pos = self.Emitter:GetPos() + diroffset + Vector(0,0,20)
			local particle = self.Emitter:Add(mats[math.random(#mats)], pos)
			if (particle) then
				particle:SetVelocity( Vector(0,0,0) )
				particle:SetColor( 255, 255, 255 )
				particle:SetLifeTime( 5 )
				particle:SetDieTime( 10 )
				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 15 )
				particle:SetEndSize( 25 )
				particle:SetRoll( math.Rand(0, 360)*10 )
				particle:SetRollDelta( math.Rand(-10, 10) )
				particle:SetAirResistance( 400 )
				particle:SetGravity( Vector( 0, 0, 0 ) )
				
				particle:SetNextThink(CurTime())
				particle.Dir = diroffset:Angle():Forward()
				particle.Vel = 30
				particle:SetThinkFunction( function()
					if !IsValid(self.Parent) and self.Emitter then self.Emitter:Finish() return end
					particle.Dir:Rotate(Angle(0,3,0))
					particle:SetVelocity( Vector(particle.Dir.x * particle.Vel, particle.Dir.y * particle.Vel, 5) )
					particle.Vel = particle.Vel + 0.1
					particle:SetNextThink(CurTime() + 0.01)
				end )
				
				self.NextParticle = CurTime() + self.Frequency
			end
		end
		if IsValid(self.Parent) then
			if (type(self.Parent.WebAura) == "number" and CurTime() > self.Parent.WebAura) or !self.Parent.WebAura then
				self.Emitter:Finish()
				self.Parent.WebAura = nil
				return false
			else
				self.Emitter:SetPos( self.Parent:GetPos() )
				return true
			end
		else
			if (self and IsValid(self.Emitter)) then
				self.Emitter:Finish()
			end
			return false
		end
	end
end

--[[---------------------------------------------------------
   Draw the effect
-----------------------------------------------------------]]
function EFFECT:Render()
end
