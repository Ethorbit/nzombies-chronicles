--[[ LICENSE HEADER MANAGED BY add-license-header

Copyright (C) 2014-2015 Alig96
Copyright (C) 2015-2017 Zet0rz
Copyright (C) 2016-2017 lolleko
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


local function cleanrag(ent, ragdoll, time)
	local dTime = math.random( time*0.75, time*1.25 )

	if ent.GetDecapitated and ent:GetDecapitated() then
		local bone = ragdoll:LookupBone("ValveBiped.Bip01_Head1")
		if !bone then bone = ragdoll:LookupBone("j_head") end

		if bone then
			ragdoll:ManipulateBoneScale(bone, Vector(0.00001,0.00001,0.00001))
			--- Y GMOD YYYYYYYY I DONT UNDERSTAND
			ragdoll:ManipulateBoneScale(bone, Vector(0.00001,0.00001,0.00001))
		end
	end

	--[[
	timer.Simple( dTime, function()
		if IsValid(ragdoll) then
			ragdoll:PhysWake()
			ragdoll:SetMoveType(MOVETYPE_NOCLIP)
			ragdoll:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
			-- ragdoll:Fire("EnableMotion")
			PrintTable(debug.getmetatable(ragdoll))
			for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do

				local phys = ragdoll:GetPhysicsObjectNum( i )
				phys:Wake()
				phys:EnableCollisions(false)
				phys:EnableGravity(false)
				phys:SetVelocityInstantaneous( Vector( 0, 0, -15) )

				-- apply another push after dealy
				timer.Simple(2, function() if IsValid(phys) then phys:SetVelocityInstantaneous(Vector( 0, 0, -20)) end end)
			end
			ragdoll:SetVelocity(Vector( 0, 0, -15))
		end
	end)
	]]--
	SafeRemoveEntityDelayed( ragdoll, dTime + 2.5 )
end

if CLIENT then
	if not ConVarExists("nz_client_ragdolltime") then CreateConVar("nz_client_ragdolltime", 30, {FCVAR_ARCHIVE}, "How long clientside Zombie ragdolls will stay in the map.") end

	function GM:CreateClientsideRagdoll( ent, ragdoll )
		local convar = GetConVar("nz_client_ragdolltime"):GetInt()
		cleanrag(ent, ragdoll, convar)
	end
else -- Server ragdolls
	if not ConVarExists("nz_server_ragdolltime") then CreateConVar("nz_server_ragdolltime", 30, {FCVAR_ARCHIVE}, "How long serverside Zombie ragdolls will stay in the map.") end

	function GM:CreateEntityRagdoll( ent, ragdoll )
		local convar = GetConVar("nz_server_ragdolltime"):GetInt()
		cleanrag(ent, ragdoll, convar)
	end
end
