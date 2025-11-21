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

local PLAYER = FindMetaTable("Player")

------------ Player Speeds ------------------
if SERVER then
    util.AddNetworkString("NZ_AddNewPlayerSpeed")
end

if CLIENT then
    net.Receive("NZ_AddNewPlayerSpeed", function()
        local is_walk = net.ReadBool()
        local alias = net.ReadString()
        local speed = net.ReadInt(15)

        if !alias or !speed then return end

        if is_walk then
            LocalPlayer():AddWalkSpeed(alias, speed)
        else
            LocalPlayer():AddRunSpeed(alias, speed)
        end
    end)
end

-----------------------------------------------------
------------ Nova Gas -------------------------------
if CLIENT then
    hook.Add("RenderScreenspaceEffects", "NZNovaGasRenderSpaceFX", function()
		if LocalPlayer().IsTouchingNovaGas and LocalPlayer():IsTouchingNovaGas() then
			DrawMotionBlur( 0.1, 0.8, 0.01 )
		end
	end)

    hook.Add("EntityEmitSound", "NZNovaGasFadeOutAudio", function(data)
        if LocalPlayer().IsTouchingNovaGas and LocalPlayer():IsTouchingNovaGas() then
            data.DSP = 30
        return true end
    end)
end
--------------------------------------------------------------
