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

-- timing for reading dates added to the gamemode by Ethorbit
-- I did this so that we can schedule events for an Event System

-- Default timezone is UTC. To update the timezone, place this in your game or server addon:
-- For example, this sets 25200 seconds (7 hours) behind UTC, which would be PST:
-- hook.Add("GetTimeZone", "SetTimeZoneValue", function()
--      return os.time() - 25200
-- end)

NZDate = {
    GetDay = function() -- 1-12
        return tonumber(os.date("!%d", hook.Call("GetTimeZone")))
    end,
    GetMonth = function() -- 1-12
        return tonumber(os.date("!%m", hook.Call("GetTimeZone")))
    end,
    GetDayName = function() -- Monday-Sunday
        return os.date("!%A", hook.Call("GetTimeZone"))
    end,
}
