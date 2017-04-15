-------------------------------------------------------------
--          General Functions
-------------------------------------------------------------
ACTION_SLOT_ATTACK = 0

-------------------------------------------------------------
--          Warrior Functions
-------------------------------------------------------------


-------------------------------------------------------------
--          Public Functions
-------------------------------------------------------------
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
function WarriorTankInstantThreat()
  AutoAttack()
  if(IsStanceActive(DEFENSIVE_STANCE)) then
    if(not (UnitIsUnit("player", "targettarget") == 1)) then
      CastSpellByName("Taunt")
    end
  end

  CastSpellByName("Sunder Armor")
end
function WarriorTankDPSRotation()
  AutoAttack()
  ClearErrors()
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
  ACTION_SLOT_CHARGE = FindActionByTexture("Ability_Warrior_Charge")
  ACTION_SLOT_INTERCEPT = FindActionByTexture("Ability_Rogue_Sprint")

  if(ACTION_SLOT_CHARGE == 0) then
    PrintColor(1, 0, 0, "Charge must be on the action bar for all macros to work correctly")
    ACTION_SLOT_CHARGE = 35
  end
  if(ACTION_SLOT_INTERCEPT == 0) then
    PrintColor(1, 0, 0, "Intercept must be on the action bar for all macros to work correctly")
    ACTION_SLOT_INTERCEPT = 34
    local texture = GetActionTexture(ACTION_SLOT_INTERCEPT);
    PrintColor(1, 1, 0, texture);
  end
end

function Custom_Init()
  s, b = SM_FindSpell("Attack")
  if(not s or not b) then
    PrintColor(1, 0, 0, "Attack must be on the action bar for all macros to work correctly")
    ACTION_SLOT_ATTACK = 36
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