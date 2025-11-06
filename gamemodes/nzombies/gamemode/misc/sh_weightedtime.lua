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
