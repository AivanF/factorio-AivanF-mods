local S = require("shared")
local Lib = require("script/event_lib")
local lib = Lib.new()

local table_frame_name = "af_engraving_table"
local act_engrave = "af-privacy-engrave"
local act_copy = "af-privacy-copy-key"
local act_merge = "af-privacy-merge-keys"
local act_split = "af-privacy-split-keys"
local color_error = {0.8, 0.2, 0.2}

function setup_key_description(stack)
  -- TODO: translate everything here
  local tag_info = stack.tags[S.key_tag_name]
  if not tag_info or #tag_info.pws < 1 then
    stack.custom_description = "Empty key"
    return
  end

  if #tag_info.pws > 1 then
    -- TODO: append all the names
    stack.custom_description = "Bunch of "..#tag_info.pws.." keys"
  else
    if tag_info.pws[1].name then
      stack.custom_description = tag_info.pws[1].name
    else
      stack.custom_description = "Untitled key"
    end
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
    -- TODO: translate everything here!
    -- frame.add{ type="label", caption="Pick a command:" }
    -- frame.add{ type="button", direction="horizontal", tags={action=act_copy}, caption="Copy" }
    -- frame.add{ type="button", direction="horizontal", tags={action=act_merge}, caption="Merge" }
    -- frame.add{ type="button", direction="horizontal", tags={action=act_split}, caption="Split" }

    -- TODO: make it a separate window state?
    frame.add{ type="label", caption="Name:" }
    frame.add{ type="textfield", name="input_name" }
    frame.input_name.style.minimal_width = 64
    frame.add{ type="label", caption="Password:" }
    frame.add{ type="textfield", name="input_pw" }
    frame.input_pw.style.minimal_width = 64
    frame.add{ type="button", direction="horizontal", tags={action=act_engrave}, caption="Engrave" }
  end
end)

lib:on_event(defines.events.on_gui_click, function(event)
  local player = game.get_player(event.player_index)
  local action = event.element and event.element.valid and event.element.tags.action
  local entity = player.opened
  if entity.name ~= S.table_item then return end
  local frame = player.gui.relative[table_frame_name]
  if not frame then return end

  -- TODO: consider keycat of the table

  if action == act_engrave then
    local name = frame.input_name.text
    local pw = frame.input_pw.text
    if false
      or #pw < 4 or #pw > 64
      or #name < 4 or #name > 64
    then
      player.print("Name and password need length in range 4:64", color_error) -- TODO: translate
      return
    end

    local done = 0
    local inv = entity.get_inventory(defines.inventory.chest)
    local stack, tag_info

    for i = 1, #inv do
      stack = inv[i]
      if stack.valid_for_read and S.registered_keys[stack.name] then
        tag_info = stack.get_tag(S.key_tag_name)
        if tag_info == nil or #tag_info.pws == 0 then
          stack.set_tag(S.key_tag_name, {pws = {{pw=pw, name=name}}})
          setup_key_description(stack)
          done = done + 1
        end
      end
    end

    if done > 0 then
      player.print("Engraved "..done.." keys!") -- TODO: translate
    else
      player.print("No appropriate keys found to engrave") -- TODO: translate
    end

  elseif action == act_copy then
    -- TODO: take first key, check it's single, copy its pw to other keys with no tags

  elseif action == act_merge then
    -- TODO: take first key to merge other into considering the same key category and max number per keycat, update custom description

  elseif action == act_split then
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