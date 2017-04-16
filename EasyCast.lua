local PLAYER_CLASS = UnitClass("player");



--------------------------------
--        System Setup        --
--------------------------------
local RegisteredEvents = {};
function RegisteredEvents.PLAYER_ENTERING_WORLD()
  local classOnLoad = {
    Warrior = Warrior_OnLoad,
  };
  errors = classOnLoad[PLAYER_CLASS]();
  if(errors and not (errors == "")) then
    _ERRORMESSAGE(errors);
  end
end

local function EventHandler(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
  if(event) then
    RegisteredEvents[event](arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10);
  end
end

local function RegisterClassEvents(registeredEvents)
  local classRegisters = {
    Warrior = Warrior_RegisterEvents,
  };
  classRegisters[PLAYER_CLASS](registeredEvents);
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
}