
-- https://lua-api.factorio.com/latest/classes/LuaGuiElement.html

local gui_update_rate = 10

local main_frame_name = "wh40k_titans_supplier_frame"
-- local main_frame_name = "wh40k_titans_main_frame"

local action_toggle_disabler = "titan_supplier_toggle_disabler"


local function remove_supplier_gui_by_player(player)
  if ctrl_data.supplier_gui[player.index] then
    ctrl_data.supplier_gui[player.index].main_frame.destroy()
    ctrl_data.supplier_gui[player.index] = nil
  end
end

function lib_spl.remove_supplier_gui_by_supplier(supplier_info)
  for _, obj in pairs(ctrl_data.supplier_gui) do
    if obj.supplier_info == supplier_info then
      remove_supplier_gui_by_player(obj.player)
    end
  end
end


local function create_supplier_gui(player, supplier_info)
  if ctrl_data.supplier_gui[player.index] then
    if ctrl_data.supplier_gui[player.index].supplier_info == supplier_info then
      -- The required GUI already exists
      return
    else
      -- Some wrong GUI exists
      remove_supplier_gui_by_player(player)
    end
  end

  ctrl_data.by_player[player.index] = ctrl_data.by_player[player.index] or {}
  local player_settings = ctrl_data.by_player[player.index]
  player_settings.guns = player_settings.guns or {}

  local guiobj = {
    player = player,
    supplier_info = supplier_info,
    guns = {},
  }
  ctrl_data.supplier_gui[player.index] = guiobj
  if player.gui.screen[main_frame_name] then
    player.gui.screen[main_frame_name].destroy()
  end
  guiobj.main_frame = player.gui.screen.add{
    type="frame", name=main_frame_name, caption={"WH40k-Titans-gui.supplier-dashboard-title"},
    direction="vertical",
  }
  -- guiobj.main_frame.style.size = {340, 180}
  guiobj.main_frame.style.minimal_width = 200
  guiobj.main_frame.style.maximal_width = 480
  -- guiobj.main_frame.style.minimal_height = 128
  -- guiobj.main_frame.style.maximal_height = 320

  -- guiobj.main_frame.auto_center = true
  player.opened = guiobj.main_frame

  guiobj.main_frame.add{ type="label", name="label_weights" }
  guiobj.main_frame.add{ type="label", name="label_status" }

  guiobj.ammo_table = guiobj.main_frame.add{type="table", name="ammo_table", column_count=#shared.ammo_list, style="filter_slot_table"}
  guiobj.ammo_counter = {}
  guiobj.ammo_disabler = {}

  for _, ammo_name in ipairs(shared.ammo_list) do
    guiobj.ammo_counter[ammo_name] = guiobj.ammo_table.add{
      type="sprite-button", sprite="item/"..ammo_name,
      tooltip=make_titled_text(
        {"item-name."..ammo_name},
        {"item-description."..ammo_name}
      ),
    }
  end
  for _, ammo_name in ipairs(shared.ammo_list) do
    guiobj.ammo_disabler[ammo_name] = guiobj.ammo_table.add{
      type="sprite-button",
      tooltip={"WH40k-Titans-gui.supplier-ammo-filtering"},
      tags={action=action_toggle_disabler, ammo_name=ammo_name},
      -- Sprite is set in the update
    }
  end

end


local function get_crew(supplier_info)
  local crew = {}
  crew[#crew+1] = supplier_info.entity.get_driver()
  crew[#crew+1] = supplier_info.entity.get_passenger()
  return crew
end


local function update_guis()
  for _, guiobj in pairs(ctrl_data.supplier_gui) do
    local supplier_info = guiobj.supplier_info
    if false
      or (not guiobj.player.valid or not guiobj.supplier_info.entity or not guiobj.supplier_info.entity.valid)
      or (not table.contains(list_players(get_crew(guiobj.supplier_info)), guiobj.player))
    then
      remove_supplier_gui_by_player(guiobj.player)
    else

      for _, ammo_name in ipairs(shared.ammo_list) do
        if supplier_info.disabled_ammo[ammo_name] then
          guiobj.ammo_disabler[ammo_name].sprite = "virtual-signal/signal-red"
        else
          guiobj.ammo_disabler[ammo_name].sprite = "virtual-signal/signal-green"
        end

        guiobj.ammo_counter[ammo_name].number = supplier_info.inventory[ammo_name] or 0
      end

      guiobj.main_frame.label_status.caption = guiobj.supplier_info.supplying and {"WH40k-Titans-gui.supplier-state-transferring"} or {"WH40k-Titans-gui.supplier-state-idle"}

      local weight = lib_spl.count_weight(guiobj.supplier_info)
      guiobj.main_frame.label_weights.caption = {
        "WH40k-Titans-gui.supplier-ammo-weight",
        weight, math.floor(100*weight/lib_spl.get_max_weight(guiobj.supplier_info)),
      }

    end
  end
end


lib_spl:on_event(defines.events.on_gui_click, function(event)
  local player = game.get_player(event.player_index)
  local supplier_info = nil
  if ctrl_data.supplier_gui[event.player_index] then
    supplier_info = ctrl_data.supplier_gui[event.player_index].supplier_info
  end
  local action = event.element and event.element.valid and event.element.tags.action

  -- if action == act_main_frame_close then
  --   if player.gui.screen[main_frame_name] and player.gui.screen[main_frame_name].valid then
  --     player.gui.screen[main_frame_name].destroy()
  --     ctrl_data.supplier_gui[event.player_index] = nil
  --   end
  -- else
  if action == action_toggle_disabler then
    supplier_info.disabled_ammo[event.element.tags.ammo_name] = not supplier_info.disabled_ammo[event.element.tags.ammo_name]
  end
end)


lib_spl:on_event(defines.events.on_player_driving_changed_state, function(event)
  local player = game.players[event.player_index]
  if not player.character then return end
  if player.character.vehicle then
    local supplier_info = ctrl_data.supplier_index[player.character.vehicle.unit_number]
    if not supplier_info then return end
    create_supplier_gui(player, supplier_info)
  else
    remove_supplier_gui_by_player(player)
  end
end)


lib_spl:on_nth_tick(gui_update_rate, update_guis)
