


local function Warrior_IsStanceActive(stance)
  if(stance == nil or stance == 0) then
    return false
  end
  _, _, active = GetShapeshiftFormInfo(stance);
  return active
end

local WarriorEvents = {};
function WarriorEvents.UNIT_COMBAT(target, action, modifier, value, type)
  if(target == 'target' and action == 'DODGE') then
    print("Target dodged player's attack!!!");
  end
end
local function RegisterEvents(registeredEvents)
  for k, v in pairs(WarriorEvents) do
    registeredEvents[k] = v;
  end
  print("Warrior events registered");
end

Warrior = {
  IsStanceActive = IsStanceActive,
  RegisterEvents = RegisterEvents,
};