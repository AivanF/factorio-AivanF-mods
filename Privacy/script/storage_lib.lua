S = require("shared")
require("script/utils")
local Lib = require("script/event_lib")
local storage_lib = Lib.new()
storage_classes = {}

color_error = {0.8, 0.2, 0.2}
color_fine = {1, 1, 1}

main_frame_name = "af_privacy"

act_toggle_pw = "af-privacy-toggle-pw"
act_main_frame_close = "af-privacy-close-main"
act_save_keys = "af-privacy-save-keys"

sprite_on  = "virtual-signal/signal-green"
sprite_off = "virtual-signal/signal-grey"


function make_gui_select_key(class_spec, storage_info, player)
    -- TODO: merge keys with the same PW
    local pws = get_player_pws(player, class_spec.accepted_categories)
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
    row.add{ type="button", direction="horizontal", tags={action=act_save_keys}, caption={"af-privacy.btn-lock"} }
    row.add{ type="button", direction="horizontal", tags={action=act_main_frame_close}, caption={"af-privacy.btn-cancel"} }
end


storage_lib:on_event(defines.events.on_gui_click, function(event)
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
      player.gui.screen[main_frame_name].destroy()
      ctrl_data.opened[event.player_index] = nil

      -- TODO: make it working with bank safes too
      storage_info.pws = pws
      player.opened = storage_info.inv

      player.print({"af-privacy.setup-done"})
      storage_info.entity.surface.play_sound{
        path="af-privacy-lock",
        position=storage_info.entity.position,
      }
    else
      player.print({"af-privacy.at-least-1-key"})
      storage_info.entity.surface.play_sound{
        path="af-privacy-locked",
        position=storage_info.entity.position,
      }
    end
  end
end)


storage_lib:on_event(defines.events.on_gui_closed, function(event)
  local player = game.get_player(event.player_index)

  if event.element and event.element.valid and event.element.name == main_frame_name then
    event.element.destroy()
    ctrl_data.opened[event.player_index] = nil
  end

  if event.inventory and event.inventory.mod_owner and event.inventory.mod_owner == S.mod_name then
    local storage_info = ctrl_data.opened[event.player_index]
    if storage_info then
      storage_classes[storage_info.subtype]:closed(storage_info)
    end
    ctrl_data.opened[event.player_index] = nil
  end
end)


storage_lib:on_event(defines.events.on_player_removed, function(event)
  -- TODO: go over all banks, remove event.player_index in each by_player
  -- TODO: go over all personal chests?
end)

return storage_lib