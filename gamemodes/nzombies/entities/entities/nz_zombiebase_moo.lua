-- READ: moo's base is NOT a replacement for nz_zombiebase!!
--  please do not copy paste from zombiebase (as in, keep duplicate code out)
--  please do not needlessly override things from zombiebase
--  please inherit functionality from zombiebase with the usage of BaseClass if you do happen to override something (unless the base's version conflicts too much)
-- Thanks

AddCSLuaFile()

local holidayEnabled = GetConVar("nzc_holiday_events")

ENT.Base = "nz_zombiebase"
--ENT.Type = "nextbot"
ENT.Category = "Brainz"
ENT.Author = "Lolle, Zet0r, GhostlyMoo, Ethorbit, FlamingFox"
--ENT.Spawnable = true

DEFINE_BASECLASS(ENT.Base)

game.AddParticles("particles/bo1overhaul_blood_fx.pcf")
PrecacheParticleSystem("nz_blood_headshot")
PrecacheParticleSystem("nz_blood_gib")

--[[-------------------------------------------------------------------------
Localization/optimization
---------------------------------------------------------------------------]]
local CurTime = CurTime
local type = type
local Path = Path
local IsValid = IsValid
local GetPos = GetPos
local pairs = pairs

local coroutine = coroutine
local ents = ents
local math = math
local hook = hook
local util = util
local self = self
local ENT = ENT
local SERVER = SERVER

local util_traceline = util.TraceLine
local util_tracehull = util.TraceHull

ENT.AttackRange = 75
ENT.CrawlAttackRange = 70
ENT.DamageRange = 75
ENT.AttackDamage = 50

AccessorFunc( ENT, "fTraversalCheckRange", "TraversalCheckRange", FORCE_NUMBER)
AccessorFunc( ENT, "bStandingAttack", "StandingAttack", FORCE_BOOL)
AccessorFunc( ENT, "bCrawler", "Crawler", FORCE_BOOL)
AccessorFunc( ENT, "bTeleporting", "Teleporting", FORCE_BOOL)
AccessorFunc( ENT, "bShouldDie", "SpecialShouldDie", FORCE_BOOL)
AccessorFunc( ENT, "bIsBusy", "IsBusy", FORCE_BOOL)
AccessorFunc( ENT, "bShouldCount", "ShouldCount", FORCE_BOOL)

AccessorFunc( ENT, "m_bTargetLocked", "TargetLocked", FORCE_BOOL) -- Stops the Zombie from retargetting and keeps this target while it is valid and targetable

ENT.ActStages = {}

if CLIENT then
    ENT.RedEyes = true
end

local eyetrails = GetConVar("nz_zombie_eye_trails") -- I've considered for those who don't have this... Your welcome.
local comedyday = os.date("%d-%m") == "01-04"

function ENT:SetupDataTables()
    BaseClass.SetupDataTables(self)
    self:NetworkVar("Bool", 3, "MooSpecial")
    self:NetworkVar("Bool", 4, "WaterBuff")
    self:NetworkVar("Bool", 5, "BomberBuff")
end

function ENT:Precache()
    if self.PassiveSounds then
        for _,v in pairs(self.PassiveSounds) do
            util.PrecacheSound( v )
        end
    end
    if self.PainSounds then
        for _,v in pairs(self.PainSounds) do
            util.PrecacheSound( v )
        end
    end
    if self.DeathSounds then
        for _,v in pairs(self.DeathSounds) do
            util.PrecacheSound( v )
        end
    end
end

if SERVER then
    function ENT:UpdateModel()
        local models = self.Models
        local choice = models[math.random(#models)]
        util.PrecacheModel( choice.Model )
        self:SetModel(choice.Model)
        if choice.Skin then self:SetSkin(choice.Skin) end
        for i,v in ipairs(self:GetBodyGroups()) do
            self:SetBodygroup( i-1, math.random(0, self:GetBodygroupCount(i-1) - 1))
        end
    end
    --Init
    function ENT:Initialize()
        BaseClass.Initialize(self)

        self:SetStandingAttack(false)

        self.ShouldWalk = false
        self.ShouldCrawl = false

        self.CanBleed = true -- Theres some instances where a zombie shouldn't have blood... It can be a robot for all you know.

        self.Climbing = false
        self.NextClimb = 0

        self.AttackRangeUpdate = 0
        self.FailedAttack = 0

        self.LastStatusUpdate = 0
        self.LastSideStep = 0

        self:SetWaterBuff( false )
        self:SetBomberBuff( false )

        --[[Gib Related Shit]]--
        self:SetCrawler( false )
        self.LlegOff = false
        self.RlegOff = false
        --[[Gib Related Shit]]--

        self.LastStun = CurTime() + 8 -- Cooldown in between stuns on the zombie
        self.IsBeingStunned = false -- Here so zobies don't stumble twice in a row... I hope.

        self.Dying = false -- To know if a zombie is currently dying.
        self.IsIdle = false

        self:SetTraversalCheckRange( self.TraversalCheckRange )

        self:SetCollisionBounds(Vector(-14,-14, 0), Vector(14, 14, 70))

        self:SetSpecialShouldDie(false) -- Used for anims where the zombie reacts to something and they should die after the anim finishes. 
        self.CanCancelSpecial = false
        self:SetIsBusy(false) -- Used for shit like the barricades
        self.TraversalAnim = false

        self.IsTornado = false
        self.IsXbowSpinning = false
        self.IsTurned = false
        self.BecomeTurned = false

        self:SetShouldCount(false) -- Determines if the zombie should add to the amount killed for the round.

        self.SameSquare = true

        self:SetNextRetarget(0)

        self.HasSTaunted = false -- Zombies should only ever Super Taunt once.
        self.ArmsUporDown = math.random(2)
        self.AttackIsBlocked = false

        self.CurrentSeq = self.IdleSequence -- allows for the speed of the nextbot to updated automatically when using 1:1 movement speeds
        self.UpdateSeq = self.IdleSequence

        if SERVER then
            self:SpeedChanged()
            self.BarricadeJumpTries = 0
            self.ZombieAlive = true

            --[[ EYE TRAILS ]]--

            -- These look cool but will bring your game to it's knees if you got a pc of the wooden variety.
            --local defaultColor = Color(255, 75, 0, 255)
            --local eyeColor = !IsColor(nzMapping.Settings.zombieeyecolor) and defaultColor or nzMapping.Settings.zombieeyecolor
            local latt = self:LookupAttachment("lefteye")
            local ratt = self:LookupAttachment("righteye")

            local rand = math.Rand(0.1,0.2)
            if latt and ratt then
                if eyetrails ~= nil and eyetrails:GetInt() == 1 and !self.IsMooSpecial then
                    if math.random(2) == 1 then
                        self.spritetrail = util.SpriteTrail(self, latt, eyeColor, true, 5, 0, rand, 0.1, "effects/laser_citadel1.vmt")
                        self.spritetrail2 = util.SpriteTrail(self, ratt, eyeColor, true, 5, 0, rand, 0.1, "effects/laser_citadel1.vmt")
                    end
                end
            end
            --[[ EYE TRAILS ]]--
        end
    end

    function ENT:SpeedChanged()
        if self.SpeedBasedSequences then
            self:UpdateMovementSequences()
        end
    end

    function ENT:UpdateMovementSpeed() -- This is what allows zombies to use the movement speed from their movement anim as a posed to just using the one given to them by code.
        if self:GetCrawler() or self.IsMooSpecial then
            local speed = self:GetSequenceGroundSpeed( self:GetSequence() )
            self:SetRunSpeed( speed )
            self.loco:SetDesiredSpeed( self:GetRunSpeed() )
            self.DesiredSpeed = self:GetRunSpeed()
        end
    end
end

if SERVER then
    -- Select a spawn sequence and sound to play. This is called after everything is initialized
    function ENT:SelectSpawnSequence()
        local s
        if self.SpawnSounds then s = self.SpawnSounds[math.random(#self.SpawnSounds)] end
        return type(self.SpawnSequence) == "table" and self.SpawnSequence[math.random(#self.SpawnSequence)] or self.SpawnSequence, s
    end

    -- Collide When Possible
    local collidedelay = 0.25
    local bloat = Vector(5,5,0)

    function ENT:Think()
        BaseClass.Think(self)

        self:ZombieStatusEffects()

        if not self.NextSound or self.NextSound < CurTime() then
            self:Sound()
        end
    end

    function ENT:StuckPrevention()
        -- We don't want to say we're stuck if it's because we're attacking or timed out and !self:GetTimedOut() 
        if !self:GetIsBusy() and !self:GetSpecialAnimation() and !self:GetAttacking() and self:GetLastPositionSave() + 4 < CurTime() then
            if self:GetPos():DistToSqr( self:GetStuckAt() ) < 10 then
                self:SetStuckCounter( self:GetStuckCounter() + 1)
                --print(self:GetStuckCounter())
            else
                self:SetStuckCounter( 0 )
            end

            if self:GetStuckCounter() > 1 then
                local tr = util_tracehull({
                    start = self:GetPos(),
                    endpos = self:GetPos(),
                    maxs = self:OBBMaxs(),
                    mins = self:OBBMins(),
                    filter = self
                })
                if !tr.HitNonWorld then
                    self:ApplyRandomPush(750) -- Made this comically high so it actually PUSHES them and doesn't just breathe on them.
                end
                if self:GetStuckCounter() > 3 then
                    if self.NZBossType then
                        local spawnpoints = {}
                        for k,v in pairs(ents.FindByClass("nz_spawn_zombie_special")) do -- Find and add all valid spawnpoints that are opened and not blocked
                            if (v.link == nil or nzDoors:IsLinkOpened( v.link )) and v:IsSuitable() then
                                table.insert(spawnpoints, v)
                            end
                        end
                        local selected = spawnpoints[math.random(#spawnpoints)] -- Pick a random one
                        self:SetPos(selected:GetPos())
                    else
                        self:RespawnZombie()
                    end
                    self:SetStuckCounter( 0 )
                end
            end
            self:SetLastPositionSave( CurTime() )
            self:SetStuckAt( self:GetPos() )
        end
    end
end

------- Fields -------
ENT.SoundDelayMin = 3
ENT.SoundDelayMax = 5
ENT.BehindSoundDistance = 0 -- The distance to a target where we will play "behind sounds" instead (0 = disable). This requires ENT.BehindSounds to be set

function ENT:PlaySound(s, lvl, pitch, vol, chan, delay) --Moo Mark This part is a port of the nZu zombie base sound functions.
    local delay = delay or math.Rand(self.SoundDelayMin, self.SoundDelayMax)
    if s then
        local dur = SoundDuration(s)
        self:EmitSound(s, lvl, pitch, vol, chan)
        delay = delay + dur
    end
    self.NextSound = CurTime() + delay
end

function ENT:Sound()
    if self:GetAttacking() or !self:Alive() or self:GetDecapitated() then return end

    local amount = nzEnemies:TotalAlive()
    local vol = 80

    if amount < 2 then vol = 511 end

    if self.BehindSoundDistance > 0 -- We have enabled behind sounds
        and IsValid(self.Target)
        and self.Target:IsPlayer() -- We have a target and it's a player within distance
        and self:GetRangeTo(self.Target) <= self.BehindSoundDistance
        and (self.Target:GetPos() - self:GetPos()):GetNormalized():Dot(self.Target:GetAimVector()) >= 0 then -- If the direction towards the player is same 180 degree as the player's aim (away from the zombie)
            self:PlaySound(self.BehindSounds[math.random(#self.BehindSounds)], 100, math.random(80, 110), 1, 2) -- Play the behind sound, and a bit louder!
    
    --[[ A big "if then" thingy for playing other sounds. ]]--
    elseif self.ElecSounds and (self.BO4IsShocked and self:BO4IsShocked() or self.BO4IsScorped and self:BO4IsScorped() or self.BO4IsSpinning and self:BO4IsSpinning()) then
        self:PlaySound(self.ElecSounds[math.random(#self.ElecSounds)],vol, math.random(80, 110), 1, 2)
    elseif IsValid(self.Target) and self.Target:GetClass() == "nz_monkeybomb" and self.MonkeySounds and !self.IsMooSpecial then
        self:PlaySound(self.MonkeySounds[math.random(#self.MonkeySounds)], 100, math.random(80, 110), 1, 2)
    elseif self:GetCrawler() and self.CrawlerSounds then
        self:PlaySound(self.CrawlerSounds[math.random(#self.CrawlerSounds)],vol, math.random(80, 110), 1, 2)
    elseif (self:BomberBuff() or self.IsTurned ) and self.GasVox and !self.IsMooSpecial then
        self:PlaySound(self.GasVox[math.random(#self.GasVox)],vol, math.random(95, 105), 1, 2)
    elseif self.PassiveSounds then
        self:PlaySound(self.PassiveSounds[math.random(#self.PassiveSounds)],vol, math.random(80, 110), 1, 2)
    else


        -- We still delay by max sound delay even if there was no sound to play
        self.NextSound = CurTime() + self.SoundDelayMax
    end
end

-- Moo Mark 4/14/23: The function below this is one of two things I've found out about since using DrgBase for the first time and HOLY shit this function is useful.

function ENT:HandleAnimEvent(a,b,c,d,e) -- Moo Mark 4/14/23: You don't know how sad I am that I didn't know about this sooner.
    if e == "melee" then
        if self:BomberBuff() and self.GasAttack then
            self:EmitSound(self.GasAttack[math.random(#self.GasAttack)], 100, math.random(95, 105), 1, 2)
        else
            if self.AttackSounds then
                self:EmitSound(self.AttackSounds[math.random(#self.AttackSounds)], 100, math.random(85, 105), 1, 2)
            end
        end
        self:DoAttackDamage()
    end
    if e == "generic_taunt" then
        if self.TauntSounds then
            self:EmitSound(self.TauntSounds[math.random(#self.TauntSounds)], 100, math.random(85, 105), 1, 2)
            self.NextSound = CurTime() + self.SoundDelayMax
        end
    end
    if e == "special_taunt" then
        if self.TauntSounds then
            self:EmitSound("nz_moo/zombies/vox/_classic/taunt/spec_taunt.mp3", 100, math.random(85, 105), 1, 2)
            self.NextSound = CurTime() + self.SoundDelayMax
        end
    end
    if e == "death_ragdoll" then
        self:BecomeRagdoll(DamageInfo())
    end
    if e == "start_traverse" then
        --print("starttraverse")
        self.TraversalAnim = true
    end
    if e == "finish_traverse" then
        --print("finishtraverse")
        self.TraversalAnim = false
    end
end

if SERVER then

    
    function ENT:AI() end -- Called at the end of the RunBehaviour. Use this for additional abilities/functions an enemy may have.

    function ENT:PostAdditionalZombieStuff() end -- Called in the AdditionalZombieStuff func. Use this for enemies that closely mimic normal zombies.

    function ENT:TempBehaveThread(callback) -- Moo Mark 4/14/23: My little project with DrgBase showed me the light, like holy fuck...
        local CurrentThread = self.BehaveThread
        self.BehaveThread = coroutine.create(function()
            callback(self)
            self.BehaveThread = CurrentThread
        end)
    end

    function ENT:RunBehaviour()
        BaseClass.RunBehaviour(self)
    end

    function ENT:RunBehaviourLoop()
        self:AI()
        self:AdditionalZombieStuff()
    end
    
    function ENT:TraversalCheck()
        -- ORIGINALLY TAKEN FROM THE VJBASE L4D COMMON INFECTED SNPCS!!!
        -- Moo Mark 3/18/23: Now includes a failsafe for enemies who lack climb anims.
        if !self:GetSpecialAnimation() and !self:GetAttacking() and !self.Climbing and CurTime() > self.NextClimb then

            local seq
            local target
            local anim = false
            local hasanim = false

            local finalpos = self:GetPos()
            local tr6 = util_traceline({
                start = self:GetPos() + self:GetUp()*200, 
                endpos = self:GetPos() + self:GetUp()*200 + self:GetForward()*self.TraversalCheckRange,
                ignoreworld = true,
                filter = function(ent) if (ent:GetClass() == "jumptrav_block") then return true end
            end}) -- 200
            local tr5 = util_traceline({
                start = self:GetPos() + self:GetUp()*160, 
                endpos = self:GetPos() + self:GetUp()*160 + self:GetForward()*self.TraversalCheckRange,
                ignoreworld = true, 
                filter = function(ent) if (ent:GetClass() == "jumptrav_block") then return true end 
            end}) -- 160
            local tr4 = util_traceline({
                start = self:GetPos() + self:GetUp()*120, 
                endpos = self:GetPos() + self:GetUp()*120 + self:GetForward()*self.TraversalCheckRange,
                ignoreworld = true, 
                filter = function(ent) if (ent:GetClass() == "jumptrav_block") then return true end 
            end}) -- 120
            local tr3 = util_traceline({
                start = self:GetPos() + self:GetUp()*96, 
                endpos = self:GetPos() + self:GetUp()*96 + self:GetForward()*self.TraversalCheckRange,
                ignoreworld = true, 
                filter = function(ent) if (ent:GetClass() == "jumptrav_block") then return true end 
            end}) -- 96
            local tr2 = util_traceline({
                start = self:GetPos() + self:GetUp()*72, 
                endpos = self:GetPos() + self:GetUp()*72 + self:GetForward()*self.TraversalCheckRange,
                ignoreworld = true, 
                filter = function(ent) if (ent:GetClass() == "jumptrav_block") then return true end 
            end}) -- 72
            local tr1 = util_traceline({
                start = self:GetPos() + self:GetUp()*48, 
                endpos = self:GetPos() + self:GetUp()*48 + self:GetForward()*self.TraversalCheckRange,
                ignoreworld = true, 
                filter = function(ent) if (ent:GetClass() == "jumptrav_block") then return true end 
            end}) -- 48
            local tr0 = util_traceline({
                start = self:GetPos() + self:GetUp()*36, 
                endpos = self:GetPos() + self:GetUp()*36 + self:GetForward()*self.TraversalCheckRange,
                ignoreworld = true, 
                filter = function(ent) if (ent:GetClass() == "jumptrav_block") then return true end 
            end}) -- 36
            local tru = util_traceline({
                start = self:GetPos(), 
                endpos = self:GetPos() + self:GetUp()*200, 
                ignoreworld = true,
                filter = self and function(ent) if ent:IsValidZombie() then return false end 
            end})
            
            debugoverlay.Line(self:GetPos() + self:GetUp()*200, self:GetPos() + self:GetUp()*200 + self:GetForward()*self.TraversalCheckRange, 1, Color( 255, 100, 100 ), false)
            debugoverlay.Line(self:GetPos() + self:GetUp()*160, self:GetPos() + self:GetUp()*160 + self:GetForward()*self.TraversalCheckRange, 1, Color( 255, 0, 255 ), false)
            debugoverlay.Line(self:GetPos() + self:GetUp()*120, self:GetPos() + self:GetUp()*120 + self:GetForward()*self.TraversalCheckRange, 1, Color( 255, 255, 0 ), false)
            debugoverlay.Line(self:GetPos() + self:GetUp()*96, self:GetPos() + self:GetUp()*96 + self:GetForward()*self.TraversalCheckRange, 1, Color( 255, 0, 0 ), false)
            debugoverlay.Line(self:GetPos() + self:GetUp()*72, self:GetPos() + self:GetUp()*72 + self:GetForward()*self.TraversalCheckRange, 1, Color( 0, 255, 0 ), false)
            debugoverlay.Line(self:GetPos() + self:GetUp()*48, self:GetPos() + self:GetUp()*48 + self:GetForward()*self.TraversalCheckRange, 1, Color( 0, 0, 255 ), false)
            debugoverlay.Line(self:GetPos() + self:GetUp()*36, self:GetPos() + self:GetUp()*36 + self:GetForward()*self.TraversalCheckRange, 1, Color( 255, 10, 50 ), false)

            if !IsValid(tru.Entity) then
                if IsValid(tr6.Entity) then
                local tr6b = util_traceline({start = self:GetPos() + self:GetUp()*260, endpos = self:GetPos() + self:GetUp()*260 + self:GetForward()*self.TraversalCheckRange, filter = function(ent) if (ent:GetClass() == "jumptrav_block") then return true end end})
                if !IsValid(tr6b.Entity) then
                    if self.Climb200 then
                        target = type(self.Climb200) == "table" and self.Climb200[math.random(#self.Climb200)] or self.Climb200
                        seq = self:LookupSequence(target)
                        hasanim = true
                    end
                    anim = seq or true
                    finalpos = tr6.HitPos
                end
                elseif IsValid(tr5.Entity) then
                    if self.Climb160 then
                        target = type(self.Climb160) == "table" and self.Climb160[math.random(#self.Climb160)] or self.Climb160
                        seq = self:LookupSequence(target)
                        hasanim = true
                    end
                    anim = seq or true
                    finalpos = tr5.HitPos
                elseif IsValid(tr4.Entity) then
                    if self.Climb120 then
                        target = type(self.Climb120) == "table" and self.Climb120[math.random(#self.Climb120)] or self.Climb120
                        seq = self:LookupSequence(target)
                        hasanim = true
                    end
                    anim = seq or true
                    finalpos = tr4.HitPos
                elseif IsValid(tr3.Entity) then
                    if self.Climb96 then
                        target = type(self.Climb96) == "table" and self.Climb96[math.random(#self.Climb96)] or self.Climb96
                        seq = self:LookupSequence(target)
                        hasanim = true
                    end
                    anim = seq or true
                    finalpos = tr3.HitPos
                elseif IsValid(tr2.Entity) then
                    if self.Climb72 then
                        target = type(self.Climb72) == "table" and self.Climb72[math.random(#self.Climb72)] or self.Climb72
                        seq = self:LookupSequence(target)
                        hasanim = true
                    end
                    anim = seq or true
                    finalpos = tr2.HitPos
                elseif IsValid(tr1.Entity) then
                    if self.Climb48 then
                        target = type(self.Climb48) == "table" and self.Climb48[math.random(#self.Climb48)] or self.Climb48
                        seq = self:LookupSequence(target)
                        hasanim = true
                    end
                    anim = seq or true
                    finalpos = tr1.HitPos
                elseif IsValid(tr0.Entity) then
                    if self.Climb36 then
                        target = type(self.Climb36) == "table" and self.Climb36[math.random(#self.Climb36)] or self.Climb36
                        seq = self:LookupSequence(target)
                        hasanim = true
                    end
                    anim = seq or true
                    finalpos = tr0.HitPos
                end
            end
            if anim ~= false then
                if IsValid(self) then
                    self:SolidMaskDuringEvent(MASK_NPCSOLID_BRUSHONLY)
                    self:TimeOut(0.35)
                    self.Climbing = true
                    self:SetSpecialAnimation(true)
                    self:SetPos(finalpos)
                    if hasanim ~= false then
                        self:PlaySequenceAndWait(anim)
                    else -- For enemies that don't have a traversal for a given height or doesn't have traversal anims period.
                        local effectData = EffectData()
                        effectData:SetOrigin( self:GetPos() + Vector(0, 0, 50)  )
                        effectData:SetMagnitude( 1 )
                        effectData:SetEntity(nil)
                        util.Effect("panzer_spawn_tp", effectData) -- Express Portal to their destination.
                        self:TimeOut(0.25)
                    end
                    self:SetSpecialAnimation(false)
                    self:CollideWhenPossible()
                    self.Climbing = false
                end
            end
            self.NextClimb = CurTime() + 0.25
        end
    end

    function ENT:ZombieStatusEffects()
        if CurTime() > self.LastStatusUpdate then

            if self.IsTurned or !self:Alive() then return end

            if self:GetSpecialAnimation() and !self.CanCancelSpecial or self.IsMooSpecial and !self.MooSpecialZombie then return end    
            if self:GetCrawler() then
                if self.BO3IsCooking and self:BO3IsCooking() then
                    --print("Uh oh Mario, I'm about to fucking inflate lol.")
                    self:SetSpecialShouldDie(true)
                    self:DoSpecialAnimation(self.CrawlMicrowaveSequences[math.random(#self.CrawlMicrowaveSequences)])
                end
                if self.BO4IsFrozen and self:BO4IsFrozen() then
                    --print("Uh oh Mario, I'm frozen lol.")
                    self:SetSpecialShouldDie(true)
                    self:DoSpecialAnimation(self.CrawlFreezeDeathSequences[math.random(#self.CrawlFreezeDeathSequences)])
                end
            else
                if self.BO3IsSlipping and self:BO3IsSlipping() and !self.IsTurned then
                    --print("Uh oh Luigi, I've been played for a fool lol.")
                    self:DoSpecialAnimation(self.SlipGunSequences[math.random(#self.SlipGunSequences)])
                end
                if self.BO3IsPulledIn and self:BO3IsPulledIn() and !self.IsTurned then
                    --print("Uh oh Mario, I'm getting pulled to my doom lol.")
                    self:SetSpecialShouldDie(true)
                    self:DoSpecialAnimation(self.IdGunSequences[math.random(#self.IdGunSequences)])
                end
                if self.BO3IsSkullStund and self:BO3IsSkullStund() and !self.IsTurned then
                    --print("Uh oh Mario, I'm ASCENDING lol.")
                    if !self.Non3arcZombie then
                        self:DoSpecialAnimation(self.SoulDrainSequences[math.random(#self.SoulDrainSequences)])
                    else
                        self:DoSpecialAnimation(self.DeathRaySequences[math.random(#self.DeathRaySequences)])
                    end
                end
                if self.BO3IsCooking and self:BO3IsCooking() and !self.IsTurned then
                    --print("Uh oh Mario, I'm about to fucking inflate lol.")
                    self:SetSpecialShouldDie(true)
                    self:DoSpecialAnimation(self.MicrowaveSequences[math.random(#self.MicrowaveSequences)])
                end
                if self.BO4IsFrozen and self:BO4IsFrozen() and !self:GetSpecialAnimation() and !self.IsTurned then
                    --print("Uh oh Mario, I'm frozen lol.")
                    self:SetSpecialShouldDie(true)
                    self:DoSpecialAnimation(self.FreezeSequences[math.random(#self.FreezeSequences)])
                end
                if self.BO4IsShrunk and self:BO4IsShrunk() and !self.IsTurned then
                    self:DoSpecialAnimation(self.ShrinkSequences[math.random(#self.ShrinkSequences)])
                end
                if self.BO4IsTornado and self:BO4IsTornado() and !self.IsTurned then
                    self:SetSpecialShouldDie(true)
                    if !self.IsTornado then
                        self:DoSpecialAnimation("nz_alistairs_tornado_lift")
                        self.IsTornado = true
                    end
                end
                if self.BO4IsSpinning and self:BO4IsSpinning() and !self.IsTurned then
                    self:SetSpecialShouldDie(true)
                    if !self.IsXbowSpinning then
                        self:DoSpecialAnimation("nz_dth_ww_xbow_intro")
                        self.IsXbowSpinning = true
                    end
                end
                if self.IsAATTurned and self:IsAATTurned() then
                    if self.IsTurned then -- TURNED
                        if !self.BecomeTurned then
                            self:SetRunSpeed(200)
                            self:SpeedChanged()
                            self:Retarget()
                            self:TimeOut(0.2)
                            self.BecomeTurned = true
                        end
                    else -- TURNT
                        self:PlaySound(self.DanceSounds[math.random(#self.DanceSounds)], 511)
                        self:DoSpecialAnimation(self.DanceSequences[math.random(#self.DanceSequences)])
                    end
                end
                if self.IsATTCryoFreeze and self:IsATTCryoFreeze() and !self.IsTurned then 
                    self:SetSpecialShouldDie(true)
                    self:DoSpecialAnimation(self.IceStaffSequences[math.random(#self.IceStaffSequences)])
                end
            end
            self.LastStatusUpdate = CurTime() + 0.25
        end
    end

    -- ulx luarun "Entity(1):GetEyeTrace().Entity:ATTCryoFreeze(3, Entity(1), Entity(1):GetActiveWeapon())"
    -- ulx luarun "Entity(1):GetEyeTrace().Entity:AATTurned(10, Entity(1), true)"
    -- ulx luarun "Entity(1):GetEyeTrace().Entity:AATTurned(30, Entity(1), false)"
    -- ulx luarun "Entity(1):GetEyeTrace().Entity:BO4Tornado(5, Entity(1), Entity(1):GetActiveWeapon())"

    function ENT:AdditionalZombieStuff()
        if self:GetSpecialAnimation() or self.IsMooSpecial and !self.MooSpecialZombie or self.IsTurned then return end
        if self:Alive() and self:Health() <= 0 then return end
        if self.BO4IsToxic and self:BO4IsToxic() then
            self:SetRunSpeed(1)
            self:SpeedChanged()
            self:FleeTarget(3)
        end
        if !self.HasSTaunted and math.random(200) == 1 and self:GetRunSpeed() <= 40 then
            if self:GetCrawler() then return end
            if self.Non3arcZombie then return end
            self.HasSTaunted = true
            self:DoSpecialAnimation(self.SuperTauntSequences[math.random(#self.SuperTauntSequences)])
            self:SetRunSpeed(36)
            self:SpeedChanged()
        end
        if self:GetRunSpeed() < 145 and nzRound:InProgress() and nzRound:GetNumber() >= 4 and !nzRound:IsSpecial() and nzRound:GetZombiesKilled() >= nzRound:GetZombiesMax() - 3 then
            if self:GetCrawler() then return end
            self.LastZombieMomento = true
        end
        if self.LastZombieMomento and !self:GetSpecialAnimation() then
            --print("Uh oh Mario, I'm about to beat your fucking ass lol.")
            self.LastZombieMomento = false
            self:SetRunSpeed(100)
            self:SpeedChanged()
        end
        --[[if self.loco:GetVelocity():Length2D() < 75 then
            self:TraversalCheck()
        end]]
        if IsValid(self:GetTarget()) and self:GetTarget():IsPlayer() and self.IsIdle then
            -- THAT FUCKER GOT THEM FAKE J'S ON!!!
            self.IsIdle = false
            if self:GetCrawler() then return end
            if self.Non3arcZombie then return end
            if self:IsAttackBlocked() then return end
            if self:GetRunSpeed() > 50 then
                local seq = self.ReactTauntSequences[math.random(#self.ReactTauntSequences)]
                local normal = (self:GetPos() - self:GetTarget():GetPos()):GetNormalized()
                local fwd = self:GetForward()
                local right = self:GetRight()
                local dot = fwd:Dot(normal)
                local dot2 = right:Dot(normal)

                -- This looks like dog water, but until I can find a better way to write this... This is how it'll stay.

                --The zombie will turn to face the general direction their new target is in... If they aren't walking.
                if dot2 < -0.5 and dot >= -0.5 then
                    seq = "nz_stn_idle_react_r_v1"
                elseif dot2 > 0.5 and dot <= 0.5 then
                    seq = "nz_stn_idle_react_l_v1"
                else
                    if dot < 0 then
                        seq = "nz_stn_idle_react_f_v1"
                    else
                        seq = "nz_stn_idle_react_b_v1"
                    end
                end
                if self:SequenceHasSpace(seq) then
                    self:DoSpecialAnimation(seq, true, true)
                end
            else
                self:DoSpecialAnimation(self.ReactTauntSequences[math.random(#self.ReactTauntSequences)], true, true)
            end
        end
        if nzMapping.Settings.sidestepping then -- Commence thy tomfoolery.
            if self:GetCrawler() then return end -- But not if you're a cripple :man_in_manual_wheelchair:
            if self.Non3arcZombie then return end -- Or if you're a WW2 man.
            if self:TargetInRange(200) and !self.AttackIsBlocked and math.random(200) <= 15 and CurTime() > self.LastSideStep then
                if !self:IsInSight() then return end
                if self:TargetInRange(75) then return end
                if self:GetRunSpeed() > 140 then return end
                if IsValid(self:GetTarget()) and self:GetTarget():IsPlayer() then
                    local seq = self.SideStepSequences[math.random(#self.SideStepSequences)]
                    if self:SequenceHasSpace(seq) then
                        self:DoSpecialAnimation(seq, true, true)
                    end
                    self.LastSideStep = CurTime() + 4
                end
            end
        end
        self:PostAdditionalZombieStuff()
    end

    function ENT:OnTakeDamage(dmginfo) -- Added by Ethorbit for implementation of the ^^^
        --if self.SpawnProtection then
        --  dmginfo:ScaleDamage(0) -- Stop zombies from taking damage if they're being spawnprotected.
        --  return                 -- A humble surprise is that this seems to stop Zero Health Zombies from appearing like 90% of the time. I'm being optimistic with the 90%.
        --end
        
        --if (dmginfo:GetDamageType() == DMG_DISSOLVE and dmginfo:GetDamage() >= self:Health() and self:Health() > 0) then
        --  self:DissolveEffect()
        --end

        if dmginfo:GetDamageType() == DMG_BURN or dmginfo:GetDamageType() == DMG_SLOWBURN or dmginfo:GetDamageType() == 268435464 then
            local attacker = dmginfo:GetAttacker()
            local inflictor = dmginfo:GetInflictor()

            -- Zombies will handle taking flame damage themselves. It allows for them to always be killed.
            
            -- No, fire weapon devs should apply the damage by a percentage of health instead. At least in NZC this is how it has always worked.
            -- More weapons will be affected by this change than will even be added, so it is more than fair to comment this out.
            if attacker and inflictor then -- This is how 3arc made the Flamethower always kill, by doing damage with the Zombie's max health * numbers 0.1 to 0.15
                self:TakeDamage(self:GetMaxHealth() * math.Rand(0.1, 0.15), attacker, inflictor) -- Granted this changes depending on the round in the actual game, I just included the multipliers that are used past round 11.
            end
        end

        if dmginfo:GetDamage() == 75 and dmginfo:IsDamageType(DMG_MISSILEDEFENSE) and not self:GetSpecialAnimation() then
            if self.IsMooSpecial then return end
            self:SetTarget(nil)
            --print("Uh oh Luigi, I'm about to commit insurance fraud lol.")
            self:DoSpecialAnimation(self.ThunderGunSequences[math.random(#self.ThunderGunSequences)])
        end

        if self:CrawlerDamageTest(dmginfo) and !self.ShouldCrawl then
            self.ShouldCrawl = true
        end

        self:PostTookDamage(dmginfo)

        --self:SetLastHurt(CurTime())
    
        BaseClass.OnTakeDamage(self, dmginfo)
    end

    function ENT:PostTookDamage(dmginfo) end -- Use this if you want things to happen after the enemy takes damage.

    -- Moo Mark 3/27/23: The two functions below this comment are functions to stop zombies from attacking you through the world and entities(minus other zombies and players).
    function ENT:UpdateAttackRange()
        if CurTime() > self.AttackRangeUpdate and IsValid(self.Target) then
            if self:IsAttackBlocked() and self.Target:IsPlayer() then
                self.AttackIsBlocked = true
                if self.FailedAttack < 6 then
                    self:SetAttackRange(1) -- For as long as the trace is hitting something, the attack range will be 1.
                else
                    self:SetAttackRange(self.AttackRange)
                end
                if self:TargetInRange(self.DamageRange) then -- But the player is in range... They may be trying to exploit but we don't know for sure, hence the delay.
                    self.FailedAttack = self.FailedAttack + 1 
                end
            else
                self.AttackIsBlocked = false
                self.FailedAttack = 0
                if self:GetCrawler() then
                    self:SetAttackRange(self.CrawlAttackRange)
                elseif self.IsTurned then -- This one only affects turned zombies.
                    self:SetAttackRange(self.AttackRange + 45)
                    self.DamageRange = self.DamageRange + 45
                elseif IsValid(self.Target) and self.Target:GetClass() == "nz_bo3_tac_gersch" or self.BO3IsWebbed and self:BO3IsWebbed() then
                    self:SetAttackRange(1) -- So the zombie can as close as possible to the gersch.
                else
                    self:SetAttackRange(self.AttackRange) -- Revert the range back to normal if theres nothing blocking the trace.
                end
            end
            --print("Attack Range changed, new range is "..self:GetAttackRange()..".")
            self.AttackRangeUpdate = CurTime() + 1
        end
    end

    function ENT:IsAttackBlocked()
        if IsValid(self.Target) and self.Target:IsPlayer() then
            local tr = util_traceline({
                start = self:EyePos(),
                endpos = self.Target:EyePos(),
                filter = self,
                mask = MASK_PLAYERSOLID,
                collisiongroup = COLLISION_GROUP_WORLD, -- This is what allows zombies to ignore each other.
                ignoreworld = false
            })

            -- Runs a trace from the zombie to the player to make sure theres nothing in between them.

            local ent = tr.Entity

            if IsValid(ent) and ent:IsPlayer() then return false end

            return tr.Hit
        end
    end

    function ENT:IsAttackEntBlocked(ent) -- 4/24/23: Same as above but allows use of an inserted Entity rather than the bot's current target.
        if IsValid(ent) and ent:IsPlayer() then
            local tr = util_traceline({
                start = self:EyePos(),
                endpos = ent:EyePos(),
                filter = self,
                mask = MASK_PLAYERSOLID,
                collisiongroup = COLLISION_GROUP_WORLD, -- This is what allows zombies to ignore each other.
                ignoreworld = false
            })

            -- Runs a trace from the zombie to the player to make sure theres nothing in between them.

            local ent = tr.Entity

            if IsValid(ent) and ent:IsPlayer() then return false end

            return tr.Hit
        end
    end

    -- Moo Mark 6/26/23: A function that allows you to check the end destination of a sequence.
    -- You'd use this before doing a PlaySequenceAndMove to see if the sequence would end up putting the bot somewhere undesirable like falling off a ledge or moving into a wall.
    function ENT:SequenceHasSpace(seq)
        local spos = self:GetPos()
        local comedy = true -- A bool that does nothing other than allow the GetSequenceMovement data to go through.

        local comedy, vec, angles = self:GetSequenceMovement(self:LookupSequence(seq), 0, 1) -- Get the sequence's postion data
        if isvector(vec) then
            vec = Vector(vec.x, vec.y, vec.z)
        end
        vec = self:LocalToWorld(vec) -- Make the Vector local to the bot itself

        debugoverlay.Sphere(vec, 15, 5, Color( 255,255,255), false) -- Shows a debug sphere at the selected sequences destination
        local minBound, maxBound = self:OBBMins(), self:OBBMaxs()
        if self:CollisionBoxClear(self, vec, minBound, maxBound) then -- Check if theres space
            --print("Collision Clear")
            local qtr = util.QuickTrace(vec, vector_up*-12, self) -- Check if theres a floor
            if qtr.Hit then
                return true -- Returned true, we can play the sequence without having problems.
            end
        end
    end

    function ENT:IsEntBlocked(ent) 
        if IsValid(ent) then
            local pos = ent:GetPos()
            local tr = util_traceline({
                start = self:EyePos(),
                endpos = Vector(pos.x,pos.y+50,pos.z),
                filter = self,
                mask = MASK_PLAYERSOLID,
                collisiongroup = COLLISION_GROUP_WORLD,
                ignoreworld = false
            })

        
            local ent = tr.Entity

            if IsValid(ent) and ent:IsPlayer() then return false end
            if IsValid(ent) and ent:GetClass() == "random_box" then return false end
            if IsValid(ent) and ent:GetClass() == "perk_machine" then return false end

            return tr.Hit
        end
    end

    -- This function is full of stench
    function ENT:OnBarricadeBlocking( barricade, dir )
        if not self:GetSpecialAnimation() then
            BaseClass.OnBarricadeBlocking(self, barricade, dir)
        end
    end
end

function ENT:TimeOut(time)
    if self.IsTornado or self.IsXbowSpinning or !self:GetSpecialShouldDie() then
        self:PerformIdle()
    end

    BaseClass.TimeOut(self, time)
end

function ENT:OnThink()
    BaseClass.OnThink(self)

    if not IsValid(self) then return end

    if SERVER and self:Alive() and self:GetDecapitated() then // Decapitation bleedout

        if not self.nextbleedtick then
            self.nextbleedtick = CurTime() + 0.25
            self.bleedtickcount = 0
        end

        if self.nextbleedtick and self.nextbleedtick < CurTime() then
            ParticleEffectAttach("nz_blood_headshot", 4, self, 10)

            self.nextbleedtick = CurTime() + math.Rand(0.15, 0.4)
            self.bleedtickcount = self.bleedtickcount + 1
        end

        if self.bleedtickcount and self.bleedtickcount > 10 then
            print(self, "Bleeding out.", "bleedtick:", self.bleedtickcount, "health:", self:Health())
            self:TakeDamage(self:Health() + 666, Entity(0), Entity(0))
        end
    end
end

--Default NEXTBOT Events
function ENT:OnLandOnGround()
    BaseClass.OnLandOnGround(self)

    if self:Alive() then
        --self:EmitSound("physics/flesh/flesh_impact_hard" .. math.random(1, 6) .. ".wav")
        --self:SetJumping( false )
        --self:SetLastLand(CurTime())
        if !self:GetAttacking() and !self:GetSpecialAnimation() and self:Alive() then
            self:ResetMovementSequence()
        end
        --self:OnLandOnGroundZombie()
    end
end

--function ENT:OnLeaveGround( ent )
--  self:SetJumping( true )
--end

--function ENT:OnLandOnGroundZombie() end

function ENT:OnNavAreaChanged(old, new)
    BaseClass.OnNavAreaChanged(self, old, new)

    if !self.IsMooSpecial and !self.ShouldCrawl and IsValid(new) then
        if bit.band(new:GetAttributes(), NAV_MESH_CROUCH) ~= 0 then
            if !self:GetCrawler() then
                self:BecomeCrawler()
            end
        else
            if self:GetCrawler() then
                self:BecomeNormal()
            end
        end
    end
end

function ENT:WanderAround()
    if !self:GetCrawler() then
        self:StartActivity(ACT_WALK)
    end

    self:SetWandering(true)
    self.loco:SetDesiredSpeed(40)
    self:MoveToPos(self:GetPos() + Vector(math.random(-512, 512), math.random(-512, 512), 0), {
        repath = 3,
        maxage = 5
    })
end

if SERVER then
    ENT.DeathRagdollForce = 9500
    ENT.CrawlerForce = 7500
    ENT.GibForce = 200
    ENT.StunForce = 1250
    ENT.HasGibbed = false

    function ENT:RagdollForceTest(force)
        if force == nil then return nil end
        return self.DeathRagdollForce^2 <= force:LengthSqr()
    end

    function ENT:CrawlerForceTest(force)
        if force == nil then return nil end
        return self.CrawlerForce^2 <= force:LengthSqr()
    end

    function ENT:GibForceTest(force)
        if force == nil then return nil end
        return self.GibForce^2 <= force:LengthSqr()
    end

    function ENT:StunForceTest(force)
        if force == nil then return nil end
        return self.StunForce^2 <= force:LengthSqr()
    end

    function ENT:CrawlerDamageTest(dmginfo)
        if not dmginfo then return nil end
        return self:CrawlerForceTest(dmginfo:GetDamageForce()) and dmginfo:IsExplosionDamage() and !self.IsMooSpecial and !self.HasGibbed and (self:Health() - dmginfo:GetDamage()) <= self:Health() / 1.5
    end

    -- This function is really only used for normal zombies a lot, so this can be overridden without problems.
    function ENT:OnInjured(dmginfo)
        
        local hitgroup = util.QuickTrace(dmginfo:GetDamagePosition(), dmginfo:GetDamagePosition()).HitGroup
        local hitforce = dmginfo:GetDamageForce()

        if !self:GetCrawler() and !self.IsMooSpecial and !self.Non3arcZombie then

            --[[ CRAWLER CREATION FROM DAMAGE ]]--
            if (self.ShouldCrawl or self:CrawlerDamageTest(dmginfo)) and !self:GetCrawler() and self:Alive() and self:Health() > 0 then
                local lleg = self:LookupBone("j_knee_le")
                local rleg = self:LookupBone("j_knee_ri")
                local randleggib = math.random(4) -- Have a chance of randomly removing either the left, right or both legs. jib.

                self:CreateCrawler()
                if (lleg and !self.LlegOff) and (randleggib == 1 or randleggib == 3) then
                    self:GibLegL()
                end
                if (rleg and !self.RlegOff) and (randleggib == 2 or randleggib == 3) then
                    self:GibLegR()
                end
            end

            --[[ GIBBING SYSTEM ]]--
            if self:GibForceTest(hitforce) then
                local head = self:LookupBone("j_head")
                local larm = self:LookupBone("j_elbow_le")
                local rarm = self:LookupBone("j_elbow_ri")
                local randgib = math.random(4)

                if (head and hitgroup == HITGROUP_HEAD) and !self.IsMooSpecial and !self.MarkedForDeath and randgib == 4 and (self:Health() <= self.GibForce) then
                    self:GibHead()
                end

                if (larm and hitgroup == HITGROUP_LEFTARM) and !self.IsMooSpecial and !self.HasGibbed then
                    self:GibArmL()
                end

                if (rarm and hitgroup == HITGROUP_RIGHTARM) and !self.IsMooSpecial and !self.HasGibbed then
                    self:GibArmR()
                end
            end
        end

        BaseClass.OnInjured(self, dmginfo)
    end

    function ENT:CreateCrawler()
        timer.Simple(0, function() -- Need to delay it till next tick otherwise it doesn't work. //its like 3arcs 'waitnetworkedframe'
            if !IsValid(self) then return end
            if !self:Alive() then return end
            if self:Health() <= 0 then return end

            if self.CanBleed then
                self:EmitSound("nz_moo/zombies/gibs/bodyfall/fall_0"..math.random(2)..".mp3",100)
            end
            self:BecomeCrawler() -- Is it's own separate function for ease of doing other things.
        end)
    end

    function ENT:GibArmL()
        if not IsValid(self) then return end
        if self.LArmOff then return end
        self.LArmOff = true
        self.HasGibbed = true

        local lelbone = self:LookupBone("j_elbow_le")
        if lelbone then
            self:DeflateBones({
                "j_elbow_le",
                "j_wrist_le",
                "j_wristtwist_le",
                "j_thumb_le_1",
                "j_thumb_le_2",
                "j_thumb_le_3",
                "j_index_le_1",
                "j_index_le_2",
                "j_index_le_3",
                "j_mid_le_1",
                "j_mid_le_2",
                "j_mid_le_3",
                "j_ring_le_1",
                "j_ring_le_2",
                "j_ring_le_3",
                "j_pinky_le_1",
                "j_pinky_le_2",
                "j_pinky_le_3",
            })

            if not self.MarkedForDeath and self.CanBleed then
                self:EmitSound("nz_moo/zombies/gibs/gib_0"..math.random(3)..".mp3",100)
                ParticleEffectAttach("nz_blood_gib", 4, self, 5)
            end
        end
        self:OnGib(1)
    end

    function ENT:GibArmR()
        if not IsValid(self) then return end
        if self.RArmOff then return end
        self.RArmOff = true
        self.HasGibbed = true

        local relbone = self:LookupBone("j_elbow_ri")
        if relbone then
            self:DeflateBones({
                "j_elbow_ri",
                "j_wrist_ri",
                "j_wristtwist_ri",
                "j_thumb_ri_1",
                "j_thumb_ri_2",
                "j_thumb_ri_3",
                "j_index_ri_1",
                "j_index_ri_2",
                "j_index_ri_3",
                "j_mid_ri_1",
                "j_mid_ri_2",
                "j_mid_ri_3",
                "j_ring_ri_1",
                "j_ring_ri_2",
                "j_ring_ri_3",
                "j_pinky_ri_1",
                "j_pinky_ri_2",
                "j_pinky_ri_3",
            })

            if not self.MarkedForDeath and self.CanBleed then
                self:EmitSound("nz_moo/zombies/gibs/gib_0"..math.random(3)..".mp3",100)
                ParticleEffectAttach("nz_blood_gib", 4, self, 6)
            end
        end
        self:OnGib(2)
    end

    function ENT:GibLegL()
        if not IsValid(self) then return end
        if self.LlegOff then return end
        self.LlegOff = true
        self.HasGibbed = true

        local lleg = self:LookupBone("j_knee_le")
        if lleg then
            self:DeflateBones({
                "j_knee_le",
                "j_knee_bulge_le",
                "j_ankle_le",
                "j_ball_le",
            })

            if not self.MarkedForDeath and self.CanBleed then
                self:EmitSound("nz_moo/zombies/gibs/gib_0"..math.random(3)..".mp3",100)
                ParticleEffectAttach("nz_blood_gib", 4, self, 7)
            end
        end
        self:OnGib(3)
    end

    function ENT:GibLegR()
        if not IsValid(self) then return end
        if self.RlegOff then return end
        self.RlegOff = true
        self.HasGibbed = true

        local rleg = self:LookupBone("j_knee_ri")
        if rleg then
            self:DeflateBones({
                "j_knee_ri",
                "j_knee_bulge_ri",
                "j_ankle_ri",
                "j_ball_ri",
            })

            if not self.MarkedForDeath and self.CanBleed then
                self:EmitSound("nz_moo/zombies/gibs/gib_0"..math.random(3)..".mp3",100)
                ParticleEffectAttach("nz_blood_gib", 4, self, 8)
            end
        end
        self:OnGib(4)
    end

    function ENT:GibRandom()
        if not IsValid(self) then return end
        if self.HasGibbed then return end

        local gib = math.random(4)
        if gib == 1 then
            self:GibArmL()
        elseif gib == 2 then
            self:GibArmR()
        elseif gib == 3 then
            self:GibLegL()
        elseif gib == 4 then
            self:GibLegR()
        end
    end

    function ENT:GibHead()
        if self:GetDecapitated() then return end
        self:SetDecapitated(true)

        if IsValid(self.spritetrail) and IsValid(self.spritetrail2) then
            SafeRemoveEntity(self.spritetrail)
            SafeRemoveEntity(self.spritetrail2)
        end

        local head = self:LookupBone("ValveBiped.Bip01_Head1")
        if !head then head = self:LookupBone("j_head") end
        if head then
            self:ManipulateBoneScale(head, Vector(0.00001,0.00001,0.00001))
        end

        if self.CanBleed then
            self:EmitSound("nz_moo/zombies/gibs/head/head_explosion_0"..math.random(4)..".mp3", 100, math.random(95,105))
            self:EmitSound("nz_moo/zombies/gibs/death_nohead/death_nohead_0"..math.random(2)..".mp3", 85, math.random(95,105))
            ParticleEffectAttach("nz_blood_headshot", 4, self, 10)
        end
        self:OnGib(5)
    end

    function ENT:OnGib(gib) -- Called when a zombie is gibbed in any way.
        //1 = Left Arm
        //2 = Right Arm
        //3 = Left Leg
        //4 = Right Leg
        //5 = Head
    end

    -- Moo base has its own.
    function ENT:TryDecapitation(dmgInfo)
    end

    function ENT:OnKilled(dmginfo)
        -- Moo Mark 5/16/23: Trying something where the Kill func is dead died body fell to pieces :nerd:
        if dmginfo and self:Alive() then -- Only call once!
            -- self:TimeOut(0) -- This consistently makes zero health zombies!!! Thats actually a good thing believe it or not.
            -- Actually gonna keep the TimeOut above to consistently make zero health zombies for testing.
            if !self:GetShouldCount() then
                nzEnemies:OnEnemyKilled(self, dmginfo:GetAttacker(), dmginfo, 0)
            end

            if IsValid(self.spritetrail) and IsValid(self.spritetrail2) then
                SafeRemoveEntity(self.spritetrail)
                SafeRemoveEntity(self.spritetrail2)
            end

            if !self.IsMooSpecial then
                if dmginfo:IsDamageType(DMG_SHOCK) and math.random(8) == 1 then //Random head-pop
                    self:GibHead()
                    self:EmitSound("TFA_BO3_WAFFE.Pop")
                end

                local hitgroup = util.QuickTrace(dmginfo:GetDamagePosition(), dmginfo:GetDamagePosition()).HitGroup
                if (hitgroup == HITGROUP_HEAD or nzPowerUps:IsPowerupActive("insta")) then
                    self:GibHead()
                end
            end

        --    local dmg_attacker = dmginfo:GetAttacker()
        --    local dmg_inflictor = dmginfo:GetInflictor()
        --    local dmg_type = dmginfo:GetDamageType()
        --    local dmg_amount = dmginfo:GetDamage()
        --    local dmg_force = dmginfo:GetDamageForce()
        --    
        --    self:TimedEvent(2, function()
        --        print("Invincible Moo zombie. Auto fixing..")
        --        
        --        local dmg = DamageInfo()
        --        dmg:SetAttacker(dmg_attacker)
        --        dmg:SetInflictor(dmg_inflictor)
        --        dmg:SetDamageType(dmg_type)
        --        dmg:SetDamage(dmg_amount)
        --        dmg:SetDamageForce(dmg_force)

        --        self:Kill(dmg)
        --    end)

            self.ZombieAlive = false -- WARNING, this will make the zombie invincible if it died during or before spawning phase. The line above should fix that.
        --  --self:SetAlive(false)
        --  self.Dying = true

            --self:RemoveTrigger()
            --self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
            self:DisableCollision()
            self:PostDeath(dmginfo)
            self:PerformDeath(dmginfo)
        end

        BaseClass.OnKilled(self, dmginfo)
    end

    -- DON'T RAGDOLL. We got our own cool death thing.
    function ENT:OnZombieDeath()
    end

    function ENT:PostDeath(dmginfo) end -- Called when you want something to happen after the zombie dies...

    function ENT:PerformDeath(dmginfo)
        local damagetype = dmginfo:GetDamageType()
        if damagetype == DMG_MISSILEDEFENSE or damagetype == DMG_ENERGYBEAM or damagetype == DMG_SONIC then
            self:BecomeRagdoll(dmginfo) -- Only Thundergun and Wavegun Ragdolls constantly.
        return end

        --if damagetype == DMG_REMOVENORAGDOLL then
        --    self:Remove(dmginfo)
        --return end
        
        if damagetype == DMG_DISSOLVE or IsValid(self.Target) and self.Target:GetClass() == "nz_bo3_tac_gersch" and !self.IsMooSpecial then
            if self.DeathSounds then
                self:PlaySound(self.DeathSounds[math.random(#self.DeathSounds)], 90, math.random(85, 105), 1, 2)
            end
            self:DoDeathAnimation(self.BlackHoleDeathSequences[math.random(#self.BlackHoleDeathSequences)], dmginfo)
        return end

        if self.DeathRagdollForce == 0 or self:GetSpecialAnimation() then
            if self.DeathSounds then
                self:PlaySound(self.DeathSounds[math.random(#self.DeathSounds)], 90, math.random(85, 105), 1, 2)
            end
            self:BecomeRagdoll(dmginfo)
        else
            if self:GetCrawler() then
                if self:RagdollForceTest(dmginfo:GetDamageForce()) then
                    if self.DeathSounds then
                        self:PlaySound(self.DeathSounds[math.random(#self.DeathSounds)], 90, math.random(85, 105), 1, 2)
                    end
                    self:BecomeRagdoll(dmginfo)
                elseif damagetype == DMG_SHOCK then
                    if self.ElecSounds then 
                        self:PlaySound(self.ElecSounds[math.random(#self.ElecSounds)], 90, math.random(85, 105), 1, 2)
                    end
                    self:DoDeathAnimation(self.CrawlTeslaDeathSequences[math.random(#self.CrawlTeslaDeathSequences)], dmginfo)
                else
                    if self.DeathSounds then
                        self:PlaySound(self.DeathSounds[math.random(#self.DeathSounds)], 90, math.random(85, 105), 1, 2)
                    end
                    self:DoDeathAnimation(self.CrawlDeathSequences[math.random(#self.CrawlDeathSequences)], dmginfo)
                end
            else
                if self:RagdollForceTest(dmginfo:GetDamageForce()) then
                    if self.DeathSounds then
                        self:PlaySound(self.DeathSounds[math.random(#self.DeathSounds)], 90, math.random(85, 105), 1, 2)
                    end
                    self:GibRandom()
                    self:DoDeathAnimation(self.BlastDeathSequences[math.random(#self.BlastDeathSequences)], dmginfo)
                elseif damagetype == DMG_SHOCK then
                    if self.ElecSounds then
                        self:PlaySound(self.ElecSounds[math.random(#self.ElecSounds)], 90, math.random(85, 105), 1, 2)
                    end
                    self:DoDeathAnimation(self.ElectrocutionSequences[math.random(#self.ElectrocutionSequences)], dmginfo)
                elseif damagetype == DMG_SLASH or damagetype == DMG_CLUB then -- Why the fuck does the knife do DMG_CLUB?
                    if self.DeathSounds then
                        self:PlaySound(self.DeathSounds[math.random(#self.DeathSounds)], 90, math.random(85, 105), 1, 2)
                    end
                    self:DoDeathAnimation(self.MeleeDeathSequences[math.random(#self.MeleeDeathSequences)], dmginfo)
                else
                    if self.DeathSounds then
                        self:PlaySound(self.DeathSounds[math.random(#self.DeathSounds)], 90, math.random(85, 105), 1, 2)
                    end
                    self:DoDeathAnimation(self.DeathSequences[math.random(#self.DeathSequences)], dmginfo)
                end
            end
        end
    end

    function ENT:DoDeathAnimation(seq, dmginfo)
        -- Fix for DMG_REMOVENORAGDOLL added by Ethorbit
        local dont_create_ragdoll = (dmginfo:GetDamageType() == DMG_REMOVENORAGDOLL)
        
        self.BehaveThread = coroutine.create(function()
            self:SetSpecialAnimation(true)
            self:PlaySequenceAndWait(seq)
            
            if dont_create_ragdoll then
                self:Remove()
            else
                self:BecomeRagdoll(DamageInfo())
            end
        end)
    end


    --[[ 
        The DoSpecialAnimation function is probably one of the most important functions in this whole base.
        Instead of doing something like PlaySequenceAndWait, you could use this function instead.
        This function pauses the main coroutine and creates a temporary one.
        You can also have the bot keep their collision or allow them to be able to cancel the anim.
        By default, bots lose their collision and can't cancel the anim. 
        Allowing them to cancel their anim or not can be a touchy one though so becareful how you use it.
    ]]--

    function ENT:DoSpecialAnimation(seq, collision, cancancel)
        collision = collision or false -- Works in conjunction with "SolidMaskDuringEvent" so you can decide if the zombie should keep their collision or not during the special anim.
        cancancel = cancancel or false -- Did this so zombies don't appear to be "Stuck in time" when trying to play a special anim while they're currently playing one.
        self:TempBehaveThread(function(self)
            self:TimeOut(0)
            self:SetSpecialAnimation(true)
            if cancancel then
                self.CanCancelSpecial = true
            else
                self.CanCancelSpecial = false
            end

            self:SolidMaskDuringEvent(MASK_PLAYERSOLID, collision)
            self:PlaySequenceAndMove(seq, {gravity = true})
            if !self:GetSpecialShouldDie() and IsValid(self) and self:Alive() then -- COMMON NZ VALID W
                self:CollideWhenPossible()
                self:SetSpecialAnimation(false) -- Stops them from going back to idle.
                self.CanCancelSpecial = false
            else
                self:TimeOut(666)
            end
        end)
    end

    function ENT:BecomeCrawler() -- For turning into Crawlers.
        self:SetCrawler(true) -- CRIPPLE THEIR SORRY ASSES!!!
        self:SetCollisionBounds(Vector(-14,-14, 0), Vector(14, 14, 26))
    end

    function ENT:BecomeNormal() -- For turning back to normal, i.e they get their legs back.
        self:SetCrawler(false) -- Uncripple them, they may just be doing something funny.
        self:SetCollisionBounds(Vector(-14,-14, 0), Vector(14, 14, 70))
    end

    function ENT:DeflateBones(tbl,ent)
        if !IsValid(self) then return end

        for i,b in pairs(tbl) do
            if self:LookupBone(b) then
                self:ManipulateBoneScale(self:LookupBone(b),Vector(0.00001,0.00001,0.00001))
            end
        end
    end
end

--function ENT:FakeKillZombie()
--    self:SetCollisionGroup(COLLISION_GROUP_VEHICLE_CLIP)
--    --self:SetAlive(false)
--    self.ZombieAlive = false
--    self:SetShouldCount(false)
--
--    if self.DeathSounds then
--        self:PlaySound(self.DeathSounds[math.random(#self.DeathSounds)], 90, math.random(85, 105), 1, 2)
--    end
--    if nzRound:InProgress() then -- Only do this if theres a round in progress.
--        local ply = {}
--        local possibleply
--        local sspawn
--        for k,v in pairs(player.GetAll()) do
--            table.insert(ply, v)
--        end
--        possibleply = ply[math.random(#ply)]
--        sspawn = self:FindNearestSpawner(possibleply:GetPos())
--        if self.IsMooSpecial or self.NZBossType then
--            sspawn = self:FindNearestSpecialSpawner(possibleply:GetPos())
--        end
--        if sspawn then
--            local zobie = ents.Create(self:GetClass())
--            zobie:SetPos(sspawn:GetPos())
--            zobie:SetAngles(sspawn:GetAngles())
--            zobie:Spawn()
--        else
--            return -- In case for whatever reason there wasn't a spawn around... Just return and try again.
--        end
--    end
--    self:TempBehaveThread(function(self)
--        if self.DeathSequences then
--            self:DoDeathAnimation(self.DeathSequences[math.random(#self.DeathSequences)])
--        else
--            self:Remove()
--        end 
--    end)
--
--    print("Uh oh Mario, I've suffered a fatal heart attack. (at: " .. tostring(self:GetPos()) .. ")")
--end

if SERVER then
    function ENT:Retarget() -- Causes a retarget
--      if self:GetTargetLocked() and self:IsValidTarget(self.Target) then return end
--
--      local target, dist = self:GetPriorityTarget()
--      self.Target = target
--      self:SetNextRetarget(self:CalculateNextRetarget(target, dist))
    end

    -- Lets your determine what target to go for next upon retargeting
    --function ENT:GetPriorityTarget() -- We're using a modified version of the nZu targetting code... This mainly improves performance in multiplayer games.
    --  self:SetLastTargetCheck( CurTime() )

    --  local target = nil
    --  local highestPriority = TARGET_PRIORITY_NONE
    --  local mindist = self:GetTargetCheckRange()
    --  local target
    --  for k,v in pairs(ents.GetAll()) do
    --      if v:GetTargetPriority() == TARGET_PRIORITY_ALWAYS then return v end
    --      local d = self:GetRangeTo(v)
    --      if v:GetTargetPriority() == TARGET_PRIORITY_SPECIAL and !self.IsMooSpecial or d < mindist and self:IsValidTarget(v) then
    --          target = v
    --          mindist = d
    --          --print(target, mindist)
    --          if IsValid(self.Target) and v:GetTargetPriority() == TARGET_PRIORITY_SPECIAL and not self.IsMooSpecial then
    --              self:SetBlockAttack(true)
    --          elseif self:GetBlockAttack() then
    --              self:SetBlockAttack(false)
    --          end
    --      end
    --  end

    --  return target, mindist
    --end

    function ENT:ChaseTarget( options )
        if !self:GetAttacking() and !self:GetSpecialAnimation() and self:IsOnGround() then
            self:ResetMovementSequence() -- This is the main point that starts the movement anim. Moo Mark
        end

        return BaseClass.ChaseTarget(self, options)
    end

    function ENT:IsAllowedToMove()
        if self:GetSpecialAnimation() then
            return false
        end 
        if self:GetSpecialShouldDie() then
            return false
        end 
    --  --[[if self:GetIsBusy() then
    --      return false
    --  end]]
    --  if self:GetCrawler() then
    --      return true
    --  end
        if self:GetTeleporting() then
            return true
        end
        return BaseClass.IsAllowedToMove(self)
    end

    local function PointOnSegmentNearestToPoint(a, b, p)
        local ab = b - a
        local ap = p - a

        local t = ap:Dot(ab) / (ab.x^2 + ab.y^2 + ab.z^2)
            t = math.Clamp(t, 0, 1)
        return a + t*ab
    end

    -- A standard attack you can use it or create something fancy yourself
    function ENT:Attack( data )
        --local attacktbl = self.AttackSequences

        --if nzMapping.Settings.badattacks and self.Bo3AttackSequences or self.IsTurned and self.Bo3AttackSequences then
        --    attacktbl = self.Bo3AttackSequences
        --end

        --self:SetStandingAttack(false)

        --if self:GetCrawler() then
        --    attacktbl = self.CrawlAttackSequences
        --end

        --if self:GetTarget():GetVelocity():LengthSqr() < 15 and self:TargetInRange( self.DamageRange ) and !self:GetCrawler() and !self.IsTurned then
        --    if self.StandAttackSequences then -- Incase they don't have standing attack anims.
        --        attacktbl = self.StandAttackSequences
        --    end
        --    self:SetStandingAttack(true)
        --end
        --
        --self.AttackSequences = attacktbl

        --BaseClass.Attack(self, data)

        self:SetLastAttack(CurTime())

        local useswalkframes = false

        data = data or {}

        data.attackseq = data.attackseq
        if !data.attackseq then

            local attacktbl = self.AttackSequences


            if nzMapping.Settings.badattacks and self.Bo3AttackSequences or self.IsTurned and self.Bo3AttackSequences then
                attacktbl = self.Bo3AttackSequences
            end

            self:SetStandingAttack(false)

            if self:GetCrawler() then
                attacktbl = self.CrawlAttackSequences
            end

            if self:GetTarget():GetVelocity():LengthSqr() < 15 and self:TargetInRange( self.DamageRange ) and !self:GetCrawler() and !self.IsTurned then
                if self.StandAttackSequences then -- Incase they don't have standing attack anims.
                    attacktbl = self.StandAttackSequences
                end
                self:SetStandingAttack(true)
            end

            local target = type(attacktbl) == "table" and attacktbl[math.random(#attacktbl)] or attacktbl

            if type(target) == "table" then
                local id, dur = self:LookupSequenceAct(target.seq)
                if target.dmgtimes then
                    data.attackseq = {seq = id, dmgtimes = target.dmgtimes }
                    useswalkframes = false
                else
                    data.attackseq = {seq = id} -- Assume that if the selected sequence isn't using dmgtimes, its probably using notetracks.
                    useswalkframes = true
                end
                data.attackdur = dur
            elseif target then -- It is a string or ACT
                local id, dur = self:LookupSequenceAct(attacktbl)
                data.attackseq = {seq = id, dmgtimes = {dur/2}}
                data.attackdur = dur
            else
                local id, dur = self:LookupSequence("swing")
                data.attackseq = {seq = id, dmgtimes = {1}}
                data.attackdur = dur
            end
        end
    
        self:SetAttacking( true )
        if IsValid(self:GetTarget()) and self:GetTarget():Health() and self:GetTarget():Health() > 0 then -- Doesn't matter if its a player... If the zombie is targetting it, they probably wanna attack it.
            if data.attackseq.dmgtimes then
                for k,v in pairs(data.attackseq.dmgtimes) do
                    self:TimedEvent( v, function()
                        if self.AttackSounds then self:PlaySound(self.AttackSounds[math.random(#self.AttackSounds)], 100, math.random(85, 105), 1, 2) end
                        self:EmitSound("nz_moo/zombies/fly/attack/whoosh/zmb_attack_med_0"..math.random(0,2)..".mp3", 75)
                        self:DoAttackDamage()
                    end)
                end
            end
        end

        self:TimedEvent(data.attackdur, function()
            self:SetAttacking(false)
            self:SetLastAttack(CurTime())
        end)

        if useswalkframes then
            self:PlaySequenceAndMove(data.attackseq.seq, 1, self.FaceEnemy)
        else
            self:PlayAttackAndWait(data.attackseq.seq, 1)
        end
    end


    function ENT:DoAttackDamage() -- Moo Mark 4/14/23: Made the part that does damage during an attack its own function.
        local target = self:GetTarget()
        if IsValid(target) and target:Health() and target:Health() > 0 then -- Doesn't matter if its a player... If the zombie is targetting it, they probably wanna attack it.
            if self:IsValid(target) and (self:GetIsBusy() and self:TargetInRange( self.AttackRange + 45 ) or self:TargetInRange( self.AttackRange + 25 )) then
                local dmgInfo = DamageInfo()
                dmgInfo:SetAttacker( self )
                if self:WaterBuff() and self:BomberBuff() then
                    dmgInfo:SetDamage( self.AttackDamage * 3 ) -- Moo Mark. 6/15/23: The Tri-Buff of being inflicted by a Water Cat and Nova Bomba causes them to wanna LIFE OVVA!!!
                elseif self:WaterBuff() then
                    dmgInfo:SetDamage( self.AttackDamage * 2 ) 
                else
                    dmgInfo:SetDamage( self.AttackDamage )
                end
                dmgInfo:SetDamageType( DMG_SLASH )
                dmgInfo:SetDamageForce( (target:GetPos() - self:GetPos()) * 7 + Vector( 0, 0, 16 ) )
                if self:TargetInRange( self.DamageRange ) then 
                    if !IsValid(target) then return end
                    target:TakeDamageInfo(dmgInfo)
                    if comedyday then --or math.random(500) == 1 then
                        if self.GoofyahAttackSounds then target:EmitSound(self.GoofyahAttackSounds[math.random(#self.GoofyahAttackSounds)], SNDLVL_TALKING, math.random(95,105)) end
                    else
                        target:EmitSound( "nz_moo/zombies/plr_impact/_zhd/evt_zombie_hit_player_0"..math.random(0,5)..".mp3", SNDLVL_TALKING, math.random(95,105))
                    end

                    if target:IsPlayer() then
                        target:ViewPunch( VectorRand():Angle() * 0.01 )
                    end
                end
            end
        end
    end

    function ENT:PlayAttackAndWait( name, speed )

        local len = self:SetSequence( name )
        speed = speed or 1

        self:ResetSequenceInfo()
        self:SetCycle( 0 )
        self:SetPlaybackRate( speed )

        local endtime = CurTime() + len / speed

        while ( true ) do

            if ( endtime < CurTime() ) then
                if !self:GetStop() then
                    if !self:GetCrawler() then
                        self.loco:SetDesiredSpeed( self:GetRunSpeed() )
                    end
                end
                return
            end
            if self:IsValidTarget( self:GetTarget() ) then
                if not self:IsStandingAttack() and not self:GetCrawler() then
                    if self.loco:GetVelocity():Length2D() >= 140 and !self.IsMooSpecial then
                        self.loco:SetDesiredSpeed( self:GetRunSpeed() + 40 ) -- This just to mimic lung some attack anims have
                    else
                        self.loco:SetDesiredSpeed( self:GetRunSpeed() )
                    end
                    self.loco:Approach( self:GetTarget():GetPos(), 10 )
                    self.loco:FaceTowards( self:GetTarget():GetPos() )
                end
            end
            coroutine.yield()
        end
    end

    --function ENT:Flames( state )
    --  if state then
    --      self.FlamesEnt = ents.Create("env_fire")
    --      if IsValid( self.FlamesEnt ) then
    --      
    --          self.FlamesEnt:SetParent(self)
    --          self.FlamesEnt:SetOwner(self)
    --          self.FlamesEnt:SetPos(self:GetPos())
    --          --no glow + delete when out + start on + last forever
    --          self.FlamesEnt:SetKeyValue("spawnflags", tostring(128 + 32 + 4 + 2 + 1))
    --          self.FlamesEnt:SetKeyValue("firesize", (1 * math.Rand(0.7, 1.1)))
    --          self.FlamesEnt:SetKeyValue("fireattack", 0)
    --          self.FlamesEnt:SetKeyValue("health", 0)
    --          self.FlamesEnt:SetKeyValue("damagescale", "-10") -- only neg. value prevents dmg

    --          self.FlamesEnt:Spawn()
    --          self.FlamesEnt:Activate()
    --      end
    --  elseif IsValid( self.FlamesEnt )  then
    --      self.FlamesEnt:Remove()
    --      self.FlamesEnt = nil
    --  end
    --end

    function ENT:Explode(dmg, suicide)
        suicide = suicide or true
        dmg = dmg or 50

        if SERVER then
            local pos = self:WorldSpaceCenter()
            local targ = self:GetTarget()

            local attacker = self
            local inflictor = self

            if IsValid(targ) and targ.GetActiveWeapon then
                attacker = targ
                if IsValid(targ:GetActiveWeapon()) then
                    inflictor = targ:GetActiveWeapon()
                end
            end

            local tr = {
                start = pos,
                filter = self,
                mask = MASK_NPCSOLID_BRUSHONLY
            }

            for k, v in pairs(ents.FindInSphere(pos, 200)) do
                if v:IsPlayer() or v:IsNPC() or v:IsNextBot() then
                    if v:GetClass() == self:GetClass() then continue end
                    if v == self then continue end
                    if v:EntIndex() == self:EntIndex() then continue end
                    if v:Health() <= 0 then continue end
                    --if !v:Alive() then continue end
                    tr.endpos = v:WorldSpaceCenter()
                    local tr1 = util_traceline(tr)
                    if tr1.HitWorld then continue end

                    local expdamage = DamageInfo()
                    expdamage:SetAttacker(attacker)
                    expdamage:SetInflictor(inflictor)
                    expdamage:SetDamageType(DMG_BLAST)

                    local distfac = pos:Distance(v:WorldSpaceCenter())
                    distfac = 1 - math.Clamp((distfac/200), 0, 1)
                    expdamage:SetDamage(dmg * distfac)

                    expdamage:SetDamageForce(v:GetUp()*5000 + (v:GetPos() - self:GetPos()):GetNormalized() * 10000)

                    v:TakeDamageInfo(expdamage)
                end
            end

            local effectdata = EffectData()
            effectdata:SetOrigin(self:GetPos())

            util.Effect("HelicopterMegaBomb", effectdata)
            util.Effect("Explosion", effectdata)

            util.ScreenShake(self:GetPos(), 20, 255, 1.5, 400)
        end

        -- Hate.
        if suicide and self:Alive() then self:TakeDamage(self:Health() + 666, self, self) end
    end

    function ENT:BodyUpdate() -- Moo Mark. Remember all that shit with Act Stages? Yeah fuck that, its all gone now... I got rid of all the reasons to keep it finally.

        if not self:GetSpecialAnimation() and not self:IsAttacking() and not self:IsJumping() and not self:IsTimedOut() then
            if not self.FrozenTime then
                self:BodyMoveXY()
            end
        end

        if self:GetSpecialAnimation() or self:IsAttacking() then
            self:SetStuckCounter(0)
        end

        if self.FrozenTime then 
            if self.FrozenTime < CurTime() then
                self.FrozenTime = nil
                self:SetStop(false)
            end
            self:BodyMoveXY()
        else
            self:FrameAdvance()
        end
    end

    function ENT:UpdateSequence()
        self:BodyUpdate()
        self:ResetMovementSequence()
    end

    function ENT:TriggerBarricadeJump( barricade, dir, ... )
        self.ActStages[self:GetActStage()] = self.ActStages[self:GetActStage()] or {}
        self.ActStages[self:GetActStage()].barricadejumps = self.JumpSequences or self:SafeSelectWeightedSequence(ACT_JUMP)
        BaseClass.TriggerBarricadeJump(self, barricade, dir, ...)
    end

    --function ENT:TriggerBarricadeJump( barricade, dir )
    --  if not self:GetSpecialAnimation() then

    --      local useswalkframes = false

    --      self:SetSpecialAnimation(true)
    --      self:SetBlockAttack(true)

    --      local id, dur, speed
    --      local animtbl = self.JumpSequences

    --      if self:GetCrawler() then
    --          animtbl = self.CrawlJumpSequences
    --      end
 
    --      if self.JumpSequences then
    --          if type(animtbl) == "number" then -- ACT_ is a number, this is set if it's an ACT
    --              id = self:SafeSelectWeightedSequence(animtbl)
    --              dur = self:SequenceDuration(id)
    --              speed = self:GetSequenceGroundSpeed(id)
    --              if speed < 10 then
    --                  speed = 20
    --              end
    --          else
    --              local targettbl = animtbl and animtbl[math.random(#animtbl)] or self.JumpSequences
    --              if targettbl then -- It is a table of sequences
    --                  id, dur = self:LookupSequenceAct(targettbl.seq) -- Whether it's an ACT or a sequence string
    --                  speed = targettbl.speed
    --                  if speed then
    --                      useswalkframes = false
    --                  else
    --                      useswalkframes = true
    --                  end
    --              else
    --                  id = self:SafeSelectWeightedSequence(ACT_JUMP)
    --                  dur = self:SequenceDuration(id)
    --                  speed = 30
    --              end
    --          end
    --      end

    --      self:SolidMaskDuringEvent(MASK_NPCSOLID_BRUSHONLY)

    --      if useswalkframes then
    --          self:PlaySequenceAndMove(id, 1)
    --          --self:PlaySequenceAndMove(id, {gravity = false}) -- Leaving this here for now... Will use later.
    --          self:ResetMovementSequence()
    --      else
    --          if self.JumpSequences then
    --              self.loco:SetDesiredSpeed(speed)
    --              self:SetVelocity(self:GetForward() * speed)
    --              self:ResetSequence(id)
    --              self:SetCycle(0)
    --              self:SetPlaybackRate(1)
    --          end

    --          local pos = barricade:GetPos() - dir * 50
    --          self:MoveToPos(pos, { -- Zombie will move through the barricade.
    --              lookahead = 1,
    --              tolerance = 10,
    --              draw = false,
    --              maxage = dur, -- 12/7/22: Using the current mantle anim's duration allows for more consistent mantling and lessens the zombie's chances of getting stuck.
    --              repath = dur,
    --          })
    --          self:SetPos(pos)
    --          self.loco:SetAcceleration( self.Acceleration )
    --          self.loco:SetDesiredSpeed(self:GetRunSpeed())
    --      end
    --      self:SetBlockAttack(false)
    --      self:SetSpecialAnimation(false)
    --      self:SetIsBusy(false)
    --      self:CollideWhenPossible() -- Remove the mask as soon as we can
    --      self:TimeOut(0.25)
    --  end
    --end

    --function ENT:ZombieWaterLevel()
    --  local pos1 = self:GetPos()
    --  local halfSize = self:OBBCenter()
    --  local pos2 = pos1 + halfSize
    --  local pos3 = pos2 + halfSize
    --  if bit.band( util.PointContents( pos3 ), CONTENTS_WATER ) == CONTENTS_WATER or bit.band( util.PointContents( pos3 ), CONTENTS_SLIME ) == CONTENTS_SLIME then
    --      return 3
    --  elseif bit.band( util.PointContents( pos2 ), CONTENTS_WATER ) == CONTENTS_WATER or bit.band( util.PointContents( pos2 ), CONTENTS_SLIME ) == CONTENTS_SLIME then
    --      return 2
    --  elseif bit.band( util.PointContents( pos1 ), CONTENTS_WATER ) == CONTENTS_WATER or bit.band( util.PointContents( pos1 ), CONTENTS_SLIME ) == CONTENTS_SLIME then
    --      return 1
    --  end

    --  return 0
    --end

    function ENT:SolidMaskDuringEvent(mask, collision)  -- Changes the zombie's mask until the end of the event. If nil is passed, it immediately removes the mask
        --collision = collision or false
        --if collision then
        --  self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
        --else
        --  self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
        --end
        --if mask then
        --  self:SetSolidMask(mask)
        --  self.EventMask = true
        --else
        --  self:SetSolidMask(MASK_NPCSOLID)
        --  self.EventMask = nil
        --end
    end

    function ENT:CollideWhenPossible() 
        if self:Alive() then 
            self.DoCollideWhenPossible = true -- Make the zombie solid again as soon as there is space
        end
    end

    ENT.IdleSequence = "nz_idle_ad"

    ENT.IdleSequenceAU = "nz_idle_au" -- Same as the one above but the zombie's arms are raised instead of being down at their sides.

    ENT.CrawlIdleSequence = "nz_idle_crawl"

    ENT.TornadoSequence = "nz_alistairs_tornado_loop"

    ENT.XbowWWSequence = "nz_dth_ww_xbow_loop"

    -- Called when the zombie wants to idle. Play an animation here
    function ENT:PerformIdle()
        if self:GetSpecialAnimation() and !self.IsTornado and !self.IsXbowSpinning then return end
        if self:GetCrawler() and !self.IsMooSpecial then
            self:ResetSequence(self.CrawlIdleSequence)
        elseif (self.BO4IsShocked and self:BO4IsShocked() or self.BO4IsScorped and self:BO4IsScorped() or self.BO4IsSpinning and self:BO4IsSpinning() or self:GetNW2Bool("OnAcid")) and self:GetCrawler() and !self.IsMooSpecial then
            self:ResetSequence(self.SparkyCrawlAnim)
        elseif (self.BO4IsShocked and self:BO4IsShocked() or self.BO4IsScorped and self:BO4IsScorped() or self:GetNW2Bool("OnAcid")) and !self:GetCrawler() and !self.IsMooSpecial then
            self:ResetSequence(self.SparkyAnim)
        elseif self.BO3IsMystified and self:BO3IsMystified() then
            self:ResetSequence(self.UnawareAnim)
        elseif self.BO4IsTornado and self:BO4IsTornado() and !self.IsMooSpecial and self.IsTornado then
            self:ResetSequence(self.TornadoSequence)
        elseif self.BO4IsSpinning and self:BO4IsSpinning() and !self.IsMooSpecial and self.IsXbowSpinning then
            self:ResetSequence(self.XbowWWSequence)
        elseif self.ArmsUporDown == 1 and !self:GetCrawler() and !self.IsMooSpecial then
            self:ResetSequence(self.IdleSequenceAU)
            if !self.IsIdle and !IsValid(self:GetTarget()) then
                self.IsIdle = true
            end
        else
            self:ResetSequence(self.IdleSequence)
            if !self.IsIdle and !IsValid(self:GetTarget()) then
                self.IsIdle = true
            end
        end
    end

    -- Returns to normal movement sequence. Call this in events where you want to MoveToPos after an animation
    function ENT:ResetMovementSequence()
        if self:GetCrawler() then
            self:ResetSequence(self.CrawlMovementSequence)
            self.CurrentSeq = self.CrawlMovementSequence
        elseif IsValid(self.Target) and self.Target:GetClass() == "nz_bo3_tac_gersch" and !self.IsMooSpecial then
            self:ResetSequence(self.BlackholeMovementSequence)
            self.CurrentSeq = self.BlackholeMovementSequence
        elseif self:ZombieWaterLevel() >= 2 and !self.IsMooSpecial then
            self:ResetSequence(self.LowgMovementSequence)
            self.CurrentSeq = self.LowgMovementSequence
        elseif self.IsTurned and self.TurnedMovementSequence and !self.IsMooSpecial then
            self:ResetSequence(self.TurnedMovementSequence)
            self.CurrentSeq = self.TurnedMovementSequence
        elseif (self.AATIsBlastFurnace and self:AATIsBlastFurnace() or self.BO4IsMagmaIgnited and self:BO4IsMagmaIgnited()) and !self.IsMooSpecial then
            self:ResetSequence(self.FireMovementSequence)
            self.CurrentSeq = self.FireMovementSequence
        else
            self:ResetSequence(self.MovementSequence)
            self.CurrentSeq = self.MovementSequence
        end
        if self.UpdateSeq ~= self.CurrentSeq then -- Moo Mark 4/19/23: Finally got a system where the speed actively updates when the movement sequence set is changed.
            --print("update")
            self.UpdateSeq = self.CurrentSeq
            self:UpdateMovementSpeed()
        end
    end

    -- ulx luarun "Entity(1):GetEyeTrace().Entity:AATBlastFurnace(3, Entity(1), Entity(1):GetActiveWeapon())"

    function ENT:UpdateMovementSequences()
        -- Select a random anim to perform so a zombie doesn't switch constantly.
        if self.SparkySequences and self.CrawlSparkySequences then
            self.SparkyAnim = self.SparkySequences[math.random(#self.SparkySequences)]
            self.SparkyCrawlAnim = self.CrawlSparkySequences[math.random(#self.CrawlSparkySequences)]
        end
        if self.UnawareSequences then
            self.UnawareAnim = self.UnawareSequences[math.random(#self.UnawareSequences)]
        end

        if self.SequenceTables then
                local t
            if self.SpeedBasedSequences then
                for k,v in pairs(self.SequenceTables) do
                    if v.Threshold and v.Threshold > self:GetRunSpeed() then break end
                    t = v
                end
            else
                t = self.SequenceTables[math.random(#self.SequenceTables)]
            end

            if t then
                local seqs = t.Sequences[1] and t.Sequences[math.random(#t.Sequences)] or t.Sequences -- If Sequences is a numerical table, pick a random one (supports random selection)
                for k,v in pairs(seqs) do
                    self[k] = v[math.random(#v)] -- Pick a random entry
                end
            end
        end
    end

    --function ENT:IsValidTarget( ent )
    --  if not ent then return false end

    --  -- Turned Zombie Targetting
    --  if self.IsTurned then return IsValid(ent) and ent:IsValidZombie() and !ent.IsTurned and !ent.IsMooSpecial and ent:Alive() end
    --
    --  return IsValid( ent ) and ent:GetTargetPriority() ~= TARGET_PRIORITY_NONE and ent:GetTargetPriority() ~= TARGET_PRIORITY_FUNNY -- This is really funny.
    --end

    -- Lets you determine how long until the next retarget
    -- This is called after a retarget. You can use the distance, it is known to be the smallest distance to all players
    function ENT:CalculateNextRetarget(target, dist)
        return math.Clamp(dist/200, 3, 15) -- 1 second for every 100 units to the closet player
    end

    function ENT:GetTargetPosition() return self.LockedTargetPosition or self:SelectTargetPosition() end -- Get the current goal location. Supports locked goal locations

    function ENT:SetNextRetarget(time) self.NextRetarget = CurTime() + time end -- Sets the next time the Zombie will repath to its target --Moo Mark Target

    -- Here you can do things such as determine your own locations that might not be right on the target
    function ENT:SelectTargetPosition()
        return self.Target:GetPos()
    end


    local function GetClearPaths(ent, pos, tiles)
        local clearPaths = {}
        local filter = player.GetAll()
        for _, tile in pairs( tiles ) do
            local tr = util_traceline({
                start = pos,
                endpos = tile,
                filter = filter,
                mask = MASK_PLAYERSOLID
            })

            if not tr.Hit and util.IsInWorld(tile) then
                table.insert( clearPaths, tile )
            end
        end

        return clearPaths
    end

    local function GetSurroundingTiles(ent, pos)
        local tiles = {}
        local x, y, z
        local minBound, maxBound = ent:OBBMins(), ent:OBBMaxs()
        local checkRange = math.max(12, maxBound.x, maxBound.y)

        for z = -1, 1, 1 do
            for y = -1, 1, 1 do
                for x = -1, 1, 1 do
                    local testTile = Vector(x,y,z)
                    testTile:Mul( checkRange )
                    local tilePos = pos + testTile
                    table.insert( tiles, tilePos )
                end
            end
        end

        return tiles
    end

    function ENT:CollisionBoxClear(ent, pos, minBound, maxBound)
        local filter = {ent}
        local tr = util.TraceEntity({
            start = pos,
            endpos = pos,
            filter = filter,
            mask = MASK_PLAYERSOLID
        }, ent)

        return !tr.StartSolid || !tr.AllSolid
    end

    function ENT:FindSpotBehindPlayer(pos, count, range, stepd, stepu)
        local targ = self:GetTarget()
        pos = pos or targ:GetPos()
        range = range or 100
        stepd = stepd or 25
        stepu = stepu or 25
        count = count or 6

        if navmesh.IsLoaded() then
            local tab = navmesh.Find(pos, range, stepd, stepu)
            local postab = {}

            for i=1, count do
                for _, nav in RandomPairs(tab) do
                    if IsValid(nav) and not nav:IsUnderwater() then
                        local testpos = nav:GetRandomPoint()
                        local norm = (testpos - pos):GetNormal()

                        if targ:GetAimVector():Dot(norm) < 0 then
                            table.insert(postab, testpos)
                            break
                        end
                    end
                end
            end

            if not table.IsEmpty(postab) then
                table.sort(postab, function(a, b) return a:DistToSqr(pos) < b:DistToSqr(pos) end)
                pos = postab[1]
            end
        end

        local minBound, maxBound = self:OBBMins(), self:OBBMaxs()
        if not self:CollisionBoxClear( self, pos, minBound, maxBound ) then
            local surroundingTiles = GetSurroundingTiles( self, pos )
            local clearPaths = GetClearPaths( self, pos, surroundingTiles ) 
            for _, tile in pairs( clearPaths ) do
                if self:CollisionBoxClear( self, tile, minBound, maxBound ) then
                    pos = tile
                    break
                end
            end
        end

        return pos
    end

    function ENT:FindNearestSpawner(pos)
        local nearbyents = {}
        for k, v in pairs(ents.FindByClass("nz_spawn_zombie_normal")) do
            if v.GetSpawner and v:GetSpawner() then
                if (v.link == nil or nzDoors:IsLinkOpened( v.link )) and v:IsSuitable() and !v:GetMasterSpawn() then
                    table.insert(nearbyents, v)
                end
            end
        end

        table.sort(nearbyents, function(a, b) return a:GetPos():DistToSqr(pos) < b:GetPos():DistToSqr(pos) end)
        return nearbyents[1]
    end

    function ENT:FindNearestSpecialSpawner(pos)
        local nearbyents = {}
        for k, v in pairs(ents.FindByClass("nz_spawn_zombie_special")) do
            if v.GetSpawner and v:GetSpawner() then
                if (v.link == nil or nzDoors:IsLinkOpened( v.link )) and v:IsSuitable() and !v:GetMasterSpawn() then
                    table.insert(nearbyents, v)
                end
            end
        end

        table.sort(nearbyents, function(a, b) return a:GetPos():DistToSqr(pos) < b:GetPos():DistToSqr(pos) end)
        return nearbyents[1]
    end

    function ENT:FindNearestBossSpawner(pos)
        local nearbyents = {}
        for k, v in pairs(ents.FindByClass("nz_spawn_zombie_boss")) do
            if v.GetSpawner and v:GetSpawner() then
                if (v.link == nil or nzDoors:IsLinkOpened( v.link )) and v:IsSuitable() and !v:GetMasterSpawn() then
                    table.insert(nearbyents, v)
                end
            end
        end

        table.sort(nearbyents, function(a, b) return a:GetPos():DistToSqr(pos) < b:GetPos():DistToSqr(pos) end)
        return nearbyents[1]
    end

    --Below function credited to CmdrMatthew
    function ENT:getvel(pos, pos2, time)    -- target, starting point, time to get there
        local diff = pos - pos2 --subtract the vectors

        local velx = diff.x/time -- x velocity
        local vely = diff.y/time -- y velocity

        local velz = (diff.z - 0.5*(-GetConVarNumber( "sv_gravity"))*(time^2))/time --  x = x0 + vt + 0.5at^2 conversion

        return Vector(velx, vely, velz)
    end 

    function ENT:LaunchArc(pos, pos2, time, t)  -- target, starting point, time to get there, fraction of jump
        local v = self:getvel(pos, pos2, time).z
        local a = (-GetConVarNumber( "sv_gravity"))
        local z = v*t + 0.5*a*t^2
        local diff = pos - pos2
        local x = diff.x*(t/time)
        local y = diff.y*(t/time)

        return pos2 + Vector(x, y, z)
    end
end

--[[
self.funny = Material("the_cage.png"), "unlitgeneric smooth")

local function Draw3DText( pos, ang, scale, flipView, material )
    if ( flipView ) then
        ang:RotateAroundAxis( vector_up, 180 )
    end

    cam.Start3D2D(pos, ang, scale)
        surface.SetMaterial(material)
        surface.SetDrawColor(color_white)
        surface.DrawTexturedRect(-16, -16, 48,48)
    cam.End3D2D()
end

function ENT:Draw()
    local pos = self:EyePos()
    local ang = however you get the zombies looking angle, maybe their forward:Angle()?

    ang = Angle(ang.x, ang.y, 0)
    ang:RotateAroundAxis(ang:Up(), -90)
    ang:RotateAroundAxis(ang:Forward(), 90)

    Draw3DText( pos, ang, 0.2, false, self.funny)
    Draw3DText( pos, ang, 0.2, true, self.funny)

    self:DrawModel()
end
]]

-- Moo Mark 4/14/23: ROBBERY!!! EVERYTHING IN THIS is pulled from Drgbase, I mainly did this just so I can use "PlaySeqeunceAndMove" and have no actual know how of doing this from scratch. 

function ENT:FaceTowards(pos)
    if isentity(pos) then pos = pos:GetPos() end
    self.loco:FaceTowards(pos)
end

function ENT:FaceEnemy()
    if IsValid(self:GetTarget()) then self:FaceTowards(self:GetTarget()) end
end

function ENT:DrG_TraceHull(vec, data)
    if not isvector(vec) then vec = Vector(0, 0, 0) end
    local bound1, bound2 = self:GetCollisionBounds()
    if bound1.z < bound2.z then
        local temp = bound1
        bound1 = bound2
        bound2 = temp
    end
    local trdata = {}
    data = data or {}
    if data.step then
        bound2.z = self.loco:GetStepHeight()
    end
    trdata.start = data.start or self:GetPos()
    trdata.endpos = data.endpos or trdata.start + vec
    trdata.collisiongroup = data.collisiongroup or self:GetCollisionGroup()
    trdata.mask = data.mask or self:GetSolidMask()
    trdata.ignoreworld = false
    trdata.filter = data.filter or self
    trdata.maxs = data.maxs or bound1
    trdata.mins = data.mins or bound2

    local trace = util_tracehull(trdata) -- The one line fix in question

    return trace
end

local function ResetSequence(self, seq)
    local len = self:SetSequence(seq)
    self:SetCycle(0)
    self:ResetSequenceInfo()
    return len
end

function ENT:OnAnimChange() end

function CallOnAnimChange(self, old, new)
    return self:OnAnimChange(self:GetSequenceName(old), self:GetSequenceName(new))
end

function ENT:PlaySequenceAndWait(seq, rate, callback)
    rate = rate or 1
    if isstring(seq) then seq = self:LookupSequence(seq)
    elseif not isnumber(seq) then return end
    if seq == -1 then return end
    local current = self:GetSequence()
    if seq == self:GetSequence() or CallOnAnimChange(self, current, seq) ~= false then
        ResetSequence(self, seq)
        self:SetPlaybackRate(rate or 1)
        local now = CurTime()
        local lastCycle = -1
        while seq == self:GetSequence() do
            local cycle = self:GetCycle()
            if lastCycle >= cycle then break end
            if lastCycle >= cycle and cycle >= 1 then break end
            lastCycle = cycle
            if isfunction(callback) then
                local res = callback(self, cycle)
                if res then break end
            end
            coroutine.yield()
        end
        return CurTime() - now
    end
end

function ENT:PlaySequenceAndMove(seq, options, callback)
    if isstring(seq) then seq = self:LookupSequence(seq)
    elseif not isnumber(seq) then return end
    if seq == -1 then return end
    if isnumber(options) then options = {rate = options}
    elseif not istable(options) then options = {} end
    if options.gravity == nil then options.gravity = true end
    if options.collisions == nil then options.collisions = true end

        local previousCycle = 0
        local previousPos = self:GetPos()
        local res = self:PlaySequenceAndWait(seq, options.rate, function(self, cycle)
        local success, vec, angles = self:GetSequenceMovement(seq, previousCycle, cycle)
        if success then
            if isvector(options.multiply) then
                vec = Vector(vec.x*options.multiply.x, vec.y*options.multiply.y, vec.z*options.multiply.z)
            end
            vec:Rotate(self:GetAngles() + angles)
            self:SetAngles(self:LocalToWorldAngles(angles))
            local tr = self:DrG_TraceHull(vec, {step = self:IsOnGround()})
            if !tr.Hit or self:GetIsBusy() and (self.TraversalAnim or tr.HitNoDraw or IsValid(tr.Entity) and tr.Entity:GetClass() == "breakable_entry") then
                if not options.gravity then
                    previousPos = previousPos + vec*self:GetModelScale()
                    self:SetPos(previousPos)
                elseif not vec:IsZero() then
                    previousPos = self:GetPos() + vec*self:GetModelScale()
                    self:SetPos(previousPos)
                else
                    previousPos = self:GetPos() 
                end
            elseif options.stoponcollide then 
                return true
            elseif not options.gravity then
                self:SetPos(previousPos)
            end
        end
        previousCycle = cycle
        if isfunction(callback) then return callback(self, cycle) end
    end)
    if not options.gravity then
        self:SetPos(previousPos)
        self:SetVelocity(Vector(0, 0, 0))
    end
    return res
end

ENT.RagdollDeathSequences = {
    "ragdoll"
}
ENT.MeleeDeathSequences = {
    "nz_death_falltoknees_1",
    "nz_death_falltoknees_2",
    "nz_death_nerve",
    "nz_death_neckgrab"
}
ENT.BlackHoleDeathSequences = {
    "nz_blackhole_crawl_death_v1",
    "nz_blackhole_crawl_death_v2",
    "nz_blackhole_crawl_death_v3"
}
ENT.BlastDeathSequences = {
    "nz_death_blast_1",
    "nz_death_blast_2"
}
ENT.BlastDeathLeftSequences = {
    "nz_death_blast_from_right",
}
ENT.BlastDeathRightSequences = {
    "nz_death_blast_from_left",
}
ENT.BlastDeathBackSequences = {
    "nz_death_blast_from_back",
}

ENT.ReactTauntSequences = {
    "nz_legacy_taunt_v1",
    "nz_legacy_taunt_v2",
}

ENT.SuperTauntSequences = {
    "nz_legacy_taunt_v11",
    "nz_legacy_taunt_v12",
}

ENT.SlipGunSequences = {
    "nz_slipslide_collapse",
    "nz_sprint_slipslide",
    "nz_sprint_slipslide_a",
}
ENT.ThunderGunSequences = {
    "nz_margwa_smash_react_a",
}
ENT.MicrowaveSequences = {
    "nz_dth_microwave_1",
    "nz_dth_microwave_2",
    "nz_dth_microwave_3",
}
ENT.FreezeSequences = {
    "nz_dth_freeze_1",
    "nz_dth_freeze_2",
    "nz_dth_freeze_3",
}
ENT.DeathRaySequences = {
    "nz_dth_deathray_2",
    "nz_dth_deathray_3",
    "nz_dth_deathray_4",
}
ENT.SoulDrainSequences = {
    "nz_dth_soul_drain_loop",
}

ENT.IdGunSequences = {
    "nz_idgunhole",
}
ENT.AcidStunSequences = {
    "nz_acid_stun_1",
    "nz_acid_stun_2",
    "nz_acid_stun_3",
}
ENT.IceStaffSequences = {
    "nz_icestaff_death_a",
    "nz_icestaff_death_b",
    "nz_icestaff_death_c",
    "nz_icestaff_death_d",
    "nz_icestaff_death_e",
}
ENT.SparkySequences = {
    "nz_sparky_a",
    "nz_sparky_b",
    "nz_sparky_c",
    "nz_sparky_d",
    "nz_sparky_e",
}
ENT.ShrinkSequences = {
    "nz_alistairs_shrunk",
}
ENT.UnawareSequences = {
    "nz_unaware_idle",
    "nz_unaware_idle_2",
}
ENT.CrawlDeathSequences = {
    "nz_crawl_death_v1",
    "nz_crawl_death_v2",
}
ENT.CrawlTeslaDeathSequences = {
    "nz_crawl_tesla_death_v1",
    "nz_crawl_tesla_death_v2",
}
ENT.CrawlFreezeDeathSequences = {
    "nz_crawl_freeze_death_v1",
    "nz_crawl_freeze_death_v2",
}
ENT.CrawlMicrowaveSequences = {
    "nz_crawl_dth_microwave_1",
    "nz_crawl_dth_microwave_2",
    "nz_crawl_dth_microwave_3",
}
ENT.CrawlSparkySequences = {
    "nz_crawl_sparky_a",
    "nz_crawl_sparky_b",
    "nz_crawl_sparky_c",
    "nz_crawl_sparky_d",
    "nz_crawl_sparky_e",
}
ENT.DanceSequences = {
    "nz_goofyah_v1",
    "nz_goofyah_v2",
    "nz_goofyah_v3",
    "nz_goofyah_v4",
    "nz_goofyah_v5",
    "nz_goofyah_v6",
    "nz_goofyah_v7",
    "nz_goofyah_v8",
    "nz_goofyah_v9",
    "nz_goofyah_v10",
    "nz_goofyah_v11",
    "nz_goofyah_v12",
    "nz_goofyah_v13",
    "nz_goofyah_v14",
}
ENT.SideStepSequences = {
    "nz_dodge_sidestep_left_a",
    "nz_dodge_sidestep_left_b",
    "nz_dodge_sidestep_right_a",
    "nz_dodge_sidestep_right_b",
    "nz_dodge_roll_a",
    "nz_dodge_roll_b",
    "nz_dodge_roll_c",
}
ENT.PainSequences = {
    "nz_pain_head_v1",
    "nz_pain_head_v2",
    "nz_pain_left_v1",
    "nz_pain_left_v2",
    "nz_pain_right_v1",
    "nz_pain_right_v2"
}
ENT.HeadPainSequences = {
    "nz_pain_head_v1",
    "nz_pain_head_v2",
}
ENT.LeftPainSequences = {
    "nz_pain_left_v1",
    "nz_pain_left_v2",
}
ENT.RightPainSequences = {
    "nz_pain_right_v1",
    "nz_pain_right_v2",
}
ENT.WindowAttackSequences = {
    "nz_win_attack_larm",
    "nz_win_attack_rarm",
    "nz_win_attack_lbody",
    "nz_win_attack_rbody",
}

ENT.UndercroftSequences = {
    "nz_undercroft_spawn_v2",
    "nz_undercroft_spawn_v3",
}

ENT.BarricadeTearSequences = {} -- These are anims that enemies can specifically when attacking barricades.

ENT.CrawlerSounds = {
    Sound("nz_moo/zombies/vox/_classic/crawl/crawl_00.mp3"),
    Sound("nz_moo/zombies/vox/_classic/crawl/crawl_01.mp3"),
    Sound("nz_moo/zombies/vox/_classic/crawl/crawl_02.mp3"),
    Sound("nz_moo/zombies/vox/_classic/crawl/crawl_03.mp3"),
    Sound("nz_moo/zombies/vox/_classic/crawl/crawl_04.mp3"),
    Sound("nz_moo/zombies/vox/_classic/crawl/crawl_05.mp3"),
}

ENT.MonkeySounds = {
    Sound("nz_moo/zombies/vox/monkey/groan_00.mp3"),
    Sound("nz_moo/zombies/vox/monkey/groan_01.mp3"),
    Sound("nz_moo/zombies/vox/monkey/groan_02.mp3"),
    Sound("nz_moo/zombies/vox/monkey/groan_03.mp3"),
    Sound("nz_moo/zombies/vox/monkey/groan_04.mp3"),
    Sound("nz_moo/zombies/vox/monkey/groan_05.mp3"),
    Sound("nz_moo/zombies/vox/monkey/groan_06.mp3"),
    Sound("nz_moo/zombies/vox/monkey/groan_07.mp3"),
}

ENT.TauntSounds = {
    Sound("nz_moo/zombies/vox/_classic/taunt/taunt_00.mp3"),
    Sound("nz_moo/zombies/vox/_classic/taunt/taunt_01.mp3"),
    Sound("nz_moo/zombies/vox/_classic/taunt/taunt_02.mp3"),
    Sound("nz_moo/zombies/vox/_classic/taunt/taunt_03.mp3"),
    Sound("nz_moo/zombies/vox/_classic/taunt/taunt_04.mp3"),
    Sound("nz_moo/zombies/vox/_classic/taunt/taunt_05.mp3"),
    Sound("nz_moo/zombies/vox/_classic/taunt/taunt_06.mp3"),
}

ENT.GoofyahAttackSounds = {
    Sound("nz_moo/zombies/plr_impact/_goofy/punch_boxing_bodyhit03.wav"),
    Sound("nz_moo/zombies/plr_impact/_goofy/punch_boxing_facehit1.wav"),
    Sound("nz_moo/zombies/plr_impact/_goofy/punch_boxing_facehit2.wav"),
    Sound("nz_moo/zombies/plr_impact/_goofy/punch_boxing_facehit3.wav"),
    Sound("nz_moo/zombies/plr_impact/_goofy/punch_boxing_facehit4.wav"),
}

ENT.DanceSounds = {
    Sound("nz_moo/effects/aats/turned/gallery_music_1.mp3"),
    Sound("nz_moo/effects/aats/turned/gallery_music_2.mp3"),
    Sound("nz_moo/effects/aats/turned/disco_of_the_dead_shorter_1.mp3"),
    Sound("nz_moo/effects/aats/turned/disco_of_the_dead_shorter_2.mp3"),
    Sound("nz_moo/effects/aats/turned/low_quality_funky_town.mp3"),
    Sound("nz_moo/effects/aats/turned/goofy_ah_sounds.mp3"),
    Sound("nz_moo/effects/aats/turned/turned_up_1.mp3"),
    Sound("nz_moo/effects/aats/turned/turned_up_2.mp3"),
    Sound("nz_moo/effects/aats/turned/turned_up_3.mp3"),
    Sound("nz_moo/effects/aats/turned/turned_up_4.mp3"),
    Sound("nz_moo/effects/aats/turned/chasing_nightmares.mp3"),
    Sound("nz_moo/effects/aats/turned/back_in_reverse.mp3"),
    Sound("nz_moo/effects/aats/turned/low_quality_19_2000_instrumental.mp3"),
    Sound("nz_moo/effects/aats/turned/roblose.mp3"),
    Sound("nz_moo/effects/aats/turned/the_penis_EEK.mp3"),
    Sound("nz_moo/effects/aats/turned/testicular_tango.mp3"),
    Sound("nz_moo/effects/aats/turned/fnaf1_ambience.mp3"),
    Sound("nz_moo/effects/aats/turned/fnaf2_hallway_ambience.mp3"),
}

function ENT:IsStandingAttack()
    return self:GetStandingAttack()
end

function ENT:EyePos()

    local eyepos = self:LookupBone("j_head") -- If the model of the enemy has a 'j_head' bone, just use that for the eye pos.

    if !eyepos then return self:WorldSpaceCenter() + (self:OBBCenter()*0.7) end

    return eyepos:GetPos()
end

function ENT:WaterBuff() return self:GetWaterBuff() end

function ENT:BomberBuff() return self:GetBomberBuff() end

function ENT:TripleBuff() return self:GetTripleBuff() end

if CLIENT then
    local eyeglow =  Material("nz_moo/sprites/moo_glow1")
    local defaultColor = Color(255, 75, 0, 255)

    function ENT:Draw() //Runs every frame
        --if !self:GetSpawned() then return end
        self:DrawModel()
        
        if self.RedEyes and self:Alive() and !self:GetDecapitated() and !self:GetMooSpecial() and !self.IsMooSpecial then
            self:DrawEyeGlow() 
        end

        if self:WaterBuff() and !self:BomberBuff() and self:Alive() then
            local elight = DynamicLight( self:EntIndex(), true )
            if ( elight ) then
                local bone = self:LookupBone("j_spineupper")
                local pos = self:GetBonePosition(bone)
                pos = pos 
                elight.pos = pos
                elight.r = 0
                elight.g = 50
                elight.b = 255
                elight.brightness = 10
                elight.Decay = 1000
                elight.Size = 40
                elight.DieTime = CurTime() + 1
                elight.style = 0
                elight.noworld = true
            end
        elseif self:BomberBuff() and !self:WaterBuff() and self:Alive() then
            local elight = DynamicLight( self:EntIndex(), true )
            if ( elight ) then
                local bone = self:LookupBone("j_spineupper")
                local pos = self:GetBonePosition(bone)
                pos = pos 
                elight.pos = pos
                elight.r = 150
                elight.g = 255
                elight.b = 75
                elight.brightness = 10
                elight.Decay = 1000
                elight.Size = 40
                elight.DieTime = CurTime() + 1
                elight.style = 0
                elight.noworld = true
            end
        elseif self:WaterBuff() and self:BomberBuff() and self:Alive() then
            local elight = DynamicLight( self:EntIndex(), true )
            if ( elight ) then
                local bone = self:LookupBone("j_spineupper")
                local pos = self:GetBonePosition(bone)
                pos = pos 
                elight.pos = pos
                elight.r = 255
                elight.g = 0
                elight.b = 0
                elight.brightness = 10
                elight.Decay = 1000
                elight.Size = 40
                elight.DieTime = CurTime() + 1
                elight.style = 0
                elight.noworld = true
            end
        end

        if GetConVar( "nz_zombie_debug" ):GetBool() then
            render.DrawWireframeBox(self:GetPos(), Angle(0,0,0), self:OBBMins(), self:OBBMaxs(), Color(255,0,0), true)
        end
    end

    function ENT:DrawEyeGlow()
        local eyeColor = !IsColor(nzMapping.Settings.zombieeyecolor) and defaultColor or nzMapping.Settings.zombieeyecolor
        local latt = self:LookupAttachment("lefteye")
        local ratt = self:LookupAttachment("righteye")

        if latt == nil then return end
        if ratt == nil then return end

        local leye = self:GetAttachment(latt)
        local reye = self:GetAttachment(ratt)

        if leye == nil then return end
        if reye == nil then return end

        local righteyepos = leye.Pos + leye.Ang:Forward()*0.5
        local lefteyepos = reye.Pos + reye.Ang:Forward()*0.5

        if (holidayEnabled and holidayEnabled:GetInt() > 0) then
            if (NZEvent == "Christmas") then
                eyeColor = Color(math.random(0, 255), math.random(0, 255), math.random(0, 255)) -- Christmas light eyes
            end
        end

        if lefteyepos and righteyepos then
            render.SetMaterial(eyeglow)
            render.DrawSprite(lefteyepos, 4, 4, eyeColor)
            render.DrawSprite(righteyepos, 4, 4, eyeColor)
        end
    end
end
