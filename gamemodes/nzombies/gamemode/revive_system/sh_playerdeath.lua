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


-- Better function by Ethorbit (Doesn't rely on PlayerShouldTakeDamage and ROUNDS the damage with health
-- so that when it checks like 0.5, it actually is 0 and downs the player like it should...)
-- function nzRevive.DoPlayerDeath(ply, dmg)
-- 	if IsValid(ply) and ply:IsPlayer() then
-- 		if (dmg:GetAttacker():IsPlayer()) then return end

-- 		if (math.floor(ply:Health() - dmg:GetDamage()) <= 0) then
-- 			local allow = hook.Call("PlayerShouldTakeDamage", nil, ply, dmg:GetAttacker())
-- 			if allow != false then
-- 				if ply:GetNotDowned() then
-- 					print(ply:Nick() .. " got downed!")
-- 					ply:DownPlayer()
-- 				else
-- 					ply:KillDownedPlayer() -- Kill them if they are already downed
-- 				end
-- 			end
-- 		return true end
-- 	end
-- end

function nzRevive.DoPlayerDeath(ply, dmg)
	if IsValid(ply) and ply:IsPlayer() then
		if (math.floor(ply:Health() - dmg:GetDamage()) <= 0) then
			local allow = hook.Call("PlayerShouldTakeDamage", nil, ply, dmg:GetAttacker())

			if allow != false then -- Only false should prevent it (not nil)
				if ply:GetNotDowned() then
					print(ply:Nick() .. " got downed!")
					ply:DownPlayer()
					--ply:SetMaxHealth(100) -- failsafe for Jugg not resetting
					return true
				else
					ply:KillDownedPlayer() -- Kill them if they are already downed
				end
			end

			return true
		elseif !ply:GetNotDowned() then
			return true -- Downed players cannot take non-fatal damage
		end
	end
end

function nzRevive.PostPlayerDeath(ply)
	-- Performs all the resetting functions without actually killing the player
	if !ply:GetNotDowned() then ply:KillDownedPlayer(nil, false, true) end
end

local function HandleKillCommand(ply)
	if (ply:IsPlaying() and !ply:IsSpectating()) or ply:IsInCreative() then
		if ply:GetNotDowned() then
			ply:DownPlayer()
		else
			ply:KillDownedPlayer()
		end
	end
	return false
end

-- Hooks
hook.Add("EntityTakeDamage", "nzDownKilledPlayers", nzRevive.DoPlayerDeath)
hook.Add("PostPlayerDeath", "nzPlayerDeathRevivalReset", nzRevive.PostPlayerDeath)
hook.Add("CanPlayerSuicide", "nzSuicideDowning", HandleKillCommand)
