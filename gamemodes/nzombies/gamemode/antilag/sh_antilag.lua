-- AntiLag module created by: Ethorbit
-- It was inspired by an nZC server addon I made

local max_time = 2 -- Maximum time between lag level tests. You don't want this too high or scans could take a bit.
local lag_time = 0.03 -- How long to wait before rechecking lag for lag confirmation?
local cooldown = 5 -- After an AntiLag definition's function runs, it cannot run again until after this many seconds
local cooldowns = {}
local definitions = {} -- The AntiLag definitions created at runtime. Defaults are created just below..
local levels = {}

NZAntiLag = {
    Levels = {
        Get = function(name)
            if !name then return levels end
            return levels[name]
        end,
        Add = function(name, fps)
            levels[name] = fps
        end
    },
    Create = function(name, level_name, func)
        definitions[level_name] = definitions[level_name] or {}
        definitions[level_name][name] = func
    end
}

-- Default Levels
local function update_levels(max_fps)
    NZAntiLag.Levels.Add("ONE", 1)
    NZAntiLag.Levels.Add("TWO", 2)
    NZAntiLag.Levels.Add("THREE", 3)
    NZAntiLag.Levels.Add("FOUR", 4)
    NZAntiLag.Levels.Add("FIVE", 5)
    NZAntiLag.Levels.Add("TEN", 10)
    NZAntiLag.Levels.Add("TWENTY", 20)
    NZAntiLag.Levels.Add("THIRTY", 30)
    NZAntiLag.Levels.Add("LOW", (max_fps * 0.25))
    NZAntiLag.Levels.Add("CRITICAL", (max_fps * 0.1))
end
-- Default Definitions
NZAntiLag.Create("Respawn Zombies", "LOW", function()
    if SERVER then
        for _,zombie in pairs(ents.GetAll()) do
            if zombie:IsValidZombie() then
                zombie:RespawnZombie()
            end
        end
    end
end)
NZAntiLag.Create("Restart Round", "CRITICAL", function()
    if SERVER and nzRound:InProgress() then
        RunConsoleCommand("nz_restartround")
    end
end)

hook.Add(SERVER and "Initialize" or "InitPostEntity", "NZAntiLag.UpdateDefaultLevels", function()
    update_levels(MaxFPS())
end)
hook.Add("MaxFPSChange", "NZAntiLag.MaxFPSUpdate", function(_, new_fps)
    update_levels(new_fps)
end)

-- The brain
local next_scan = 0
hook.Add("FPSChange", "NZAntiLag.Scanner", function(_, new_fps)
    if CurTime() < next_scan then return end

    -- Sort levels and their timings in decending order, then
    -- iterate one after another with max_time delay
    --
    -- The reason we do it like this, is so that if a lag fix works
    -- then the other ones won't be triggered since by the time they run
    -- the FPS would be lower
    local iterations = 0
    for level_name, level_value in SortedPairsByValue(levels, true) do
        if definitions[level_name] then
            iterations = iterations + 1
        end

        next_scan = CurTime() + (max_time * iterations)
        timer.Simple(max_time * iterations, function()
            if definitions[level_name] then
                if level_value > 0 then
                    if (new_fps < level_value) then
                        cooldowns[level_name] = cooldowns[level_name] or 0
                        if cooldowns[level_name] and CurTime() > cooldowns[level_name] then
                            cooldowns[level_name] = CurTime() + cooldown
                            -- We already know the FPS is low, but let's check again a little later
                            -- this way we can tell if it's lag or just a small dip in FPS
                            timer.Simple(lag_time, function()
                                if (CurrentFPS() < level_value) then
                                    if SERVER then
                                        ServerLog(string.format("[nZombies Anti-Lag] FPS REACHED LEVEL: %s (%i).\n", level_name, level_value))
                                    end

                                    if !definitions[level_name] then return end
                                    for definition_name, definition_func in pairs(definitions[level_name]) do
                                        if !definition_name then return end
                                        if !isfunction(definition_func) then return end
                                        if SERVER then
                                            PrintMessage(HUD_PRINTTALK, string.format("[nZombies Anti-Lag] Executing %s FPS FIX: %s.", level_name, definition_name))
                                        end
                                        -- Finally, run the definition's custom function, where it will do something to (hopefully) resolve the lag.
                                        definition_func()
                                    end
                                else
                                    -- Since we didn't actually run it, reset its cooldown
                                    cooldowns[level_name] = 0
                                end
                            end)
                        end
                    end
                end
            end
        end)
    end
end)
