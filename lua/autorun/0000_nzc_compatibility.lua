--[[ LICENSE HEADER MANAGED BY add-license-header

Copyright (C) 2014-2015 Alig96
Copyright (C) 2015-2017 Zet0rz
Copyright (C) 2016-2017 lolleko
Copyright (C) 2020-2026 Ethorbit

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

--[[
Gamemode name compatibility
Copyright (C) Ethorbit, 2026

Added because nZR loves hardcoding "nzombies" checks in their addons.
https://imgur.com/a/6qNhTBL

This file tricks bad addons into thinking we're the regular nZombies.
--]]

local print_debug_messages = false -- If something isn't working as expected, set this to true and look at console

if engine.ActiveGamemode() == "nzombies" then
    print("nZC gamemode name compatibility successfully loaded.")
return end

local old_active_gamemode = engine.ActiveGamemode
local this_source = debug.getinfo(1, "S").source:gsub("^@", "")
local function_cache = setmetatable({}, { __mode = "k" })
local source_cache = {}
local warned_sources = {}

local function normalize_source(raw)
    local source = raw:gsub("^@", "")
    local stripped = source:match("lua/.+$")
    return stripped or source
end

local function uses_legacy_check(contents)
    return contents:find("[\"']nzombies[\"']%s*[=~!]=")   -- "nzombies" == /~= / !=
        or contents:find("[=~!]=%s*[\"']nzombies[\"']")   -- == / ~= / != "nzombies"
end

local function log(msg)
    print(string.format("[nZC Compatibility] %s", msg))
end

if print_debug_messages then
    log("Loading compatibility...")
end

function engine.ActiveGamemode()
    local info = debug.getinfo(2, "fS")
    local caller = info and info.func

    if print_debug_messages then
        log(info.source)
        log(info.short_src)
        log(caller)
    end

    if not caller then
        return old_active_gamemode()
    end

    local cached = function_cache[caller]

    if cached then
        return cached
    end

    local normalized = normalize_source(info.source)
    local source = info.source

    -- skip detection/warning entirely for this file's own self-test
    if normalized == this_source then
        local result = old_active_gamemode()
        function_cache[caller] = result
        return result
    end

    local contents = source_cache[source]

    if contents == nil then
        contents = file.Read(normalized, "GAME") or ""
        source_cache[source] = contents
    end

    if print_debug_messages then
        log(normalized)
        log(contents)
    end

    local result

    if uses_legacy_check(contents) then
        if not warned_sources[source] then
            warned_sources[source] = true
            ErrorNoHalt(
                string.format(
                    "[nZC Compatibility] %s is checking for the 'nzombies' gamemode identifier directly. Contact the author and send them this guide: https://steamcommunity.com/sharedfiles/filedetails/?id=3772554459\n",
                    source
                )
            )
        end
        result = "nzombies"
    else
        result = old_active_gamemode()
    end

    function_cache[caller] = result

    return result
end
