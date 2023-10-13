local S = require("shared")
require("script/utils")
local Lib = require("script/event_lib")
local lib = Lib.new()

local table_frame_name = "af_engraving_table"
local act_info ="af-privacy-table-key-info"
local act_engrave = "af-privacy-table-engrave"
local act_engrave_open = "af-privacy-table-engrave-open"
local act_back = "af-privacy-table-main"
local act_copy = "af-privacy-table-copy-key"
local act_merge = "af-privacy-table-merge-keys"
local act_split = "af-privacy-table-split-keys"
local act_clean = "af-privacy-table-clean-keys"
local color_error = {0.8, 0.2, 0.2}


local function main_menu(frame)
  frame.clear()
  frame.add{ type="label", caption={"af-privacy.lbl-pick-cmd"} }

  if settings.global["af-privacy-debug"].value then
  frame.add{ type="button", direction="horizontal", tags={action=act_info}, caption="Info" }
  end
  frame.add{ type="button", direction="horizontal", tags={action=act_engrave_open}, caption={"af-privacy.btn-engrave"} }
  frame.add{ type="button", direction="horizontal", tags={action=act_copy}, caption={"af-privacy.btn-copy"} }
  frame.add{ type="button", direction="horizontal", tags={action=act_merge}, caption={"af-privacy.btn-merge"} }
  frame.add{ type="button", direction="horizontal", tags={action=act_split}, caption={"af-privacy.btn-split"} }
  frame.add{ type="button", direction="horizontal", tags={action=act_clean}, caption={"af-privacy.btn-clean"} }
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


-- TODO: make these function work without player/frame/table_info/entity, to be easily used as API

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
  local stack

  for i = 1, #inv do
    stack = inv[i]
    if check_raw_key_stack(stack, table_keycats) then
      pw = af_simple_hash(pw)
      engrave_key_item(stack, name, pw)
      done = done + 1
    end
  end

  if done > 0 then
    player.print({"af-privacy.engrave-done", done})
  else
    player.print({"af-privacy.no-key-to-engrave"})
  end
end


function do_copy(player, frame, table_info, entity)
    local table_keycats = dict_from_keys_array(table_info.keycats, true)
    local inv = entity.get_inventory(defines.inventory.chest)
    local stack1 = inv[1]
    local tag_info1 = get_ready_key_stack_info(stack1, table_keycats)
    if not tag_info1 then
      player.print("af-privacy.no-suitable-to-copy", color_error)
      return
    end
    if #tag_info1.pws ~= 1 then
      player.print({"af-privacy.not-single-copy-key"}, color_error)
      return
    end
    local name = tag_info1.pws[1].name
    local pw   = tag_info1.pws[1].pw
    local done = 0
    local stack2
    for i = 2, #inv do
      stack2 = inv[i]
      if check_raw_key_stack(stack2, table_keycats) then
        engrave_key_item(stack2, name, pw)
        done = done + 1
      end
    end
    if done > 0 then
      player.print({"af-privacy.copy-done", done})
    else
      player.print({"af-privacy.copy-nothing"})
    end
end


function _can_merge(stack1, tag_info1, stack2, tag_info2)
  ----------- Items must be an already validated shaped keys
  -- Check keycat is the same
  local keycat1 = get_key_category(stack1, tag_info1)
  local keycat2 = get_key_category(stack2, tag_info2)
  if keycat1 ~= keycat2 then return false end
  -- Check item number is enough
  if stack2.count < stack1.count then return false end
  -- Check total number is allowed to unite
  local max_merge = (S.registered_keycats[keycat1] and S.registered_keycats[keycat1].max_merge) or 1
  if #tag_info1.pws + #tag_info2.pws > max_merge then return false end
  -- Check names don't overlap
  local names_set = {}
  for _, pw_info in pairs(tag_info1.pws) do
    names_set[pw_info.name or "-"] = true
  end
  for _, pw_info in pairs(tag_info2.pws) do
    if pw_info.name and names_set[pw_info.name] then
      return false
    end
  end
  return true
end

function _perform_merge(stack1, tag_info1, stack2, tag_info2)
  for _, pw_info in pairs(tag_info2.pws) do
    if not pw_info.item then
      pw_info.item = stack2.name
    end
    table.insert(tag_info1.pws, pw_info)
  end
  stack2.count = stack2.count - stack1.count
end


function do_merge(player, frame, table_info, entity)
    -- TODO: maybe mechanical keys should be merged into a separate bunch object?
    local table_keycats = dict_from_keys_array(table_info.keycats, true)
    local inv = entity.get_inventory(defines.inventory.chest)
    local stack1 = inv[1]
    local tag_info1 = get_ready_key_stack_info(stack1, table_keycats)
    if not tag_info1 then
      player.print({"af-privacy.no-suitable-to-merge"}, color_error)
      return
    end
    if #tag_info1.pws < 1 then
      player.print({"af-privacy.no-suitable-to-merge"}, color_error)
      return
    end
    local stack2, tag_info2
    local key_number = 0
    for i = 2, #inv do
      stack2 = inv[i]
      tag_info2 = get_ready_key_stack_info(stack2, table_keycats)
      if tag_info2 then
        if _can_merge(stack1, tag_info1, stack2, tag_info2) then
          _perform_merge(stack1, tag_info1, stack2, tag_info2)
          key_number = key_number + #tag_info2.pws
        end
      end
    end
    if key_number > 0 then
      stack1.set_tag(S.key_tag_name, tag_info1)
      setup_key_description(stack1)
      player.print({"af-privacy.merge-done", #tag_info1.pws})
    else
      player.print({"af-privacy.merge-nothing"})
    end
end


function do_split(player, frame, table_info, entity)
    local table_keycats = dict_from_keys_array(table_info.keycats, true)
    local inv = entity.get_inventory(defines.inventory.chest)
    local stack1 = inv[1]
    local tag_info1 = get_ready_key_stack_info(stack1, table_keycats)
    if not tag_info1 then
      player.print({"af-privacy.no-suitable-to-split"}, color_error)
      return
    end
    if #tag_info1.pws < 2 then
      player.print({"af-privacy.no-suitable-to-split"}, color_error)
      return
    end
    local keycat = get_key_category(stack1, tag_info1)
    local done = 0
    local left = false
    local stack2, pw_info, new_item
    for i = #tag_info1.pws, 2, -1 do
      --[[
      TODO:
      Try to find and merge into existing stack?    inv.find_item_stack(item)
      But the same item name can have diff tags, the method doesn't check this,
      and custom search is a bad thing...
      ]]--
      stack2, _ = inv.find_empty_stack()
      if stack2 then
        pw_info = tag_info1.pws[i]
        stack2.set_stack({
          name  = pw_info.item or stack1.name,
          count = stack1.count,
          tags  = {
            [S.key_tag_name] = {
              pws = {
                {
                  pw   = pw_info.pw,
                  name = pw_info.name,
                }
              },
              cat = keycat,
            }
          }
        })
        setup_key_description(stack2)
        tag_info1.pws[i] = nil
        done = done + 1
      else
        left = true
        break
      end
    end
    if done > 0 then
      stack1.set_tag(S.key_tag_name, tag_info1)
      setup_key_description(stack1)
      player.print({"af-privacy.split-done", done})
    end
    if left then
      player.print({"af-privacy.split-no-space"}, color_error)
    end
end


function do_clean(player, frame, table_info, entity)
  local table_keycats = dict_from_keys_array(table_info.keycats, true)
  local inv = entity.get_inventory(defines.inventory.chest)
  local done = 0
  local stack, tag_info
  for i = 1, #inv do
    stack = inv[i]
    tag_info = get_ready_key_stack_info(stack, table_keycats)
    if tag_info and #tag_info.pws == 1 then
      stack.remove_tag(S.key_tag_name)
      setup_key_description(stack)
      done = done + 1
    end
  end
  if done > 0 then
    player.print({"af-privacy.clean-done", done + 1})
  else
    player.print({"af-privacy.no-suitable-to-clean"}, color_error)
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
  local table_keycats = dict_from_keys_array(table_info.keycats, true)
  local inv = entity.get_inventory(defines.inventory.chest)

  if action == act_info then
    local stack = inv[1]
    local tag_info = get_ready_key_stack_info(stack, table_keycats)
    player.print(stack.name..": "..serpent.block(tag_info))

  elseif action == act_engrave then
    do_engrave(player, frame, table_info, entity)

  elseif action == act_back then
    main_menu(frame)

  elseif action == act_engrave_open then
    engrave_menu(frame)

  elseif action == act_copy then
    do_copy(player, frame, table_info, entity)

  elseif action == act_merge then
    do_merge(player, frame, table_info, entity)

  elseif action == act_split then
    do_split(player, frame, table_info, entity)

  elseif action == act_clean then
    do_clean(player, frame, table_info, entity)

  end
end)

lib:on_event(defines.events.on_gui_closed, function(event)
  local player = game.get_player(event.player_index)
  if player.gui.relative[table_frame_name] then
    player.gui.relative[table_frame_name].destroy()
  end
end)

return lib