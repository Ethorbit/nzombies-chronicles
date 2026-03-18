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


--AddCSLuaFile()
--DEFINE_BASECLASS( "base_anim" )
ENT.Type = "point"
ENT.Base = "base_point"

ENT.PrintName		= ""
ENT.Author			= "Hidden"
ENT.Contact			= "steamcommunity.com/id/LambdaHidden (tell me you came because of this ENT in the comments)"
ENT.Purpose			= "Lets you check if players are carrying this item. Will be removed if Map Extensions is not ticked in the loaded config."
ENT.Instructions	= ""

ENT.Spawnable			= false
ENT.AdminOnly			= false

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "ID")
end

function ENT:AcceptInput( inputName, activator, called, data )
	if (inputName == "Check") then
		self:Check(activator)
	end
	if (inputName == "CheckAndTake") then
		self:CheckAndTake(activator)
	end
	if (inputName == "Kill") then
		SafeRemoveEntity(self)
	end
end

function ENT:KeyValue( key, value )
	-- Key Values
	--print(key, value)
	if (key == "itemid") then
		self:SetID(value)
	end
	
	-- Outputs
	if ( string.Left( key, 2 ) == "On" ) then
		self:StoreOutput( key, value )
	end
end

function ENT:Check( ply )
	local success = false
	
	--PrintTable(ply:GetCarryItems())
	--print(self:GetID())
	for k,v in pairs(ply:GetCarryItems()) do
		if v == self:GetID() then 
			success = true 
			break 
		end
	end
	
	
	if success then
		self:TriggerOutput("OnCheckSuccess")
	else
		self:TriggerOutput("OnCheckFail")
	end
end

function ENT:CheckAndTake( ply )
	local success = false
	
	for k,v in pairs(ply:GetCarryItems()) do
		if v == self:GetID() then 
			success = true 
			break 
		end
	end
	
	
	if success then
		self:TriggerOutput("OnCheckSuccess")
		ply:RemoveCarryItem(self:GetID())
	else
		self:TriggerOutput("OnCheckFail")
	end
end
/*
function ENT:Initialize()
	
	self:SetModel( "models/MaxOfS2D/cube_tool.mdl" )
	self:SetNoDraw(true)
	--self:PhysicsInit(SOLID_NONE)
	--self.Entity:SetMoveType( MOVETYPE_NONE )
	--self.Entity:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	--self.Entity:SetSolid( SOLID_VPHYSICS )
	--self.Entity:DrawShadow( false )
	--self:SetNWBool("active", false)
	--self:SetNWInt("souls", 0)
end
*/
