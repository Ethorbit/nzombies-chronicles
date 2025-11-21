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

nzTools:CreateTool("rbox", {
	displayname = "Random Box Spawnpoint",
	desc = "LMB: Place Random Box Spawnpoint, RMB: Remove Random Box Spawnpoint",
	condition = function(wep, ply)
		return true
	end,

	PrimaryAttack = function(wep, ply, tr, data)
		nzMapping:BoxSpawn(tr.HitPos, Angle(0,(tr.HitPos - ply:GetPos()):Angle()[2] - 90,0), data.PossibleSpawn, ply)
	end,

	SecondaryAttack = function(wep, ply, tr, data)
		if IsValid(tr.Entity) and tr.Entity:GetClass() == "random_box_spawns" then
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
	displayname = "Random Box Spawnpoint",
	desc = "LMB: Place Random Box Spawnpoint, RMB: Remove Random Box Spawnpoint",
	icon = "icon16/briefcase.png",
	weight = 4,
	condition = function(wep, ply)
		return true
	end,
	interface = function(frame, data)
		local valz = {}
		valz["Row1"] = data.PossibleSpawn

		local DProperties = vgui.Create( "DProperties", frame )
		DProperties:SetSize( 280, 180 )
		DProperties:SetPos( 110, 20 )
		
		function DProperties.CompileData()
			data.PossibleSpawn = valz["Row1"]
			return data
		end
		
		function DProperties.UpdateData(data)
			nzTools:SendData(data, "rbox")
		end

		local Row1 = DProperties:CreateRow( "Random Box", "Possible Spawn?" )
		Row1:Setup( "Boolean" )
		Row1:SetValue( valz["Row1"] )
		Row1.DataChanged = function( _, val ) valz["Row1"] = val DProperties.UpdateData(DProperties.CompileData()) end

		return DProperties
	end,
	defaultdata = {
		PossibleSpawn = 0,
	}
})
