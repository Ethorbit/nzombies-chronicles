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

AddCSLuaFile()

ENT.Author = "Ethorbit"
ENT.Base = "nz_zombiebase"
ENT.NZBoss = true -- So nZombies knows that we're actually a boss. ENT.BossType is applied automatically in rounds, but this is still useful.
ENT.PauseOnAttack = false -- It's too easy if we stop before each attack
ENT.IgnoreDistractions = true -- Ignore stuff like monkey bombs, we only care about the player.

-- We should shred right through barricades
ENT.BarricadeRemoveAmount = 999
ENT.BarricadeWaitForZombies = false

ENT.CanStrafe = false -- We want to reach our target as quickly as possible. Let the zombies overwhelm them.
