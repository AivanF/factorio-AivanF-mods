require("__core__.lualib.util") -- for table.deepcopy
local math2d = require("__core__.lualib.math2d")
local mod_gui = require("mod-gui")

local shared = require("shared")
require("script/common")
local Lib = require("script/event_lib")
local lib = Lib.new()

local gui_btn_name = "vehitel_ui"
local main_frame_name = "vehitel_gui_frame"
local act_gui_toggle = shared.mod_prefix.."gui-toggle"
local act_dst_select = shared.mod_prefix.."dst-select"
local act_dst_clear  = shared.mod_prefix.."dst-clear"

local ic_idle = shared.mod_prefix.."gui-btn-idle"
local ic_active = shared.mod_prefix.."gui-btn-active"
local ic_error = shared.mod_prefix.."gui-btn-error"

-- TODO: add vehicle profile:
-- register by remote API func
-- set min spd, 

local gui_update_rate = 61
local min_teleport_dst = 100
local speed_cf = 60*60*60/1000  -- tile/tick => km/h
local REQUIRED_SPEED = 88 / speed_cf  -- ±0.4074
-- local REQUIRED_SPEED = 44 / speed_cf
local OTHER_PLANET_DST = 100 * 1000  -- Karman line
local WEIGHT_COMPARATOR = 10 * 1000 * 1000
local MAX_COUNTDOWN = 5

local grid_prefix = shared.mod_prefix.."device-"

local blank_ctrl_data = {
  cars = {},
  players = {},
  delayed = {},
}
ctrl_data = table.deepcopy(blank_ctrl_data)


local function on_init()
  storage.ctrl_data = table.deepcopy(blank_ctrl_data)
  ctrl_data = storage.ctrl_data
end

local function on_load()
  ctrl_data = storage.ctrl_data
end

local function update_configuration()
  storage.ctrl_data = merge(storage.ctrl_data or {}, blank_ctrl_data, false)
  ctrl_data = storage.ctrl_data

  for _, player in pairs(game.players) do
    lib.setup_gui_btn(player)
  end
end


local function set_icon(player, icon)
  local btn = mod_gui.get_button_flow(player)[gui_btn_name]
  if btn == nil then return end
  btn.sprite = icon
  local text = nil
  if icon == ic_idle then
    text = {"VehiTel-gui.tooltip-idle"}
  elseif icon == ic_active then
    text = {"VehiTel-gui.tooltip-active"}
  elseif icon == ic_error then
    text = {"VehiTel-gui.tooltip-error"}
  end
  btn.tooltip = make_titled_text({"VehiTel-gui.main-ui-title"}, text)
end


local function show_quick_msg(player, text)
  player.create_local_flying_text{
    text=text,
    create_at_cursor=true,
    time_to_live=gui_update_rate,
  }
end


local function on_any_remove(event)
  local unit_number
  local entity = event.entity
  if entity and entity.valid then
    unit_number = entity.unit_number
  else
    entity = nil
  end
  unit_number = unit_number or event.unit_number
  if not unit_number then return end

  ctrl_data.cars[unit_number] = nil
end


local function validate_vehicle(entity)
  if entity == nil or not entity.valid then return nil end
  if not entity.grid then return nil end
  local car_info = ctrl_data.cars[entity.unit_number]

  -- Prevent frequent intense calculations
  if car_info and (game.tick - (car_info.last_update or 0)) < 15 then return car_info end

  local content = entity.grid.get_contents()
  local grade = 0
  local power = 0
  local cnt
  -- Check MK1
  cnt = content[shared.device1] or 0
  if cnt > 0 then grade = 1 end
  power = power + cnt * 1
  -- Check MK2
  cnt = content[shared.device2] or 0
  if cnt > 0 then grade = 2 end
  power = power + cnt * 5
  -- Check MK3
  cnt = content[shared.device3] or 0
  if cnt > 0 then grade = 3 end
  power = power + cnt * 10

  if not car_info then
    if grade > 0 then
      car_info = {entity=entity}
      ctrl_data.cars[entity.unit_number] = car_info
    else
      return nil
    end
  end

  car_info.grade = grade
  car_info.power = power
  car_info.efficiency = 100 * power / 20
  car_info.last_update = game.tick

  car_info.now_fuel_energy = calc_vehicle_fuel_energy(entity) or 0
  car_info.now_grid_energy = calc_equipment_energy(entity.grid, grid_prefix) or 0
  car_info.max_grid_energy = calc_equipment_max_energy(entity.grid, grid_prefix, true) or 1
  car_info.weight = calc_vehicle_weight(entity)

  local player = player_maybe_character(car_info.entity.get_driver())
  local player_info = player and lib.get_or_make_player_data(player)
  local dst = player_info and lib.calc_dist(player_info)
  if dst then
    dst = round_by(dst, 100)
    car_info.driver = player
    car_info.player_info = player_info
    car_info.distance = dst

    local base_required_energy = dst * 1000 / (1 + (car_info and car_info.efficiency/100 or 0))
    base_required_energy = base_required_energy * (1 + car_info.weight / WEIGHT_COMPARATOR)

    car_info.fuel_required = base_required_energy * 400
    car_info.grid_required = base_required_energy * 10

  else
    car_info.driver = nil
    car_info.player_info = nil
    car_info.distance = nil
    car_info.fuel_required = nil
    car_info.grid_required = nil
  end

  return car_info
end


function lib.setup_gui_btn(player)
  local button_flow = mod_gui.get_button_flow(player)
  if button_flow[gui_btn_name] == nil then
    local btn = button_flow.add{
      type="sprite-button",
      name=gui_btn_name,
      sprite=shared.mod_prefix.."gui-btn-main",
      -- style=mod_gui.button_style,
      tags={action=act_gui_toggle},
    }
  end
end


local clr_gray = "#aaaaaa"
local clr_blue   = "0.5,0.7,0.8"
local clr_red    = "0.8,0.1,0.1"
local clr_orange = "0.9,0.5,0"
local clr_white  = "1,1,1"
local clr_green  = "0.1,0.8,0.1"
local clr_purple = "0.7,0.3,1"
local function make_colored(text, color)
  if color then
    return {"", "[color="..color.."]", text, "[/color]"}
  else
    return text
  end
end
local function make_blue(text)
  return make_colored(text, clr_blue)
end
local function make_gray(text)
  return make_colored(text, clr_gray)
end
local function make_bold(text)
  return {"", "[font=default-bold]", text, "[/font]"}
end


local function color_from_energy(required, have)
  if have > 2 * required + 2000 then
    return clr_purple
  elseif have > 1.05 * required + 1000 then
    return clr_green
  elseif have > required then
    return clr_orange
  else
    return clr_red
  end
end


local function color_from_grade(grade)
  if grade >= 3 then
    return clr_purple
  elseif grade >= 2 then
    return clr_green
  elseif grade >= 1 then
    return clr_blue
  else
    return clr_red
  end
end


function lib.get_or_make_player_data(player)
  if not ctrl_data.players[player.index] then
    ctrl_data.players[player.index] = {
      player = player,
    }
  end
  return ctrl_data.players[player.index]
end


function lib.find_vehicle(player)
  -- Ignoring vehicles player are in as a passanger

  -- Remote control
  if player.vehicle and player.vehicle.get_driver() == player then
    return player.vehicle
  end

  -- Physical control
  if player.physical_vehicle and player.physical_vehicle.get_driver().player == player then
    return player.physical_vehicle
  end

  return nil
end


function lib.calc_dist(player_info)
  if not (player_info and player_info.player and player_info.destination) then
    return nil
  end
  local player = player_info.player
  local source_entity = lib.find_vehicle(player)
  -- Just character
  if source_entity == nil and player.character then
    source_entity = player.character
  end
  -- player.position can be a player flying around the map

  if source_entity then
    if source_entity.surface == player_info.surface then
      return math.min(math2d.position.distance(source_entity.position, player_info.destination), OTHER_PLANET_DST)
    else
      return OTHER_PLANET_DST
    end
  else
    return nil
  end
end


function lib.create_main_window(player)
  if player.gui.screen[main_frame_name] then
    player.gui.screen[main_frame_name].destroy()
  end

  local player_info = lib.get_or_make_player_data(player)

  main_frame = player.gui.screen.add{
    type="frame", name=main_frame_name,
    -- caption={"WH40k-Titans-gui.gen-ui-title"},
    direction="vertical",
  }
  main_frame.style.minimal_width = 256
  main_frame.style.maximal_width = 640
  -- main_frame.style.minimal_height = 128
  main_frame.style.maximal_height = 800

  main_frame.auto_center = true
  player.opened = main_frame
  player_info.main_frame = main_frame

  local flowtitle = main_frame.add{ type = "flow", name = "title" }
  local title = flowtitle.add{ type = "label", style = "frame_title", caption={"VehiTel-gui.main-ui-title"} }
  title.drag_target = main_frame
  local pusher = flowtitle.add{ type = "empty-widget", style = "draggable_space_header" }
  pusher.style.vertically_stretchable = true
  pusher.style.horizontally_stretchable = true
  pusher.drag_target = main_frame
  pusher.style.maximal_height = 24
  flowtitle.add{ type="sprite-button", style="frame_action_button", tags={action=act_gui_toggle}, sprite="utility/close" }

  local stats = main_frame.add{type="table", name="stats", column_count=3, style="filter_slot_table"}

  local function make_row(args)
    stats.add{ type="label", name=args.prefix.."_ttl", caption={"VehiTel-gui."..args.title_key} }
    stats.add{ type="label"}  -- padding
    stats.add{ type="label", name=args.prefix.."_val" }
  end

  stats.add{ type="label", name="head_1", caption=make_bold{"VehiTel-gui.vehicle-title"} }
  stats.add{ type="label", name="head_2" }
  stats.add{ type="label", name="head_3" }
  stats.head_2.style.minimal_width = 4

  make_row{prefix="name", title_key="vehicle-name"}
  make_row{prefix="weight", title_key="vehicle-weight"}
  make_row{prefix="fuel_energy", title_key="vehicle-fuel-energy"}
  make_row{prefix="grid_energy", title_key="vehicle-grid-energy"}
  make_row{prefix="grade", title_key="vehicle-device-grade"}
  -- make_row{prefix="power", title_key="vehicle-device-power"}
  make_row{prefix="eff", title_key="vehicle-device-eff"}

  stats.add{ type="label", }
  stats.add{ type="label", }
  stats.add{ type="label", }

  stats.add{ type="label", caption=make_bold{"VehiTel-gui.dst-title"} }
  stats.add{ type="label", }
  stats.add{ type="label", }

  make_row{prefix="planet", title_key="dst-planet"}
  make_row{prefix="position", title_key="dst-position"}
  make_row{prefix="distance", title_key="dst-distance"}
  make_row{prefix="fuel_required", title_key="dst-fuel-required"}
  make_row{prefix="grid_required", title_key="dst-grid-required"}

  local sub_frame = main_frame.add{ type="flow", direction="horizontal" }
  sub_frame.add{ type="button", tags={action=act_dst_clear},
    caption=make_bold{"VehiTel-gui.dst-btn-clear"} }
  sub_frame.add{ type="button", tags={action=act_dst_select},
    caption=make_bold{"VehiTel-gui.dst-btn-set"} }

  main_frame.add{ type="flow", name="camera_holder", direction="vertical" }

  lib.update_player_gui(player_info)
end


function lib.update_player_gui(player_info)
  -- TODO: for passengers, show driver's destination, and describe it!
  local player = player_info.player
  local main_frame = player_info.main_frame
  if main_frame == nil or not main_frame.valid then return end
  local car = lib.find_vehicle(player)
  local car_info = validate_vehicle(car)
  local stats =  main_frame.stats

  stats.name_val.caption = car and make_blue({"entity-name."..car.name}) or {"VehiTel-gui.vehicle-nocar"}
  stats.weight_val.caption = car_info and make_blue(shorten_mass(car_info.weight)) or {"VehiTel-gui.vehicle-nocar"}
  stats.fuel_energy_val.caption = car_info and make_blue(
      (shorten_energy(car_info.now_fuel_energy) or 0).."J"
    ) or {"VehiTel-gui.vehicle-nocar"}
  stats.grid_energy_val.caption = car_info and make_blue(string.format(
      "%sJ, %.0f%%",
      car and shorten_energy(car_info.now_grid_energy) or 0,
      100*car_info.now_grid_energy/car_info.max_grid_energy
    )) or {"VehiTel-gui.vehicle-nocar"}

  stats.grade_val.caption = car_info and make_colored("MK"..car_info.grade, color_from_grade(car_info.grade)) or {"VehiTel-gui.vehicle-nodev"}
  -- stats.power_val.caption = car_info and make_blue(car_info.power) or {"VehiTel-gui.vehicle-nodev"}
  stats.eff_val.caption = car_info and make_blue(string.format("+%.0f%%", car_info.efficiency)) or {"VehiTel-gui.vehicle-nodev"}

  stats.planet_val.caption = make_blue(player_info.surface and (nil
    -- or player_info.surface.planet and ("[planet="..player_info.surface.planet.name.."]")
    or player_info.surface.planet and {"space-location-name."..player_info.surface.planet.name}
    or player_info.surface.localised_name
    or player_info.surface.name
  ) or {"VehiTel-gui.dst-empty"})

  stats.position_val.caption = player_info.destination and make_blue(
      string.format("x=%.0f y=%.0f", player_info.destination.x, player_info.destination.y)
    ) or {"VehiTel-gui.dst-empty"}

  stats.distance_val.caption = car_info and car_info.distance and make_blue(car_info.distance == OTHER_PLANET_DST and {"VehiTel-gui.dst-other-planet-dist"} or distance_to_km(car_info.distance)) or make_gray("?")
  stats.fuel_required_val.caption = car_info and car_info.fuel_required and make_colored(
      shorten_energy(car_info.fuel_required).."J", color_from_energy(car_info.fuel_required, car_info.now_fuel_energy)
    ) or make_gray("?")
  stats.grid_required_val.caption = car_info and car_info.grid_required and make_colored(
      shorten_energy(car_info.grid_required).."J", color_from_energy(car_info.grid_required, car_info.now_grid_energy)
    ) or make_gray("?")

  if not main_frame.camera_holder.camera and player_info.destination then
    main_frame.camera_holder.add{
      name="camera",
      type="minimap",
      position=player_info.destination,
      surface_index=player_info.surface.index,
      zoom=0.5,
    }
  end
end


local function verify_teleport_conditions(car_info, silent)
  if car_info == nil then
    return false
  end
  car_info = validate_vehicle(car_info.entity)
  if car_info.driver == nil then
    return false
  end

  if not car_info.player_info.surface then
    set_icon(car_info.driver, ic_idle)
    return false
  end

  if car_info.entity.surface ~= car_info.player_info.surface and car_info.grade < 2 then
    _ = silent or show_quick_msg(car_info.driver, {"VehiTel-gui.msg-dst-not-cross-planet"});
    set_icon(car_info.driver, ic_error)
    return false
  end

  if not car_info.player_info.surface.can_place_entity{
    name=car_info.entity.name,
    position=car_info.player_info.destination
  } then
    _ = silent or show_quick_msg(car_info.driver, {"VehiTel-gui.msg-dst-no-space"});
    set_icon(car_info.driver, ic_error)
    return false
  end

  if car_info.now_fuel_energy < car_info.fuel_required then
    _ = silent or show_quick_msg(car_info.driver, {"VehiTel-gui.msg-fuel-lack-energy"});
    set_icon(car_info.driver, ic_error)
    return false
  end
  if car_info.now_grid_energy < car_info.grid_required then
    _ = silent or show_quick_msg(car_info.driver, {"VehiTel-gui.msg-grid-lack-energy"});
    set_icon(car_info.driver, ic_error)
    return false
  end

  set_icon(car_info.driver, ic_active)
  return true
end


local function update_periodic_car(car_info)
  local recently = game.tick - (car_info.active_tick or 0) < gui_update_rate+5;
  if not car_info.entity.valid then
    return false
  end

  -- TODO: use req spd from vehicle profile

  if car_info.entity.speed > REQUIRED_SPEED then
    if recently then
      car_info.active_tick = game.tick
      if car_info.countdown > 0 then
        ----- Count down
        show_quick_msg(car_info.driver, {"VehiTel-gui.msg-tl-cooldown", car_info.countdown})
        -- car_info.entity.surface.create_entity{
        --   name="compi-speech-bubble",
        --   text="Teleporting in "..car_info.countdown,
        --   position=car_info.entity.position,
        --   source=car_info.entity,
        --   lifetime=gui_update_rate,
        --   -- target=position_scatter(car_info.entity.position, 5),
        -- }
        car_info.countdown = car_info.countdown - 1
        car_info.entity.surface.play_sound{
          path=shared.mod_prefix.."teleport-progress",
          position=car_info.entity.position, volume_modifier=1
        }
      else
        ----- Do the teleportation
        car_info.countdown = 0
        car_info.active_tick = 0
        validate_vehicle(car_info.entity)
        if verify_teleport_conditions(car_info) then
          if take_vehicle_fuel_energy(car_info.entity, car_info.fuel_required) then
            take_vehicle_equipment_energy(car_info.entity.grid, car_info.grid_required, grid_prefix)

            -- TODO: make fire and/or explosion
            -- for i = 1, 7 do
            --   car_info.entity.surface.create_entity{
            --     name="flamethrower-fire-stream",
            --     force=car_info.entity.force,
            --     position=car_info.entity.position,
            --     source=car_info.entity.position,
            --     target=position_scatter(car_info.entity.position, 5),
            --     speed=5,
            --   }
            -- end
            table.insert(ctrl_data.delayed, {
              car_info.entity.surface.play_sound,
                {
                path=shared.mod_prefix.."teleport-finish",
                position=car_info.entity.position, volume_modifier=1,
              },
            })
            -- car_info.entity.surface.play_sound{
            --   path=shared.mod_prefix.."teleport-finish",
            --   position=car_info.entity.position, volume_modifier=1,
            --   override_sound_type="gui-effect",
            -- }
            car_info.entity.teleport(car_info.player_info.destination, car_info.player_info.surface, true, false)
            if car_info.entity.prototype.type == "car" then
              -- Spider don't support speed editing, weird
              car_info.entity.speed = car_info.entity.speed / 3
            end
            car_info.driver.force.chart(car_info.player_info.surface, {
              {x=car_info.player_info.destination.x-1, y=car_info.player_info.destination.y-1},
              {x=car_info.player_info.destination.x+1, y=car_info.player_info.destination.y+1}
            })
            table.insert(ctrl_data.delayed, {
              car_info.entity.surface.play_sound,
                {
                path=shared.mod_prefix.."teleport-finish",
                position=car_info.player_info.destination, volume_modifier=1,
              },
            })
            -- car_info.player_info.surface.play_sound{
            --   path=shared.mod_prefix.."teleport-finish",
            --   position=car_info.player_info.destination, volume_modifier=1,
            --   override_sound_type="gui-effect",
            -- }
            -- TODO: car_info.driver.print teleportation stats info: dst or from/to planet + energy
            lib.clear_dst(car_info.driver)
            car_info.active_tick = 0
          else
            car_info.driver.print({"VehiTel-gui.msg-fuel-lack-energy"})
            car_info.active_tick = 0
            car_info.entity.surface.play_sound{
              path=shared.mod_prefix.."teleport-shutdown",
              position=car_info.entity.position, volume_modifier=1
            }
          end
        end
      end
    else  -- speedy but not recently, do start
      validate_vehicle(car_info.entity)
      local player_info = car_info.player_info
      if player_info and player_info.destination then
        if verify_teleport_conditions(car_info) then
          -- TODO: lock required energy values? But how to check if cargo was changed?..
          car_info.entity.surface.play_sound{
            path=shared.mod_prefix.."teleport-start",
            position=car_info.entity.position, volume_modifier=1
          }
          car_info.active_tick = game.tick
          car_info.countdown = MAX_COUNTDOWN - 1
          show_quick_msg(car_info.driver, {"VehiTel-gui.msg-tl-start", car_info.countdown+1})
        end
      end
    end  -- recently end
  else  -- not speedy
    if recently then
      show_quick_msg(car_info.driver, {"VehiTel-gui.msg-tl-failed-speed"})
      car_info.entity.surface.play_sound{
        path=shared.mod_prefix.."teleport-shutdown",
        position=car_info.entity.position, volume_modifier=1
      }
    end
  end  -- speedy end
end


local function update_periodic()
  for _, player_info in pairs(ctrl_data.players) do
    if player_info.main_frame and player_info.main_frame.valid then
      lib.update_player_gui(player_info)
    end
  end

  for index, car_info in pairs(ctrl_data.cars) do
    if update_periodic_car(car_info) == false then
      ctrl_data.cars[index] = nil
    end
  end
end


function lib.clear_dst(player)
  local player_info = lib.get_or_make_player_data(player)
  local main_frame = player.gui.screen[main_frame_name]
  if player_info.destination == nil then return end

  player_info.destination = nil
  player_info.surface = nil
  if main_frame then main_frame.camera_holder.clear() end
  lib.update_player_gui(player_info)
  set_icon(player, ic_idle)
  -- car_info.entity.surface.play_sound{
  --   path=shared.mod_prefix.."teleport-shutdown",
  --   position=car_info.entity.position, volume_modifier=1
  -- }
end


local function on_player_selected_area(event)
  if event.item ~= shared.dst_selector then return end
  local alt = event.name == defines.events.on_player_alt_selected_area
  local surface = event.surface
  local target = {
    x = (event.area.left_top.x + event.area.right_bottom.x) / 2,
    y = (event.area.left_top.y + event.area.right_bottom.y) / 2
  }
  local player = game.players[event.player_index]
  local player_info = lib.get_or_make_player_data(player)
  local main_frame = player.gui.screen[main_frame_name]

  -- game.print(serpent.block{  -- Debugging, or game API exploring
  --   phys_vehicle_pos=player.physical_vehicle and player.physical_vehicle.position,
  --   phys_vehicle_driver=player.physical_vehicle and player.physical_vehicle.get_driver(),
  --   vehicle_pos=player.vehicle and player.vehicle.position,
  --   vehicle_driver=player.vehicle and player.vehicle.get_driver(),
  --   character=player.character and player.character.position,
  --   position=player.position,
  -- }); if true then return end;

  lib.clear_dst(player)
  if alt then
    return
  end

  if not surface.is_chunk_generated(position_to_chunk(target)) then
    player.print({"VehiTel-gui.msg-dst-unexplored"})
    return
  end

  local car = lib.find_vehicle(player)
  if car and not car.surface.can_place_entity{
    name=car.name,
    position=target,
  } then
    player.print({"VehiTel-gui.msg-dst-no-space"})
    return
  end

  local dst = lib.calc_dist{
    player=player,
    destination=target,
    surface=surface,
  }
  if dst and dst < min_teleport_dst then
    player.print({"VehiTel-gui.msg-dst-too-close", min_teleport_dst, shorten_distance(dst)})
    return
  end

  player_info.destination = target
  player_info.surface = surface
  lib.update_player_gui(player_info)
  player.print({"VehiTel-gui.msg-dst-saved", string.format("[gps=%s,%s,%s]", target.x, target.y, surface.name)})

  -- set_icon(player, ic_active)
  local car = lib.find_vehicle(player)
  local car_info = car and validate_vehicle(car)
  verify_teleport_conditions(car_info, silent)
end


lib:on_event(defines.events.on_gui_closed, function(event)
  if event.element and event.element.name == main_frame_name then
    event.element.destroy()
  end
end)


lib:on_event(defines.events.on_gui_click, function(event)
  local player = game.get_player(event.player_index)
  local main_frame = player.gui.screen[main_frame_name]
  local action = event.element and event.element.valid and event.element.tags.action
  local player_info = ctrl_data.players[player.index]

  if action == act_gui_toggle then
    if main_frame then
      main_frame.destroy()
      return
    else
      lib.create_main_window(player)
    end

  elseif action == act_dst_select then
    if player.cursor_stack.valid and not player.cursor_stack.valid_for_read then
      player.cursor_stack.set_stack({name=shared.dst_selector, amount=1})
    end

  elseif action == act_dst_clear and player_info then
    lib.clear_dst(player)
  end
end)


local function on_tick()
  local fn
  for _, task in ipairs(ctrl_data.delayed or {}) do
    fn = task[1]
    fn(task[2])
  end
  ctrl_data.delayed = {}
end


lib:on_event(defines.events.on_player_driving_changed_state, function(event)
  local player = game.players[event.player_index]
  local car = lib.find_vehicle(player)

  if car then
    car_info = validate_vehicle(car)
    verify_teleport_conditions(car_info, true)  -- To update the top icon
  else
    set_icon(player, ic_idle)
  end
end)


lib:on_init(on_init)
lib:on_load(on_load)
lib:on_configuration_changed(update_configuration)

lib:on_any_built(on_any_built)
lib:on_any_remove(on_any_remove)

lib:on_event(defines.events.on_player_created, function(event)
  lib.setup_gui_btn(game.players[event.player_index])
end)

lib:on_event(defines.events.on_player_selected_area, on_player_selected_area)
lib:on_event(defines.events.on_player_alt_selected_area, on_player_selected_area)

lib:on_event(defines.events.on_tick, on_tick)
lib:on_nth_tick(gui_update_rate, update_periodic)

return lib