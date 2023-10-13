S = require("shared")
require("script/utils")
local Lib = require("script/event_lib")
local storage_lib = Lib.new()

storage_classes = {}

inv_type_main = "main"
inv_type_pers = "personal"
inv_type_lock = "lockable"

color_error = {0.8, 0.2, 0.2}
color_fine = {1, 1, 1}

main_frame_name = "af_privacy"
locking_frame_name = "af_locking"
extra_title_frame_name = "af_extra_title"

act_toggle_pw = "af-privacy-toggle-pw"
act_main_frame_close = "af-privacy-close-main"
act_save_keys = "af-privacy-save-keys"
act_bank_on = "af-privacy-bank-on"
act_bank_off = "af-privacy-bank-off"
act_bank_open_team = "af-privacy-bank-open-team"
act_bank_open_personal = "af-privacy-bank-open-personal"
act_bank_open_other = "af-privacy-bank-open-other"
act_open_locking = "af-privacy-open-locking"

sprite_on  = "virtual-signal/signal-green"
sprite_off = "virtual-signal/signal-grey"


function open_inv(player, storage_info, caption, sound, inv, inv_type, data)
  ctrl_data.opened[player.name] = { storage_info=storage_info, inv_type=inv_type }
  if data then
    for k, v in pairs(data) do
      ctrl_data.opened[player.name][k] = v
    end
  end

  player.opened = inv
  if sound then
    storage_info.entity.surface.play_sound{
      path=sound,
      position=storage_info.entity.position,
    }
  end

  local anchor = {
    gui=defines.relative_gui_type.script_inventory_gui,
    position=defines.relative_gui_position.top,
  }
  local frame = player.gui.relative.add{ type="frame", name=extra_title_frame_name, anchor=anchor, direction="vertical" }
  frame.add{ type="label", style="frame_title", caption=caption }
end


function make_main_frame(player, caption)
  if player.gui.screen[main_frame_name] then
    player.gui.screen[main_frame_name].destroy()
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
  local title = flowtitle.add{ type="label", style="frame_title", caption=caption }
  title.drag_target = main_frame
  local pusher = flowtitle.add{ type="empty-widget", style="draggable_space_header" }
  pusher.style.vertically_stretchable = true
  pusher.style.horizontally_stretchable = true
  pusher.drag_target = main_frame
  pusher.style.maximal_height = 24
  flowtitle.add{ type="sprite-button", style="frame_action_button", tags={action=act_main_frame_close}, sprite="utility/close_white" }

  return main_frame
end


function add_locking_button(player)
  -- NOTE: ctrl_data.opened[player.name] must be already set with correct inv_type!
  -- and player.opened must be a private inventory
  local anchor = {
    gui=defines.relative_gui_type.script_inventory_gui,
    position=defines.relative_gui_position.right,
  }
  local frame = player.gui.relative.add{ type="frame", name=locking_frame_name, anchor=anchor, direction="vertical" }
  frame.add{ type="button", direction="horizontal", tags={action=act_open_locking}, caption={"af-privacy.btn-lock"} }
end


function add_locked_side(player, storage_or_safe_info)
  local anchor = {
    gui=defines.relative_gui_type.script_inventory_gui,
    position=defines.relative_gui_position.right,
  }
  local frame = player.gui.relative.add{ type="frame", name=locking_frame_name, anchor=anchor, direction="vertical" }
  frame.add{ type="label", name="label", caption={"af-privacy.lbl-locked-with", #storage_or_safe_info.pws} }
  -- TODO: show name if single!
end


function make_gui_select_key(class_spec, storage_info, player)
    -- TODO: generalise it to work with bank safes
    -- TODO: unite keys with the same PW
    local pws = get_player_pws(player, class_spec.accepted_categories)
    if #pws < 1 then
      show_msg(storage_info, player, {"af-privacy.no-key-init-error"}, color_error)
      storage_info.entity.surface.play_sound{
        path="af-privacy-cannot-open",
        position=storage_info.entity.position,
      }
      return
    end

    local main_frame = make_main_frame(player, "Setting lock") -- TODO: translate
    local pane = main_frame.add{ type="scroll-pane", name="scrollable" }
    pane.add{ type="label", name="label", caption={"af-privacy.lbl-select-keys"} }
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
    row.add{ type="button", direction="horizontal", tags={action=act_save_keys}, caption={"af-privacy.btn-lock"} }
    row.add{ type="button", direction="horizontal", tags={action=act_main_frame_close}, caption={"af-privacy.btn-cancel"} }
end


function make_gui_bank_main(class_spec, storage_info, player)
  local main_frame = make_main_frame(player, {"entity-name."..storage_info.entity.name})
  if storage_info.active then
    if class_spec.deactivetable then
      main_frame.add{ type="button", direction="horizontal", tags={action=act_bank_off}, caption={"af-privacy.btn-deactivate"} }
    end
    main_frame.add{ type="label", name="label", caption={"af-privacy.lbl-safe-select"} }

    local pane = main_frame.add{ type="scroll-pane", name="scrollable" }
    pane.style.minimal_width = 256

    local btn, caption
    if storage_info.inv ~= nil then
      btn = pane.add{ type="button", direction="horizontal", tags={action=act_bank_open_team}, caption={"af-privacy.lbl-safe-team"} }
      btn.style.minimal_width = 128
    end
    if storage_info.by_player[player.name] then
      btn = pane.add{ type="button", direction="horizontal", tags={action=act_bank_open_personal}, caption={"af-privacy.lbl-safe-personal"} }
      btn.style.minimal_width = 128
    end
    for i = 1, class_spec.lockables_number do
      caption = {"af-privacy.lbl-safe-other", i}
      if storage_info.by_key[i] and storage_info.by_key[i].pws and #storage_info.by_key[i].pws > 0 then
        caption = {"", caption, " [item="..S.bronze_key_item.."]"}
      end
      btn = pane.add{ type="button", direction="horizontal", tags={action=act_bank_open_other, index=i}, caption=caption }
      btn.style.minimal_width = 128
    end
    -- TODO: in case of single safe present, don't show this window, open the safe immediately; usefule for future collapsing lootboxes
  else
    main_frame.add{ type="button", direction="horizontal", tags={action=act_bank_on}, caption={"af-privacy.btn-activate"} }
  end
end


storage_lib:on_event(defines.events.on_gui_click, function(event)
  local player = game.get_player(event.player_index)
  local action = event.element and event.element.valid and event.element.tags.action
  local player_opened_info = ctrl_data.opened[player.name]
  if not player_opened_info then return end
  local storage_info = player_opened_info.storage_info
  local class_spec = storage_classes[storage_info.subtype]

  if action == act_main_frame_close then
    if player.gui.screen[main_frame_name] and player.gui.screen[main_frame_name].valid then
      player.gui.screen[main_frame_name].destroy()
      ctrl_data.opened[event.player_index] = nil
    end

  elseif action == act_toggle_pw then
    event.element.sprite = (event.element.sprite == sprite_off) and sprite_on or sprite_off

  elseif action == act_bank_on then
    storage_info.active = true
    storage_info.entity.minable = false
    storage_info.entity.surface.play_sound{
      path="af-bank-on",
      position=storage_info.entity.position,
    }
    make_gui_bank_main(class_spec, storage_info, player)

  elseif action == act_bank_off then
    class_spec:inventory_audit(storage_info)
    if storage_info.oc_stacks > 0 then
      player.print({"af-privacy.not-empty-error", storage_info.oc_safes, storage_info.oc_stacks}, color_error)
    else
      storage_info.active = false
      storage_info.entity.minable = true
      storage_info.entity.surface.play_sound{
        path="af-bank-off",
        position=storage_info.entity.position,
      }
      -- Close all open safes
      for other_player_name, other_storage_info in pairs(ctrl_data.opened) do
        if storage_info == other_storage_info then
          local other_player = game.get_player(other_player_name)
          if other_player then
            other_player.opened = nil
          end
          ctrl_data.opened[other_player_name] = nil
        end
      end
      make_gui_bank_main(class_spec, storage_info, player)
    end

  elseif action == act_bank_open_team then
    open_inv(player, storage_info, {"af-privacy.lbl-safe-team"}, "af-privacy-safe", storage_info.inv, inv_type_main)

  elseif action == act_bank_open_personal then
    open_inv(player, storage_info, {"af-privacy.lbl-safe-personal"}, "af-privacy-safe", storage_info.by_player[player.name], inv_type_pers)

  elseif action == act_bank_open_other then
    -- TODO: optionally create the safe
    local lockable_index = event.element.tags.index

    local safe_info = storage_info.by_key[lockable_index]
    if not safe_info then
      storage_info.by_key[lockable_index] = {
        name = nil,
        pws = {},
        inv = game.create_inventory(class_spec.new_size),
        index = lockable_index,
      }
      safe_info = storage_info.by_key[lockable_index]
    end

    if #safe_info.pws > 0 then
      if check_player_has_keys(player, safe_info.pws, class_spec.accepted_categories) then
        open_inv(player, storage_info, {"af-privacy.lbl-safe-other", lockable_index}, "af-privacy-safe", safe_info.inv, inv_type_lock, {index=lockable_index})
        add_locked_side(player, safe_info)
        storage_info.entity.surface.play_sound{
          path="af-privacy-safe",
          position=storage_info.entity.position,
        }
      else
        show_msg(storage_info, player, {"af-privacy.no-key-error"}, color_error)
        storage_info.entity.surface.play_sound{
          path="af-privacy-cannot-open",
          position=storage_info.entity.position,
        }
      end

    else
      open_inv(player, storage_info, {"af-privacy.lbl-safe-other", lockable_index}, "af-open-unlocked", safe_info.inv, inv_type_lock, {index=lockable_index})
      add_locking_button(player)
    end

  elseif action == act_open_locking then
    make_gui_select_key(class_spec, storage_info, player)

  elseif action == act_save_keys then
    local pws = {}

    if not player.gui.screen[main_frame_name] or not player.gui.screen[main_frame_name].valid then return end
    local scrollable = player.gui.screen[main_frame_name].scrollable
    for _, row in pairs(scrollable.children) do
      if row.name:find("row", 1, true) then
        if row.toggler.sprite == sprite_on then
          pws[#pws+1] = {pw=row.toggler.tags.pw, name=row.toggler.tags.name, item=row.toggler.tags.item}
        end
      end
    end

    if #pws > 5 then
      show_msg(storage_info, player, {"af-privacy.too-many-keys-error", 5}, color_error)
      return
    end
    if #pws > 0 then
      player.gui.screen[main_frame_name].destroy()

      if player_opened_info.inv_type == inv_type_lock then
        local safe_info = storage_info.by_key[player_opened_info.index]
        safe_info.pws = pws
        open_inv(player, storage_info, {"af-privacy.lbl-safe-other", player_opened_info.index}, nil, safe_info.inv, inv_type_lock, {index=player_opened_info.index})
      else
        storage_info.pws = pws
        open_inv(player, storage_info, {"entity-name."..storage_info.entity.name}, "af-privacy-lock", storage_info.inv, inv_type_main)
      end

      player.print({"af-privacy.setup-done"})
      storage_info.entity.surface.play_sound{
        path="af-privacy-lock",
        position=storage_info.entity.position,
      }
    else
      player.print({"af-privacy.at-least-1-key"})
      storage_info.entity.surface.play_sound{
        path="af-privacy-cannot-open",
        position=storage_info.entity.position,
      }
    end
  end
end)


storage_lib:on_event(defines.events.on_gui_closed, function(event)
  if event.element and event.element.valid and event.element.name == main_frame_name then
    event.element.destroy()
    ctrl_data.opened[event.player_index] = nil
  end

  local player = game.get_player(event.player_index)
  if player.gui.relative[locking_frame_name] then
    player.gui.relative[locking_frame_name].destroy()
  end

  local player = game.get_player(event.player_index)
  if player.gui.relative[extra_title_frame_name] then
    player.gui.relative[extra_title_frame_name].destroy()
  end

  local player_opened_info = ctrl_data.opened[event.player_index]
  if not player_opened_info then return end
  local storage_info = player_opened_info.storage_info
  local class_spec = storage_classes[storage_info.subtype]

  if event.inventory and event.inventory.mod_owner and event.inventory.mod_owner == S.mod_name then
    class_spec:closed(storage_info)
    ctrl_data.opened[event.player_index] = nil
    if class_spec.has_main_menu then
      -- Open main menu if it's a bank
      class_spec:try_open(storage_info, player)
    end
  end
end)


storage_lib:on_event(defines.events.on_player_removed, function(event)
  -- TODO: go over all banks, remove event.player_index in each by_player
  -- TODO: go over all personal chests?
end)

return storage_lib