AddCSLuaFile()

ENT.Type = "anim"

ENT.PrintName		= "drop_tombstone"
ENT.Author			= "Zet0r"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

function ENT:SetupDataTables()

	self:NetworkVar( "Entity", 0, "PerkOwner" )

    -- Don't allow multiple tombs of the same owner - Added by Ethorbit
    -- if SERVER then
    --     self:NetworkVarNotify("PerkOwner", function(ent, name, old, new)
    --         for _,v in pairs(ents.FindByClass(self:GetClass())) do
    --             if v != self and v:GetPerkOwner() == new then
    --                 v:Remove()
    --             end
    --         end
    --     end)
    -- end
end

function ENT:Initialize()

	self:SetModel("models/props_c17/gravestone003a.mdl")

	--self:PhysicsInit(SOLID_VPHYSICS)
	self:PhysicsInitSphere(60, "default_silent")
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	if SERVER then
		self:SetTrigger(true)
	end
	self:UseTriggerBounds(true, 0)
	self:DrawShadow(false)
	self:SetMaterial("models/shiny.vtf")
	self:SetColor( Color(255,200,0) )

	self.OwnerData = self.OwnerData or {}

	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end

	--[[timer.Create( self:EntIndex().."_deathtimer", 100, 1, function()
		if self:IsValid() then
			timer.Destroy(self:EntIndex().."_deathtimer")
			if SERVER then
				self:Remove()
			end
		end
	end)]]

	--self.RemoveTime = CurTime() + 120
end

if SERVER then
	function ENT:StartTouch(hitEnt)
		--print("Collided")
		if (IsValid(hitEnt) and hitEnt:IsPlayer() and hitEnt == self:GetPerkOwner()) then
			if CurTime() - hitEnt:GetLastSpawned() <= 1 then return end -- They touched us from Spectator in the same tick they spawned, this is not valid.

			-- Weapons are completely replaced
			if self.OwnerData.weps != nil then
				hitEnt:StripWeapons()

				for k,v in pairs(self.OwnerData.weps) do
					local wep = hitEnt:Give(v.class)

					timer.Simple(0, function()
						if v and v.pap and IsValid(wep) and IsValid(hitEnt) then
							wep:ApplyNZModifier("pap")
						end
					end)
				end
			end

			local oldPerks = hitEnt:GetPerks()
			hitEnt:RemovePerks() -- We need to shift these perks AFTER the old ones (what we're about to be given)

			if self.OwnerData.perks != nil then
				for i = 1, #self.OwnerData.perks do
					local v = self.OwnerData.perks[i]
					if v != "tombstone" then
						hitEnt:GivePerk(v)
					end
				end
			end

			-- Give them back the new perks
			if oldPerks then
				for i = 1,#oldPerks do
					local perk = oldPerks[i]
					hitEnt:GivePerk(perk)
				end
			end

			hitEnt:GiveMaxAmmo()

			--timer.Destroy(self:EntIndex().."_deathtimer")
			self:Remove()
		end
	end

	function ENT:Think()
		-- Remove if game has ended
		-- if nzRound:GetState() == ROUND_WAITING then
		-- 	self:Remove()
		-- end

		if !self.RemoveTime then
			local ply = self:GetPerkOwner()
			if IsValid(ply) then
				if ply:Alive() and ply:GetNotDowned() and (ply:IsPlaying() or ply:IsInCreative()) then
					self.RemoveTime = CurTime() + 90
				end
			else
				-- Man, the player must've disconnected or crashed :/
				self:Remove()
			end
		elseif self.RemoveTime and CurTime() > self.RemoveTime then
			self:Remove()
		end
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end

	function ENT:Think()
		if !self:GetRenderAngles() then self:SetRenderAngles(self:GetAngles()) end
		self:SetRenderAngles(self:GetRenderAngles()+(Angle(0,50,0)*FrameTime()))
	end

	-- hook.Add( "PreDrawHalos", "drop_powerups_halos", function()
	-- 	halo.Add( ents.FindByClass( "drop_powerup" ), Color( 0, 255, 0 ), 2, 2, 2 )
	-- end )
end
