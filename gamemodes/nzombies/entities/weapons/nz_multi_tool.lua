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

SWEP.PrintName			= "Create Mode Toolgun"
SWEP.Author				= "Zet0r"
SWEP.Contact			= ""
SWEP.Purpose			= ""
SWEP.Instructions		= ""

SWEP.ViewModel			= "models/weapons/c_toolgun.mdl"
SWEP.WorldModel			= "models/weapons/w_toolgun.mdl"
SWEP.AnimPrefix			= "python"

SWEP.Slot				= 5
SWEP.SlotPos			= 1

SWEP.UseHands			= true

util.PrecacheModel( SWEP.ViewModel )
util.PrecacheModel( SWEP.WorldModel )

SWEP.ShootSound			= Sound( "Airboat.FireGunRevDown" )

SWEP.Tool				= {}

SWEP.Primary =
{
	ClipSize 	= -1,
	DefaultClip = -1,
	Automatic = false,
	Ammo = "none"
}

SWEP.Secondary =
{
	ClipSize 	= -1,
	DefaultClip = -1,
	Automatic = false,
	Ammo = "none"
}

SWEP.CanHolster			= true
SWEP.CanDeploy			= true

SWEP.NZPreventBox = true

--[[---------------------------------------------------------
	Initialize
-----------------------------------------------------------]]
function SWEP:Initialize()
	self.Primary =
	{
		ClipSize 	= -1,
		DefaultClip = -1,
		Automatic = false,
		Ammo = "none"
	}

	self.Secondary =
	{
		ClipSize 	= -1,
		DefaultClip = -1,
		Automatic = false,
		Ammo = "none"
	}

	self.ToolMode = "default"
end

--[[---------------------------------------------------------
   Precache Stuff
-----------------------------------------------------------]]
function SWEP:Precache()

	util.PrecacheSound( self.ShootSound )

end

--[[---------------------------------------------------------
	The shoot effect
-----------------------------------------------------------]]
function SWEP:DoShootEffect( hitpos, hitnormal, entity, physbone, bFirstTimePredicted )

	self.Weapon:EmitSound( self.ShootSound	)
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )


	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	if ( !bFirstTimePredicted ) then return end

	local effectdata = EffectData()
		effectdata:SetOrigin( hitpos )
		effectdata:SetNormal( hitnormal )
		effectdata:SetEntity( entity )
		effectdata:SetAttachment( physbone )
	util.Effect( "selection_indicator", effectdata )

	local effectdata = EffectData()
		effectdata:SetOrigin( hitpos )
		effectdata:SetStart( self.Owner:GetShootPos() )
		effectdata:SetAttachment( 1 )
		effectdata:SetEntity( self.Weapon )
	util.Effect( "ToolTracer", effectdata )

end

--[[---------------------------------------------------------
	Switch to another toolmode
-----------------------------------------------------------]]
function SWEP:SwitchTool(id)

	-- Only allow if the condition has been met
	if nzTools.ToolData[id].condition(self, self.Owner) then
		self.ToolMode = id

		-- Update the server with the newly equipped tool, switches data server-side
		nzTools:SendData( nzTools.SavedData[id], id )
	end

end


--[[---------------------------------------------------------
	Trace a line then send the result to a mode function
-----------------------------------------------------------]]
function SWEP:PrimaryAttack()

	local tr = util.GetPlayerTrace( self.Owner )
	tr.mask = bit.bor( CONTENTS_SOLID, CONTENTS_MOVEABLE, CONTENTS_MONSTER, CONTENTS_WINDOW, CONTENTS_DEBRIS, CONTENTS_GRATE, CONTENTS_AUX )
	local trace = util.TraceLine( tr )
	if (!trace.Hit) then return end

	self:DoShootEffect( trace.HitPos, trace.HitNormal, trace.Entity, trace.PhysicsBone, IsFirstTimePredicted() )

	if CLIENT and !game.SinglePlayer() and !IsFirstTimePredicted() then return end
	if nzTools.ToolData[self.ToolMode] and nzTools.ToolData[self.ToolMode].PrimaryAttack then
		nzTools.ToolData[self.ToolMode].PrimaryAttack(self, self.Owner, trace, self.Owner.NZToolData)
	end
	if ( game.SinglePlayer() ) then self:CallOnClient( "PrimaryAttack" ) end
end


--[[---------------------------------------------------------
	SecondaryAttack - Reset everything to how it was
-----------------------------------------------------------]]
function SWEP:SecondaryAttack()

	local tr = util.GetPlayerTrace( self.Owner )
	tr.mask = bit.bor( CONTENTS_SOLID, CONTENTS_MOVEABLE, CONTENTS_MONSTER, CONTENTS_WINDOW, CONTENTS_DEBRIS, CONTENTS_GRATE, CONTENTS_AUX )
	local trace = util.TraceLine( tr )
	if (!trace.Hit) then return end

	self:DoShootEffect( trace.HitPos, trace.HitNormal, trace.Entity, trace.PhysicsBone, IsFirstTimePredicted() )

	if CLIENT and !game.SinglePlayer() and !IsFirstTimePredicted() then return end
	if nzTools.ToolData[self.ToolMode] and nzTools.ToolData[self.ToolMode].SecondaryAttack then
		nzTools.ToolData[self.ToolMode].SecondaryAttack(self, self.Owner, trace, self.Owner.NZToolData)
	end
	if ( game.SinglePlayer() ) then self:CallOnClient( "SecondaryAttack" ) end
end

local reload_cd = CurTime()

function SWEP:Reload()
	if reload_cd < CurTime() then
		local tr = util.GetPlayerTrace( self.Owner )
		tr.mask = bit.bor( CONTENTS_SOLID, CONTENTS_MOVEABLE, CONTENTS_MONSTER, CONTENTS_WINDOW, CONTENTS_DEBRIS, CONTENTS_GRATE, CONTENTS_AUX )
		local trace = util.TraceLine( tr )
		if (!trace.Hit) then return end

		self:DoShootEffect( trace.HitPos, trace.HitNormal, trace.Entity, trace.PhysicsBone, IsFirstTimePredicted() )

		reload_cd = CurTime() + 0.3

		if CLIENT and !game.SinglePlayer() and !IsFirstTimePredicted() then return end
		if nzTools.ToolData[self.ToolMode] and nzTools.ToolData[self.ToolMode].Reload then
			nzTools.ToolData[self.ToolMode].Reload(self, self.Owner, trace, self.Owner.NZToolData)
		end

	end
	if ( game.SinglePlayer() ) then self:CallOnClient( "Reload" ) end
end

function SWEP:Deploy()
	if CLIENT and !game.SinglePlayer() and !IsFirstTimePredicted() then return end
	if nzTools.ToolData[self.ToolMode] and nzTools.ToolData[self.ToolMode].OnEquip then
		nzTools.ToolData[self.ToolMode].OnEquip(self, self.Owner, self.Owner.NZToolData)
	end
	if ( game.SinglePlayer() ) then self:CallOnClient( "Deploy" ) end
end

function SWEP:Holster(wep)
	if nzTools.ToolData[self.ToolMode] and nzTools.ToolData[self.ToolMode].OnHolster then
		nzTools.ToolData[self.ToolMode].OnHolster(self, self.Owner, self.Owner.NZToolData)
	end
	if ( game.SinglePlayer() ) then self:CallOnClient( "Holster" ) end
	return true
end

function SWEP:Think()
	if nzTools.ToolData[self.ToolMode] and nzTools.ToolData[self.ToolMode].Think then
		nzTools.ToolData[self.ToolMode].Think()
	end
end

--[[
RENDER The scroll text Liek in sandbox
--]]

if CLIENT then
	local matScreen 	= Material( "models/weapons/v_toolgun/screen" )
	local txBackground	= surface.GetTextureID( "models/weapons/v_toolgun/screen_bg" )

	-- GetRenderTarget returns the texture if it exists, or creates it if it doesn't
	local RTTexture 	= GetRenderTarget( "GModToolgunScreen", 256, 256 )

	surface.CreateFont( "GModToolScreen", {
		font	= "Helvetica",
		size	= 60,
		weight	= 900
	} )


	local function DrawScrollingText( text, y, texwide )

		local w, h = surface.GetTextSize( text  )
		w = w + 64

		y = y - h / 2 -- Center text to y position

		local x = RealTime() * 250 % w * -1

		while ( x < texwide ) do

			surface.SetTextColor( 0, 0, 0, 255 )
			surface.SetTextPos( x + 3, y + 3 )
			surface.DrawText( text )

			surface.SetTextColor( 255, 255, 255, 255 )
			surface.SetTextPos( x, y )
			surface.DrawText( text )

			x = x + w

		end

	end

	--[[---------------------------------------------------------
		We use this opportunity to draw to the toolmode
			screen's rendertarget texture.
	-----------------------------------------------------------]]
	function SWEP:RenderScreen()

		local TEX_SIZE = 256
		local mode = GetConVarString( "gmod_toolmode" )
		local oldW = ScrW()
		local oldH = ScrH()

		-- Set the material of the screen to our render target
		matScreen:SetTexture( "$basetexture", RTTexture )

		local OldRT = render.GetRenderTarget()
		local text = "Toolgun"
		if nzTools.ToolData[self.ToolMode] then
			text = nzTools.ToolData[self.ToolMode].displayname
			if nzTools.SavedData[self.ToolMode] then
				for k,v in pairs(nzTools.SavedData[self.ToolMode]) do
					text = text .."    -    "..k..": ".. tostring(v)
				end
				text = text .. "    - "
			end
		end

		-- Set up our view for drawing to the texture
		render.SetRenderTarget( RTTexture )
		render.SetViewPort( 0, 0, TEX_SIZE, TEX_SIZE )
		cam.Start2D()

			-- Background
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetTexture( txBackground )
			surface.DrawTexturedRect( 0, 0, TEX_SIZE, TEX_SIZE )

			surface.SetFont( "GModToolScreen" )
			DrawScrollingText( text, 104, TEX_SIZE )

		cam.End2D()
		render.SetRenderTarget( OldRT )
		render.SetViewPort( 0, 0, oldW, oldH )
	end

	function SWEP:DrawHUD()
		if nzTools.ToolData[self.ToolMode] and nzTools.ToolData[self.ToolMode].drawhud then
			nzTools.ToolData[self.ToolMode].drawhud()
		end
	end
end
