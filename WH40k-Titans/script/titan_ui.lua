local lib_ruins = require("script/ruins")

-- https://lua-api.factorio.com/latest/classes/LuaGuiElement.html

local gui_update_rate = 9
local main_frame_name = "wh40k_titans_main_frame"
local action_toggle_ammo_count = "titan_toggle_ammo_count"
local action_toggle_gun_mod = "titan_toggle_gun_mod"
local action_zoom_out = "titan_zoom_out"


local function remove_titan_gui_by_player(player)
  if ctrl_data.titan_gui[player.index] then
    ctrl_data.titan_gui[player.index].main_frame.destroy()
    ctrl_data.titan_gui[player.index] = nil
  end
end


function  lib_ttn.remove_titan_gui_by_titan(titan_info)
  for _, obj in pairs(ctrl_data.titan_gui) do
    if obj.titan_info == titan_info then
      remove_titan_gui_by_player(obj.player)
    end
  end
end


local function create_titan_gui(player, titan_info)
  if ctrl_data.titan_gui[player.index] then
    if ctrl_data.titan_gui[player.index].titan_info == titan_info then
      -- The required GUI already exists
      return
    else
      -- Some wrong GUI exists
      remove_titan_gui_by_player(player)
    end
  end

  ctrl_data.by_player[player.index] = ctrl_data.by_player[player.index] or {}
  local player_settings = ctrl_data.by_player[player.index]
  player_settings.guns = player_settings.guns or {}

  local guiobj = {
    player = player,
    titan_info = titan_info,
    guns = {},
  }
  ctrl_data.titan_gui[player.index] = guiobj
  if player.gui.screen[main_frame_name] then
    player.gui.screen[main_frame_name].destroy()
  end
  guiobj.main_frame = player.gui.screen.add{
    type="frame", name=main_frame_name, caption={"WH40k-Titans-gui.titan-dashboard-title"},
    direction="horizontal",
  }
  -- guiobj.main_frame.style.size = {340, 180}
  guiobj.main_frame.style.minimal_width = 200
  guiobj.main_frame.style.maximal_width = 480
  -- guiobj.main_frame.style.minimal_height = 128
  -- guiobj.main_frame.style.maximal_height = 320

  -- guiobj.main_frame.auto_center = true
  player.opened = guiobj.main_frame

  guiobj.weapon_table = guiobj.main_frame.add{type="table", name="weapon_table", column_count=#titan_info.guns, style="filter_slot_table"}
  -- guiobj.weapon_table.clear()
  for k, cannon in pairs(titan_info.guns) do
    if not player_settings.guns[k] then
      player_settings.guns[k] = {mode = math.ceil(k/2)}
    end
    guiobj.guns[k] = {}
    guiobj.guns[k].img = guiobj.weapon_table.add{
      type="sprite-button", sprite=("recipe/"..shared.mod_prefix..cannon.name),
      tooltip=make_titled_text(
        {"item-name."..shared.mod_prefix..cannon.name},
        shared.get_weapon_descr(shared.weapons[cannon.name])
      ),
      show_percent_for_small_numbers=true,
    }
  end
  for k, cannon in pairs(titan_info.guns) do
    if shared.weapons[cannon.name].ammo then
      guiobj.guns[k].ammo = guiobj.weapon_table.add{
        type="sprite-button", sprite=("item/"..shared.weapons[cannon.name].ammo),
        tooltip={"item-name."..shared.weapons[cannon.name].ammo},
        -- show_percent_for_small_numbers=true,
        tags={action=action_toggle_ammo_count},
      }
    else
      guiobj.guns[k].ammo = guiobj.weapon_table.add{
        type="sprite-button", sprite="virtual-signal/signal-red",
        -- tooltip={"item-name."..shared.weapons[cannon.name].ammo}, -- TODO: show "no ammo usage"
      }
    end
  end
  for k, cannon in pairs(titan_info.guns) do
    guiobj.guns[k].mode = guiobj.weapon_table.add{
      type="sprite-button", tags={action=action_toggle_gun_mod, index=k},
      -- Sprite is set in the update
    }
  end

  guiobj.titan_info_table = guiobj.main_frame.add{type="table", name="titan_info_table", column_count=1, style="filter_slot_table"}
  guiobj.titan_info_table.add{
    type="sprite-button", sprite="item/radar",
    tooltip={"WH40k-Titans-gui.zoom-out"},
    tags={action=action_zoom_out},
  }
  guiobj.health = guiobj.titan_info_table.add{
    type="sprite-button", sprite="item/"..shared.frame_part,
    tooltip={"WH40k-Titans-gui.health"},
    tags={action=action_toggle_ammo_count},
  }
  guiobj.void_shield = guiobj.titan_info_table.add{
    type="sprite-button", sprite="item/"..shared.void_shield,
    tooltip={"WH40k-Titans-gui.vs-value"},
    tags={action=action_toggle_ammo_count},
  }
end


lib_ttn:on_event(defines.events.on_player_driving_changed_state, function(event)
  local player = game.players[event.player_index]
  if not player.character then return end
  if player.character.vehicle then
    local titan_info = ctrl_data.titans[player.character.vehicle.unit_number]
    if not titan_info then return end

    create_titan_gui(player, titan_info)
  else
    remove_titan_gui_by_player(player)
  end
end)


local function update_guis()
  local tick = game.tick
  for _, guiobj in pairs(ctrl_data.titan_gui) do
    -- TODO: separate if player is not valid, as there will be no UI objects anymore
    if false
      or (not guiobj.player.valid or not guiobj.titan_info.entity or not guiobj.titan_info.entity.valid)
      or (not table.contains(list_players(lib_ttn.get_crew(guiobj.titan_info)), guiobj.player))
    then
      remove_titan_gui_by_player(guiobj.player)

    else

      local player_settings = ctrl_data.by_player[guiobj.player.index] or {}
      if guiobj.void_shield then
        if player_settings.percent_ammo then
          guiobj.void_shield.number = math.floor(100 * guiobj.titan_info.shield / lib_ttn.get_unit_shield_max_capacity(guiobj.titan_info))
        else
          guiobj.void_shield.number = math.floor(guiobj.titan_info.shield)
        end
      end
      if guiobj.health then
        if player_settings.percent_ammo then
          guiobj.health.number = math.floor(100 * guiobj.titan_info.entity.health / shared.titan_types[guiobj.titan_info.class].health)
        else
          guiobj.health.number = math.floor(guiobj.titan_info.entity.health)
        end
      end
      local still_cd
      for k, cannon in pairs(guiobj.titan_info.guns) do
        still_cd = cannon.gun_cd > tick
        if still_cd then
          guiobj.guns[k].img.number = 1- (cannon.gun_cd-tick) /shared.weapons[cannon.name].cd /UPS
        else
          guiobj.guns[k].img.number = nil
        end
        if guiobj.guns[k].img.toggled ~= nil then
          guiobj.guns[k].img.toggled = still_cd or (cannon.target ~= nil) and (tick < cannon.ordered + lib_ttn.order_ttl)
        end
        if shared.weapons[cannon.name].ammo then
          if player_settings.percent_ammo then
            guiobj.guns[k].ammo.number = math.floor(100 *(cannon.ammo_count or 0) /shared.weapons[cannon.name].inventory)
          else
            guiobj.guns[k].ammo.number = cannon.ammo_count or 0
          end
        end
        if guiobj.titan_info.guns[k].ai then
          guiobj.guns[k].mode.sprite = "virtual-signal/signal-info"
          guiobj.guns[k].mode.tooltip=make_titled_text({"WH40k-Titans-gui.attack-ai"}, {"WH40k-Titans-gui.attack-click"})
        elseif player_settings.guns[k].mode == 1 then
          guiobj.guns[k].mode.sprite = "virtual-signal/signal-1"
          guiobj.guns[k].mode.tooltip=make_titled_text({"controls."..shared.mod_prefix.."attack-1"}, {"WH40k-Titans-gui.attack-click"})
        elseif player_settings.guns[k].mode == 2 then
          guiobj.guns[k].mode.sprite = "virtual-signal/signal-2"
          guiobj.guns[k].mode.tooltip=make_titled_text({"controls."..shared.mod_prefix.."attack-2"}, {"WH40k-Titans-gui.attack-click"})
        elseif player_settings.guns[k].mode == 3 then
          guiobj.guns[k].mode.sprite = "virtual-signal/signal-3"
          guiobj.guns[k].mode.tooltip=make_titled_text({"controls."..shared.mod_prefix.."attack-3"}, {"WH40k-Titans-gui.attack-click"})
        elseif player_settings.guns[k].mode == 4 then
          guiobj.guns[k].mode.sprite = "virtual-signal/signal-4"
          guiobj.guns[k].mode.tooltip=make_titled_text({"controls."..shared.mod_prefix.."attack-4"}, {"WH40k-Titans-gui.attack-click"})
        else
          guiobj.guns[k].mode.sprite = "virtual-signal/signal-red"
          guiobj.guns[k].mode.tooltip = make_titled_text({"WH40k-Titans-gui.attack-0"}, {"WH40k-Titans-gui.attack-click"})
        end
      end

    end
  end
end


lib_ttn:on_nth_tick(gui_update_rate, update_guis)


lib_ttn:on_event(defines.events.on_gui_click, function(event)
  local player = game.get_player(event.player_index)
  local player_settings = ctrl_data.by_player[event.player_index]
  local titan_info = nil
  if player.character and player.character.vehicle then
    titan_info = ctrl_data.titans[player.character.vehicle.unit_number]
  end

  if event.element.tags.action == action_toggle_ammo_count then
    player_settings.percent_ammo = not player_settings.percent_ammo

  elseif event.element.tags.action == action_toggle_gun_mod then
    local k = event.element.tags.index
    if not titan_info then return end
    if titan_info.guns[k].ai then
      titan_info.guns[k].ai = false
    else
      player_settings.guns[k].mode = math.fmod((player_settings.guns[k].mode or 0) + 1, 5)
      if player_settings.guns[k].mode == 0 then
        titan_info.guns[k].ai = true
      end
    end

  elseif event.element.tags.action == action_zoom_out then
    if not titan_info then return end
    player.zoom = 1 / (3 + titan_info.class/10)
  end
end)
