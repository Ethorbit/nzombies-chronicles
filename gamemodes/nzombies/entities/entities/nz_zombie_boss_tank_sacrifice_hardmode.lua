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

AddCSLuaFile()

ENT.Base = "nz_zombie_boss_tank_base"

DEFINE_BASECLASS(ENT.Base)

ENT.PrintName = "Tank The Sacrifice Harmode"
ENT.Category = "Brainz"
ENT.Author = "Berb"

ENT.Models = { "models/enhanced_infected/hulk_3.mdl" } 

nzRound:AddBossType("Tank [The Sacrifice] [Hardmode]", "nz_zombie_boss_tank_sacrifice", {
    specialspawn = true,
    initfunc = function()
        --nzRound:SetNextBossRound(math.random(6,8)) -- Randomly spawn in rounds 6-8
        nzRound:SetNextBossRound(nzRound:GetNumber() + math.random(10, 12))

        -- We can't have boss round on dog round
        if (nzRound:GetNextSpecialRound() == nzRound:GetNextBossRound()) then 
            nzRound:SetNextBossRound(nzRound:GetNextBossRound() + 1)
        end
    end,
    spawnfunc = function(tank)
	 tank:SetHealth(tank:GetTankHealth())
	 tank:SetMaxHealth(tank:GetTankHealth())
    end,
    deathfunc = function(panzer, killer, dmginfo, hitgroup)
        nzRound:SetNextBossRound(nzRound:GetNumber() + math.random(3,5)) -- Delay further boss spawning by 3-5 rounds after its death
        --nzRound:SetNextBossRound(nzRound:GetNumber() + 6)
            
        if IsValid(attacker) and attacker:IsPlayer() and attacker:GetNotDowned() then
            attacker:GivePoints(500) -- Give killer 500 points if not downed
        end

        -- We can't have boss round on dog round
        if (nzRound:GetNextSpecialRound() == nzRound:GetNextBossRound()) then 
            nzRound:SetNextBossRound(nzRound:GetNextBossRound() + 1)
        end
    end
}) -- No onhit function, we don't give points on hit for this guy

function ENT:StatsInitialize()
    if SERVER then
         self:SetRunSpeed(230)
         self:SetHealth(self:GetTankHealth())
         self:SetMaxHealth(self:GetTankHealth())
         shooting = false
         dying = false
         helmet = true
         counting = false
         hasTaunted = false
    end
end

function ENT:GetTankHealth() -- To be called within all registered tanks' spawnfuncs
    local hp = (nzRound:GetNumber() * 220) + 10000 --2500
    return hp
end
