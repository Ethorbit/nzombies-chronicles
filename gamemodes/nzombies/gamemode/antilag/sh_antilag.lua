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

-- AntiLag module created by: Ethorbit
-- It was inspired by an nZC server addon I made

-- If you're not sure why it's not working or why there is a false positive, set this to true and watch the console/chat.
CreateConVar( "nz_lag_debug", "0", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_CHEAT } )
lagvar = GetConVar("nz_lag_debug")

local function is_debugging()
    return lagvar and lagvar:GetBool()
end

local lag_check_proportion = 0.15 -- 0 (0%) to 1 (100%)
local lag_check_time = 2 -- If it lags <lag_check_proportion> for this many seconds, then consider it lag.
local cooldowns = {}
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
    Create = function(name, level_name, func, cooldown)
        cooldown = cooldown or 5
        if !isstring(name) then print("[nZ] Failed to create NZAntiLag definition. Invalid name.\n") return end
        if !isfunction(func) then print(string.format("[nZ] Failed to create NZAntiLag definition. Invalid function for lag level %s, entry %s\n", level_name, name)) return end

        local fps_threshold = levels[level_name]
        if !fps_threshold then print(string.format("[nZ] Failed to create NZAntiLag definition. fps_threshold for lag level %s, entry %s is invalid.\n", level_name, name)) return end

        hook.Add("FPSDrop", level_name .. "_" .. name, function(fps, _)
            if game.SinglePlayer() then return end -- Unless a miracle happens, Singleplayer will always be a laggy mess. No serious soul should play nZombies in Singleplayer..
            if not nzRound:InState(ROUND_PROG) then return end -- We really only need AntiLag for real gameplay

            cooldowns[level_name] = cooldowns[level_name] or {}
            cooldowns[level_name][name] = cooldowns[level_name][name] or {}
            cooldowns[level_name][name].cooldown = cooldowns[level_name][name].cooldown or 0

            if CurTime() < cooldowns[level_name][name].cooldown then return end
            cooldowns[level_name][name].cooldown = CurTime() + lag_check_time + 1 -- Don't let it run while we're currently checking lag time

            if CurrentFPS() < fps_threshold then
                -- Lag confirmation, avoids false positives (i.e millisecond lag spikes caused by background server processes running on the same thread)
                nzMisc.TimeWeightedCheck(lag_check_time, lag_check_proportion, function()
                    if is_debugging() then
                        print(string.format("[nZ] AntiLag Debugging. Is CurrentFPS (%i) under FPS Threshold (%i)?", CurrentFPS(), fps_threshold))
                    end
                    return CurrentFPS() < fps_threshold
                end,
                function(condition, success_proportion, results)
                    if condition then
                        if SERVER then
                            local msg = string.format("[nZ] Executing %s FPS fix: %s.", level_name, name)
                            PrintMessage(HUD_PRINTTALK, msg)
                            print(msg)
                            hook.Run("NZAntiLag.Execute", level_name, name)
                        end

                        if isfunction(func) then
                            cooldowns[level_name][name].cooldown = CurTime() + cooldown
                            func()
                        end
                    else
                        -- Reset the cooldown since it didn't actually execute
                        cooldowns[level_name][name].cooldown = 0
                    end

                    if is_debugging() then
                        print(string.format("[nZ] AntiLag Debugging. Success Proportion was: %f", success_proportion))
                        print("[nZ] AntiLag Debugging. Here's what the results table looks like")
                        PrintTable(results)
                    end
                end)
            end
        end)
    end
}

-- Defaults
local function update_levels(max_fps)
    NZAntiLag.Levels.Add("ONE", 1)
    NZAntiLag.Levels.Add("TWO", 2)
    NZAntiLag.Levels.Add("THREE", 3)
    NZAntiLag.Levels.Add("FOUR", 4)
    NZAntiLag.Levels.Add("FIVE", 5)
    NZAntiLag.Levels.Add("TEN", 10)
    NZAntiLag.Levels.Add("TWENTY", 20)
    NZAntiLag.Levels.Add("THIRTY", 30)
    NZAntiLag.Levels.Add("MEDIUM", math.Round(max_fps * 0.5))
    NZAntiLag.Levels.Add("LOW", math.Round(max_fps * 0.25))
    NZAntiLag.Levels.Add("CRITICAL", math.Round(max_fps * 0.1))

    NZAntiLag.Create("Respawn Zombies", "LOW", function()
        if SERVER then
            for _,zombie in pairs(ents.GetAll()) do
                if zombie.RespawnZombie then
                    zombie:RespawnZombie()
                end
            end
        end
    end, 5)

    -- Restarting the round is too disruptive to gameplay
    -- NZAntiLag.Create("Restart Round", "CRITICAL", function()
    --     if SERVER and nzRound:InProgress() then
    --         RunConsoleCommand("nz_restartround")
    --     end
    -- end, 20)

    hook.Run("NZAntiLag.Initialize", NZAntiLag)
end

update_levels(MaxFPS and MaxFPS() or 60)
hook.Add(SERVER and "Initialize" or "InitPostEntity", "NZAntiLag.UpdateDefaultLevels", function()
    update_levels(MaxFPS())
end)
hook.Add("MaxFPSChange", "NZAntiLag.MaxFPSUpdate", function(_, new_fps)
    update_levels(new_fps)
end)
