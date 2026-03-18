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

function nzPerks:UpdateQuickRevive()
	if #player.GetAllPlaying() <= 1 then
		for k,v in pairs(ents.FindByClass("perk_machine")) do
			if v:GetPerkID() == "revive" then
				v:SetPrice(500) -- Price is 500 for Solo variant and always on
				v:TurnOn()
			end
		end
	else
		for k,v in pairs(ents.FindByClass("perk_machine")) do
			if v:GetPerkID() == "revive" then
				v:SetPrice(1500) -- Reset to default 1500 and turn off if power is not on
				if !IsElec() then
					v:TurnOff()
				else
					v:TurnOn()
				end
			end
		end
	end
end

hook.Add("OnPlayerDropIn", "UpdateRevive", function()
	nzPerks:UpdateQuickRevive()
end)

hook.Add("OnPlayerDropOut", "UpdateRevive", function()
	nzPerks:UpdateQuickRevive()
end)
