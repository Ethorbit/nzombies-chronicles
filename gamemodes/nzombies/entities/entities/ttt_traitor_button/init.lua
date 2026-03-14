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

AddCSLuaFile("shared.lua")
include("shared.lua")

-- serverside only
ENT.RemoveOnPress = false

ENT.Model = Model("models/weapons/w_bugbait.mdl")

function ENT:Initialize()
	self:SetModel(self.Model)

	--self:SetNoDraw(true)
	self:DrawShadow(false)
	self:SetSolid(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)

	self:SetDelay(self.RawDelay or 1)

	if self:GetDelay() < 0 then
		-- func_button can be made single use by setting delay to be negative, so
		-- mimic that here
		self.RemoveOnPress = true
	end

	if self.RemoveOnPress then
		self:SetDelay(-1) -- tells client we're single use
	end

	if self:GetUsableRange() < 1 then
		self:SetUsableRange(1024)
	end

	self:SetNextUseTime(0)
	self:SetTTTLocked(self:HasSpawnFlags(2048))

	self:SetDescription(self.RawDescription or "?")

	self.RawDelay = nil
	self.RawDescription = nil
end

function ENT:KeyValue(key, value)
	if key == "OnPressed" then
		self:StoreOutput(key, value)
	elseif key == "wait" then -- as Delay Before Reset in func_button
		self.RawDelay = tonumber(value)
	elseif key == "description" then
		self.RawDescription = tostring(value)

		if self.RawDescription and string.len(self.RawDescription) < 1 then
			self.RawDescription = nil
		end
	elseif key == "RemoveOnPress" then
		self[key] = tobool(value)
	else
		self:SetNetworkKeyValue(key, value)
	end
end


function ENT:AcceptInput(name, activator)
	if name == "Toggle" then
		self:SetTTTLocked(not self:GetTTTLocked())
		return true
	elseif name == "Hide" or name == "Lock" then
		self:SetTTTLocked(true)
		return true
	elseif name == "Unhide" or name == "Unlock" then
		self:SetTTTLocked(false)
		return true
	end
end

function ENT:TraitorUse(ply)
	if not (IsValid(ply) and ply:IsPlaying() and ply:GetNotDowned()) then return false end
	if not self:IsUsable() then return false end

	--if self:GetPos():Distance(ply:GetPos()) > self:GetUsableRange() then return false end

	-- send output to all entities linked to us
	self:TriggerOutput("OnPressed", ply)

	if self.RemoveOnPress then
		self:SetTTTLocked(true)
		self:Remove()
	else
		-- lock ourselves until we should be usable again
		self:SetNextUseTime(CurTime() + self:GetDelay())
	end

	return true
end

--[[function ENT:Use(activator)
	if self:IsUsable() then
		local data = self:GetDoorData()
		if data then
			if data.price <= 0 or activator:CanAfford(data.price) then
				self:TraitorUse(activator)
				activator:TakePoints(data.price)
			end
		end
	end
end]]

function ENT:UseViaButtonBox(user)
	if self:IsUsable() then
		local data = self:GetDoorData()
		if data then
			if data.price <= 0 or activator:CanAfford(data.price) then
				self:TraitorUse(activator)
				activator:TakePoints(data.price)
			end
		end
	end
end
