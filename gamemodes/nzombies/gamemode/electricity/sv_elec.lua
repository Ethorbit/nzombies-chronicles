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

--

function nzElec:Activate(nochat)

	--if self.Active then return end -- We don't wanna turn it on twice

	self.Active = true
	self:SendSync()
	
	-- Open all doors with no price and electricity requirement
	for k,v in pairs(ents.GetAll()) do
		if v:IsBuyableEntity() then
			local data = v:GetDoorData()
			if data then
				if tonumber(data.price) == 0 and tobool(data.elec) == true then
					nzDoors:OpenDoor( v )
				end
			end
		end
	end
	
	-- Turn on all perk machines
	for k,v in pairs(ents.FindByClass("perk_machine")) do
		v:TurnOn()
	end
	
	for k,v in pairs(ents.FindByClass("wunderfizz_machine")) do
		v:TurnOff() -- Reset all Wunderfizz's
	end
	
	local wund = ents.FindByClass("wunderfizz_machine")
	local machine = wund[math.random(#wund)]
	if IsValid(machine) then machine:TurnOn() end
	
	-- Inform players
	if !nochat then
		PrintMessage(HUD_PRINTTALK, "[nZ] Electricity is on!")
		net.Start("nz.nzElec.Sound")
			net.WriteBool(true)
		net.Broadcast()
	end
	
	for k,v in pairs(ents.FindByClass("nz_electricity")) do
		v:Fire("OnElectricityOn")
	end
	
	hook.Call("ElectricityOn")
	
end

function nzElec:Reset(nochat)

	if !self.Active then return end -- No need to turn it off again
	
	self.Active = false
	-- Reset the button aswell
	local prevs = ents.FindByClass("power_box")
	for k,v in pairs(prevs) do
		v:SetSwitch(false)
	end
	
	-- Turn off all perk machines
	for k,v in pairs(ents.FindByClass("perk_machine")) do
		v:TurnOff()
	end
	
	-- And Wunderfizz Machines
	for k,v in pairs(ents.FindByClass("wunderfizz_machine")) do
		v:TurnOff()
	end
	
	self:SendSync()
	
	if !nochat then
		net.Start("nz.nzElec.Sound")
			net.WriteBool(false)
		net.Broadcast()
	end
	
	for k,v in pairs(ents.FindByClass("nz_electricity")) do
		v:Fire("OnElectricityOff")
	end
	
	hook.Call("ElectricityOff")
	
end
