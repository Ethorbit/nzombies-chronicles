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

AddCSLuaFile( )

ENT.Base = "nz_spawner_base"
ENT.PrintName = "Zombie"

ENT.NZOnlyVisibleInCreative = true

function ENT:GetSpawnerData() -- A list of the enemies this spawns, and the chances for us to spawn them
    return {[nzRound:GetZombieClass()] = {chance = 100}}
end

--function ENT:OnZombieTypeChanged(id)
--
--end

function ENT:OnReset()
    self.SpawnersThatFinished = {}
    self.CustomSpawnDelay = 2
end

function ENT:AddMaxZombies()
    local zombie_amount = nzCurves.GenerateMaxZombies(nzRound:GetNumber()) -- The max allowed NORMAL zombies
    self:SetSpawnerAmount(zombie_amount) 
end

function ENT:OnRoundStart(round_num)
    timer.Simple(3, function()
        if !IsValid(self) then return end

        self.CustomSpawnDelay = math.Clamp(2 - (0.1 * (round_num - 1)), 0.8, 1) -- 2) -- Delay based on https://www.reddit.com/r/CODZombies/comments/5tuy65/an_indepth_look_into_black_ops_1_zombie_mechanics/
        self:AddMaxZombies()
    
        if (!nzRound:IsSpecial()) then -- It's not a special enemy round so normal zombies can spawn
            self:SetActive(true)
        end
    end)
end

-- Make sure that if all zombie spawners can't complete their spawning, we keep this one going until the end of the game..

-- This should NOT happen, but when coding custom spawners, it is very easy for the coder to mess up
-- and without this failsafe, games could potentially be ruined with no more zombies spawning:
function ENT:OnZombieSpawnerUnderspawn(spawner)
    if self != self.Updater then return end -- We don't want the code below to fire for ALL of ours spawners

    self.SpawnersThatFinished[spawner:GetClass()] = 1

    if (table.Count(self.SpawnersThatFinished) >= #Spawner:GetActiveClasses()) then -- Oh no, ALL the spawners underspawned and now no more zombies are spawning.. Fix it!!
        self:SetSpawnerAmount(nzRound:GetZombiesMax() - nzRound:GetZombiesKilled())
        self:SetNextSpawn(CurTime())
        self:SetActive(true)

        ServerLog("All spawners disabled before the max amount of zombies were killed! Enabling failsafe to continue spawning normal zombies..\n")
    end
end

function ENT:GetDelay()
    return hook.Run("NormalZombieSpawnDelay", self) or (self.CustomSpawnDelay or 0.8)
end
