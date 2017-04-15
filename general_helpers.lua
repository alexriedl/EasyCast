----------------------
--  User Functions  --
----------------------

function GetCooldownByName(name)
  return GetSpellCooldown(SM_FindSpell(name))
end

function IsOffCooldown(name)
  return GetCooldownByName(name) == 0
end

function GetRage()
  return UnitMana("player")
end

function GetMana()
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

function AutoAttack()
  if(not IsCurrentAction(ACTION_SLOT_ATTACK)) then
    UseAction(ACTION_SLOT_ATTACK)
  end
end

function ClearErrors()
  UIErrorsFrame:Clear()
end

--------------------------
-- Action Bar Functions --
--------------------------
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
