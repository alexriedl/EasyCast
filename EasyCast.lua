


--------------------------------
--     Registered Events      --
--------------------------------
local RegisteredEvents = {};

--[[
function RegisteredEvents.UNIT_COMBAT(target, action, modifier, value, type)
end
]]

local function RegisterClassEvents(registeredEvents)
  local playerClass = UnitClass("player");
  local classRegisters = {
    Warrior = Warrior.RegisterEvents,
  };
  classRegisters[playerClass](registeredEvents);
end

--------------------------------
--        System Setup        --
--------------------------------
local function EventHandler(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
  if(event) then
    RegisteredEvents[event](arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10);
  end
end

local function OnLoad(this)
  RegisterClassEvents(RegisteredEvents);
  for k, v in pairs(RegisteredEvents) do
    this:RegisterEvent(k);
  end
  printc("EasyCast Loaded!", 1, 0.8, 0);
end

local function OnUpdate(this)
end

--------------------------------
--        Global Setup        --
--------------------------------
EC = {
  OnLoad = OnLoad,
  OnEvent = EventHandler,
  OnUpdate = OnUpdate,

  Warrior = Warrior,
}