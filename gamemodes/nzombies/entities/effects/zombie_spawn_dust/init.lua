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

local matground = {
	Model("particle/particle_smokegrenade"),
	Model("particle/particle_noisesphere")
}
local matshoot = {
	Model("particle/particle_debris_01"),
	Model("particle/particle_debris_02"),
	Model("particle/particle_noisesphere"),
	Model("particle/particle_smokegrenade")
}


function EFFECT:Init( data )
	local pos = data:GetOrigin()
	local duration = data:GetMagnitude()
	local em = ParticleEmitter( pos )
		for i = 0, 10 do
			local p = em:Add( matshoot[math.random(#matshoot)] , pos )
			if p then
		        p:SetColor(math.random(45,55), math.random(40,50), math.random(40,50))
		        p:SetStartAlpha(255)
		        p:SetEndAlpha(0)
				local vel = VectorRand() * math.Rand(40,70)
				vel.z = math.random(200,1000)
		        p:SetVelocity(vel)
				p:SetGravity(Vector(0,0,-1000))
		        p:SetLifeTime(0)

		        p:SetDieTime(math.Rand(duration + 0.5, duration + 1))

		        p:SetStartSize(math.random(35, 40))
		        p:SetEndSize(math.random(10, 20))
		        p:SetRoll(math.random(-180, 180))
		        p:SetRollDelta(math.Rand(-0.1, 0.1))
		        p:SetAirResistance(100)

		        p:SetCollide(true)
		        p:SetBounce(0.4)

		        p:SetLighting(false)
			end
		end
		for i = 0, 5 do
			local p = em:Add( matground[math.random(#matground)] , pos )
			if p then
		        p:SetColor(math.random(45,55), math.random(40,50), math.random(40,50))
		        p:SetStartAlpha(255)
		        p:SetEndAlpha(250)
				local vel = VectorRand() * math.Rand(10,50)
				vel.z = 0
		        p:SetVelocity(vel)
		        p:SetLifeTime(0)

		        p:SetDieTime(math.Rand(duration + 0.75, duration + 1.5))

		        p:SetStartSize(math.random(45, 50))
		        p:SetEndSize(math.random(20, 30))
		        p:SetRoll(math.random(-180, 180))
		        p:SetRollDelta(math.Rand(-0.1, 0.1))
		        p:SetAirResistance(100)

		        p:SetCollide(true)
		        p:SetBounce(0.4)

		        p:SetLighting(false)
			end
		end
	em:Finish()
	
	sound.Play("nz/zombies/spawn/zm_spawn_dirt"..math.random(1,2)..".wav", pos, 75, 100, 1)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
	return false
end
