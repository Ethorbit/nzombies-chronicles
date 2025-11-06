local timescale_cvar
local function get_time_scale()
    timescale_cvar = GetConVar("host_timescale") or timescale_cvar
    return timescale_cvar and timescale_cvar:GetFloat() or 1
end

function TimescaleChanged()
    return get_time_scale() ~= 1 or game.GetTimeScale() ~= 1
end
