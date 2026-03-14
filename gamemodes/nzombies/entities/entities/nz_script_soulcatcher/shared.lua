--[[ LICENSE HEADER MANAGED BY add-license-header

Copyright (C) 2014-2015 Alig96
Copyright (C) 2015-2017 Zet0rz
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

AddCSLuaFile( )

ENT.Type = "anim"
 
ENT.PrintName		= "nz_script_soulcatcher"
ENT.Author			= "Zet0r"
ENT.Contact			= "youtube.com/Zet0r"
ENT.Purpose			= "Scriptable soul catcher for nZombies"
ENT.Instructions	= ""

ENT.NZEntity = true

function ENT:Initialize()
	if SERVER then
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_VPHYSICS )
		--self:DrawShadow( false )
		self:SetUseType( SIMPLE_USE )
		self.CurrentAmount = 0
		self:SetTargetAmount( self.TargetAmount or 20 )
		self:SetCondition(self.Condition or function(z, dmg) return true end) -- Always allow
		self:SetCatchFunction(self.CatchFunc or function(z) end) -- Nothing by default
		self:SetCompleteFunction(self.CompleteFunc or function(z) end) -- Nothing either
		self:SetRange(self.Range or 500) -- Default range
		self:SetEnabled(self.Enabled or true)
	end
end

function ENT:OnRemove()
	hook.Call("nzmapscript_SoulCatcherRemoved", nil, self)
end

function ENT:SetCatchFunction( func )
	self.CatchFunc = func
end
function ENT:SetCompleteFunction( func )
	self.CompleteFunc = func
end
function ENT:SetTargetAmount( num )
	self.TargetAmount = tonumber(num)
end
function ENT:SetCondition( func )
	self.Condition = func
end
function ENT:SetRange( num )
	self.Range = tonumber(num)^2
end
function ENT:SetEnabled( bool )
	self.Enabled = tobool(bool)
end
function ENT:SetReleaseOverride( func )
	self.ReleaseOverride = func
end

function ENT:SetCurrentAmount( num )
	self.CurrentAmount = tonumber(num)
end
function ENT:Reset()
	self.CurrentAmount = 0
end

function ENT:ReleaseSoul( z )
	if self.ReleaseOverride then
		self:ReleaseOverride(z) -- You can override the effect and count logic with this
	else
		if self.CurrentAmount >= self.TargetAmount then return end
		local e = EffectData()
		e:SetOrigin(z:GetPos() + Vector(0,0,50))
		e:SetEntity(self)
		util.Effect("zombie_soul", e)
		self.CurrentAmount = self.CurrentAmount + 1
	end
end

function ENT:CollectSoul()
	self:CatchFunc()
	if self.CurrentAmount >= self.TargetAmount then 
		self:CompleteFunc()
	end
end

hook.Add("EntityTakeDamage", "SoulCatchZombies", function(ent, dmg)
	if ent:IsValidZombie() and ent:Health() <= dmg:GetDamage() then
		for k,v in pairs(ents.FindByClass("nz_script_soulcatcher")) do
			if v.Enabled and ent:GetPos():DistToSqr(v:GetPos()) <= v.Range and v:Condition(ent, dmg) then
				v:ReleaseSoul(ent)
				break
			end
		end
	end
end)

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end
