local PLAYER_CLASS = UnitClass("player");

local function SetupMacros()
  local macros = {};
  local classRegisters = {
    Warrior = Warrior_SetupMacros,
  };
  if(classRegisters[PLAYER_CLASS]) then
    classRegisters[PLAYER_CLASS](macros);
  end
  SyncMacros(macros);
end

SLASH_EASYCAST1, SLASH_EASYCAST2 = '/easycast', '/ec';
local function ChatHandler(msg, editbox)
  local title = "|c00997700";
  local info = "|c00ffffff";
  if(StringNullOrEmpty(msg)) then
    print(title .. "Usage: " .. info .. "/ec {macrosync | about}");
    print(title .. "-macrosync: " .. info .. "Sync EasyCast Macros with player macros");
    print(title .. "-about: " .. info .. "Display information about this addon");
  elseif(msg == "macrosync") then
    SetupMacros();
    printc("Macros Synced!", 1, .8, 0);
  elseif(msg == "about") then
    printc("EasyCast!! By Alex", 1, .8, 0);
  else
    printc("Unknown EasyCast command! Type '/ec' for more information", 1, 0, 0);
  end
end
SlashCmdList["EASYCAST"] = ChatHandler;

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
