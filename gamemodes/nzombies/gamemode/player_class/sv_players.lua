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

-- Fix OP armor health issues, inside Think for now as the overriding PLAYER:SetHealth and SetArmor gave weird errors
local next_armor_update
hook.Add("Think", "FixBSArmorHealthExploits", function()
    if !next_armor_update or CurTime() > next_armor_update then
        local max_health = GetConVar("nz_difficulty_max_player_health"):GetInt()
        local max_armor = GetConVar("nz_difficulty_max_player_armor"):GetInt()
        
        for _,ply in pairs(player.GetAll()) do
            if (ply:Health() > max_health) then
                ply:SetHealth(max_health)
            end

            if (ply:Armor() > max_armor) then
                ply:SetArmor(max_armor)
            end
        end

        next_armor_update = CurTime() + 4
    end
end)

-- Always hear voice
hook.Add("PlayerCanHearPlayersVoice", "ProximityBlocker", function( listener, talker )
	if talker.IsShadowMuted and talker:IsShadowMuted() then return false end
	return true
end)

-- No sprays
hook.Add("PlayerSpray", "RemoveDumbSprays", function(ply)
	return true
end)

-- function nzPlayers.HurtZombie(ply, zombie)
-- 	if (!ply.hurtZombieTbl) then
-- 		ply.hurtZombieTbl = {}
-- 	end

-- 	if (ply.hurtZombieTbl[zombie]) then return end

-- 	--ply.hurtZombieTbl[zombie] = 1
-- 	table.insert(ply.hurtZombieTbl, zombie)

-- 	timer.Simple(0.05, function()
-- 		ply.hurtZombieTbl[zombie] = nil
-- 	end)
-- end

function nzPlayers.BurnZombie(ply, zombie)
	if (!ply.burnedZombieTbl) then
		ply.burnedZombieTbl = {}
	end

	if (ply.burnedZombieTbl[zombie]) then return end

	ply.burnedZombieTbl[zombie] = 1

	timer.Simple(0.2, function()
		ply.burnedZombieTbl[zombie] = nil
	end)
end

-- function nzPlayers.ZombieWasHurt(ply, zombie)
-- 	return istable(ply.hurtZombieTbl) and ply.hurtZombieTbl[zombie]
-- end

function nzPlayers.ZombieWasBurned(ply, zombie)
	return ply.burnedZombieTbl and ply.burnedZombieTbl[zombie]
end

function nzPlayers.PlayerNoClip( ply, desiredState )
	if ply:Alive() and nzRound:InState( ROUND_CREATE ) then
		return ply:IsInCreative()
	--else
		--return GetConVar("nz_allow_noclip"):GetBool()
	end
end

function nzPlayers:FullSync( ply )
	-- A full sync module using the new rewrites
	if IsValid(ply) then
		ply:SendFullSync()
	end
end

local function initialSpawn( ply )
	timer.Simple(1, function()
		-- Fully Sync
		nzPlayers:FullSync( ply )
	end)
end

local function playerLeft( ply )
	-- this was previously hooked to PlayerDisconnected
	-- it will now detect leaving players via entity removed, to take kicking banning etc into account.
	if ply:IsPlayer() then
		ply:DropOut()
		if IsValid(ply.TimedUseEntity) then
			ply:StopTimedUse()
		end
	end
end

local function friendlyFire( ply, ent )
	if (IsValid(ent) and ent:IsValidZombie() and ent:Health() <= 0 and ent.FireHound and IsValid(ply) and ply:IsPlayer() and ply:HasPerk("phd")) then return false end
	if !ply:GetNotDowned() or (ply:IsSpectating() and !ply:IsInCreative()) then return false end
	if ent:IsPlayer() then
		if ent == ply then
			-- You can damage yourself as long as you don't have PhD
			return !ply:HasPerk("phd") and !ply.SELFIMMUNE
		else
			--Friendly fire is disabled for all other players TODO make hardcore setting?
			return false
		end
	elseif ent:IsValidZombie() then
		if ply:HasPerk("widowswine") and ply:GetAmmoCount(GetNZAmmoID("grenade")) > 0 then -- WIDOWS WINE TAKE DAMAGE EFFECT
			local pos = ply:GetPos()

			ply.SELFIMMUNE = true
			util.BlastDamage(ply, ply, pos, 350, 50)
			ply.SELFIMMUNE = nil

			local zombls = ents.FindInSphere(pos, 350)

			local e = EffectData()
			e:SetMagnitude(1.5)
			e:SetScale(20) -- The time the effect lasts

			local fx = EffectData()
			fx:SetOrigin(pos)
			fx:SetMagnitude(1)
			util.Effect("web_explosion", fx)

			for k,v in pairs(zombls) do
				if IsValid(v) and v:IsValidZombie() then
					v:ApplyWebFreeze(20)
				end
			end

			ply:SetAmmo(ply:GetAmmoCount(GetNZAmmoID("grenade")) - 1, GetNZAmmoID("grenade"))
		end
	end
end

function GM:PlayerNoClip( ply, desiredState )
	return nzPlayers.PlayerNoClip(ply, desiredState)
end

local function playerReleaseKey(ply, btn)
	if btn == IN_USE then
		ply.isUsing = false
	end
end

local function playerHoldKey(ply, btn)
	if btn == IN_USE then
		ply.isUsing = true

		local function UseLoop()
			timer.Simple(0.2, function()
				if ply.isUsing and ply:GetNotDowned() then -- They are holding USE
					local barrier = ply.LastBarricade -- They've pressed USE on a barricade in the past

					if (IsValid(barrier) && barrier:GetPos():Distance(ply:GetPos()) < 80) then -- They are still at the barricade
						ply:RepairBarricade()
					end

					UseLoop()
				end
			end)
		end
		UseLoop()

	end
end

hook.Add( "PlayerInitialSpawn", "nzPlayerInitialSpawn", initialSpawn )
hook.Add( "PlayerShouldTakeDamage", "nzFriendlyFire", friendlyFire )
hook.Add( "EntityRemoved", "nzPlayerLeft", playerLeft )
hook.Add( "KeyRelease", "nzPlayerReleaseKey", playerReleaseKey )
hook.Add( "KeyPress", "nzPlayerHoldKey", playerHoldKey )
