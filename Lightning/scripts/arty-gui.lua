require("common")
local mod_gui = require("mod-gui")

local arty_pwr_btn_name = "af_tsl_arty_pwr_btn"
local arty_pwr_open_act = "af-tsl-arty-pwr-open"
local arty_pwr_window_name = "af_tsl_arty_pwr_window"
local arty_pwr_table_name = "af_tsl_arty_pwr_table"
local arty_pwr_str_name = "af_tsl_arty_pwr_strike"
local arty_pwr_bmb_name = "af_tsl_arty_pwr_bombing"
local arty_pwr_save_act = "af-tsl-arty-pwr-save"

function setup_gui_btn(player_index)
  local player = game.get_player(player_index)
  local button_flow = mod_gui.get_button_flow(player)
  if button_flow[arty_pwr_btn_name] == nil then
    local btn = button_flow.add{
      type="sprite-button", name=arty_pwr_btn_name, sprite="tsl-energy-2",
      style=mod_gui.button_style, tags={action=arty_pwr_open_act}
    }
    btn.tooltip = {"tsl.aty-gui-caption"}
  end
end

function update_arty_window_values(player)
  local main_frame = player.gui.screen[arty_pwr_window_name]
  if not main_frame then return end
  main_frame[arty_pwr_table_name][arty_pwr_str_name].text = tostring(get_player_power_level(player, false))
  main_frame[arty_pwr_table_name][arty_pwr_bmb_name].text = tostring(get_player_power_level(player, true))

  local button_flow = mod_gui.get_button_flow(player)
  -- button_flow[arty_pwr_btn_name].sprite = "tsl-energy-"..get_max_force_power_level(player.force.index, false) -- Looks a bit ugly
  button_flow[arty_pwr_btn_name].number = get_player_power_level(player, false)
end

local function create_arty_window(player)
  local main_frame = player.gui.screen.add{
    type="frame", name=arty_pwr_window_name, --caption={"tsl.aty-gui-caption"},
    direction="vertical",
  }
  main_frame.style.size = {320, 128}
  main_frame.auto_center = true
  player.opened = main_frame
  main_frame.focus()
  main_frame.bring_to_front()

  local flowtitle = main_frame.add{ type = "flow", name = "title" }
  local title = flowtitle.add{ type = "label", style = "frame_title", caption={"tsl.aty-gui-caption"} }
  title.drag_target = main_frame
  local pusher = flowtitle.add{ type = "empty-widget", style = "draggable_space_header" }
  pusher.style.vertically_stretchable = true
  pusher.style.horizontally_stretchable = true
  pusher.drag_target = main_frame
  pusher.style.maximal_height = 24
  flowtitle.add{ type="sprite-button", style="frame_action_button", tags={action=arty_pwr_open_act}, sprite="utility/close_white" }

  main_frame.add{ type="label", caption={"tsl.aty-gui-max-lvl", get_max_force_power_level(player.force.index, false)} }

  local el
  local grid = main_frame.add{ type="table", name=arty_pwr_table_name, column_count=3, style="filter_slot_table" }
  -- Row 1
  grid.add{ type="label", caption="Strike" }
  grid.add{ type="label", caption="Bombing" }
  grid.add{ type="empty-widget" }
  -- Row 2
  el = grid.add{ type="textfield", numeric=true, lose_focus_on_confirm=true, name=arty_pwr_str_name }
  el.style.maximal_width = 64
  el = grid.add{ type="textfield", numeric=true, lose_focus_on_confirm=true, name=arty_pwr_bmb_name }
  el.style.maximal_width = 64
  el = grid.add{ type="button", style="confirm_button", caption={"tsl.aty-gui-apply"}, tags={action=arty_pwr_save_act} }
  el.focus()

  update_arty_window_values(player)
end

local function confirm_arty_window(player)
  local main_frame = player.gui.screen[arty_pwr_window_name]
  if main_frame then
    local pwr_str = tonumber(main_frame[arty_pwr_table_name][arty_pwr_str_name].text)
    local pwr_bmb = tonumber(main_frame[arty_pwr_table_name][arty_pwr_bmb_name].text)
    set_attack_level(player.index, pwr_str, false, false)
    set_attack_level(player.index, pwr_bmb, true, false)
    update_arty_window_values(player)
    main_frame.destroy()
  end
end

script.on_event(defines.events.on_gui_click, function(event)
  local player = game.get_player(event.player_index)
  local main_frame = player.gui.screen[arty_pwr_window_name]

  if event.element.tags.action == arty_pwr_open_act then
    if main_frame then
      main_frame.destroy()
      return
    else
      create_arty_window(player)
    end

  elseif event.element.tags.action == arty_pwr_save_act then
    if main_frame then
      confirm_arty_window(player)
      return
    end
  end
end)

script.on_event(defines.events.on_gui_closed, function(event)
  local player = game.get_player(event.player_index)
  if event.element and event.element.name == arty_pwr_window_name then
    confirm_arty_window(player)
  end
end)
