--------------------------------
--           Globals          --
--------------------------------
ACTION_SLOT_ATTACK = 0
ACTION_SLOT_CHARGE = 0;
ACTION_SLOT_INTERCEPT = 0;

BATTLE_STANCE = 1;
DEFENSIVE_STANCE = 2;
BERSERKER_STANCE = 3;
ACTIVE_STANCE = 1; -- TODO: Come up with a better way to set this
STANCES = {
  [BATTLE_STANCE] = "Battle Stance",
  [DEFENSIVE_STANCE] = "Defensive Stance",
  [BERSERKER_STANCE] = "Berserker Stance",
}

LAST_TARGET_DODGE_TIME = 0;
LAST_TARGET_DODGE_NAME = nil;

REND_ENABLED = true
DEM_SHOUT_ENABLED = true

CHARGE_DELAY_TIME = 1
LAST_CHARGE_TIME = 0

--------------------------------
--  Warrior Helper Functions  --
--------------------------------
local function Warrior_IsStanceActive(stance)
  if(stance == nil or stance == 0) then
    return false;
  end
  _, _, active = GetShapeshiftFormInfo(stance);
  return active;
end
local function Warrior_SwitchToStance(stance) -- Returns true if already in correct stance
  if(not stance) then
    printc("Attempted to switch to NULL stance", 1, 0, 0);
    return false;
  end
  if(not Warrior_IsStanceActive(stance)) then
    local spell = STANCES[stance];
    CastSpellByName(spell);
    return false;
  end
  return true;
end
local function Warrior_SwitchToActiveStance() -- Returns true if already in correct stance
  if(not ACTIVE_STANCE) then
    printc("Active Stance is null -- Unable to switch to it", 1, 0, 0);
    return false;
  end
  return Warrior_SwitchToStance(ACTIVE_STANCE);
end
local function Warrior_ForceCastStanceSpell(stance, spell, rage) -- Returns true if desired spell was casted
  if(rage == nil) then rage = 0 end
  if(rage > 0 and GetRage() < rage or not IsOffCooldown(spell)) then
    Warrior_SwitchToActiveStance();
    return false;
  end
  if(Warrior_SwitchToStance(stance)) then
    CastSpellByName(spell);
    return true;
  end
  return false;
end
local function Warrior_RotationSpellWithRageAndCooldown(spell, rage)
  if(GetRage() >= rage and IsOffCooldown(spell)) then
    CastSpellByName(spell);
  end
end

--------------------------------
--   Warrior State Functions  --
--------------------------------
function ToggleRend()
  REND_ENABLED = not REND_ENABLED
  printc("Rend " .. (REND_ENABLED and "Enabled" or "Disabled"), 1, 1, 0)
end
function ToggleDemoralizingShout()
  DEM_SHOUT_ENABLED = not DEM_SHOUT_ENABLED
  printc("Demoralizing Shout " .. (DEM_SHOUT_ENABLED and "Enabled" or "Disabled"), 1, 1, 0)
end
function SetBattleStance()
  ACTIVE_STANCE = BATTLE_STANCE
  printc("Battle Stance " .. (BATTLE_STANCE and "Enabled" or "Disabled"), 1, 1, 0)
  Warrior_SwitchToActiveStance()
end
function SetDefensiveStance()
  ACTIVE_STANCE = DEFENSIVE_STANCE
  printc("Defensive Stance " .. (DEFENSIVE_STANCE and "Enabled" or "Disabled"), 1, 1, 0)
  Warrior_SwitchToActiveStance()
end

--------------------------------
--       Warrior Spells       --
--------------------------------
function RotationCastOverpower()
  local targetName = GetName("target");
  -- TODO: Dodge checks needed in rotation overpower?
  if(targetName == LAST_TARGET_DODGE_NAME and LAST_TARGET_DODGE_TIME + 5 > GetTime()) then
    Warrior_RotationSpellWithRageAndCooldown("Overpower", 5);
    targetName = nil;
  end
end
function RotationCastExecute()
  if(GetHealth("target") < 20) then
    Warrior_RotationSpellWithRageAndCooldown("Execute", 15);
  end
end
function RotationCastBloodrage()
  local spell = "Bloodrage";
  if(GetRage() < 65 and GetHealth("player") > 20 and IsOffCooldown(spell)) then
    CastSpellByName(spell);
  end
end
function RotationCastBattleShout()
  if(MissingBuff(spell)) then
    Warrior_RotationSpellWithRageAndCooldown("Battle Shout", 10);
  end
end
function RotationCastDemoralizingShout()
  if(DEM_SHOUT_ENABLED and GetHealth("target") > 10 and MissingBuff(spell, "target")) then
    Warrior_RotationSpellWithRageAndCooldown("Demoralizing Shout", 10);
  end
end
function RotationCastRend()
  if(REND_ENABLED and MissingBuff(spell, "target") and GetHealth("target") > 25) then
    Warrior_RotationSpellWithRageAndCooldown("Rend", 10);
  end
end
function RotationCastMortalStrike()
  Warrior_RotationSpellWithRageAndCooldown("Mortal Strike", 30);
end
function RotationCastSweepingStrikes()
  Warrior_RotationSpellWithRageAndCooldown("Sweeping Strikes", 30);
end
function RotationCastCleave()
  Warrior_RotationSpellWithRageAndCooldown("Cleave", 20);
end
function RotationCastRevenge()
  Warrior_RotationSpellWithRageAndCooldown("Revenge", 5);
end
function RotationCastHeroicStrike()
  Warrior_RotationSpellWithRageAndCooldown("Heroic Strike", 15);
end

function ForceCastOverpower()
  Warrior_ForceCastStanceSpell(BATTLE_STANCE, "Overpower", 5);
end
function ForceCastPummel()
  Warrior_ForceCastStanceSpell(BERSERKER_STANCE, "Pummel", 10);
end
function ForceCastBerserkerRage()
  Warrior_ForceCastStanceSpell(BERSERKER_STANCE, "Berserker Rage");
end

--------------------------------
--   Advanced Spell Casting   --
--------------------------------
function CastSuperCharge()
  local time = GetTime();

  -- Prevent attempting to charge too early (like during a charge)
  if(time - LAST_CHARGE_TIME < CHARGE_DELAY_TIME) then
    Warrior_SwitchToActiveStance();
    return false;
  end

  -- Both Charge and Intercept have the same range
  local inRange = IsActionInRange(ACTION_SLOT_CHARGE) == 1;
  local isCharging = IsCurrentAction(ACTION_SLOT_CHARGE) == 1;
  local isIntercepting = IsCurrentAction(ACTION_SLOT_INTERCEPT) == 1;
  local canChargeOrIntercept = inRange and not (isCharging or isIntercepting);
  if(not canChargeOrIntercept) then
    Warrior_SwitchToActiveStance();
    return
  end

  -- Cast correct charge
  local charged = false;
  if(IsInCombat()) then
    if(Warrior_ForceCastStanceSpell(BERSERKER_STANCE, "Intercept", 10)) then
      charged = IsCurrentAction(ACTION_SLOT_INTERCEPT) == 1;
    end
  else
    if(Warrior_ForceCastStanceSpell(BATTLE_STANCE, "Charge")) then
      charged = IsCurrentAction(ACTION_SLOT_CHARGE) == 1;
    end
  end

  -- Mark charge time only if charge was casted
  if(charged) then
    LAST_CHARGE_TIME = time;
  end
end
function InstantThreat()
  AutoAttack()
  if(Warrior_IsStanceActive(DEFENSIVE_STANCE)) then
    if(not (UnitIsUnit("player", "targettarget") == 1)) then
      CastSpellByName("Taunt")
    end
  end

  CastSpellByName("Sunder Armor")
end

--------------------------------
--           Setup            --
--------------------------------
local WarriorEvents = {};
function WarriorEvents.UNIT_COMBAT(target, action, modifier, value, type)
  if(target == 'target' and action == 'DODGE') then
    LAST_TARGET_DODGE_TIME = GetTime();
    LAST_TARGET_DODGE_NAME = UnitName("target");
  end
end
function Warrior_RegisterEvents(registeredEvents)
  for k, v in pairs(WarriorEvents) do
    registeredEvents[k] = v;
  end
end

function Warrior_OnLoad()
  ACTION_SLOT_CHARGE = FindActionByName("Charge")
  ACTION_SLOT_INTERCEPT = FindActionByName("Intercept")
  ACTION_SLOT_ATTACK = FindActionByName("Attack")

  errors = "";
  index = 1;

  if(ACTION_SLOT_CHARGE == 0) then
    errors = errors .. index .. ": Missing Charge on Action Bars\n";
    index = index + 1;
    ACTION_SLOT_CHARGE = 35
  end
  if(ACTION_SLOT_INTERCEPT == 0) then
    errors = errors .. index .. ": Missing Intercept on Action Bars\n";
    index = index + 1;
    ACTION_SLOT_INTERCEPT = 34
  end
  if(ACTION_SLOT_ATTACK == 0) then
    errors = errors .. index .. ": Missing Attack on Action Bars\n";
    index = index + 1;
    ACTION_SLOT_ATTACK = 36
  end

  return errors;
end