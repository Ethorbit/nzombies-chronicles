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

--

if SERVER then

	function nzNotifications:PlaySound(path, delay)
		self:SendRequest("sound", {path = path, delay = delay})
	end
	
end

if CLIENT then
	
	function nzNotifications:AddSoundToQueue(data)
		table.insert(self.Data.SoundQueue, data)
	end
	
	function nzNotifications.SoundHandler()
		-- Check we're allowed to play the next sound
		if CurTime() > nzNotifications.Data.NextSound then
			-- Check the queue
			if nzNotifications.Data.SoundQueue[1] != nil then
				local data = nzNotifications.Data.SoundQueue[1]
				table.remove(nzNotifications.Data.SoundQueue, 1)
				surface.PlaySound( data.path )
				nzNotifications.Data.NextSound = CurTime() + data.delay
			end
		end
	end
	
	timer.Create("nz.Sound.Handler", 1, 0, nzNotifications.SoundHandler)
end



