local S = require("shared")
require("script/utils")
local Lib = require("script/event_lib")
local lib = Lib.new()

local table_frame_name = "af_engraving_table"
local act_engrave = "af-privacy-table-engrave"
local act_engrave_open = "af-privacy-table-engrave-open"
local act_back = "af-privacy-table-main"
local act_copy = "af-privacy-table-copy-key"
local act_merge = "af-privacy-table-merge-keys"
local act_split = "af-privacy-table-split-keys"
local color_error = {0.8, 0.2, 0.2}


local function main_menu(frame)
  frame.clear()
  frame.add{ type="label", caption={"af-privacy.lbl-pick-cmd"} }
  frame.add{ type="button", direction="horizontal", tags={action=act_engrave_open}, caption={"af-privacy.btn-engrave"} }
  frame.add{ type="button", direction="horizontal", tags={action=act_copy}, caption={"af-privacy.btn-copy"} }
  frame.add{ type="button", direction="horizontal", tags={action=act_merge}, caption={"af-privacy.btn-merge"} }
  frame.add{ type="button", direction="horizontal", tags={action=act_split}, caption={"af-privacy.btn-split"} }
end


local function engrave_menu(frame)
  frame.clear()
  frame.add{ type="label", caption={"af-privacy.lbl-name"} }
  frame.add{ type="textfield", name="input_name" }
  frame.input_name.style.minimal_width = 64
  frame.add{ type="label", caption={"af-privacy.lbl-pw"} }
  frame.add{ type="textfield", name="input_pw" }
  frame.input_pw.style.minimal_width = 64
  frame.add{ type="button", direction="horizontal", tags={action=act_engrave}, caption={"af-privacy.btn-engrave"} }
  frame.add{ type="button", direction="horizontal", tags={action=act_back}, caption={"af-privacy.btn-back"} }
end


function do_engrave(player, frame, table_info, entity)
  local name = frame.input_name.text
  local pw = frame.input_pw.text
  if false
    or #pw < 2 or #pw > 64
    or #name < 2 or #name > 32
  then
    player.print({"af-privacy.error-lengths", 2, 32}, color_error)
    return
  end

  local table_keycats = dict_from_keys_array(table_info.keycats, true)
  local inv = entity.get_inventory(defines.inventory.chest)
  local done = 0
  local stack, tag_info

  for i = 1, #inv do
    stack = inv[i]
    if check_raw_key_stack(stack, table_keycats) then
      engrave_key_item(stack, name, pw)
      done = done + 1
    end
  end

  if done > 0 then
    player.print({"af-privacy.engrave-done"})
  else
    player.print({"af-privacy.no-key-to-engrave"})
  end
end


lib:on_event(defines.events.on_gui_opened, function(event)
  local player = game.get_player(event.player_index)
  if event.entity and event.entity.name == S.table_item then
    local anchor = {
      gui=defines.relative_gui_type.container_gui,
      position=defines.relative_gui_position.right,
    }
    local frame = player.gui.relative.add{ type="frame", name=table_frame_name, anchor=anchor, direction="vertical" }
    main_menu(frame)
  end
end)


lib:on_event(defines.events.on_gui_click, function(event)
  local player = game.get_player(event.player_index)
  local action = event.element and event.element.valid and event.element.tags.action
  local entity = player.opened
  if not entity or entity.object_name ~= "LuaEntity" then return end
  local table_info = S.registered_tables[entity.name]
  if not table_info then return end
  local frame = player.gui.relative[table_frame_name]
  if not frame      then return end

  if action == act_engrave then
    do_engrave(player, frame, table_info, entity)

  elseif action == act_back then
    main_menu(frame)

  elseif action == act_engrave_open then
    engrave_menu(frame)

  elseif action == act_copy then
    player.print("Not implemented yet, wait a bit")
    -- TODO: take first key, check it's single, copy its pw to other keys with no tags

  elseif action == act_merge then
    player.print("Not implemented yet, wait a bit")
    -- TODO: take first key to merge other into considering the same key category and max number per keycat, update custom description

  elseif action == act_split then
    player.print("Not implemented yet, wait a bit")
    -- TODO: find a key with multiple pws, split until there is enough space trying to keep item name, update custom descriptions
  end
end)

lib:on_event(defines.events.on_gui_closed, function(event)
  local player = game.get_player(event.player_index)
  if player.gui.relative[table_frame_name] then
    player.gui.relative[table_frame_name].destroy()
  end
end)

return lib