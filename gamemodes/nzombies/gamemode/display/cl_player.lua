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

--if (game.SinglePlayer()) then -- InitPostEntity seems to fail for Singleplayer? Weird..
playerColors = {
	Color(239,154,154),
	Color(244,143,177),
	Color(159,168,218),
	Color(129,212,250),
	Color(128,203,196),
	Color(165,214,167),
	Color(230,238,156),
	Color(255,241,118),
	Color(255,224,130),
	Color(255,171,145),
	Color(161,136,127),
	Color(224,224,224),
	Color(144,164,174),
}

local blooddecalsFallback = {
	Material("bloodline_score1.png", "unlitgeneric smooth"),
	Material("bloodline_score2.png", "unlitgeneric smooth"),
	Material("bloodline_score3.png", "unlitgeneric smooth"),
	Material("bloodline_score4.png", "unlitgeneric smooth"),
	nil
}

function player.GetColorByIndex(index)
	local color = playerColors[((index) % #playerColors)]
	if color == nil then color = Color(math.random(0, 255), math.random(0, 255), math.random(0, 255), 255) end
	return color
end

function player.GetBloodByIndex(index)
	return NZCustomPointsHUD != nil and NZCustomPointsHUD[((index) % #NZCustomPointsHUD) + 1] or blooddecalsFallback[((index) % #blooddecalsFallback) + 1]
end
--return end

-- hook.Add("InitPostEntity", "ColorAndBloodFunc", function()
	
-- end)


net.Receive("NZPlayerColors", function() -- Synchronise player colors from the server so that everyone sees the same colors
	local newTbl = net.ReadTable()
	if !newTbl || table.IsEmpty(newTbl) then return end
	playerColors = newTbl
end)

