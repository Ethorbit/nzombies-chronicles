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

surface.CreateFont("AntiCheatWarningFont", {
	font = "CenterPrintText", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 93,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = false,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = true,
})

local forcefade = false
net.Receive("AntiCheatWarning", function() -- We are about to be teleported by the Anti-Cheat, we should move!
    if (!nzMapping.Settings.acwarn and nzMapping.Settings.acwarn != nil) then return end
    forcefade = false
    hook.Remove("HUDPaint", "NZAntiCheatMessage")

    local alpha = 0
    local fadeInTime = 0
    local fadeoutTime = nil
    local fadeout = 0
    local seconds = 6
    local secTime = 0

    seconds = net.ReadInt(13) or nzMapping.Settings.actptime + 1
    --if (nzMapping.Settings.actptime) then seconds = nzMapping.Settings.actptime + 1 end

    hook.Add("HUDPaint", "NZAntiCheatMessage", function()
        if !fadeoutTime then fadeoutTime = CurTime() + (seconds - 2) end 
        if CurTime() > secTime then
            secTime = CurTime() + 1
            seconds = seconds - 1
        end
        
        if alpha < 200 and CurTime() > fadeInTime and CurTime() < fadeoutTime and !forcefade then -- Fade text in
            fadeInTime = CurTime() + 0.1
            alpha = alpha + 20 < 200 and alpha + 20 or 200
        end

        if alpha > 0 and forcefade or alpha > 0 and CurTime() > fadeoutTime then -- Fade text out
            if CurTime() > fadeout then
                fadeout = CurTime() + 0.1
                alpha = alpha - 20 >= 0 and alpha - 20 or 0
            end
        end

        draw.DrawText("Return To Mission!", "AntiCheatWarningFont", ScrW() / 2, ScrH() / 2, Color(100, 100, 255, alpha), TEXT_ALIGN_CENTER) 
        draw.DrawText(tostring(seconds), "AntiCheatWarningFont", ScrW() / 2, ScrH() / 2 + 100, Color(100, 100, 255, alpha), TEXT_ALIGN_CENTER) 

        for i = 0, 10 do
            surface.SetDrawColor(100, 100, 255, alpha)
            surface.DrawOutlinedRect(0 + i, 0 + i, ScrW() - i * 2, ScrH() - i * 2)
        end     
    end)

    -- timer.Simple(seconds + 1, function() -- We don't need to show the warning anymore
    --     hook.Remove("HUDPaint", "NZAntiCheatMessage")
    --     print("Timer Remove HUD Paint")
    -- end)
end)

net.Receive("AntiCheatWarningCancel", function() -- We aren't cheating anymore, hide warning
    forcefade = true
end)
