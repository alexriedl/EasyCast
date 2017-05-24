function RotationCastTigersFury(startAutoAttack)
  if(startAutoAttack) then
    AutoAttack();
  end

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

function Druid_SetupMacros(macros)
  macros["druid_claw"]      = { icon = 038, name = " ",         body = "/run RotationCastClaw(true)" };
end
