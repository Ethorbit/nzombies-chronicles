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

--local plymeta = FindMetaTable( "Player" )

-- hook.Add( "PlayerSpawn", "PlayerSprintSpawn", function( ply )

-- 	ply:SetSprinting( false )
-- 	ply:SetStamina( 100 )
-- 	ply:SetMaxStamina( 100 )

-- 	--The rate is fixed on 0.05 seconds
-- 	ply:SetStaminaLossAmount( 2 )
-- 	ply:SetStaminaRecoverAmount( 4 )

-- 	ply:SetLastStaminaLoss( 0 )
-- 	ply:SetLastStaminaRecover( 0 )
	
-- 	-- Delay this a bit - it seems like it takes the old sprint speed from last round state (Creative speed)
-- 	timer.Simple(0.1, function()
-- 		if IsValid(ply) then
-- 			ply:SetMaxRunSpeed( ply:GetRunSpeed() )
-- 			-- player variables (especially spritn vars) have been initialized
-- 			ply:SetSpawned(true)
-- 		end
-- 	end)
-- 	--print(player_manager.GetPlayerClass(ply))

-- end )


-- hook.Add( "Think", "PlayerSprint", function()
-- 	if !nzRound:InState( ROUND_CREATE ) then
-- 		for _, ply in pairs( player.GetAll() ) do
-- 			if ply:Alive() and ply:GetNotDowned() and ply:IsSprinting() and ply:GetStamina() >= 0 and ply:GetLastStaminaLoss() + 0.05 <= CurTime() then
-- 				ply:SetStamina( math.Clamp( ply:GetStamina() - ply:GetStaminaLossAmount(), 0, ply:GetMaxStamina() ) )
-- 				ply:SetLastStaminaLoss( CurTime() )

-- 				-- Delay the recovery a bit, you can't sprint instantly after
-- 				ply:SetLastStaminaRecover( CurTime() + 0.75 )

-- 				if ply:GetStamina() == 0 then
-- 					ply:SetRunSpeed( ply:GetWalkSpeed() )
-- 					ply:SetSprinting( false )
-- 					ply:ConCommand("-speed") 
-- 				end
-- 			elseif ply:Alive() and ply:GetNotDowned() and !ply:IsSprinting() and ply:GetStamina() < ply:GetMaxStamina() and ply:GetLastStaminaRecover() + 0.05 <= CurTime() then
-- 				ply:SetStamina( math.Clamp( ply:GetStamina() + ply:GetStaminaRecoverAmount(), 0, ply:GetMaxStamina() ) )
-- 				ply:SetLastStaminaRecover( CurTime() )
-- 			end
-- 		end
-- 	end
-- end )

-- hook.Add( "KeyPress", "OnSprintKeyPressed", function( ply, key )
-- 	if !nzRound:InState( ROUND_CREATE ) and ( key == IN_SPEED ) and IsValid(ply) and ply:Alive() then
-- 		ply:SetSprinting( true )
-- 	end
-- end )

-- hook.Add( "KeyRelease", "OnSprintKeyReleased", function( ply, key )
-- 	-- Always reset sprint state even if player is dead.
-- 	-- Reason: player can die while holding shift.
-- 	if !nzRound:InState( ROUND_CREATE ) and ( key == IN_SPEED ) and ply:IsSpawned() then
-- 		ply:SetSprinting( false )
-- 		ply:SetRunSpeed( ply:GetMaxRunSpeed() )
-- 	end
-- end )
