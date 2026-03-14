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

-- Damage extensions by: Ethorbit, makes dealing with damage a breeze
-- Customized DamageInfo() -------------------------------------
-- Since DamageInfos share the damage table, you index cTakeDmgInfo inside your getters and setters instead of 'self'
local cTakeDmgInfo = FindMetaTable("CTakeDamageInfo")

-- Add our custom dmginfo methods along with default values
local dmginfo_custom_methods = {
	["DamagePercentage"] = 0,
	["ForcedHeadshot"] = false,
	["IsAfterburnDamage"] = false
}

-- Auto add getters and setters, place them above if you don't want this to do it automatically
for funcName,_ in pairs(dmginfo_custom_methods) do
	local getFuncName = "Get" .. funcName
	local setFuncName = "Set" .. funcName

	if !cTakeDmgInfo[getFuncName] then
		cTakeDmgInfo[getFuncName] = function()
			return cTakeDmgInfo[funcName]
		end
	end

	if !cTakeDmgInfo[setFuncName] then
		cTakeDmgInfo[setFuncName] = function(dmginfo, val)
			cTakeDmgInfo[funcName] = val
		end
	end
end

local meleetypes = {
	[DMG_CLUB] = true,
	[DMG_SLASH] = true,
	[DMG_CRUSH] = true,
}

function cTakeDmgInfo:GetIsMeleeDamage() -- TODO: Make this a getter and setter like above that all melee weapons that deal damage utilize
	return meleetypes[self:GetDamageType()]
end
function cTakeDmgInfo:SetIsMeleeDamage() end -- Just in case of mistakes

local explosiontypes = {
	[DMG_BLAST] = true,
	[DMG_BLAST_SURFACE] = true
}

function cTakeDmgInfo:GetIsExplosionDamage() -- So this was actually a mistake, because dTakeDmgInfo.IsExplosionDamage is a thing already and works WAY better. -> Only use if you can improve this. Keeping for compatibility..
	local dmgType = self:GetDamageType()
	return bit.band(dmgType, DMG_BLAST) == DMG_BLAST or bit.band(dmgType, DMG_BLAST_SURFACE) == DMG_BLAST_SURFACE
end

function cTakeDmgInfo:GetIsBulletDamage()
	local dmgType = self:GetDamageType()
	return bit.band(dmgType, DMG_BULLET) == DMG_BULLET
end

function cTakeDmgInfo:GetIsShotgunDamage()
	local wep = self:GetInflictor()
	return self:GetDamageType() == DMG_BUCKSHOT or (IsValid(wep) and wep.Primary and wep.Primary.NumShots and wep.Primary.NumShots > 2)
end

function cTakeDmgInfo:Reset(override)
	for funcName, value in pairs(dmginfo_custom_methods) do
		local setFunc = self["Set" .. funcName]
		local getFunc = self["Get" .. funcName]
		if !setFunc or !getFunc then return end

		if override or getFunc() == nil then
			setFunc(self, value)
		end
	end
end
