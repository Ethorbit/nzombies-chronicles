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

local blockedhuds = {
	["CHudAmmo"] = true,
	["CHudSecondaryAmmo"] = true,
	["CHudHealth"] = true,
	["CHudBattery"] = true
}

local nzc_health_hud = GetConVar("nzc_health_hud")
local function UpdateHideHud()
	if (nzc_health_hud and nzc_health_hud:GetInt() == 3) then -- They wanna see the default HL2 HUD for some reason...
		blockedhuds["CHudHealth"] = false
		blockedhuds["CHudBattery"] = false
	else
		blockedhuds["CHudHealth"] = true
		blockedhuds["CHudBattery"] = true
	end
end

cvars.RemoveChangeCallback("nzc_health_hud", "HL2DefaultHudUpdater")
cvars.AddChangeCallback("nzc_health_hud", function()
	UpdateHideHud()
end, "HL2DefaultHudUpdater")
UpdateHideHud()

hook.Add( "HUDShouldDraw", "HideHUD", function( name )
	if blockedhuds[name] then return false end
	if name == "CHudWeaponSelection" then return !nzRound:InProgress() and !nzRound:InState(ROUND_GO) end -- Has it's own value
	--if name == "CHudHealth" then return !GetConVar("nz_bloodoverlay"):GetBool() end -- Same
end )

