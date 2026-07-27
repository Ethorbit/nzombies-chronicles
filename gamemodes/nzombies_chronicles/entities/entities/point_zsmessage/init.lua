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

ENT.NZEntity = true

function ENT:Initialize()
	-- Remove it as soon as it spawns, if the gamemode hasn't been enabled in Map Settings
	if !nzMapping.Settings.gamemodeentities then
		self:Remove()
	end
	self.SendTo = self.SendTo or -1
end

function ENT:Think()
end

function ENT:AcceptInput(name, caller, activator, args)
	name = string.lower(name)
	if name == "message" then
		args = args or ""

		args = string.gsub(args, "<.-=.->", "")
		args = string.gsub(args, "</.->", "")

		if self.SendTo == 0 then
			nz_zsCenterNotifyAll(args)
		elseif self.SendTo == -1 then
			for _, pl in pairs(player.GetAll()) do
				if pl == activator or pl == caller then
					nz_zsCenterNotifyPlayer(pl, args)
					break
				end
			end
		else
			for _, pl in pairs(player.GetAll()) do
				if self.SendTo == TEAM_HUMAN then -- Only humans
					nz_zsCenterNotifyPlayer(pl, args)
				end
			end
		end

		return true
	elseif name == "setundeadhudmessage" or name == "setzombiehudmessage" then
		SetGlobalString("hudoverride"..TEAM_UNDEAD, args)
	elseif name == "sethumanhudmessage" or name == "setsurvivorhudmessage" then
		--SetGlobalString("hudoverride"..TEAM_HUMAN, args)
	elseif name == "clearundeadhudmessage" or name == "clearzombiehudmessage" then
		--SetGlobalString("hudoverride"..TEAM_UNDEAD, "")
	elseif name == "clearhumanhudmessage" or name == "clearsurvivorhudmessage" then
		SetGlobalString("hudoverride"..TEAM_HUMAN, "")
	end
end

function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "team" then
		value = string.lower(value or "")
		if value == "zombie" or value == "undead" or value == "zombies" then
			self.SendTo = TEAM_UNDEAD
		elseif value == "human" or value == "humans" then
			self.SendTo = TEAM_HUMAN
		elseif value == "activator" or value == "caller" or value == "private" then
			self.SendTo = -1
		else
			self.SendTo = 0
		end
	end
end
