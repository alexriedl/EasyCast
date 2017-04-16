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
function StringNullOrEmpty(value)
  return value == "";
end

----------------------
--  User Functions  --
----------------------
function FindSpellByName(spell, rank) -- Returns (spell id, rank). rank parameter is optional, defults to highest rank
  if(StringNullOrEmpty(name)) then return; end
  spell = strlower(spell);
  rank = StringDefault(rank, "");
  local books = { BOOKTYPE_SPELL, BOOKTYPE_PET };
  local id = 1;

  for key, book in books do
    while(spell) do
      local foundSpell = false;
      local foundRank = false;
      local s, r = GetSpellName(id, book);
      if(StringNullOrEmpty(s)) then
        id = 1;
        break;
      end
      if(strlower(s) == spell) then foundSpell = true; end
      if((r == rank) or (r and rank and strlower(r) == strlower(rank))) then foundRank = true; end
      if((rank == "") and foundSpell and (not GetSpellName(id+1, book) or strlower(GetSpellName(id+1, book)) ~= strlower(spell))) then
        foundRank = true;
      end
      if(foundSpell and foundRank) then
        return id, book;
      end
      id = id + 1;
    end
  end
end

function GetCooldownByName(name)
  return GetSpellCooldown(FindSpellByName(name))
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

function AutoAttack() -- TODO: Move global to a better spot
  if(not IsCurrentAction(ACTION_SLOT_ATTACK)) then
    UseAction(ACTION_SLOT_ATTACK)
  end
end

function ClearErrors()
  UIErrorsFrame:Clear()
end

function HasBuff(unit, buff) -- Returns (Type [buff, debuf], Index, Buff Name)
  if(StringNullOrEmpty(buff)) then return; end
  buff = strlower(buff);
  unit = StringDefault(unit, "player");

  local tooltip = EC_Tooltip;
  local tooltipTitle = getglobal(tooltip:GetName() .. "TextLeft1");

  for i = 1, 40 do
    tooltip:SetOwner(UIParent, "ANCHOR_NONE");
    tooltip:SetUnitBuff(unit, i);
    local name = tooltipTitle:GetText();
    tooltip:Hide();
    if(name and strfind(strlower(name), buff)) then
      return "buff", i, name;
    end
  end
  for i = 1, 40 do
    tooltip:SetOwner(UIParent, "ANCHOR_NONE");
    tooltip:SetUnitDebuff(unit, i);
    local name = tooltipTitle:GetText();
    tooltip:Hide();
    if(name and strfind(strlower(name), buff)) then
      return "debuff", i, name;
    end
  end
end

function FindActionByName(name) -- Returns (Slot ID, Name) if found
  if(StringNullOrEmpty(name)) then return; end
  name = strlower(name);

  local tooltip = EC_Tooltip;
  local tooltipTitle = getglobal(tooltip:GetName() .. "TextLeft1");

  for i = 1, 120 do
    tooltip:SetOwner(UIParent, "ANCHOR_NONE");
    tooltip:SetAction(i);
    local action = tooltipTitle:GetText();
    if(action and strfind(strlower(action), name)) then
      return i, action;
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
