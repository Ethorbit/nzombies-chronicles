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

AddCSLuaFile( )

ENT.Base = "nz_spawner_base" 
ENT.PrintName = "Special"

ENT.NZOnlyVisibleInCreative = true

-- Let's add the base classes to other spawners that we want the special spawner to use as well:
local DogBaseClass = baseclass.Get("nz_spawn_zombie_dog")
--local BossBaseClass = baseclass.Get("nz_spawn_zombie_boss")
-------------------------------------------------------------------------------------------

function ENT:OnInitialize()
	self:SetColor(Color(255, 0, 0)) -- Default zombie ent is green and we have the same model, let's make ourselves distinguishable
	
	if SERVER then
		Spawner:UpdateHooks(self)
	end
end

function ENT:GetSpawnerData() -- A list of the enemies this spawns, and the chances for us to spawn them
	return {["nz_zombie_special_dog"] = {chance = 100}}
end

function ENT:OnReset()
	DogBaseClass.OnReset(self)
end

function ENT:AddMaxZombies()
	--local original_count = nzRound:GetZombiesMax()
	DogBaseClass.AddMaxZombies(self)
end

function ENT:DoSpawnChance()
	DogBaseClass.DoSpawnChance(self)
end

function ENT:SetNextSpecialRound()
	DogBaseClass.SetNextSpecialRound(self)

	if (!nzRound:GetNextSpecialRound()) then
		nzRound:SetNextSpecialRound(0) -- Guess we just don't have a special round.
	end
end

function ENT:OnRoundPreparation(round_num)
	DogBaseClass.OnRoundPreparation(self, round_num)
end

function ENT:OnRoundStart(round_num) -- Begin spawning on special round
	DogBaseClass.OnRoundStart(self, round_num)
end

function ENT:SpawnedEntity(zombie) -- We spawned something
	if (zombie:GetClass() == "nz_zombie_special_dog") then
		DogBaseClass.SpawnedEntity(self, zombie)
	end
end

function ENT:OnZombieSpawned(zombie, spawner, is_respawn)
	if (zombie:GetClass() == "nz_zombie_walker") then
		self:DoSpawnChance()
	end
end

function ENT:GetDelay()
	return DogBaseClass.GetDelay(self) -- We'll just use the dog's spawn delay since that's most likely what will spawn
end
