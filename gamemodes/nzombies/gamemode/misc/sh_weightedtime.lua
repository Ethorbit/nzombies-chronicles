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

-- Added by Ethorbit
--
-- Real Scenario:
-- We need to avoid false positives from millisecond lag spikes
-- OK, we will use this to check if it lags enough in 2 seconds time
--
-- Parameters:
-- Time - Number, seconds to check condition
-- Proportion - Number 0-1, 0.5 means 50% of how much of Time needs to meet Condition
-- Condition - Boolean or Function that returns true or false
-- Callback, Function called with info of the time weighted results
--
-- Returns:
-- Conditional result
-- Success Proportion of the input results
-- The results table
function nzMisc.TimeWeightedCheck(time, proportion, condition, callback)
    local results = { [0] = 0, [1] = 0 }
    local run_time = CurTime() + time
    local next_run = 0
    local id = "TimeWeightedCheck" .. tostring(CurTime())
    hook.Add("Tick", id, function()
        if CurTime() > run_time then
            hook.Remove("Tick", id)
            local results_total = results[0] + results[1]
            local success_proportion = results[1] / results_total
            callback(success_proportion >= proportion, success_proportion, table.Copy(results))
        else
            if CurTime() > next_run then
                next_run = CurTime() + engine.TickInterval()

                local result = condition
                if isfunction(condition) then
                    result = condition()
                end

                results[result and 1 or 0] = results[result and 1 or 0] + 1
            end
        end
    end)
end
