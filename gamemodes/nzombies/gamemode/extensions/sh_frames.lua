local highest_fps = 0
local last_fps = 0

-- Just some stuff I needed for making optimizations
function CurrentFPS()
    return math.Clamp(1 / engine.AbsoluteFrameTime(), 0, MaxFPS())
end

function MaxFPS()
    return highest_fps
end

hook.Add("Think", "UpdateFPS", function()
    local fps = CurrentFPS()

    if last_fps ~= fps then
        hook.Run("FPSChange", last_fps, fps)
        last_fps = fps
    end
end)

hook.Add("Think", "UpdateHighestFPS", function()
    local fps = (1 / FrameTime())

    if fps > highest_fps then
        hook.Run("MaxFPSChange", highest_fps, fps)
        highest_fps = fps
    end
end)
