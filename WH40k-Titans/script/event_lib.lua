--[[ By AivanF.
EventLib v2023.09.17
To be used with Factorio's builtin lualib.event_handler
For simpler migration from a single control.lua file to libs.

Single file:

  script.on_init(on_init)
  script.on_configuration_changed(on_configuration_changed)
  script.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity}, handler1)
  script.on_event(defines.events.on_entity_died, handler2)
  script.on_nth_tick(5, handle_5_step)
  add_commands()

Nice, but for only one file :(
Old approach:

  local lib = {}
  lib.on_init = on_init
  lib.on_configuration_changed = on_configuration_changed
  lib.events = {
    [defines.events.on_built_entity] = handler1,
    [defines.events.on_robot_built_entity] = handler1,
    [defines.events.on_entity_died] = handler2,
  }
  lib.on_nth_tick = {
    [5] = handle_5_step,
  }
  lib.add_commands = add_commands
  return lib

  local handler = require("event_handler")
  handler.add_lib(require("script.mylib"))

Scalable, but leads to ugly mixed syntax :(
New way:

  local Lib = require("event_lib")
  local lib = Lib.new()
  lib:on_init(on_init)
  lib:on_configuration_changed(on_configuration_changed)
  lib:on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity}, handler1)
  lib:on_event(defines.events.on_entity_died, handler2)
  lib:on_nth_tick(5, handle_5_step)
  lib.add_commands = add_commands
  return lib

  local handler = require("event_handler")
  handler.add_lib(require("script.mylib").export())

This supports having multiple files too ^_^
but it is more similar to the original syntax,
also easier to add conditional events :]]

Lib = {}
Lib.__index = Lib

function empty() end

function Lib.new()
  local lib = {
    content = {
      events = {},
      on_nth_tick = {},
      -- on_init = empty,
      -- on_load = empty,
      -- on_configuration_changed = empty,
      -- add_remote_interface = empty,
      -- add_commands = empty,
    }
  }
  setmetatable(lib, Lib)
  lib.__index = Lib
  return lib
end

function Lib:on_nth_tick(n, callback)
  if self.content.on_nth_tick[n] then
    error("Trying to register same on_nth_tick "..n.." again")
  end
  self.content.on_nth_tick[n] = callback
end

function Lib:on_event(event_list, callback)
  if type(event_list) ~= "table" then event_list = {event_list} end
  for _, event in pairs(event_list) do
    if self.content.on_nth_tick[n] then
      error("Trying to register same on_event "..event.." again")
    end
    self.content.events[event] = callback
  end
end

local push_names = {"add_remote_interface", "add_commands"}
function Lib:export()
  for _, name in pairs(push_names) do
    if self[name] then
      self.content[name] = self[name]
    end
  end
  return self.content
end

local basic_methods = {"on_init", "on_load", "on_configuration_changed"}
for _, name in pairs(basic_methods) do
  Lib[name] = function(self, callback)
    self.content[name] = callback
  end
end

return Lib