----------------------
--  Global Helpers  --
----------------------
function EC_PrintColor(msg, r, g, b)
  DEFAULT_CHAT_FRAME:AddMessage(msg, r, g, b);
end
function EC_Print(msg)
  EC_PrintColor(msg, 1, 1, 1);
end
function EC_PrintError(msg)
  _ERRORMESSAGE(msg);
end
printc = EC_PrintColor;
print = EC_Print;
printe = EC_PrintError;

function StringDefault(value, default)
  if(not value or value == "") then
    return default;
  else
    return value;
  end
end
function StringNullOrEmpty(value)
  return value == nil or value == "";
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

function GetRage(unit)
  unit = StringDefault(unit, "player");
  return UnitMana(unit)
end

function GetMana(unit)
  unit = StringDefault(unit, "player");
  return UnitMana(unit)
end

function GetEnergy(unit)
  unit = StringDefault(unit, "player");
  return UnitMana(unit)
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

function RotationSpellWithCost(spell, cost)
  if(GetMana() >= cost) then
    CastSpellByName(spell);
  end
end

function RotationSpellWithCostAndCooldown(spell, cost)
  if(GetMana() >= cost and IsOffCooldown(spell)) then
    CastSpellByName(spell);
  end
end

ACTION_SLOT_ATTACK = 0
function AutoAttack()
  if(not IsCurrentAction(ACTION_SLOT_ATTACK)) then
    UseAction(ACTION_SLOT_ATTACK)
  end
end

function ClearErrors()
  UIErrorsFrame:Clear()
end

function HasBuff(buff, unit) -- Returns (Type [buff, debuf], Index, Buff Name)
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

--------------------------------
--    Form Helper Functions   --
--------------------------------
ACTIVE_FORM = 0;
FORMS = {};

function GetCurrentFormIndex()
  local num = GetNumShapeshiftForms();
  for i = 0, num do
    if(IsFormActive(i)) then
      return i;
    end
  end

  return 0;
end

function IsFormActive(form)
  if(form == nil or form == 0) then
    return false;
  end
  _, _, active = GetShapeshiftFormInfo(form);
  return active;
end

function SwitchToForm(form) -- Returns true if already in correct form
  if(not form) then
    printc("Attempted to switch to NULL form", 1, 0, 0);
    return false;
  end
  if(not IsFormActive(form)) then
    local spell = FORMS[form];
    CastSpellByName(spell);
    return false;
  end
  return true;
end

function SwitchToActiveForm() -- Returns true if already in correct form
  if(not ACTIVE_FORM) then
    printc("Active form is null -- Unable to switch to it", 1, 0, 0);
    return false;
  end
  return SwitchToForm(ACTIVE_FORM);
end

function ForceCastFormSpell(form, spell, cost) -- Returns true if desired spell was casted
  if(cost == nil) then cost = 0 end
  if(cost > 0 and GetMana() < cost or not IsOffCooldown(spell)) then
    SwitchToActiveForm();
    return false;
  end
  if(SwitchToForm(form)) then
    CastSpellByName(spell);
    return true;
  end
  return false;
end

function SetForm(form)
  if(not form) then
    printc("Attempted to set active form to null -- Unable to set active form", 1, 0, 0);
    return;
  end
  ACTIVE_FORM = form;
  local spell = FORMS[form];
  printc(spell .. " " .. ((ACTIVE_FORM == form) and "Enabled" or "Disabled"), 1, 1, 0)
  SwitchToActiveForm()
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

----------------------
-- Macros Functions --
----------------------
local MACRO_PREFIX = "/run -- EasyCastMacro -- #"
local MACRO_PREFIX_LENGTH = string.len(MACRO_PREFIX);

function SyncMacros(macros)
  for index = 1, 36 do
    local n, icon, body = GetMacroInfo(index)
    if(IsEasyCastMacro(body)) then
      local id = GetEasyCastId(body);
      local macro = macros[id];

      if(macro and macro.body and macro.icon) then
        SetupMacro(id, macro, index);
        macros[id] = nil;
      else
        DeleteMacro(index);
      end

    end
  end

  for id, macro in pairs(macros) do
    if(macro) then
      SetupMacro(id, macro);
    end
  end
end

function SetupMacro(id, macro, index) -- if index is null, a new macro will be created. Macro { icon = <int>, name = <string>, body = <string> }
  local body = MACRO_PREFIX .. id .. "\n/run -- This macro is managed by EasyCast. Do not edit it\n" .. macro.body;
  local name = macro.name;
  local icon = macro.icon;

  if(index) then
    EditMacro(index, name, icon, body, 1);
  else
    CreateMacro(name, icon, body, 1, true);
  end
end

function IsEasyCastMacro(body)
  if(not body) then return false; end
  local header = string.sub(body, 1, MACRO_PREFIX_LENGTH);
  return (header == MACRO_PREFIX);
end

function GetEasyCastId(body)
  endOfFirstLine, lines = string.find(body, "\n");
  return string.sub(body, MACRO_PREFIX_LENGTH + 1, endOfFirstLine - 1)
end

function GetMacroIconIndex(name) -- Helper function to get the texture ID of a macro.
  local index = GetMacroIndexByName(name);
  local n, icon, body = GetMacroInfo(index)
  for iconIndex = 1, GetNumMacroIcons() do
    local t = GetMacroIconInfo(iconIndex);
    if(t == icon) then
      print("Icon for " .. name .. " is " .. iconIndex);
    end
  end
end
