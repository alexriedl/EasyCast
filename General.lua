----------------------
--  Global Helpers  --
----------------------
function EC_PrintC(msg, r, g, b)
  DEFAULT_CHAT_FRAME:AddMessage(msg, r, g, b);
end
function EC_Print(msg)
  EC_PrintC(msg, 1, 1, 1);
end
function EC_Error(msg)
  _ERRORMESSAGE(msg);
end
printc = EC_PrintC;
print = EC_Print;
printe = EC_error;

function StringDefault(value, default)
  if(not value or value == "") then
    return default;
  else
    return value;
  end
end

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

function HasBuff(unit, buff) -- Returns (Type [buff, debuf], Index, Buff Name)
  if(not buff) then return; end
  buff = strlower(buff);
  unit = StringDefault(unit, "player");

  local tooltip = EC_Tooltip;
  local tooltipTitle = getglobal(tooltip:GetName() .. "TextLeft1");

  for i=1, 40 do
    tooltip:SetOwner(UIParent, "ANCHOR_NONE");
    tooltip:SetUnitBuff(unit, i);
    local name = tooltipTitle:GetText();
    tooltip:Hide();
    if(name and strfind(strlower(name), buff)) then
      return "buff", i, name;
    end
  end
  for i=1, 40 do
    tooltip:SetOwner(UIParent, "ANCHOR_NONE");
    tooltip:SetUnitDebuff(unit, i);
    local name = tooltipTitle:GetText();
    tooltip:Hide();
    if(name and strfind(strlower(name), buff)) then
      return "debuff", i, name;
    end
  end
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
