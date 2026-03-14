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

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	-- Remove it as soon as it spawns, if the gamemode hasn't been enabled in Map Settings
	if !nzMapping.Settings.gamemodeentities then
		self:Remove()
	end
	
	self:DrawShadow(false)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
end

function ENT:AcceptInput(name, activator, caller, args)
	if name == "setviewer" then
		self:SetKeyValue("viewer", args)
		return true
	elseif name == "sethint" then
		self:SetKeyValue("hint", args)
		return true
	elseif name == "setrange" then
		self:SetKeyValue("range", args)
		return true
	end
end

function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "viewer" then
		self:SetViewable(tonumber(value) or 0)
	elseif key == "hint" then
		self:SetHint(value)
	elseif key == "range" then
		self:SetRange(tonumber(value) or 0)
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end
