-- Chat Commands
-- Recoded by Ethorbit, see constructor for more info.

if CLIENT then
	local function printCmd(cmd)
		local cmdText = cmd.text
		if cmd.usageHelp then
			cmdText = cmdText .. " " .. cmd.usageHelp
		end
		if cmd.allowAll or (!cmd.allowAll and LocalPlayer():IsNZAdmin()) then
			LocalPlayer():PrintMessage( HUD_PRINTTALK, cmdText )
		end
	end

	nzChatCommand.Add("/help", function(ply, text)
		ply:PrintMessage( HUD_PRINTTALK, "-----" )
		ply:PrintMessage( HUD_PRINTTALK, "[nZ] Available commands:" )
		ply:PrintMessage( HUD_PRINTTALK, "Arguments in [] are optional." )

		for _,cmd in pairs(nzChatCommand.GetAll()) do
			printCmd(cmd)
		end

		ply:PrintMessage( HUD_PRINTTALK, "-----" )
		ply:PrintMessage( HUD_PRINTTALK, "" )
	end, true, "   Print this list.")

	nzChatCommand.Add("/cheats", function(ply, text)
		if !IsValid(g_nz_cheats) then
			g_nz_cheats = vgui.Create("NZCheatFrame")
		else
			g_nz_cheats:Remove()
		end
	end, false, "Opens the cheat panel.")
end

if SERVER then
	nzChatCommand.Add("/ready", function(ply, text)
		ply:ReadyUp()
	end, true, "   Mark yourself as ready.")

	nzChatCommand.Add("/unready", function(ply, text)
		ply:UnReady()
	end, true, "   Mark yourself as unready.")

	nzChatCommand.Add("/dropin", function(ply, text)
		ply:DropIn()
	end, true, "   Drop into the next round.")

	nzChatCommand.Add("/dropout", function(ply, text)
		ply:DropOut()
	end, true, "   Drop out of the current round.")

	nzChatCommand.Add("/create", function(ply, text)
		local plyToCreate
		if text[1] then plyToCreate = player.GetByName(text[1]) else plyToCreate = ply end

		if IsValid(plyToCreate) then
			plyToCreate:ToggleCreativeMode()
		else
			ply:ChatPrint("[nZ] Could not find player '"..text[1].."', are you sure he exists?")
		end
	end, false, "   Respawn in creative mode.")

	nzChatCommand.Add("/generate", function(ply, text)
		if navmesh.IsLoaded() then
			ply:PrintMessage( HUD_PRINTTALK, "[nZ] Navmesh already exists, couldn't generate." )
		else
			ply:PrintMessage( HUD_PRINTTALK, "[nZ] Starting Navmesh Generation, this may take a while." )
			navmesh.BeginGeneration()
			--force generate
			if !navmesh.IsGenerating() then
				ply:PrintMessage( HUD_PRINTTALK, "[nZ] No walkable seeds found, forcing generation..." )
				local sPoint = GAMEMODE.SpawnPoints[ math.random( #GAMEMODE.SpawnPoints ) ]
				local tr = util.TraceLine( {
					start = sPoint:GetPos(),
					endpos = sPoint:GetPos() - Vector( 0, 0, 100),
					filter = sPoint
				} )

				local ent = ents.Create("info_player_start")
				ent:SetPos( tr.HitPos )
				ent:Spawn()
				navmesh.BeginGeneration()
			end

			if !navmesh.IsGenerating() then
				--Will not happen but just in case
				ply:PrintMessage( HUD_PRINTTALK, "[nZ] Navmesh Generation failed! Please try this command again or generate the navmesh manually." )
			end
		end
	end, false, "   Generate a new naviagtion mesh.")

	nzChatCommand.Add("/save", function(ply, text)
		if nzRound:InState( ROUND_CREATE ) then
			net.Start("nz_SaveConfig")
				net.WriteString(nzMapping.CurrentConfig or "")
			net.Send(ply)
		else
			ply:PrintMessage( HUD_PRINTTALK, "[nZ] You can't save a config outside of creative mode." )
		end
	end, false, "   Save your changes to a config.")

	nzChatCommand.Add("/load", function(ply, text)
		if nzRound:InState( ROUND_CREATE) or nzRound:InState( ROUND_WAITING ) then
			nzInterfaces.SendInterface(ply, "ConfigLoader", nzMapping:GetConfigs())
		else
			ply:PrintMessage( HUD_PRINTTALK, "[nZ] You can't load while playing!" )
		end
	end, false, "   Open the map config load dialog.")

	nzChatCommand.Add("/clean", function(ply, text)
		if nzRound:InState( ROUND_CREATE) or nzRound:InState( ROUND_WAITING ) then
			nzMapping:ClearConfig()
		else
			ply:PrintMessage( HUD_PRINTTALK, "[nZ] You can't clean while playing!" )
		end
	end)

	-- Tests

	nzChatCommand.Add("/spectate", function(ply, text)
		if !nzRound:InProgress() or nzRound:InState( ROUND_INIT ) then
			ply:PrintMessage( HUD_PRINTTALK, "[nZ] No round in progress, couldnt set you to spectator!" )
		elseif ply:IsReady() then
			ply:UnReady()
			ply:RemovePerks() -- Or else they may instantly die when they respawn! Weird Who's Who spectator bug!
			ply:SetSpectator()
		else
			ply:SetSpectator()
		end
	end, true)

	nzChatCommand.Add("/soundcheck", function(ply, text)
		if ply:IsSuperAdmin() then
			nzNotifications:PlaySound("nz/powerups/double_points.mp3", 1)
			nzNotifications:PlaySound("nz/powerups/insta_kill.mp3", 2)
			nzNotifications:PlaySound("nz/powerups/max_ammo.mp3", 2)
			nzNotifications:PlaySound("nz/powerups/nuke.mp3", 2)

			nzNotifications:PlaySound("nz/round/round_start.mp3", 14)
			nzNotifications:PlaySound("nz/round/round_end.mp3", 9)
			nzNotifications:PlaySound("nz/round/game_over_4.mp3", 21)
		end
	end, true)

	--cheats
	nzChatCommand.Add("/revive", function(ply, text)
		local plyToRev = text[1] and player.GetByName(text[1]) or ply
		if IsValid(plyToRev) and !plyToRev:GetNotDowned() then
			plyToRev:RevivePlayer()
		else
			ply:ChatPrint("[nZ] Player could not have been revived, are you sure he is downed?")
		end
	end, false, "[playerName]   Revive yourself or another player.")

	nzChatCommand.Add("/givepoints", function(ply, text)
		local plyToGiv = player.GetByName(text[1])
		local points

		if !plyToGiv then
			points = tonumber(text[1])
			plyToGiv = ply
		else
			points = tonumber(text[2])
		end

		if IsValid(plyToGiv) then
			if points then
				plyToGiv:GivePoints(points)
			else
				ply:ChatPrint("[nZ] No valid number provided.")
			end
		else
			ply:ChatPrint("[nZ] The player you have selected is either not valid or not alive.")
		end
	end, false, "[playerName] pointAmount   Give points to yourself or another player.")

	nzChatCommand.Add("/setpoints", function(ply, text)
		local plyToGiv = player.GetByName(text[1])
		local points

		if !plyToGiv then
			points = tonumber(text[1])
			plyToGiv = ply
		else
			points = tonumber(text[2])
		end

		if IsValid(plyToGiv) then
			if points then
				plyToGiv:SetPoints(points)
			else
				ply:ChatPrint("[nZ] No valid number provided.")
			end
		else
			ply:ChatPrint("[nZ] The player you have selected is either not valid or not alive.")
		end
	end, false, "[playerName] pointAmount   Set points for yourself or another player.")

	nzChatCommand.Add("/giveweapon", function(ply, text)
		local plyToGiv = player.GetByName(text[1])

		local wep

		if !plyToGiv then
			wep = weapons.Get(text[1])
			plyToGiv = ply
		else
			wep = weapons.Get(text[2])
		end
		if IsValid(plyToGiv) and plyToGiv:Alive() and (plyToGiv:IsPlaying() or nzRound:InState(ROUND_CREATE)) then
			if wep then
				plyToGiv:Give(wep.ClassName)
			else
				ply:ChatPrint("[nZ] No valid weapon provided.")
			end
		else
			ply:ChatPrint("[nZ] The player you have selected is either not valid or not alive.")
		end
	end, false, "[playerName] weaponName   Give a weapon to yourself or another player.")

	nzChatCommand.Add("/giveperk", function(ply, text)
		local plyToGiv = player.GetByName(text[1])

		local perk

		if !plyToGiv then
			perk = text[1]
			plyToGiv = ply
		else
			perk = text[2]
		end
		if IsValid(plyToGiv) and plyToGiv:Alive() and (plyToGiv:IsPlaying() or nzRound:InState(ROUND_CREATE)) then
			if nzPerks:Get(perk) then
				plyToGiv:GivePerk(perk)
			else
				ply:ChatPrint("[nZ] No valid perk provided.")
			end
		else
			ply:ChatPrint("[nZ] The player you have selected is either not valid or not alive.")
		end
	end, false, "[playerName] perkID   Give a perk to yourself or another player.")

	nzChatCommand.Add("/givepowerup", function(ply, text) -- Added by Ethorbit as doing this through lua or the cheat menu is tedious
		local plyToGiv = player.GetByName(text[1])
		local powerup

		if !plyToGiv then
			powerup = text[1]
			plyToGiv = ply
		else
			powerup = text[2]
		end

		if IsValid(plyToGiv) then
			local data = nzPowerUps.Data
			if data[powerup] then
				nzPowerUps:SpawnPowerUp(plyToGiv:GetPos(), powerup)
			else
				ply:ChatPrint("[nZ] The provided PowerUp ID is invalid.")
			end
		else
			ply:ChatPrint("[nZ] The player you have selected is either not valid or not alive.")
		end
	end, false, "[playerName] PowerUp ID   Spawn a powerup on yourself or another player.")

	nzChatCommand.Add("/targetpriority", function(ply, text)
		local plyToGiv
		local strstart, strend = string.find(text[1], "entity(", 1, true)
		if strstart then
			local _, strstop = string.find(text[1], ")", strend, true)
			local ent = string.sub(text[1], strend + 1, strstop - 1)
			if ent and IsValid(Entity(ent)) then
				plyToGiv = Entity(ent)
			end
		else
			plyToGiv = player.GetByName(text[1])
		end

		local priority

		if !plyToGiv then
			priority = tonumber(text[1])
			plyToGiv = ply
		else
			priority = tonumber(text[2])
		end
		if IsValid(plyToGiv) and (!plyToGiv:IsPlayer() or (plyToGiv:Alive() and (plyToGiv:IsPlaying() or nzRound:InState(ROUND_CREATE)))) then
			if priority then
				plyToGiv:SetTargetPriority(priority)
			else
				ply:ChatPrint("[nZ] No valid priority provided.")
			end
		else
			ply:ChatPrint("[nZ] The player you have selected is either not valid or not alive.")
		end
	end)

	nzChatCommand.Add("/activateelec", function(ply, text)
		nzElec:Activate()
	end)

	nzChatCommand.Add("/boss", function(ply, text)
		local bossType = nzMapping.Settings.bosstype
		if bossType then
			nzRound:SpawnBoss(bossType)
		else
			ply:ChatPrint("[nZ] There doesn't seem to be a boss configured for this map..")
		end
	end, false, "Spawn config's BossType infront of you.")

	nzChatCommand.Add("/navflush", function(ply, text)
		nzNav.FlushAllNavModifications()
		PrintMessage(HUD_PRINTTALK, "[nZ] Navlocks successfully flushed. Remember to redo them for best playing experience.")
	end)

	nzChatCommand.Add("/tools", function(ply, text)
		if ply:IsInCreative() then
			ply:Give("weapon_physgun")
			ply:Give("nz_multi_tool")
		end
	end, true, "Give creative mode tools to yourself if in Creative.")

	nzChatCommand.Add("/maxammo", function(ply, text)
		nzNotifications:PlaySound("nz/powerups/max_ammo.mp3", 2)
		-- Give everyone ammo
		for k,v in pairs(player.GetAll()) do
			v:GiveMaxAmmo()
		end
	end, false, "Gives all players max ammo.")
end
