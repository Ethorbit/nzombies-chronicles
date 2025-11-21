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

//

function nzEE:Reset()
	-- Reset the counter of eggs
	self.Data.EggCount = 0
	self.Data.MaxEggCount = 0

	-- Reset all easter eggs
	for k,v in pairs(ents.FindByClass("easter_egg")) do
		v.Used = false
	end
	hook.Call("OnEasterEggsReset")
end

function nzEE:ActivateEgg( ent, ply )

	ent.Used = true
	ent:EmitSound("WeaponDissolve.Dissolve", 100, 100)

	self.Data.EggCount = self.Data.EggCount + 1
	hook.Call( "OnEasterEggFound", ply, ent )

	if self.Data.MaxEggCount == 0 then
		self.Data.MaxEggCount = #ents.FindByClass("easter_egg")
	end

	-- What we should do when we have all the eggs
	if self.Data.EggCount == self.Data.MaxEggCount then
		print("All easter eggs found yay!")
		hook.Call( "OnAllEasterEggsFound", ply, ent )
	end
end

util.AddNetworkString("EasterEggSong")
util.AddNetworkString("EasterEggSongPreload")
util.AddNetworkString("EasterEggSongStop")

hook.Add("OnAllEasterEggsFound", "PlayEESong", function()
	net.Start("EasterEggSong")
	net.Broadcast()
end)

hook.Add("OnEasterEggsReset", "StopEESong", function()
	net.Start("EasterEggSongStop")
	net.Broadcast()
end)

hook.Add("PlayerFullyInitialized", "PreloadEESongSpawn", function(ply)
	-- Send players the map settings - this will trigger the preload client-side
	net.Start("nzMapping.SyncSettings")
		net.WriteTable(nzMapping.Settings)
	net.Send(ply)
end)
