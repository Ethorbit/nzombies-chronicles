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

game.AddParticles("particles/magic_particles.pcf")
PrecacheParticleSystem("magic_smoke")

if (SERVER) then
    util.AddNetworkString("ShowMagicalHalo")
    util.AddNetworkString("RemoveMagicalHalo")
else
    --local magicals = {}
    -- hook.Add("PreDrawHalos", "MagicalHalos", function()
    --     halo.Add(magicals, Color(0, 104, 139), 20, 20, 5, true)
    -- end)

    net.Receive("ShowMagicalHalo", function()
        local magicalEnt = net.ReadEntity()
        if IsValid(magicalEnt) then
            magicalEnt:EmitSound("chron/nz/effects/magical_loop.wav", 80, 100, 0.5)
            --table.insert(magicals, magicalEnt)
            ParticleEffectAttach("magic_smoke", PATTACH_POINT_FOLLOW, magicalEnt, 4)
        end
    end)

    net.Receive("RemoveMagicalHalo", function()
        local magicalEnt = net.ReadEntity()
        if IsValid(magicalEnt) then 
            magicalEnt:StopParticles() 
            magicalEnt:StopSound("chron/nz/effects/magical_loop.wav")
        end

        --table.RemoveByValue(magicals, magicalEnt)
    end)
end
