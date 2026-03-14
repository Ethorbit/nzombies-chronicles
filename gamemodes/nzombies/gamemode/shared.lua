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

GM.Name = "nZombies"
GM.Author = "Alig96, Zet0r, Lolle"
GM.Email = "N/A"
GM.Website = "N/A"

-- Constants --

--Round Constants

ROUND_WAITING = 0
ROUND_INIT = 1
ROUND_PREP = 2
ROUND_PROG = 3
ROUND_CREATE = 4
ROUND_GO = 5

--Team Constants

TEAM_SPECS = 1
TEAM_PLAYERS = 2
TEAM_ZOMBIES = 3

--Setup Teams
team.SetUp( TEAM_SPECS, "Spectators", Color( 255, 255, 255 ) )
team.SetUp( TEAM_PLAYERS, "Players", Color( 255, 0, 0 ) )
team.SetUp( TEAM_ZOMBIES, "Zombies", Color( 0, 255, 0 ) )
