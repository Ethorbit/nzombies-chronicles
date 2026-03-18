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

function EFFECT:Init( data )

	self.Start = data:GetOrigin()
	self.Catcher = data:GetEntity()
	self.ParticleDelay = 0.1
	self.MoveSpeed = 50
	self.DistToCatch = 100 -- Squared (10)
	
	self.NextParticle = CurTime()
	
	self.Emitter = ParticleEmitter( self.Start )
	
	print(self.Emitter, self.NextParticle, self, self.Catcher)
	
end


--[[---------------------------------------------------------
   THINK
-----------------------------------------------------------]]
function EFFECT:Think( )
	if CurTime() >= self.NextParticle then
		local particle = self.Emitter:Add("sprites/glow04_noz", self.Emitter:GetPos())
		if (particle) then		
			particle:SetVelocity( Vector(0,0,0) )
			particle:SetColor(math.random(200,255), math.random(100,200), math.random(100,150))
			particle:SetLifeTime( 0 )
			particle:SetDieTime( 0.3 )
			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( 25 )
			particle:SetEndSize( 25 )
			particle:SetRoll( math.Rand(0, 36)*10 )
			--particle:SetRollDelta( math.Rand(-200, 200) )
			particle:SetAirResistance( 400 )
			particle:SetGravity( Vector( 0, 0, 0 ) )
			
			self.NextParticle = CurTime() + self.ParticleDelay
		end
	end
	self.Emitter:SetPos( (self.Catcher:GetPos()-self.Emitter:GetPos()):GetNormal() * self.MoveSpeed * FrameTime() + self.Emitter:GetPos() )
	if self.Emitter:GetPos():DistToSqr(self.Catcher:GetPos()) <= self.DistToCatch then
		self.Catcher:CollectSoul()
		return false
	else
		return true
	end
end

--[[---------------------------------------------------------
   Draw the effect
-----------------------------------------------------------]]
function EFFECT:Render()
end
