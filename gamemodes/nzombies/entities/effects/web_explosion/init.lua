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

local mats = {
	Material( "decals/glass/shot1" ),
	Material( "decals/glass/shot2" ),
	Material( "decals/glass/shot3" ),
	Material( "decals/glass/shot4" ),
	Material( "decals/glass/shot5" ),
	nil
}

function EFFECT:Init( data )
	local pos = data:GetOrigin()
	local mag = data:GetMagnitude()
	
	local em = ParticleEmitter( pos )
		for i = 0, 10 do
			local p = em:Add( mats[math.random(#mats)], pos )
			if p then
		        p:SetColor(math.random(120,170), math.random(100,120), math.random(100,120))
		        p:SetStartAlpha(255)
		        p:SetEndAlpha(150)
				local vel = VectorRand() * math.Rand(50,300)
				vel.z = 300
		        p:SetVelocity(vel)
		        p:SetLifeTime(0)

		        p:SetDieTime(math.Rand(0.5, 1))

		        p:SetStartSize(math.random(20, 30))
		        p:SetEndSize(math.random(50, 70))
		        p:SetRoll(math.random(-180, 180))
		        p:SetRollDelta(math.Rand(-2, 2))
		        p:SetAirResistance(200)
				p:SetGravity(Vector(0,0,-100))

		        p:SetCollide(true)
		        p:SetBounce(0.4)

		        p:SetLighting(false)
			end
		end
	em:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
	return false
end
