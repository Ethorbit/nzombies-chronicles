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

function nzRound:GetState() return self.State end
function nzRound:SetState( state ) self.State = state end

function nzRound:GetNumber() return self.Number or 0 end
function nzRound:SetNumber( num ) self.Number = num end

function nzRound:IsSpecial() return self.SpecialRound or false end
function nzRound:SetSpecial( bool ) self.SpecialRound = bool end

function nzRound:InState( state )
	return nzRound:GetState() == state
end

function nzRound:InProgress()
	return nzRound:GetState() == ROUND_PREP or nzRound:GetState() == ROUND_PROG
end

-- Extra stuff brought in by: Ethorbit
function nzRound:SetZombiesMax(num)
	self.ZombiesMax = num
	hook.Run("NZ.UpdateZombiesMax", num)
end
function nzRound:GetZombiesMax() return self.ZombiesMax or 0 end

function nzRound:SetZombiesKilled(num)
	self.ZombiesKilled = num
	hook.Run("NZ.UpdateZombiesKilled", num)
end
function nzRound:GetZombiesKilled() return self.ZombiesKilled or 0 end

 -- Commented because I gave zombiebase entities a :GetMaxHealth(), which supports more than just walkers like this does.
-- function nzRound:SetZombieHealth(num) self.ZombieHealth = num end
-- function nzRound:GetZombieHealth() return self.ZombieHealth or 0 end

function nzRound:SetZombieSpeeds(tbl) self.ZombieSpeeds = tbl end
function nzRound:GetZombieSpeeds() return self.ZombieSpeeds or {} end
