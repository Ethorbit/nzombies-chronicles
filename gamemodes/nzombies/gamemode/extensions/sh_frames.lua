local highest_fps = 0

-- Just some stuff I needed for making optimizations
function CurrentFPS()
    return 1 / engine.AbsoluteFrameTime()
end

function MaxFPS()
    return highest_fps
end

hook.Add("Think", "UpdateHighestFPS", function()
    local fps = (1 / FrameTime())
    highest_fps = (highest_fps > fps and highest_fps or fps)
end)
