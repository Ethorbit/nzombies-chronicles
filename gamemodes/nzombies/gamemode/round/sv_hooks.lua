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

function nzRound:OnPlayerReady( ply )

	self:SendReadyState( ply, true )

	--Start Round if we have enough players
	if self:InState( ROUND_WAITING ) and #player.GetAllReady() > #player.GetAllNonSpecs() / 3 then
		self:Init()
	end

end

function nzRound:OnPlayerUnReady( ply )

	self:SendReadyState( ply, false )

end

function nzRound:OnPlayerDropIn( ply )

	self:SendPlayingState( ply, true )
	self:SendReadyState( ply, true )

end

function nzRound:OnPlayerDropOut( ply )

	self:SendPlayingState( ply, false )
	self:SendReadyState( ply, false )

end
