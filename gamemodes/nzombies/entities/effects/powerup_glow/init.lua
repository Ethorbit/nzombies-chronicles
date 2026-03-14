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

function EFFECT:Init( data )
	
	local vOffset = data:GetOrigin()
	
	local NumParticles = 1
	
	local emitter = ParticleEmitter( vOffset )
	
		for i=0, NumParticles do
		
			local particle = emitter:Add( "sprites/physg_glow1", vOffset )
			if (particle) then
				
				particle:SetVelocity( Vector(0,0,0) )
				particle:SetColor(math.random(50,100), math.random(200,255), math.random(100,150))
				
				particle:SetLifeTime( 0 )
				particle:SetDieTime( 0.3 )
				
				particle:SetStartAlpha( 100 )
				particle:SetEndAlpha( 0 )
				
				particle:SetStartSize( 25 )
				particle:SetEndSize( 25 )
				
				particle:SetRoll( math.Rand(0, 36)*10 )
				--particle:SetRollDelta( math.Rand(-200, 200) )
				
				particle:SetAirResistance( 400 )
				
				particle:SetGravity( Vector( 0, 0, 0 ) )
			
			end
			
		end
		
	emitter:Finish()
	
end


--[[---------------------------------------------------------
   THINK
-----------------------------------------------------------]]
function EFFECT:Think( )
	return false
end

--[[---------------------------------------------------------
   Draw the effect
-----------------------------------------------------------]]
function EFFECT:Render()
end
