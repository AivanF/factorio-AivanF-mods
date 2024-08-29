local lib_ruins = require("script/ruins")
local lib_tech = require("script/tech")

local Lib = require("script/event_lib")
lib_exc = Lib.new()

exc_update_rate = UPS
local global_exc_unit_time = heavy_debugging and 5 or 60
local exc_half_size = 4
local exc_offsets = {
  {exc_half_size, 0}, {-exc_half_size, 0},
  {0, exc_half_size}, {0, -exc_half_size}
}

local main_frame_name = "wh40k_titans_extractor"
local act_main_frame_close = "wh40k-titans-extractor-frame-close"

function lib_exc.register_excavator(entity)
  local world, ruin_entity, ruin_info
  ruin_entity = entity.surface.find_entity(shared.corpse, entity.position)
  world = ctrl_data.by_surface[entity.surface.index]

  local bodies = entity.surface.find_entities_filtered{position=entity.position, name=shared.corpse}
  if #bodies > 1 then
    -- game.print("Found "..cnt.." bodies!")
    for i = 2, #bodies do
      bodies[i].destroy()
    end
    ruin_entity = bodies[1]
  end

  if world and ruin_entity then
    ruin_info = ctrl_data.ruins[ruin_entity.unit_number]
  end
  local exc_info = {
    unit_number = entity.unit_number,
    entity = entity,
    world = world,
    ruin_entity = ruin_entity,
    ruin_info = ruin_info,
    progress = 0,
    leftover = nil,
    guis = {}, -- player.index => main_frame
  }
  -- game.print("Placed excavator "..entity.unit_number.." on ruin "..ruin_entity.unit_number.." with info: "..serpent.line(not not ruin_info))
  ctrl_data.excavator_index[entity.unit_number] = exc_info
  bucks.save(ctrl_data.excavator_buckets, exc_update_rate, entity.unit_number, exc_info)
  if ruin_info then
    entity.surface.create_entity{
      name="flying-text", position=entity.position,
      text={"WH40k-Titans-gui.msg-exc-content", bucks.total_count(ruin_info.details), bucks.total_count(ruin_info.ammo)},
    }
    ruin_info.exc_info = exc_info
  else
    entity.surface.create_entity{
      name="flying-text", position=entity.position,
      -- TODO: move into texts!
      text={"WH40k-Titans-gui.msg-exc-placed-empty"},
    }
  end
  entity.set_recipe(shared.excavation_recipe)
  entity.recipe_locked = true
  entity.active = false
end

function lib_exc.excavator_removed(unit_number)
  ctrl_data.excavator_index[unit_number] = nil
  bucks.remove(ctrl_data.excavator_buckets, exc_update_rate, unit_number)
end

local function put_leftovers(exc_info)
  for _, chest in pairs(exc_info.chests) do
    if chest.can_insert(exc_info.leftovers) then
      chest.insert(exc_info.leftovers)
      chest.surface.create_entity{
        name="flying-text", position=chest.position,
        -- TODO: add icon!
        text={"item-name."..exc_info.leftovers.name},
      }
      exc_info.leftovers = nil
      break
    end
  end
end

local function get_exc_speed(force)
  local cf = shared.exc_speed_by_level[0]
  if force then
    local level = lib_tech.get_research_level(force.index, shared.exc_speed_research)
    cf = shared.exc_speed_by_level[level]
  end
  return cf
end

local function get_exc_unit_time(exc_info)
  return global_exc_unit_time / get_exc_speed(exc_info.entity.force)
end

local function calc_expected_time(exc_info)
  local secs = 0
  local exc_unit_time = get_exc_unit_time(exc_info)
  if exc_info.ruin_info then
    for _, couple in pairs(exc_info.ruin_info.details) do
      secs = secs + couple.count * exc_unit_time
    end
    for _, couple in pairs(exc_info.ruin_info.ammo) do
      secs = secs + math.ceil(couple.count/lib_ruins.ammo_unit) * exc_unit_time
    end
    secs = secs - exc_info.progress * exc_unit_time
  end
  exc_info.expected_time = util.formattime(secs * UPS)
end

local function process_an_excavator(exc_info)
  local entity = exc_info.entity
  exc_info.chests = {}
  for _, offset in pairs(exc_offsets) do
    table.extend(exc_info.chests, entity.surface.find_entities_filtered{
      type = "container", position = math2d.position.add(entity.position, offset),
    })
  end

  if not exc_info.leftovers then
    if not exc_info.ruin_entity then 
      entity.active = false
      return
    end
    if not exc_info.ruin_entity.valid then
      entity.active = false
      exc_info.ruin_entity = nil
      entity.surface.create_entity{
        name="flying-text", position=entity.position,
        text="Excavation finished!",
      }
      entity.force.print({"WH40k-Titans-gui.msg-exc-done", {"", entity.position.x}, {"", entity.position.y}})
      return
    end

    local exc_unit_time = get_exc_unit_time(exc_info)
    local satisfaction = entity.energy / entity.electric_buffer_size
    exc_info.progress = exc_info.progress + satisfaction * exc_update_rate/UPS /exc_unit_time
    entity.active = true
    calc_expected_time(exc_info)

    if satisfaction > 0.35 and math.random() < 0.1 then
      entity.surface.play_sound{
        path="wh40k-titans-random-work",
        position=entity.position, volume_modifier=1
      }
    end

    if exc_info.progress >= 1 then
      local item_name, count = lib_ruins.ruin_extract(exc_info.ruin_info, exc_info.ruin_entity)
      if item_name and count > 0 then
        exc_info.leftovers = {name=item_name, count=count}
        put_leftovers(exc_info)
      else
        entity.surface.create_entity{
          name="flying-text", position=entity.position,
          text={"WH40k-Titans-gui.msg-exc-fail"},
        }
      end
      exc_info.progress = 0

      if exc_info.ruin_entity == nil then
        entity.active = false
      end
    end

    entity.crafting_progress = exc_info.progress

  else
    -- There are extracted but not outputted items
    entity.active = false
    put_leftovers(exc_info)
  end

  for player_index, main_frame in pairs(exc_info.guis) do
    if main_frame.valid then
      lib_exc.gui_update(exc_info, main_frame)
    else
      exc_info.guis[player_index] = nil
    end
  end
end

local function process_excavators()
  local bucket = bucks.get_bucket(ctrl_data.excavator_buckets, exc_update_rate, game.tick)
  if not bucket then return end
  for unit_number, exc_info in pairs(bucket) do
    if exc_info.entity.valid then
      process_an_excavator(exc_info)
    else
      lib_exc.excavator_removed(exc_info.unit_number)
    end
  end
end

lib_exc:on_event(defines.events.on_tick, process_excavators)

function lib_exc.gui_update(exc_info, main_frame)
  main_frame.status.caption = {"virtual-signal-name.signal-unknown"}
  main_frame.expected.caption = ""
  main_frame.results_line.clear()
  main_frame.progress.value = exc_info.progress

  -- game.print(shared.exc_speed_research..": "..lib_tech.get_research_level(exc_info.entity.force.index, shared.exc_speed_research))
  -- game.print(shared.exc_efficiency_research..": "..lib_tech.get_research_level(exc_info.entity.force.index, shared.exc_efficiency_research))

  local satisfaction = exc_info.entity.energy / exc_info.entity.electric_buffer_size
  if satisfaction < 0.2 then
    main_frame.status.caption = {"entity-status.low-power"}
    return
  end

  if exc_info.ruin_entity and exc_info.ruin_info then
    main_frame.status.caption = {"entity-status.working"}
    if exc_info.expected_time then
      main_frame.expected.caption = {
        "WH40k-Titans-gui.extracting-info",
        math.floor(100*get_exc_speed(exc_info.entity.force)),
        math.floor(100*lib_ruins.calc_extract_success_prob(exc_info.entity.force)),
        exc_info.expected_time,
      }
    end
    for _, couple in pairs(exc_info.ruin_info.details) do
      main_frame.results_line.add{
        type = "sprite-button", sprite = ("item/"..couple.name),
        tooltip = {"item-name."..couple.name},
        number = couple.count,
      }
    end
    for _, couple in pairs(exc_info.ruin_info.ammo) do
      main_frame.results_line.add{
        type = "sprite-button", sprite = ("item/"..couple.name),
        tooltip = {"item-name."..couple.name},
        number = couple.count,
      }
    end
  elseif exc_info.ruin_entity and not exc_info.ruin_info then
    main_frame.status.caption = {"entity-status.working"}
  else
    main_frame.status.caption = {"entity-status.no-minable-resources"}
  end

  if exc_info.leftovers then
    main_frame.status.caption = {"?", {"WH40k-Titans-gui.extracting-leftovers"}, {"entity-status.waiting-for-space-in-destination"}}
  end
end

local function gui_create(exc_info, player)
  local main_frame
  if player.gui.screen[main_frame_name] then
    main_frame = player.gui.screen[main_frame_name]
    -- player.gui.screen[main_frame_name].destroy(); main_frame = nil
    lib_exc.gui_update(exc_info, main_frame)
    return
  end

  if not main_frame then
    main_frame = player.gui.screen.add{ type="frame", name=main_frame_name, direction="vertical", }
    main_frame.style.minimal_width = 256
    main_frame.style.maximal_width = 320
    main_frame.style.minimal_height = 128
    main_frame.style.maximal_height = 320
  end

  -- TODO: don't close usual machine window, but stick to it?
  main_frame.auto_center = true
  player.opened = main_frame
  main_frame.focus()
  main_frame.bring_to_front()
  exc_info.guis[player.index] = main_frame

  local flowtitle = main_frame.add{ type="flow", name="title" }
  local title = flowtitle.add{ type="label", style="frame_title", caption={"entity-name.wh40k-titans-extractor"} }
  title.drag_target = main_frame
  local pusher = flowtitle.add{ type="empty-widget", style="draggable_space_header" }
  pusher.style.vertically_stretchable = true
  pusher.style.horizontally_stretchable = true
  pusher.drag_target = main_frame
  pusher.style.maximal_height = 24
  flowtitle.add{ type="sprite-button", style="frame_action_button", tags={action=act_main_frame_close}, sprite="utility/close_white" }

  main_frame.add{ type="label", name="status", caption="" }
  main_frame.add{ type="label", name="expected", caption="" }
  -- Replace to text-box if there are any issues
  main_frame.status.style.maximal_height = 128
  main_frame.status.style.single_line = false
  main_frame.expected.style.maximal_height = 128
  main_frame.expected.style.single_line = false
  main_frame.add{ type="progressbar", name="progress", direction="horizontal", value=exc_info.progress }
  main_frame.progress.style.maximal_width = 320
  -- main_frame.add{ type="label", caption={""} }
  -- main_frame.add{ type="flow", name="results_line", direction="horizontal" }
  main_frame.add{ type="table", name="results_line", column_count=7 }
  lib_exc.gui_update(exc_info, main_frame)
end

lib_exc:on_event(defines.events.on_gui_click, function(event)
  local player = game.get_player(event.player_index)
  local action = event.element and event.element.valid and event.element.tags.action
  if action == act_main_frame_close then
    if player.gui.screen[main_frame_name] then
      player.gui.screen[main_frame_name].destroy()
    end
  end
end)

lib_exc:on_event(defines.events.on_gui_opened, function(event)
  local player = game.get_player(event.player_index)
  if event.entity and ctrl_data.excavator_index[event.entity.unit_number] then
    local exc_info = ctrl_data.excavator_index[event.entity.unit_number]
    gui_create(exc_info, player)
  end
end)

lib_exc:on_event(defines.events.on_gui_closed, function(event)
  local player = game.get_player(event.player_index)
  if event.element and event.element.valid and event.element.name == main_frame_name then
    event.element.destroy()
  end
end)

return lib_exc