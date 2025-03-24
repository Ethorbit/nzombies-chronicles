if !MODULE then TFAVOX_Modules_Initialize() return end

MODULE.name = "nZombies - Perks, Box, Facilities etc."
MODULE.description = "Plays sounds based on nZombies events"
MODULE.author = "Zet0r"
MODULE.realm = "shared"

hook.Add("TFAVOX_InitializePlayer","TFAVOX_nZombiesIP",function(ply)
	if IsValid(ply) then
		local mdtbl = TFAVOX_Models[ply:GetModel()]
		if mdtbl then

			ply.TFAVOX_Sounds = ply.TFAVOX_Sounds or {}

			if mdtbl.nzombies then
				ply.TFAVOX_Sounds['nzombies'] = ply.TFAVOX_Sounds['nzombies'] or {}
				ply.TFAVOX_Sounds['nzombies'].perk = mdtbl.nzombies.perk
				ply.TFAVOX_Sounds['nzombies'].power = mdtbl.nzombies.power
				ply.TFAVOX_Sounds['nzombies'].round = mdtbl.nzombies.round
				ply.TFAVOX_Sounds['nzombies'].revive = mdtbl.nzombies.revive
				ply.TFAVOX_Sounds['nzombies'].boss = mdtbl.nzombies.boss -- Not implemented yet
				ply.TFAVOX_Sounds['nzombies'].powerup = mdtbl.nzombies.powerup
				ply.TFAVOX_Sounds['nzombies'].facility = mdtbl.nzombies.facility
				ply.TFAVOX_Sounds.murder = mdtbl.murder
			end

		end
	end

end)

hook.Add( "OnPlayerGetPerk", "TFAVOX_nZombies_Perks", function( ply, id, machine )
	timer.Simple(1, function()
		if IsValid(ply) and TFAVOX_IsValid(ply) and ply:HasPerk(id) then
			if ply.TFAVOX_Sounds and ply.TFAVOX_Sounds.nzombies then
				local sndtbl = ply.TFAVOX_Sounds['nzombies'].perk
				if sndtbl then
					if (not sndtbl[id]) or math.random(0,3) == 0 then id = "generic" end
					
					if sndtbl[id] then
						timer.Simple(0,function()
							if IsValid(ply) and ply:HasPerk(id) then
								TFAVOX_PlayVoicePriority( ply, sndtbl[id], 0 )
							end
						end)
					end
				end
			end
		end
	end)
end)

hook.Add( "OnRoundPreparation", "TFAVOX_nZombies_Round", function( round )
	if round and round > 1 then
		timer.Simple(3, function()
			if nzRound:InProgress() then
				local plys = player.GetAllPlayingAndAlive()
				local valid = {}
				for k,v in pairs(plys) do
					if TFAVOX_IsValid(v) and v.TFAVOX_Sounds and v.TFAVOX_Sounds.nzombies and v:GetNotDowned() then
						table.insert(valid, v)
					end
				end
				
				local ply = table.Random(valid)
				if IsValid(ply) then
					local sndtbl = ply.TFAVOX_Sounds['nzombies'].round
					if sndtbl and sndtbl["prepare"] then
						TFAVOX_PlayVoicePriority( ply, sndtbl["prepare"], 0 )
						
						-- Play reply 3 seconds later
						timer.Simple(3, function()
							if nzRound:InProgress() then
								local plys = player.GetAllPlayingAndAlive()
								local valid = {}
								for k,v in pairs(plys) do
									if TFAVOX_IsValid(v) and v.TFAVOX_Sounds and v.TFAVOX_Sounds.nzombies and v:GetNotDowned() and v != ply then
										table.insert(valid, v)
									end
								end
								
								local ply2 = table.Random(valid)
								if IsValid(ply2) then
									local sndtbl = ply2.TFAVOX_Sounds['nzombies'].round
									if sndtbl and sndtbl["preparereply"] then
										TFAVOX_PlayVoicePriority( ply2, sndtbl["preparereply"], 0 )
									end
								end
							end
						end)
					end
				end
			end
		end)
	end
end)

hook.Add("OnRoundStart", "TFAVOX_nZombies_Round", function( num )
	if nzRound:IsSpecial() then
		local valid = {}
		for k,v in pairs(player.GetAllPlayingAndAlive()) do
			if IsValid(v) and v.TFAVOX_Sounds and v.TFAVOX_Sounds.nzombies and v:GetNotDowned() then
				local sndtbl = v.TFAVOX_Sounds['nzombies'].round
				if sndtbl and sndtbl["special"] then
					TFAVOX_PlayVoicePriority( v, sndtbl["special"], 0 )
					--v.TFAVOX_ImportantSnd = CurTime() + 5
				end
			end
		end
	end
end)

hook.Add( "OnPlayerPickupPowerUp", "TFAVOX_nZombies_Powerups", function( ply, id, ent )
	timer.Simple(2.5, function()
		if nzRound:InProgress() then
			if IsValid(ply) and TFAVOX_IsValid(ply) then
				if ply.TFAVOX_Sounds and ply.TFAVOX_Sounds.nzombies then
					local sndtbl = ply.TFAVOX_Sounds['nzombies'].powerup
					if sndtbl then
						if (not sndtbl[id]) or math.random(0,3) == 0 then id = "generic" end
						
						if sndtbl[id] then
							TFAVOX_PlayVoicePriority( ply, sndtbl[id], 0, 5 )
						end
					end
				end
			end
		end
	end)
end)

hook.Add( "PlayerDowned", "TFAVOX_nZombies_Revive", function( ply )
	if IsValid(ply) and TFAVOX_IsValid(ply) then
		if ply.TFAVOX_Sounds and ply.TFAVOX_Sounds.nzombies then
			local sndtbl = ply.TFAVOX_Sounds['nzombies'].revive
			if sndtbl and sndtbl['downed'] then
				TFAVOX_PlayVoicePriority( ply, sndtbl['downed'], 0)
			end
		end
	end
	
	timer.Simple(3, function()
		local plys = player.GetAllPlayingAndAlive()
		local valid = {}
		for k,v in pairs(plys) do
			if TFAVOX_IsValid(v) and v.TFAVOX_Sounds and v.TFAVOX_Sounds.nzombies and v:GetNotDowned() then
				table.insert(valid, v)
			end
		end
		
		local ply = table.Random(valid)
		if IsValid(ply) then
			local sndtbl = ply.TFAVOX_Sounds['nzombies'].revive
			if sndtbl and sndtbl["otherdowned"] then
				TFAVOX_PlayVoicePriority( ply, sndtbl["otherdowned"], 0)
			end
		end
	end)
end)

hook.Add( "PlayerKilled", "TFAVOX_nZombies_Revive", function( ply )
	local plys = player.GetAllPlayingAndAlive()
	local valid = {}
	for k,v in pairs(plys) do
		if TFAVOX_IsValid(v) and v.TFAVOX_Sounds and v.TFAVOX_Sounds.nzombies and v:GetNotDowned() then
			table.insert(valid, v)
		end
	end
	
	local ply = table.Random(valid)
	if IsValid(ply) then
		local sndtbl = ply.TFAVOX_Sounds['nzombies'].revive
		if sndtbl and sndtbl["dead"] then
			TFAVOX_PlayVoicePriority( ply, sndtbl["dead"], 0)
			--v.TFAVOX_ImportantSnd = CurTime() + 5
		end
	end
end)

hook.Add( "PlayerBeingRevived", "TFAVOX_nZombies_Revive", function( ply, revivor )
	if IsValid(revivor) and TFAVOX_IsValid(revivor) then
		if revivor.TFAVOX_Sounds and revivor.TFAVOX_Sounds.nzombies then
			local sndtbl = revivor.TFAVOX_Sounds['nzombies'].revive
			if sndtbl and sndtbl['reviving'] then
				TFAVOX_PlayVoicePriority( revivor, sndtbl['reviving'], 0, 5 )
				--ply.TFAVOX_ImportantSnd = CurTime() + 5
			end
		end
	end
end)

hook.Add( "PlayerRevived", "TFAVOX_nZombies_Revive", function( ply )
	if IsValid(ply) and TFAVOX_IsValid(ply) then
		if ply.TFAVOX_Sounds and ply.TFAVOX_Sounds.nzombies then
			local sndtbl = ply.TFAVOX_Sounds['nzombies'].revive
			if sndtbl and sndtbl['revived'] then
				TFAVOX_PlayVoicePriority( ply, sndtbl['revived'], 0)
				--ply.TFAVOX_ImportantSnd = CurTime() + 5
			end
		end
	end
end)

hook.Add( "ElectricityOn", "TFAVOX_nZombies_Power", function()
	timer.Simple(3, function()
		if nzRound:InProgress() then
			-- local plys = player.GetAllPlayingAndAlive()
			-- local valid = {}
			-- for k,v in pairs(plys) do
			-- 	if TFAVOX_IsValid(v) and v.TFAVOX_Sounds and v.TFAVOX_Sounds.nzombies and v:GetNotDowned() then
			-- 		table.insert(valid, v)
			-- 	end
			-- end
			
			--local ply = table.Random(valid)
			for _,v in pairs(player.GetAllPlayingAndAlive()) do
				if IsValid(v) and TFAVOX_IsValid(v) and v.TFAVOX_Sounds and v.TFAVOX_Sounds.nzombies and v:GetNotDowned() then
					local sndtbl = v.TFAVOX_Sounds['nzombies'].power
					if sndtbl and sndtbl["on"] then
						TFAVOX_PlayVoicePriority( v, sndtbl["on"], 0 )
						--v.TFAVOX_ImportantSnd = CurTime() + 5
					end
				end
			end
		end
	end)
end)

hook.Add( "ElectricityOff", "TFAVOX_nZombies_Power", function()
	timer.Simple(3, function()
		if nzRound:InProgress() then
			local plys = player.GetAllPlayingAndAlive()
			local valid = {}
			for k,v in pairs(plys) do
				if TFAVOX_IsValid(v) and v.TFAVOX_Sounds and v.TFAVOX_Sounds.nzombies and v:GetNotDowned() then
					table.insert(valid, v)
				end
			end
			
			local ply = table.Random(valid)
			if IsValid(ply) then
				local sndtbl = ply.TFAVOX_Sounds['nzombies'].power
				if sndtbl and sndtbl["off"] then
					TFAVOX_PlayVoicePriority( ply, sndtbl["off"], 0 )
				end
			end
		end
	end)
end)

hook.Add( "OnPlayerBuyBox", "TFAVOX_nZombies_Box", function(ply, gun)
	if IsValid(ply) and TFAVOX_IsValid(ply) then
		if ply.TFAVOX_Sounds and ply.TFAVOX_Sounds.nzombies then
			local sndtbl = ply.TFAVOX_Sounds['nzombies'].facility
			if sndtbl and sndtbl['randombox'] then
				TFAVOX_PlayVoicePriority( ply, sndtbl['randombox'], 0, 5 )
			end
		end
	end
end)

hook.Add( "OnPlayerBuyBox", "TFAVOX_nZombies_Box", function(ply, gun)
	if IsValid(ply) and TFAVOX_IsValid(ply) then
		if ply.TFAVOX_Sounds and ply.TFAVOX_Sounds.nzombies then
			local sndtbl = ply.TFAVOX_Sounds['nzombies'].facility
			if sndtbl and sndtbl['randombox'] then
				TFAVOX_PlayVoicePriority( ply, sndtbl['randombox'], 0, 5 )
			end
		end
	end
end)

hook.Add( "OnPlayerBuyWunderfizz", "TFAVOX_nZombies_Wunderfizz", function(ply, perk)
	if IsValid(ply) and TFAVOX_IsValid(ply) then
		if ply.TFAVOX_Sounds and ply.TFAVOX_Sounds.nzombies then
			local sndtbl = ply.TFAVOX_Sounds['nzombies'].facility
			if sndtbl and sndtbl['wunderfizz'] then
				TFAVOX_PlayVoicePriority( ply, sndtbl['wunderfizz'], 0, 5 )
			end
		end
	end
end)

hook.Add( "OnPlayerBuyPackAPunch", "TFAVOX_nZombies_Packapunch", function(ply, gun)
	if IsValid(ply) and TFAVOX_IsValid(ply) then
		if ply.TFAVOX_Sounds and ply.TFAVOX_Sounds.nzombies then
			local sndtbl = ply.TFAVOX_Sounds['nzombies'].facility
			if sndtbl and sndtbl['packapunch'] then
				TFAVOX_PlayVoicePriority( ply, sndtbl['packapunch'], 0, 10 )
			end
		end
	end
end)

-- Zombie Killing
hook.Add("OnZombieKilled", "TFAVOX_nZombies_Kill", function(zombie, dmginfo)
	local ply = dmginfo:GetAttacker()

	if IsValid(ply) and TFAVOX_IsValid(ply) then
		if ply.TFAVOX_Sounds then
			local sndtbl = ply.TFAVOX_Sounds.murder
			if !sndtbl then return end

			if dmginfo then		
				if math.random(1, 4) == 3 then
					TFAVOX_PlayVoicePriority(ply, sndtbl['zombie'], 100, 10)
				end
			end
		end
	end
end)

-- Surrounded
local nextsearch = 0
hook.Add("PlayerTick", "NZSurroundedSounds", function(ply)
	if CurTime() > nextsearch then
		nextsearch = CurTime() + 1
		local zombiecount = 0
		for k,v in pairs(ents.FindInBox(ply:GetPos() - Vector(290, 290, 290), ply:GetPos() + Vector(290, 290, 290))) do
			if v.Type == "nextbot" then
				zombiecount = zombiecount + 1
			end
		end

		if (zombiecount >= 12) then -- Crowd close to player
			if (!ply.TFAVOX_Sounds) then return end
			sndtbl = ply.TFAVOX_Sounds.callouts
			if !sndtbl then return end
			TFAVOX_PlayVoicePriority(ply, sndtbl['surrounded'], 100)
			nextsearch = CurTime() + math.random(10, 20) -- Increase the delay to prevent quote spamming
		end
	end
end)

-- Box Move Away 
hook.Add("OnBoxMoveAway", "BoxMovedVOXSounds", function(box)
	local ply = box.LastActivator
	if (IsValid(ply) and ply:Alive() and !ply:IsSpectating()) then	
		if (!ply.TFAVOX_Sounds) then return end
		sndtbl = ply.TFAVOX_Sounds.nzombies 
		if sndtbl then sndtbl = ply.TFAVOX_Sounds.nzombies.facility end
		if sndtbl then sndtbl = ply.TFAVOX_Sounds.nzombies.facility.randombox end
		if !sndtbl then return end

		TFAVOX_PlayVoicePriority(ply, sndtbl['moved'], 100)
	end
end)

-- Not Enough Money
hook.Add("OnPlayerBuy", "PlayerBuyVOXSounds", function(ply, amount, ent, func)
	if (IsValid(ply) and ply:Alive() and amount > ply:GetPoints() and (!ply.LastNotEnoughMoneySound or (ply.LastNotEnoughMoneySound and CurTime() - ply.LastNotEnoughMoneySound > 1.5))) then
		if (!ply.TFAVOX_Sounds) then return end
		sndtbl = ply.TFAVOX_Sounds.nzombies 
		if sndtbl then sndtbl = ply.TFAVOX_Sounds.nzombies.facility end
		if !sndtbl then return end

		TFAVOX_PlayVoicePriority(ply, sndtbl['notenoughmoney'], 100)
		ply.LastNotEnoughMoneySound = CurTime()
	end
end)

-- Ally Player Death
hook.Add("PlayerDeath", "PlayerAllyDeathVOXSounds", function(victim, inflictor, attacker)
    for _,v in pairs(player.GetAllPlayingAndAlive()) do
        if (IsValid(v) and v:IsPlayer()) then
            --if (table.HasValue(MaleRebels, v:GetModel()) or table.HasValue(FemaleRebels, v:GetModel())) then
                if (v != victim) then
                    if (istable(v.TFAVOX_Sounds) and v.TFAVOX_Sounds["murder"] and v.TFAVOX_Sounds["murder"]["ally"]) then
                        TFAVOX_PlayVoicePriority(v, v.TFAVOX_Sounds["murder"]["ally"], false) 
                        v.TFAVOX_ImportantSnd = CurTime() + 5
                    end
                end
            --end
        end
    end
end)

hook.Add("EnhancedModelApply", "PlayerSpawnSound", function(ply) 
	timer.Simple( ply.ChangedModelTime or 0, function()
		if IsValid(ply) and ply.TFAVOX_Sounds and TFAVOX_IsValid(ply) and ply:Alive() then

			local sndtbl = ply.TFAVOX_Sounds['main']

			if sndtbl then

				local ind = "TFAVOX_Ply_"..ply:EntIndex().."_SpawnSound"
				timer.Create(ind,0.1,0,function()
					if !IsValid(ply) then print("notisvalid") timer.Remove(ind) end
					if ply.TFAVOX_IsFullySpawned then
						TFAVOX_PlayVoicePriority( ply, sndtbl.spawn, 2, true )
						timer.Remove(ind)
					end
				end)

			end
		end	
	end)
end)