local S = require("shared")
local Lib = require("script/event_lib")

local classes = {}

local function make_inv(size)
  return game.create_inventory(size)
end

function default_init(class_lib, storage_info)
  storage_info.inv = make_inv(class_lib.size)
  storage_info.key_categories = {S.keycat_m}
end

function default_destroy(class_lib, storage_info)
  -- TODO: check and possibly output leftovers
  storage_info.inv.destroy()
end

function default_closed(class_lib, storage_info)
  storage_info.entity.minable = storage_info.inv.is_empty()
end

-- tags[S.key_tag_name] => tag_info: {pws: list of pw_info, cat: str?}
-- pw_info: {name: loc-str, pw: str, item: original item-name}

function check_player_has_keys(player, required_pws, accepted_categories)
  local pinv = player.get_inventory(defines.inventory.character_main)
  local stack, tag
  local missing = {}
  for _, pw_info in pairs(required_pws) do
    missing[pw_info.pw] = true
  end
  local accepted_categories_dict = {}
  for _, cat in pairs(accepted_categories) do
    accepted_categories_dict[cat] = true
  end

  for i = 1, #pinv do
    stack = pinv[i]
    if stack.valid_for_read then
      tag = stack.type == "item-with-tags" and stack.get_tag(S.key_tag_name)
      if tag and accepted_categories_dict[tag.cat or S.registered_keys[stack.name]] then
        for _, pw_info in pairs(tag.pws) do
          missing[pw_info.pw or "-"] = nil
        end
      end
    end
  end

  for pw, _ in pairs(missing) do
    return false
  end
  return true
end


function get_player_pws(player, accepted_categories)
  local pinv = player.get_inventory(defines.inventory.character_main)
  local stack, tag
  local accepted_categories_dict = {}
  for _, cat in pairs(accepted_categories) do
    accepted_categories_dict[cat] = true
  end
  local pws = {}

  for i = 1, #pinv do
    stack = pinv[i]
    if stack.valid_for_read then
      tag = stack.type == "item-with-tags" and stack.get_tag(S.key_tag_name)
      if tag and accepted_categories_dict[tag.cat or S.registered_keys[stack.name]] then
        for _, pw_info in pairs(tag.pws) do
          pws[#pws+1] = pw_info
          pw_info.item = pw_info.item or stack.name
        end
      end
    end
  end
  return pws
end


local color_error = {0.8, 0.2, 0.2}
local color_fine = {1, 1, 1}

local function show_msg(storage_info, player, text, color)
  storage_info.entity.surface.create_entity{
    position = storage_info.entity.position,
    name = "flying-text",
    text = text,
    color = color,
    render_player_index = player.index,
  }
end


local main_frame_name = "af_privacy"

local act_toggle_pw = "af-privacy-toggle-pw"
local act_main_frame_close = "af-privacy-close-main"
local act_save_keys = "af-privacy-save-keys"

local sprite_on  = "virtual-signal/signal-green"
local sprite_off = "virtual-signal/signal-grey"

function make_gui_select_key(class_lib, storage_info, player)
    local pws = get_player_pws(player, class_lib.accepted_categories)
    if #pws < 1 then
      show_msg(storage_info, player, {"af-privacy.no-key-init-error"}, color_error)
      storage_info.entity.surface.play_sound{
        path="af-privacy-locked",
        position=storage_info.entity.position,
      }
      return
    end

    local main_frame = player.gui.screen.add{ type="frame", name=main_frame_name, direction="vertical", }
    main_frame.style.minimal_width = 256
    main_frame.style.maximal_width = 640
    main_frame.style.minimal_height = 128
    main_frame.style.maximal_height = 480
  
    main_frame.auto_center = true
    player.opened = main_frame
    main_frame.focus()
    main_frame.bring_to_front()

    local flowtitle = main_frame.add{ type="flow", name="title" }
    local title = flowtitle.add{ type="label", style="frame_title", caption="Setting chest's lock" } -- TODO: translate
    title.drag_target = main_frame
    local pusher = flowtitle.add{ type="empty-widget", style="draggable_space_header" }
    pusher.style.vertically_stretchable = true
    pusher.style.horizontally_stretchable = true
    pusher.drag_target = main_frame
    pusher.style.maximal_height = 24
    flowtitle.add{ type="sprite-button", style="frame_action_button", tags={action=act_main_frame_close}, sprite="utility/close_white" }

    local pane = main_frame.add{ type="scroll-pane", name="scrollable" }
    pane.add{ type="label", name="label", caption="Choose keys to lock the chest:" } -- TODO: translate
    local row

    for i, pw_info in pairs(pws) do
      row = pane.add{ type="frame", name="row"..i, direction="horizontal", }
      row.add{
        type="sprite-button", name="toggler", sprite=sprite_off,
        tags={action=act_toggle_pw, name=pw_info.name, pw=pw_info.pw, item=pw_info.item},
      }
      row.add{
        type="sprite-button", sprite="item/"..pw_info.item,
      }
      row.add{ type="label", name="label", caption=pw_info.name or "untitled" }
    end

    row = pane.add{ type="frame", direction="horizontal", }
    row.add{ type="button", direction="horizontal", tags={action=act_save_keys}, caption="Save" }
    row.add{ type="button", direction="horizontal", tags={action=act_main_frame_close}, caption="Cancel" }
end


----------- 1. Key Locked
local class_lib = Lib.new()
classes[S.sub_keylocked] = class_lib

class_lib.size = S.small_storage_size
class_lib.accepted_categories = {S.keycat_mech}

class_lib.init = default_init
class_lib.destroy = default_destroy
class_lib.closed = default_closed

function class_lib.try_open(class_lib, storage_info, player)
  if storage_info.pws then
    if check_player_has_keys(player, storage_info.pws, class_lib.accepted_categories) then
      ctrl_data.opened[player.index] = { storage_info=storage_info }
      player.opened = storage_info.inv
      storage_info.entity.surface.play_sound{
        path="af-privacy-lock",
        position=storage_info.entity.position,
      }
    else
      show_msg(storage_info, player, {"af-privacy.no-key-error"}, color_error)
      storage_info.entity.surface.play_sound{
        path="af-privacy-locked",
        position=storage_info.entity.position,
      }
    end

  else
    ctrl_data.opened[player.index] = { storage_info=storage_info }
    make_gui_select_key(class_lib, storage_info, player)
  end
end


class_lib:on_event(defines.events.on_gui_click, function(event)
  local player = game.get_player(event.player_index)
  local action = event.element and event.element.valid and event.element.tags.action
  local storage_info = ctrl_data.opened[player.index]

  if action == act_main_frame_close then
    if player.gui.screen[main_frame_name] and player.gui.screen[main_frame_name].valid then
      player.gui.screen[main_frame_name].destroy()
      ctrl_data.opened[event.player_index] = nil
    end

  elseif action == act_toggle_pw then
    event.element.sprite = (event.element.sprite == sprite_off) and sprite_on or sprite_off

  elseif action == act_save_keys then
    local pws = {}

    local storage_info = ctrl_data.opened[event.player_index]
    if not storage_info then return end
    if not player.gui.screen[main_frame_name] or not player.gui.screen[main_frame_name].valid then return end
    local scrollable = player.gui.screen[main_frame_name].scrollable
    for _, row in pairs(scrollable.children) do
      if row.name:find("row", 1, true) then
        if row.toggler.sprite == sprite_on then
          pws[#pws+1] = {pw=row.toggler.tags.pw, name=row.toggler.tags.name, item=row.toggler.tags.item}
        end
      end
    end

    if #pws > 0 then
      storage_info.pws = pws
      player.gui.screen[main_frame_name].destroy()
      ctrl_data.opened[event.player_index] = nil
      player.print({"af-privacy.setup-done"})
      storage_info.entity.surface.play_sound{
        path="af-privacy-lock",
        position=storage_info.entity.position,
      }
      player.opened = storage_info.inv
    else
      player.print({"af-privacy.at-least-1-key"})
      storage_info.entity.surface.play_sound{
        path="af-privacy-locked",
        position=storage_info.entity.position,
      }
    end
  end
end)


class_lib:on_event(defines.events.on_gui_closed, function(event)
  local player = game.get_player(event.player_index)

  if event.element and event.element.valid and event.element.name == main_frame_name then
    event.element.destroy()
    ctrl_data.opened[event.player_index] = nil
  end

  if event.inventory and event.inventory.mod_owner and event.inventory.mod_owner == S.mod_name then
    local storage_info = ctrl_data.opened[event.player_index]
    if storage_info then
      classes[storage_info.subtype]:closed(storage_info)
    end
    ctrl_data.opened[event.player_index] = nil
  end
end)


----------- 2. Personal
local class_lib = Lib.new()
classes[S.sub_personal] = class_lib

class_lib.size = S.small_storage_size

class_lib.init = default_init
class_lib.destroy = default_destroy
class_lib.closed = default_closed

function class_lib.try_open(class_lib, storage_info, player)
  if false
    or storage_info.entity.last_user == nil
    or storage_info.entity.last_user == player
  then
    ctrl_data.opened[player.index] = { storage_info=storage_info }
    player.opened = storage_info.inv
    storage_info.entity.surface.play_sound{
      path="af-privacy-lock",
      position=storage_info.entity.position,
    }
  else
    show_msg(storage_info, player, {"af-privacy.no-access-error"}, color_error)
    storage_info.entity.surface.play_sound{
      path="af-privacy-locked",
      position=storage_info.entity.position,
    }
  end
end


----------- 3. Team
local class_lib = Lib.new()
-- classes[S.sub_team] = class_lib -- Seems like this storage isn't needed

class_lib.size = S.big_storage_size

class_lib.init = default_init
class_lib.destroy = default_destroy
class_lib.closed = default_closed

function class_lib.try_open(class_lib, storage_info, player)
  if false
    or storage_info.entity.force == player.force
    or storage_info.entity.force.get_friend(player.force)
  then
    ctrl_data.opened[player.index] = { storage_info=storage_info }
    player.opened = storage_info.inv
    storage_info.entity.surface.play_sound{
      path="af-privacy-lock",
      position=storage_info.entity.position,
    }
  else
    show_msg(storage_info, player, {"af-privacy.no-access-error"}, color_error)
    storage_info.entity.surface.play_sound{
      path="af-privacy-locked",
      position=storage_info.entity.position,
    }
  end
end


----------- 4. Bank
local class_lib = Lib.new()
classes[S.sub_bank] = class_lib

class_lib.size = S.big_storage_size
class_lib.accepted_categories = {S.keycat_mech, S.keycat_el}

function class_lib.init(class_lib, storage_info, player)
  default_init(class_lib, storage_info, player)
  storage_info.key_categories = {S.keycat_m, S.keycat_el}
  storage_info.by_player = {}
  storage_info.by_key = {}
  storage_info.stacks = 0
  storage_info.entity.minable = false
end

function class_lib.try_open(class_lib, storage_info, player)
  if false
    or storage_info.entity.force == player.force
    or storage_info.entity.force.get_friend(player.force)
  then
    if storage_info.entity.energy / storage_info.entity.electric_buffer_size > 0.9 then

      if not storage_info.by_player[player.index] then
        storage_info.by_player[player.index] = make_inv(S.small_storage_size)
      end

      -- TODO: make GUI to choose between safes!
      ctrl_data.opened[player.index] = { storage_info=storage_info }
      player.opened = storage_info.by_player[player.index]
      storage_info.entity.surface.play_sound{
        path="af-privacy-safe",
        position=storage_info.entity.position,
      }

    else
      show_msg(storage_info, player, {"af-privacy.no-energy-error"}, color_error)
      storage_info.entity.surface.play_sound{
        path="af-privacy-locked",
        position=storage_info.entity.position,
      }
    end
  end
end

function class_lib.destroy(class_lib, storage_info, player)
  default_destroy(class_lib, storage_info, player)
  for player_index, inv in pairs(storage_info.by_player) do
    inv.destroy()
  end
  for _, safe_info in pairs(storage_info.by_key) do
    safe_info.inv.destroy()
  end
end

function class_lib.closed(class_lib, storage_info, player)
  -- Pass
end

class_lib:on_event(defines.events.on_player_removed, function(event)
  -- TODO: go over all banks, remove event.player_index in each by_player
  -- TODO: go over all personal chests?
end)


return classes