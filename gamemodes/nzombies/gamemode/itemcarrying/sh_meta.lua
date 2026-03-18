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

local playerMeta = FindMetaTable("Player")
if SERVER then

	function playerMeta:GiveCarryItem(id, alloverride)
		if !nzItemCarry.Players[self] then nzItemCarry.Players[self] = {} end
		if nzItemCarry.Items[id].shared and !alloverride then -- If shared, give to all players
			for k,v in pairs(player.GetAllPlaying()) do
				if !table.HasValue(nzItemCarry.Players[v], id) then
					table.insert(nzItemCarry.Players[v], id)
				end
			end
			nzItemCarry:SendPlayerItem()
			if nzItemCarry.Items[id].notif then
				nzItemCarry:SendPlayerItemNotification(nil, id)
			end
		else
			if !table.HasValue(nzItemCarry.Players[self], id) then
				table.insert(nzItemCarry.Players[self], id)
				nzItemCarry:SendPlayerItem(self)
				if nzItemCarry.Items[id].notif then
					nzItemCarry:SendPlayerItemNotification(self, id)
				end
			end
		end
	end
	
	function playerMeta:RemoveCarryItem(id, alloverride)
		if !nzItemCarry.Players[self] then nzItemCarry.Players[self] = {} end
		if nzItemCarry.Items[id].shared and !alloverride then -- If shared, remove from all players
			for k,v in pairs(player.GetAllPlaying()) do
				if table.HasValue(nzItemCarry.Players[v], id) then
					table.RemoveByValue(nzItemCarry.Players[v], id)
				end
			end
			nzItemCarry:SendPlayerItem()
		else
			if table.HasValue(nzItemCarry.Players[self], id) then
				table.RemoveByValue(nzItemCarry.Players[self], id)
				nzItemCarry:SendPlayerItem(self)
			end
		end
	end
	
end

function playerMeta:HasCarryItem(id)
	if !nzItemCarry.Players[self] then nzItemCarry.Players[self] = {} end
	return table.HasValue(nzItemCarry.Players[self], id)
end

function playerMeta:GetCarryItems()
	if !nzItemCarry.Players[self] then nzItemCarry.Players[self] = {} end
	return nzItemCarry.Players[self]
end

-- On player downed
hook.Add("PlayerDowned", "nzDropCarryItems", function(ply)
	if ply.GetCarryItems then
		for k,v in pairs(ply:GetCarryItems()) do
			local item = nzItemCarry.Items[v]
			if item.dropondowned and item.dropfunction then
				item:dropfunction(ply)
				ply:RemoveCarryItem(v)
			end
		end
	end
end)

-- Players disconnecting/dropping out need to reset the item so it isn't lost forever
hook.Add("OnPlayerDropOut", "nzResetCarryItems", function(ply)
	for k,v in pairs(ply:GetCarryItems()) do
		local item = nzItemCarry.Items[v]
		if item.dropondowned and item.dropfunction then
			item:dropfunction(ply)
		else
			item:resetfunction()
		end
	end
	nzItemCarry.Players[ply] = nil
	nzItemCarry:SendPlayerItem() -- No arguments for full sync, cleans the table of this disconnected player
end)
