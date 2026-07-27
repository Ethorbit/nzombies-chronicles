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

-- Recoded itemcarry from scratch by: Ethorbit
local part_mats = part_mats or {}
hook.Add("OnPartAdded", "NZHUDPartAdded", function(ply, part)
    if !IsValid(part) then return end
    part_mats[part] = nzDisplay.GetSpawnIcon(part:GetModel())
end)

hook.Add("OnPartRemoved", "NZHUDPartRemoved", function(ply, part)
    part_mats[part] = nil
end)

hook.Add("HUDPaint", "NZ.PartHUD", function()
    local ply = LocalPlayer():IsSpectating() and LocalPlayer():GetObserverTarget() or LocalPlayer()
    if IsValid(ply) then
        if ply:HasParts() then
            local num = 0
            for _,part in pairs(ply:GetParts()) do 
                --if part.GetBuilt and part:GetBuilt() then return end 
                
                num = num + 1
                if part_mats[part] then
                    surface.SetDrawColor(255, 255, 255)
                    surface.SetMaterial(part_mats[part])
                    surface.DrawTexturedRect((ScrW() - 310) - (90 * num), ScrH() - 90, 80, 80)
                end
            end
        end
    end
end)
