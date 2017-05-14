local PLAYER_CLASS = UnitClass("player");

local function RegisterMacros()
  local macros = {};
  local classRegisters = {
    Warrior = Warrior_SetupMacros,
  };
  if(classRegisters[PLAYER_CLASS]) then
    classRegisters[PLAYER_CLASS](macros);
  end
  SyncMacros(macros);
end


--------------------------------
--        System Setup        --
--------------------------------
local RegisteredEvents = {};
function RegisteredEvents.PLAYER_ENTERING_WORLD()
  errorlist = {};

  -- Class Setup
  local classOnLoad = {
    Warrior = Warrior_OnLoad,
  };
  if(classOnLoad[PLAYER_CLASS]) then
    classOnLoad[PLAYER_CLASS](errorlist);
  end

  -- General Setup
  ACTION_SLOT_ATTACK = FindActionByName("Attack")
  if(not ACTION_SLOT_ATTACK) then
    table.insert(errorlist, "Missing Attack on Action Bars");
  end

  RegisterMacros();

  -- Check for/display errors
  local errormsg = "";
  for k, v in errorlist do
    errormsg = errormsg .. k .. ": " .. v .. "\n";
  end

  if(not (errormsg == "")) then
    printe("EasyCast Errors:\n" .. errormsg);
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
  if(classRegisters[PLAYER_CLASS]) then
    classRegisters[PLAYER_CLASS](registeredEvents);
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
}
