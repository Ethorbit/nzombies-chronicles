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

-- Functions used to make players use a special weapon meant for when they are down
-- just like in COD
-- local PLAYER = FindMetaTable("Player")
-- function PLAYER:DownWeaponClass()
-- 	return "tfa_down_weapon" .. self:EntIndex()
-- end

-- function PLAYER:CreateDownWeapon(wep)
--     local startWep = !isstring(wep) and nzMapping.Settings.startwep
--     if (self.lastDownedWep != startWep) then
--         self.lastDownedWep = startWep

--         if (isstring(startWep)) then 
--             local tblWep = weapons.Get(startWep) 
--             tblWep.NZSpecialCategory = "Down Weapon"
--             tblWep.IsSpecial = function()
--                 return true
--             end

--             if (istable(tblWep)) then -- Starting wep is a real weapon
--                 weapons.Register(tblWep, self:DownWeaponClass())
--             end
--         end
--     end
-- end

-- if SERVER then 
--     function PLAYER:GiveDownWeapon(wep)
--         self:Give(self:DownWeaponClass()) 
--         self:SetActiveWeapon(self:GetWeapon(self:DownWeaponClass()))
--     end

--     function PLAYER:StripDownWeapon()
--         self:StripWeapon(self:DownWeaponClass())
--         self:SetActiveWeapon(nil)
--         self:EquipPreviousWeapon()
--     end
-- end
