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

-- Fixed by Ethorbit

AddCSLuaFile( )

ENT.Type = "anim"
ENT.Base = "base_entity"

nzLogic:Register("nz_button_and")
ENT.SpawnIcon = "models/maxofs2d/button_03.mdl"
ENT.PrintName = "AND Gate/Button"
ENT.Description = "This Gate will trigger if all activators linked to this buttons are activated at the same time."

ENT.NZEntity = true

DEFINE_BASECLASS("nz_button")

function ENT:ButtonSetupDataTables()
	self:SetModelID(5)

	self:NetworkVar( "String", 1, "ActivatorNZName1", {KeyName = "nz_activator_name1", Edit = {title = "Button Flag 1", order = 20, type = "Generic"}} )
	self:NetworkVar( "String", 2, "ActivatorNZName2", {KeyName = "nz_activator_name2", Edit = {title = "Button Flag 2", order = 21, type = "Generic"}} )
	self:NetworkVar( "String", 3, "LinkedNZName", {KeyName = "nz_linked_name1", Edit = {order = 23, type = "Generic"}} )

	self:SetRemoteActivated(true)
end

function ENT:GetLinkedEnts()
	local result = {}
	table.insert(result, self:GetEntsByNZName(self:GetLinkedNZName()))
	return result
end

function ENT:GetActivatorEnts()
	local result = {}
	table.insert(result, self:GetEntsByNZName(self:GetActivatorNZName1()))
	table.insert(result, self:GetEntsByNZName(self:GetActivatorNZName2()))
	table.insert(result, self:GetEntsByNZName(self:GetActivatorNZName3()))
	return result
end

function ENT:Activation(caller, duration, cooldown)
	local shouldBeActivated = true

	-- only activated if all activators are active
	for _, lEntsWithName in pairs(self:GetActivatorEnts()) do
		for _, lEnt in pairs(lEntsWithName) do
			if IsValid(lEnt) and not lEnt:IsPlayer() then
				print(lEnt, lEnt:IsActive())
				if not lEnt:IsActive() then
					shouldBeActivated = false
				end
			end
		end
	end

	if shouldBeActivated then
		BaseClass.Activation(self, caller, duration, cooldown)
	end
end

function ENT:Ready()
	BaseClass.Ready(self)
end

function ENT:Use()
	-- prevent using the and gate
	return false
end

-- IMPLEMENT ME
function ENT:OnActivation(caller, duration, cooldown) end

function ENT:OnDeactivation() end

function ENT:OnReady() end
