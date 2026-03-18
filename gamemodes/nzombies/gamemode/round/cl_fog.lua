--[[ LICENSE HEADER MANAGED BY add-license-header

Copyright (C) 2014-2015 Alig96
Copyright (C) 2015-2017 Zet0rz
Copyright (C) 2016-2017 lolleko
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

--net.Receive("nZFogUpdate", function()
--    local isOptimized = net.ReadBool()
--    local skyTexture = "gm_construct/color_room" 
--    local skyMat = Material(skyTexture)
--    
--    if isOptimized then 
--        hook.Add("PreDrawOpaqueRenderables", "NZChangeSkyboxTexture", function(isDrawingDepth, isDrawingSkybox)
--            local ply = LocalPlayer()
--			local view = render.GetViewSetup()
--			local lookdir = view.angles
--			local lookpos = view.origin
--			local looknorm = Vector(1,0,0)
--			looknorm:Rotate(lookdir)
--
--            if isDrawingSkybox and IsValid(skyMat) then 
--                render.SetMaterial(skyMat)
--                print(skyMat)
--            end 
--        end)
--    else 
--        hook.Remove("PreDrawOpaqueRenderables", "NZChangeSkyboxTexture")
--    end 
--end)

-- local fade
-- local fadetime = 5

-- local fogstart = fogstart or 50
-- local fogend = fogend or 1000
-- local fogdensity = fogdensity or 0
-- local fogcolor = fogcolor or Vector(0.4,0.7,0.8)

-- local tfogstart = tfogstart or 50
-- local tfogend = tfogend or 1000
-- local tfogdensity = tfogdensity or 0
-- local tfogcolor = tfogcolor or Vector(0.4,0.7,0.8)

-- local ofogstart = fogstart
-- local ofogend = fogend
-- local ofogdensity = fogdensity
-- local ofogcolor = fogcolor

-- local specialfog = false
-- local foginit = false

-- local DrawDistance = GetConVar("nzc_draw_distance")
-- local function IsLimitingDrawDistance()
-- 	return (DrawDistance == nil or DrawDistance != nil and DrawDistance:GetFloat() < 5000.0 and DrawDistance:GetFloat() > 0.0)
-- end

-- function nzRound:EnableSpecialFog( bool )
-- 	local ent = ents.FindByClass("edit_fog")[1]
-- 	local ent_special = ents.FindByClass("edit_fog_special")[1]
	
-- 	hook.Remove("Think", "nzFogThink")
	
-- 	if bool and (!specialfog or !foginit) then
-- 		if IsValid(ent_special) then
-- 			tfogstart = ent_special:GetFogStart()
-- 			tfogend = ent_special:GetFogEnd()
-- 			tfogdensity = ent_special:GetDensity()
-- 			tfogcolor = ent_special:GetFogColor()
-- 		else
-- 			tfogstart = 50
-- 			tfogend = 1000
-- 			tfogdensity = 0.9
-- 			tfogcolor = Vector(0.4,0.7,0.8)
-- 		end
-- 		specialfog = true
-- 	elseif specialfog or !foginit then
-- 		if IsValid(ent) then
-- 			tfogstart = ent:GetFogStart()
-- 			tfogend = ent:GetFogEnd()
-- 			tfogdensity = ent:GetDensity()
-- 			tfogcolor = ent:GetFogColor()
-- 		-- elseif (!IsLimitingDrawDistance()) then
-- 		-- 	tfogstart = 50
-- 		-- 	tfogend = DrawDistance():GetFloat() - 200.0
-- 		-- 	tfogdensity = 1
-- 		-- 	tfogcolor = Vector(0.4,0.7,0.8)
-- 		else
-- 			tfogstart = 50
-- 			tfogend = 1000
-- 			tfogdensity = 0
-- 			tfogcolor = Vector(0.4,0.7,0.8)
-- 		end
-- 		specialfog = false
-- 	end
-- 	-- Changed to always true because we now have defaults that apply if the entities don't exist
-- 	if true then --IsValid(ent) or IsValid(ent_special) then
-- 		fade = 0
-- 		ofogstart = fogstart
-- 		ofogend = fogend
-- 		ofogdensity = fogdensity
-- 		ofogcolor = fogcolor
-- 		hook.Add("Think", "nzFogFade", nzFogFade)
-- 		hook.Add("SetupWorldFog", "nzWorldFog", nzSetupWorldFog)
-- 		hook.Add("SetupSkyboxFog", "nzSkyboxFog", nzSetupSkyFog)
-- 		foginit = true
-- 	else
-- 		hook.Remove("SetupWorldFog", "nzWorldFog")
-- 		hook.Remove("SetupSkyboxFog", "nzSkyboxFog")
-- 		foginit = false
-- 	end
-- end

-- function nzFogFade()
-- 	fade = math.Approach(fade, 1, FrameTime()/fadetime)
-- 	fogstart = Lerp(fade, ofogstart, tfogstart)
-- 	fogend = Lerp(fade, ofogend, tfogend)
-- 	fogdensity = Lerp(fade, ofogdensity, tfogdensity)
-- 	fogcolor = LerpVector(fade, ofogcolor, tfogcolor)
	
-- 	if fade >= 1 then
-- 		hook.Remove("Think", "nzFogFade")
-- 		hook.Add("Think", "nzFogThink", nzFogThink)
-- 	end
-- end

-- function nzFogThink()
-- 	local ent
-- 	if specialfog then
-- 		ent = ents.FindByClass("edit_fog_special")[1]
-- 	else
-- 		ent = ents.FindByClass("edit_fog")[1]
-- 	end
-- 	--print(ent)
-- 	if IsValid(ent) then
-- 		fogstart = ent:GetFogStart()
-- 		fogend = ent:GetFogEnd()
-- 		fogdensity = ent:GetDensity()
-- 		fogcolor = ent:GetFogColor()
-- 	end
-- end

-- function nzSetupWorldFog()
-- 	render.FogMode( 1 ) 
-- 	render.FogStart(  fogstart )
-- 	render.FogEnd(fogend)
-- 	render.FogMaxDensity(fogdensity)
-- 	render.FogColor(fogcolor.x * 255, fogcolor.y * 255, fogcolor.z * 255)
-- 	return true

-- end

-- function nzSetupSkyFog( skyboxscale )
-- 	render.FogEnd( fogend )
-- 	render.FogMaxDensity( fogdensity )
-- 	render.FogColor( fogcolor.x * 255, fogcolor.y * 255, fogcolor.z * 255)
-- 	render.FogMode( 1 ) 
-- 	render.FogStart( fogstart * skyboxscale )

-- 	return true

-- end
