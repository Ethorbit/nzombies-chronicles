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

nzTools:CreateTool("ee", {
	displayname = "Easter Egg Placer",
	desc = "LMB: Easter Egg, RMB: Remove Easter Egg, Use Player Handler to select song",
	condition = function(wep, ply)
		return true
	end,
	PrimaryAttack = function(wep, ply, tr, data)
		nzMapping:EasterEgg(tr.HitPos, Angle(0,0,0), "models/props_lab/huladoll.mdl", ply)
	end,
	SecondaryAttack = function(wep, ply, tr, data)
		if IsValid(tr.Entity) and tr.Entity:GetClass() == "easter_egg" then
			tr.Entity:Remove()
		end
	end,
	Reload = function(wep, ply, tr, data)
		-- Nothing
	end,
	OnEquip = function(wep, ply, data)

	end,
	OnHolster = function(wep, ply, data)

	end
}, {
	displayname = "Easter Egg Placer",
	desc = "LMB: Easter Egg, RMB: Remove Easter Egg, Use Player Handler to select song",
	icon = "icon16/music.png",
	weight = 20,
	condition = function(wep, ply)
		return true
	end,
	interface = function(frame, data)

	end,
	--defaultdata = {}
})
