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


ENT.Type = "point"
ENT.Base = "base_point"

ENT.NZEntity = true

-- An entity to be used in Hammer that can turn the electricity on or off, and will fire outputs when this happens.
-- To use it, grab the nzombies.fgd from the gamemode and import it into Hammer.

function ENT:Initialize()
	-- Calling this when the entity is created so you can turn off the lights only if the gamemode is nZombies.
	if engine.ActiveGamemode() == "nzombies3" then
		self:TriggerOutput("OnInitialized", self)
	end
end

function ENT:KeyValue(k, v)
   
end

function ENT:AcceptInput(name, activator, caller, data)
	if name == "TurnElectricityOn" then
		nzElec:Activate(data == "1")
		return true
	elseif name == "TurnElectricityOff" then
		nzElec:Reset(data == "1")
		return true
	end
end
