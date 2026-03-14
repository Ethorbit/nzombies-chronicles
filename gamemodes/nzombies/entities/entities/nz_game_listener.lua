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


--AddCSLuaFile()
--DEFINE_BASECLASS( "base_anim" )
ENT.Type = "point"
ENT.Base = "base_point"

ENT.PrintName		= ""
ENT.Author			= "Hidden"
ENT.Contact			= "steamcommunity.com/id/LambdaHidden (tell me you came because of this ENT in the comments)"
ENT.Purpose			= "Fires outputs Fires outputs with game events such as Player Downed or Round Progressed. Will be removed if Map Extensions is not ticked in the loaded config."
ENT.Instructions	= ""

ENT.Spawnable			= false
ENT.AdminOnly			= false

function ENT:AcceptInput( inputName, activator, called, data )
	if (inputName == "Kill") then
		SafeRemoveEntity(self)
	end
end

function ENT:KeyValue( key, value )
	-- Outputs
	if ( string.Left( key, 2 ) == "On" ) then
		self:StoreOutput( key, value )
	end
end

function ENT:Initialize()
	
	--self:SetModel( "models/MaxOfS2D/cube_tool.mdl" )
	--self:SetNoDraw(true)
	--self:PhysicsInit(SOLID_NONE)
	--self.Entity:SetMoveType( MOVETYPE_NONE )
	--self.Entity:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	--self.Entity:SetSolid( SOLID_VPHYSICS )
	--self.Entity:DrawShadow( false )
	local selfent = self
	
	if SERVER then
	hook.Add( "OnGameBegin", "nZListen_OnGameStart", function()
		selfent:TriggerOutput("OnGameStart") end
	)
	hook.Add( "OnRoundPrepare", "nZListen_OnRoundPrepare", function(roundnum)
		selfent:TriggerOutput("OnGameStart", selfent, tostring(roundnum)) end
	)
	hook.Add( "OnRoundStart", "nZListen_OnRoundStart", function(roundnum)
		selfent:TriggerOutput("OnRoundStart", selfent, tostring(roundnum)) end
	)
	hook.Add( "OnPlayerDowned", "nZListen_OnPlayerDowned", function(ply)
		selfent:TriggerOutput("OnPlayerDowned", selfent, tostring(ply)) end
	)
	hook.Add( "OnPlayerDowned", "nZListen_OnPlayerDowned", function(ply)
		selfent:TriggerOutput("OnPlayerDowned", selfent, tostring(ply)) end
	)
	hook.Add( "OnPlayerRevived", "nZListen_OnPlayerRevived", function(ply)
		selfent:TriggerOutput("OnPlayerRevived", selfent, tostring(ply)) end
	)
	hook.Add( "OnGameOver", "nZListen_OnGameOver", function(roundnum)
		selfent:TriggerOutput("OnGameOver", selfent, tostring(roundnum)) end
	)
	hook.Add( "OnGameReset", "nZListen_OnGameReset", function()
		selfent:TriggerOutput("OnGameReset", selfent, "") end
	)
	end
end
