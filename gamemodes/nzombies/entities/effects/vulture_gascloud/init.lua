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

local gasparticles = {
	Model("particle/particle_smokegrenade"),
	Model("particle/particle_noisesphere")
}

--Main function
function EFFECT:Init(data)
	--Create particle emitter
	local emitter = ParticleEmitter(data:GetOrigin())
		--Amount of particles to create
		for i=0, 16 do
			--Safeguard
			if !emitter then return end

			local Pos = (data:GetOrigin() + Vector( math.Rand(-5,5), math.Rand(-5,5), math.Rand(-5,5) ))
			local particle = emitter:Add( table.Random(gasparticles), Pos )
			if (particle) then
				particle:SetVelocity(VectorRand() * math.Rand(100,200))
				particle:SetLifeTime(0)
				particle:SetDieTime(math.Rand(4, 6))
				particle:SetColor(100,255,150)
				particle:SetLighting(false)
				particle:SetStartAlpha(255)
				particle:SetEndAlpha(0)
				
				local Size = math.Rand(10,20)
				particle:SetStartSize(Size)
				particle:SetEndSize(Size)
				particle:SetRoll(math.Rand(-360, 360))
				particle:SetRollDelta(math.Rand(-0.21, 0.21))
				particle:SetAirResistance(math.Rand(520,620))
				particle:SetGravity( Vector(0, 0, 0) )
				particle:SetCollide(false)
				particle:SetBounce(0.42)
				particle:SetLighting(1)
			end
		end
	--We're done with this emitter
	emitter:Finish()
end

--Kill effect
function EFFECT:Think()
return false
end

--Not used
function EFFECT:Render()
end
