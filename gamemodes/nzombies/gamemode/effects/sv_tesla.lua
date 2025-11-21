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

--Name: Tesla Effect using point_tesla
--Author: Lolle
--
--
--Arguments:
--
--Data Table:
--
--pos: vector required
--
--ent: entity required
--
--radius: float or string def: 50
--
--beamcountMin : integer or string def:20
--beamcountMax : integer or string def:35
--
--color: string "r g b" def: 255 255 255
--
--texture: string (path to .vmt relative to materials) def: effects/tool_tracer.vmt
--
--turnOn: boolean def: false (true will periodically emit lightnigs)
--
--Interval, how often arcs will be emitted (only makes sense with higher dieTime and turnOn = true)
--intervalMin: float (seconds) or string def: 0.5
--intervalMax: float (seconds) or string def: 0.5
--
--dieTime: float (seconds) def: 3 (use nil or false to prevent removal)
--
--thickMin: float or string def:5 (lighnting thickness)
--thickMax: float or string def 15
--
--MakeSure to adjust the dieTime atleast to lifetimeMax*2
--lifetimeMin: float or string def: 0.3 (lighnting lifetime)
--lifetimeMax: float or string def: 0.55
--
--sound: string def: weapons/physcannon/superphys_small_zap1.wav (sound to play on emit)
--Return:
--
--Returns wether the effect could be created or not
--returns: boolean
--

function nzEffects:Tesla( data )

	local tesla = ents.Create("point_tesla")

	if not IsValid( tesla ) then return false end
	tesla:SetPos( data.pos )
	tesla:SetParent( data.ent )
	tesla:SetOwner( data.ent )

	tesla:SetKeyValue("texture", data.texture and tostring(data.texture) or "trails/electric.vmt")
	tesla:SetKeyValue("m_iszSpriteName", "sprites/physbeam.vmt")
	tesla:SetKeyValue("m_Color", data.color and tostring(data.color) or "255 255 255")
	tesla:SetKeyValue("m_flRadius", data.radius and tostring(data.radius) or "50")
	tesla:SetKeyValue("interval_min", data.intevalMin and tostring(data.intervalMin) or "0.5")
	tesla:SetKeyValue("interval_max", data.intervalMax and tostring(data.intervalMax) or "0.5")
	tesla:SetKeyValue("beamcount_min", data.beamcountMin and tostring(data.beamcountMin) or "20")
	tesla:SetKeyValue("beamcount_max", data.beamcountMax and tostring(data.beamcountMax) or "35")
	tesla:SetKeyValue("thick_min", data.thickMin and tostring(data.thickMin) or "5")
	tesla:SetKeyValue("thick_max", data.thickMax and tostring(data.thickMax) or "15")
	tesla:SetKeyValue("lifetime_min", data.lifetimeMin and tostring(data.lifetimeMin) or "0.3")
	tesla:SetKeyValue("lifetime_max", data.lifetimeMax and tostring(data.lifetimeMax) or "0.55")
	tesla:SetKeyValue("m_SoundName", data.sound and tostring(data.sound) or tostring("weapons/physcannon/superphys_small_zap" .. math.random(1,4) .. ".wav"))

	tesla:Spawn()
	tesla:Activate()

	if data.turnOn then
		tesla:Fire("TurnOn", "", 0)
	else
		--emit one spark
		tesla:Fire("DoSpark", "", 0)
	end

	if data.dieTime then
		SafeRemoveEntityDelayed( tesla, data.dieTime or 3 )
	end

	return true

end
