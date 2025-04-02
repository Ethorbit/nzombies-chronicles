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
    local fps = math.Round(1 / FrameTime())

    if fps > highest_fps then
        hook.Run("MaxFPSChange", highest_fps, fps)
        highest_fps = fps
    end
end)
