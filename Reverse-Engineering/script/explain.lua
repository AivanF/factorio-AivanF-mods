require("utils")
require("script.worth")
local Lib = require("event_lib")
local lib = Lib.new()

-- TODO: add GUI to select any item
local function explain(cmd)
  local player = game.get_player(cmd.player_index)
  local item_name = cmd.parameter
  local answers = {}
  if ignore_item[item_name] then
    table.insert(answers, "builtin ignored")
  end
  if global.add_ignore_items[item_name] then
    table.insert(answers, "remotely ignored")
  end
  if global.scipacks[item_name] then
    table.insert(answers, "is a science pack")
  end
  if override_items[item_name] then
    table.insert(answers, "builtin overriden")
  end
  if global.add_override_items[item_name] then
    table.insert(answers, "remotely overriden")
  end
  local item_info = global.reverse_items[item_name]
  if item_info then
    table.insert(answers, "registered: "..serpent.line(item_info))
  end
  if #answers < 0 then
    table.insert(answers, "not registered.")
  end
  local result = "RevEng-Explain "..serpent.line(item_name)..": "..table.concat(answers, ", ")
  player.print(result)
  log(result)
end

lib.add_commands = function()
  commands.add_command(
    "reveng-explain",
    "Tells info about given item name. You can also find stats in a table in the script-output folder.",
    explain)
end

return lib