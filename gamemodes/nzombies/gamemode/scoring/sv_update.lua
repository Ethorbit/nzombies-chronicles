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

function GM:OnZombieKilled(zombie, dmgInfo)
	local attacker = dmgInfo:GetAttacker()
	if IsValid(attacker) and attacker:IsPlayer() then
		attacker:IncrementTotalKills()
		hook.Call("XPFromZombie", nil, attacker, zombie)
	end
end

-- function GiveNuke() -- For testing point exploit with nuke
-- 	---Entity(1):ConCommand("+attack2")

-- 	--timer.Simple(0.3, function()
-- 		nzPowerUps:SpawnPowerUp(Entity(1):GetPos(), "nuke")
-- 	--end)
	
-- 	-- timer.Simple(1, function()
-- 	-- 	Entity(1):ConCommand("-attack2")
-- 	-- end)
-- end

hook.Add("PlayerRevived", "nzupdateReviveScore", function(ply, revivor)
	if IsValid(revivor) and revivor:IsPlayer() then
		revivor:IncrementTotalRevives()
		
		if ply != revivor then
			--revivor:GiveXP(Maxwell.XPAmountFromRevives)
			hook.Call("XPFromRevive", nil, revivor)
		end
	end
end )

hook.Add("PlayerDowned", "nzupdateDownedScore", function(ply)
	if IsValid(ply) and ply:IsPlayer() then
		ply:IncrementTotalDowns()
	end
end )
