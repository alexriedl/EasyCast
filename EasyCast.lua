--------------------------------
--          Helpers           --
--------------------------------

function EasyCast_PrintC(msg, r, g, b)
  DEFAULT_CHAT_FRAME:AddMessage(msg, r, g, b);
end
function EasyCast_Print(msg)
  EasyCast_PrintC(msg, 1, 1, 1);
end
print = EasyCast_Print;
printc = EasyCast_PrintC;




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