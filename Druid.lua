--------------------------------
--           Globals          --
--------------------------------
HUMAN_FORM = 0;
BEAR_FORM = 1;
WATER_FORM = 2;
CAT_FORM = 3;
TRAVEL_FORM = 4;
MOONKIN_FORM = 5;
TREE_FORM = 6;

--------------------------------
--        Druid Spells        --
--------------------------------
function RotationCastTigersFury()
  tigersFury = "Tiger's Fury"
  if(MissingBuff(tigersFury)) then
    RotationSpellWithCostAndCooldown(tigersFury, 30);
  end
end

function RotationCastClaw(startAutoAttack)
  if(startAutoAttack) then
    AutoAttack();
  end

  comboPoints = GetComboPoints();
  if(comboPoints >= 5) then
    RotationSpellWithCost("Ferocious Bite", 35);
  else
    RotationSpellWithCost("Claw", 40);
  end
end

--------------------------------
--           Setup            --
--------------------------------
function Druid_OnLoad(errorlist)
  -- TODO: This may need to move to spot to only happen once on load
  ACTIVE_FORM = GetCurrentFormIndex();

  FORMS[0] = "Humaniod"; -- Special Case
  FORMS[1] = "Bear Form"; -- Also Dire Bear Form?
  FORMS[2] = "Aquatic Form";
  FORMS[3] = "Cat Form";
  FORMS[4] = "Travel Form";
  FORMS[5] = "Moonkin Form";
  FORMS[6] = "Tree Form";
end

function Druid_SetupMacros(macros)
  macros["druid_claw"]        = { icon = 038, name = " ",         body = "/run RotationCastClaw(true)" };
  macros["druid_tigers_fury"] = { icon = 038, name = "  ",        body = "/run RotationCastTigersFury()" };
end
