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
    -- TODO: Verify this has a cost and/or cooldown
    RotationSpellWithCostAndCooldown("Ferocious Bite", 30);
  else
    RotationSpellWithCost("Claw", 40);
  end
end
