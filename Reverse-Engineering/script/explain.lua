require("utils")
require("script.worth")
local Lib = require("event_lib")
local lib = Lib.new()

local main_frame_name = "reverse_lab_worth"
local act_main_frame_close = "af-reverse-lab-frame-close"
local act_set_item = "af-reverse-lab-set-item"

local function explain(cmd)
  local player = game.get_player(cmd.player_index)
  local item_name = cmd.parameter
  local answers = {}
  if ignore_item[item_name] then
    table.insert(answers, "builtinly ignored")
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

local function gui_create(player, toggle)
  if player.gui.screen[main_frame_name] then
    player.gui.screen[main_frame_name].destroy()
    if toggle then return end
  end

  local main_frame = player.gui.screen.add{ type="frame", name=main_frame_name, direction="vertical", }
  main_frame.style.minimal_width = 256
  main_frame.style.maximal_width = 640
  main_frame.style.minimal_height = 128
  main_frame.style.maximal_height = 320

  main_frame.auto_center = true
  player.opened = main_frame
  main_frame.focus()
  main_frame.bring_to_front()

  local flowtitle = main_frame.add{ type="flow", name="title" }
  local title = flowtitle.add{ type="label", style="frame_title", caption={"af-reverse-lab.see-worth-title"} }
  title.drag_target = main_frame
  local pusher = flowtitle.add{ type="empty-widget", style="draggable_space_header" }
  pusher.style.vertically_stretchable = true
  pusher.style.horizontally_stretchable = true
  pusher.drag_target = main_frame
  pusher.style.maximal_height = 24
  flowtitle.add{ type="sprite-button", style="frame_action_button", tags={action=act_main_frame_close}, sprite="utility/close_white" }

  main_frame.add{ type="flow", name="input_line", direction="horizontal" }
  main_frame.input_line.add{ type="choose-elem-button", elem_type="item", tags={action=act_set_item}, name="selector" }
  main_frame.input_line.add{ type="label", name="title", caption="" }

  main_frame.add{ type="label", name="status", caption="" }
  main_frame.add{ type="flow", name="packs_line", direction="horizontal" }
end

local function gui_explain(player, item_name)
  local main_frame = player.gui.screen[main_frame_name]
  if not main_frame_name then return end
  
  main_frame.packs_line.clear()
  main_frame.input_line.title.caption = {"?", {"item-name."..item_name}, {"entity-name."..item_name}, ""}
  main_frame.status.caption = ""

  local status = {"af-reverse-lab.useless"}
  local ok = false
  
  if ignore_item[item_name] then
    -- status = "builtinly ignored"
  elseif global.add_ignore_items[item_name] then
    -- status = "remotely ignored"
  elseif global.scipacks[item_name] then
    status = {"af-reverse-lab.a-science-pack"}
  elseif global.add_override_items[item_name] then
    status = "remotely valued"
    ok = true
  elseif global.reverse_items[item_name] then
    status = "automatically valued"
    ok = true
  end
  main_frame.status.caption = status

  if ok then
    local item_info = global.add_override_items[item_name] or global.reverse_items[item_name]
    main_frame.status.caption = {
      "af-reverse-lab.see-worth-info",
      -- string.format("%.0f", item_info.price),
      string.format("%.0f%%", item_info.prob*100),
      item_info.need,
    }
    for _, pack_name in pairs(item_info.ingredients) do
      main_frame.packs_line.add{
        type="sprite-button", sprite=("item/"..pack_name),
        tooltip={"item-name."..pack_name},
      }
    end
  end
end

lib:on_event(defines.events.on_gui_closed, function(event)
  local player = game.get_player(event.player_index)
  if event.element and event.element.name == main_frame_name then
    event.element.destroy()
  end
end)

lib:on_event(defines.events.on_gui_click, function(event)
  local player = game.get_player(event.player_index)
  if event.element.tags.action == act_main_frame_close then
    if player.gui.screen[main_frame_name] then
      player.gui.screen[main_frame_name].destroy()
    end
  end
end)

lib:on_event(defines.events.on_gui_elem_changed, function(event)
  local player = game.get_player(event.player_index)
  if event.element.tags.action == act_set_item then
    gui_explain(player, event.element.elem_value)
  end
end)

lib:on_event(defines.events.on_lua_shortcut, function (event)
  local player = game.get_player(event.player_index)
  if event.prototype_name == "af-reverse-lab-worth" then
    gui_create(player, toggle)
  end
end)

return lib