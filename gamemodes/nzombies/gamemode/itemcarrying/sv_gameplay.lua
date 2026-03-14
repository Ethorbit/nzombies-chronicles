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


function nzItemCarry.OnPlayerPickItemUp( ply, ent )
	-- Downed players can't pick up anything!
	if !ply:GetNotDowned() then return false end
	
	-- Players can't pick stuff up while using special weapons! (Perk bottles, knives, etc)
	if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():IsSpecial() then return false end
	
	-- Used in map scripting
	if ent.OnUsed and type(ent.OnUsed) == "function" then
		if ply:KeyPressed(IN_USE) then
			ent:OnUsed(ply)
		end
	end
	
	local category = ent:GetNWString("NZItemCategory")
	if category != "" then
		local item = nzItemCarry.Items[category]
		if item.pickupfunction and item:condition(ply) then -- If it has a pickup function and it is allowed in this case
			--print("allowed")
			item:pickupfunction(ply, ent)
		end
	end
end
hook.Add( "PlayerUse", "nzPlayerPickupItems", nzItemCarry.OnPlayerPickItemUp )

function nzItemCarry.RemoveItemsOnRemoved( ent )
	local item = nzItemCarry.Items[ent:GetNWString("NZItemCategory")]
	if item and item.items and table.HasValue(item.items, ent) then
		table.RemoveByValue(item.items, ent)
	end
end
hook.Add( "EntityRemoved", "nzItemCarryRemoveItems", nzItemCarry.RemoveItemsOnRemoved )

-- These correctly obey Use types (SIMPLE_USE etc.) by directly injecting into ENTITY:Use()

local meta = FindMetaTable("Entity")
function meta:AddUseFunction( func )
	local olduse = self.Use
	if olduse then
		self.Use = function(self2,a,b,c,d)
			olduse(self2,a,b,c,d)
			func(self2,a,b,c,d)
		end
	else
		self:ReplaceUseFunction(func)
	end
end
function meta:ReplaceUseFunction( func )
	self.Use = function(self2,a,b,c,d)
		func(self2,a,b,c,d)
	end
end
