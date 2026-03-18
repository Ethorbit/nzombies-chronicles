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

-- Just some stuff I needed for making optimizations
-- Stuff that I think Garry's Mod should already have in Lua
--
-- Functions: MaxFPS, CurrentFPS
-- Hooks: MaxFPSChange, FPSChange, FPSDrop

local highest_fps = 0
local last_fps = 0

function CurrentFPS()
    return math.Round(math.Clamp(1 / engine.AbsoluteFrameTime(), 0, MaxFPS()))
end

function MaxFPS()
    return math.Round(highest_fps)
end

hook.Add("Think", "UpdateFPS", function()
    if TimescaleChanged() then return end

    local fps = CurrentFPS()

    if last_fps ~= fps then
        if fps < MaxFPS() then
            hook.Run("FPSDrop", fps)
        end

        hook.Run("FPSChange", last_fps, fps)
        last_fps = fps
    end
end)

hook.Add("Think", "UpdateHighestFPS", function()
    if TimescaleChanged() then return end

    local fps = math.Round(1 / FrameTime())

    if fps > highest_fps then
        hook.Run("MaxFPSChange", highest_fps, fps)
        highest_fps = fps
    end
end)
