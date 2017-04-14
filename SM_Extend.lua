-------------------------------------------------------------
--          General Functions
-------------------------------------------------------------
ACTION_SLOT_ATTACK = 0
function GetCooldownByName(name)
  return GetSpellCooldown(SM_FindSpell(name))
end
function OffCooldown(name)
  return GetCooldownByName(name) == 0
end
function GetRage()
  return UnitMana("player")
end
function GetHealth(unit)
  return UnitHealth(unit) / UnitHealthMax(unit) * 100.0
end
function MissingBuff(name, unit)
  local _,hasBuff = FindBuff(name, unit)
  return not hasBuff
end
function IsInCombat()
  return UnitAffectingCombat("player")
end
function IsStanceActive(stance)
  if(stance == nil or stance == 0) then
    return false
  end
  _, _, active = GetShapeshiftFormInfo(stance);
  return active
end
function ClearErrors()
  UIErrorsFrame:Clear()
end
function AutoAttack()
  if(not IsCurrentAction(ACTION_SLOT_ATTACK)) then
    UseAction(ACTION_SLOT_ATTACK)
  end
end
function FindActionByTexture(name)
  local slotId = 0
  for slotId = 1, 120 do
    local texture = GetActionTexture(slotId)
    if(texture) then
      if(strfind(texture, name)) then
        return slotId
      end
    end
  end
  return 0
end

-------------------------------------------------------------
--          Warrior Functions
-------------------------------------------------------------
REND_ENABLED = true
DEM_SHOUT_ENABLED = true

ACTION_SLOT_CHARGE = 0
ACTION_SLOT_INTERCEPT = 0

BATTLE_STANCE = 1
DEFENSIVE_STANCE = 2
BERSERKER_STANCE = 3
ACTIVE_STANCE = BATLLE_STANCE
STANCES = {
  [BATTLE_STANCE] = "Battle Stance",
  [DEFENSIVE_STANCE] = "Defensive Stance",
  [BERSERKER_STANCE] = "Berserker Stance"
}

CHARGE_DELAY_TIME = 2
LAST_CHARGE_TIME = 0

function CastSpellWithRageAndCooldown(spell, rage)
  if(GetRage() >= rage and OffCooldown(spell)) then
    CastSpellByName(spell)
  end
end
function CastOverpower()
  CastSpellWithRageAndCooldown("Overpower", 5)
end
function CastExecute()
  if(GetHealth("target") < 20) then
    CastSpellWithRageAndCooldown("Execute", 15)
  end
end
function CastBloodrage()
  local spell = "Bloodrage"
  if(GetRage() < 65 and GetHealth("player") > 20 and OffCooldown(spell)) then
    CastSpellByName(spell)
  end
end
function CastBattleShout()
  local rage = 10
  local spell = "Battle Shout"
  if(GetRage() >= rage and MissingBuff(spell)) then
    CastSpellByName(spell)
  end
end
function CastDemoralizingShout()
  local rage = 10
  local spell = "Demoralizing Shout"
  if(DEM_SHOUT_ENABLED and GetRage() >= rage and GetHealth("target") > 10 and MissingBuff(spell, "target")) then
    CastSpellByName(spell)
  end
end
function CastRend()
  local rage = 10
  local spell = "Rend"
  if(REND_ENABLED and GetRage() >= rage and MissingBuff(spell, "target") and GetHealth("target") > 20) then
    CastSpellByName(spell)
  end
end
function CastMortalStrike()
  CastSpellWithRageAndCooldown("Mortal Strike", 30)
end
function CastSweepingStrikes()
  CastSpellWithRageAndCooldown("Sweeping Strikes", 30)
end
function CastCleave()
  CastSpellWithRageAndCooldown("Cleave", 20)
end
function CastRevenge()
  CastSpellWithRageAndCooldown("Revenge", 5)
end
function CastHeroicStrike()
  CastSpellWithRageAndCooldown("Heroic Strike", 15)
end
function SwitchToStance(stance) -- Returns true if already in correct stance
  if(not stance) then
    PrintColor(1, 0, 0, "Attempted to switch to NULL stance")
    return false
  end
  if(not IsStanceActive(stance)) then
    local spell = STANCES[stance]
    CastSpellByName(spell)
    return false
  end
  return true
end
function SwitchToActiveStance() -- Returns true if already in correct stance
  if(not ACTIVE_STANCE) then
    PrintColor(1, 0, 0, "Active Stance is null -- Unable to switch to it");
    return false
  end
  return SwitchToStance(ACTIVE_STANCE)
end
function CastStanceSpell(stance, spell, rage) -- Returns true if desired spell was casted
  if(rage == nil) then rage = 0 end
  if(rage > 0 and GetRage() < rage or not OffCooldown(spell)) then
    SwitchToActiveStance()
    return false
  end

  if(SwitchToStance(stance)) then
    CastSpellByName(spell)
    return true
  end
  return false
end

-------------------------------------------------------------
--          Public Functions
-------------------------------------------------------------
function ToggleRend()
  REND_ENABLED = not REND_ENABLED
  PrintColor(1, 1, 0, "Rend " .. (REND_ENABLED and "Enabled" or "Disabled"))
end
function ToggleDemoralizingShout()
  DEM_SHOUT_ENABLED = not DEM_SHOUT_ENABLED
  PrintColor(1, 1, 0, "Demoralizing Shout " .. (DEM_SHOUT_ENABLED and "Enabled" or "Disabled"))
end
function SetBattleStance()
  ACTIVE_STANCE = BATTLE_STANCE
  PrintColor(1, 1, 0, "Battle Stance " .. (BATTLE_STANCE and "Enabled" or "Disabled"))
  SwitchToActiveStance()
end
function SetDefensiveStance()
  ACTIVE_STANCE = DEFENSIVE_STANCE
  PrintColor(1, 1, 0, "Defensive Stance " .. (DEFENSIVE_STANCE and "Enabled" or "Disabled"))
  SwitchToActiveStance()
end
function WarriorDPSRotation()
  AutoAttack()
  CastOverpower()
  CastExecute()
  CastBloodrage()
  CastBattleShout()
  CastDemoralizingShout()
  CastRend()
  CastMortalStrike()
  ClearErrors()
end
function WarriorAOERotation()
  AutoAttack()
  CastOverpower()
  CastBloodrage()
  CastBattleShout()
  CastDemoralizingShout()
  CastSweepingStrikes()
  CastCleave()
  ClearErrors()
end
function WarriorTankAggroRotation()
  AutoAttack()
  CastRevenge()
  CastHeroicStrike()
  CastBloodrage()
  ClearErrors()
end
function WarriorTankDPSRotation()
  AutoAttack()
  CastBloodrage()
  CastRevenge()
  CastDemoralizingShout()
  CastRend()
  CastMortalStrike()
  ClearErrors()
end
function CastPummel()
  CastStanceSpell(BERSERKER_STANCE, "Pummel", 10)
end
function CastBerserkerRage()
  CastStanceSpell(BERSERKER_STANCE, "Berserker Rage")
end
function CastSuperCharge()
  local time = GetTime()

  -- Prevent attempting to charge too early (like during a charge)
  if(time - LAST_CHARGE_TIME < CHARGE_DELAY_TIME) then
    SwitchToActiveStance()
    return false
  end

  -- Both Charge and Intercept have the same range
  local inRange = IsActionInRange(ACTION_SLOT_CHARGE) == 1
  local isCharging = IsCurrentAction(ACTION_SLOT_CHARGE) == 1
  local isIntercepting = IsCurrentAction(ACTION_SLOT_INTERCEPT) == 1
  local canChargeOrIntercept = inRange and not (isCharging or isIntercepting)
  if(not canChargeOrIntercept) then
    SwitchToActiveStance()
    return
  end

  -- Cast correct charge
  local charged = false
  if(IsInCombat()) then
    if(CastStanceSpell(BERSERKER_STANCE, "Intercept", 10)) then
      charged = IsCurrentAction(ACTION_SLOT_INTERCEPT) == 1
    end
  else
    if(CastStanceSpell(BATTLE_STANCE, "Charge")) then
      charged = IsCurrentAction(ACTION_SLOT_CHARGE) == 1
    end
  end

  -- Mark charge time only if charge was casted
  if(charged) then
    LAST_CHARGE_TIME = time
  end
end

-------------------------------------------------------------
--          Init Functions
-------------------------------------------------------------
function Custom_Warrior_Init()
  ACTION_SLOT_CHARGE = FindActionByTexture("_Charge")
  ACTION_SLOT_INTERCEPT = FindActionByTexture("_Intercept")

  if(ACTION_SLOT_CHARGE == 0) then
    PrintColor(1, 0, 0, "Charge must be on the action bar for all macros to work correctly")
  end
  if(ACTION_SLOT_INTERCEPT == 0) then
    PrintColor(1, 0, 0, "Intercept must be on the action bar for all macros to work correctly")
  end
end

function Custom_Init()
  s, b = SM_FindSpell("Attack")
  if(not s or not b) then
    PrintColor(1, 0, 0, "Attack must be on the action bar for all macros to work correctly")
  else
    texture = GetSpellTexture(s, b)
    ACTION_SLOT_ATTACK = FindActionByTexture(texture)
  end

  local class = UnitClass("player")
  if(class == "Warrior") then
    Custom_Warrior_Init()
  end
end

Custom_Init()