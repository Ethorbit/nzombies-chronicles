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

local defaultdata = {
	DownTime = true,
	ReviveTime = true,
	RevivePlayer = true,
}

function nzRevive:PlayerDowned( ply )
	local attdata = {}
	-- Attach whatever other data was attached to the table, other than the default ones
	for k,v in pairs(nzRevive.Players[ply:EntIndex()]) do
		if !defaultdata[k] then attdata[k] = v end
	end
	self:SendPlayerDowned( ply, nil, attdata )
end

function nzRevive:PlayerRevived( ply )
	if (IsValid(ply)) then
		if (!ply:IsPlayer()) then
			ply = ply:GetPerkOwner()
		end

		if (IsValid(ply) and ply:IsPlayer()) then
			ply:SetUsingSpecialWeapon(false)
		end
	end
	self:SendPlayerRevived( ply )
end

function nzRevive:PlayerBeingRevived( ply, revivor )
	self:SendPlayerBeingRevived( ply, revivor )
end

function nzRevive:PlayerNoLongerBeingRevived( ply )
	self:SendPlayerBeingRevived( ply ) -- No second argument means no revivor
end


function nzRevive:PlayerKilled( ply )
	self:SendPlayerKilled( ply )
end
