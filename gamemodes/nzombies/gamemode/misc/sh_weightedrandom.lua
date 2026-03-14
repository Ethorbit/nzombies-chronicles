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

-- http://snippets.luacode.org/snippets/Weighted_random_choice_104

-- Modified to allow special weight keys

local function weighted_total( choices, weightkey )
	local total = 0
	if weightkey then
		for choice, weight in pairs(choices) do
			total = total + weight[weightkey]
		end
	else
		for choice, weight in pairs(choices) do
			total = total + weight
		end
	end
	return total
end

local function weighted_random_choice( choices, weightkey )
	local threshold = math.random(0, weighted_total( choices, weightkey ))
	local last_choice
	if weightkey then
		for choice, weight in pairs(choices) do
			threshold = threshold - weight[weightkey]
			if threshold <= 0 then return choice end
			last_choice = choice
		end
	else
		for choice, weight in pairs(choices) do
			threshold = threshold - weight
			if threshold <= 0 then return choice end
			last_choice = choice
		end
	end
	return last_choice
end

function nzMisc.WeightedRandom( choices, weightkey )
	return weighted_random_choice( choices, weightkey )
end
