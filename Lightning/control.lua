local perlin = require("perlin")
local shared = require("shared")

local mod_name = "Lightning"

local set_nauvis_base = settings.global["af-tls-nauvis-base"].value
local set_nauvis_scale = settings.global["af-tls-nauvis-scale"].value
local set_energy_cf = settings.global["af-tls-energy-cf"].value
local set_rate_cf = settings.global["af-tls-rate-cf"].value
local set_main_debug = false --settings.global["af-tls-debug-main"].value
local set_perf_debug = false --settings.global["af-tls-debug-perf"].value

local global_max_power_level = 4

-- Ticks per second
local second_ups = 60
-- Ticks per minute
local minute_ups = second_ups * 60
-- Lightning calc delay
local lightning_update_rate = 15
-- Lightning delay per chunk
local chunk_lightning_rate = minute_ups /1 /set_rate_cf
-- For stickers
local entity_update_rate = 120
-- Used to reduce Perlin noise calc per step
local chunk_cache_ttl = minute_ups * 1

local MJ = 1000 * 1000
local chunk_size = 32

local subtype_accum = 2
local subtype_simple = 1
local rod_protos = {
    ["lightning-rod-2-accumulator"] = subtype_accum,
    ["lightning-rod-1"] = subtype_simple,
}
-- To be used with ipairs; accumulators go first
local rod_protos_ordered = {
  [1] = "lightning-rod-2-accumulator",
  [2] = "lightning-rod-1",
}

local script_data = {}

local function perf_print(txt)
  log(txt)
  if set_perf_debug then
    game.print(txt)
  end
end

local function debug_print(txt)
  log(txt)
  if set_main_debug then
    game.print(txt)
  end
end

local function reset_global()
  debug_print("TLS reset_global")
  -- TODO: add different planetes when SE is on
  script_data.surfSettings = {
    ["nauvis"] = { base=set_nauvis_base, scale=set_nauvis_scale }
  }
  script_data.rods_by_surface = {}
end

local function update_runtime_settings()
  -- Read
  set_energy_cf = settings.global["af-tls-energy-cf"].value
  set_rate_cf = settings.global["af-tls-rate-cf"].value
  set_nauvis_base = settings.global["af-tls-nauvis-base"].value
  set_nauvis_scale = settings.global["af-tls-nauvis-scale"].value
  -- Apply
  chunk_lightning_rate = minute_ups /1 /set_rate_cf
  script_data.surfSettings["nauvis"].base = set_nauvis_base
  script_data.surfSettings["nauvis"].scale = set_nauvis_scale
end

local function register_rod(entity)
  local surface_name = entity.surface.name
  local unit_number = entity.unit_number
  local surface_bucket = script_data.rods_by_surface[surface_name]
  if not surface_bucket then
    surface_bucket = {}
    script_data.rods_by_surface[surface_name] = surface_bucket
  end
  local inner_bucket = surface_bucket[unit_number % entity_update_rate]
  if not inner_bucket then
    inner_bucket = {}
    surface_bucket[unit_number % entity_update_rate] = inner_bucket
  end
  inner_bucket[unit_number] = entity
end

local function on_any_built(event)
  local entity = event.created_entity or event.entity or event.destination
  if not (entity and entity.valid) then return end
  if rod_protos[entity.name] then
    register_rod(entity)
  end
end

function clean_drawings()
  local ids = rendering.get_all_ids(mod_name)
  for _, id in pairs(ids) do
    if rendering.is_valid(id) then
      rendering.destroy(id)
    end
  end
end

function rods_reload()
  found = 0
  for _, surface in pairs(game.surfaces) do
    for name, _ in pairs(rod_protos) do
      for _, entity in pairs(surface.find_entities_filtered{name=name}) do
        register_rod(entity)
        found = found + 1
      end
    end
  end
  local txt = "TLS AivanF migration: found "..found.." rods"
  -- game.print(txt)
  log(txt)
end


function draw_lightning(surface, position, tint)
  -- game.print("Lightning: [gps="..position[1]..","..position[2]..","..surface.index.."]")
  -- TODO: add small random rotation
  rendering.draw_sprite{
    sprite="tsl-lightning", x_scale=1, y_scale=1, tint=tint,
    render_layer="light-effect", only_in_alt_mode=false,
    target=position, target_offset={0, 0}, surface=surface, time_to_live=second_ups/2
  }
  surface.play_sound{path="tsl-lightning", position=position, volume_modifier=1}
end


local function PosShift(pos, sx, sy)
  return {pos[1]+sx, pos[2]+sy}
end

function make_damage(surface, position, power_level)
  if power_level >= 2 then
  end

  -- https://wiki.factorio.com/Data.raw#explosion
  if power_level >= 5 then
    surface.create_entity{name="nuke-explosion", position=position, force="neutral"}
  end
  if power_level >= 4 then
    surface.create_entity{name="massive-explosion", position=PosShift(position, 0, -2), force="neutral"}
    surface.create_entity{name="massive-explosion", position=PosShift(position, -2, 0), force="neutral"}
    surface.create_entity{name="massive-explosion", position=PosShift(position, 0, 2), force="neutral"}
    surface.create_entity{name="massive-explosion", position=PosShift(position, 2, 0), force="neutral"}

    surface.create_entity{name="fire-flame-on-tree", position=PosShift(position, 0, -1), force="neutral"}
    surface.create_entity{name="fire-flame-on-tree", position=PosShift(position, -1, 0), force="neutral"}
    surface.create_entity{name="fire-flame-on-tree", position=PosShift(position, 0, 1), force="neutral"}
    surface.create_entity{name="fire-flame-on-tree", position=PosShift(position, 1, 0), force="neutral"}
  end
  if power_level >= 3 then
    -- https://wiki.factorio.com/Data.raw#explosion
    surface.create_entity{name="massive-explosion", position=position, force="neutral"}
    surface.create_entity{name="fire-flame", position=position, force="neutral"}
    surface.create_entity{name="fire-flame-on-tree", position=position, force="neutral"}
  else
    surface.create_entity{name="medium-explosion",  position=position, force="neutral"}
  end

  -- TODO: correct this!
  -- local hidden = surface.create_entity{
  --   name="entity-ghost", position=position, force="neutral",
  --   inner_name="accumulator", expires=true,
  -- }
  -- surface.create_entity{name="tsl-damage-1", position=position, target=hidden, force="neutral"}
  -- surface.create_entity{name="tsl-damage-2", position=position, target=hidden, force="neutral"}
end


function order_by_empty_acc(ar, i, j)
  local a = ar[i]
  local b = ar[j]
  return (a.electric_buffer_size - a.energy) > (b.electric_buffer_size - b.energy)
end

function make_lightning(surface, area, power_level, capture_limit)
  local toCheck, rods, lightning_energy, volume, tint
  local position = nil
  local target = nil
  local captured = false
  local volume = 1

  if capture_limit == nil then capture_limit = shared.max_catch_radius end
  if capture_limit > shared.max_catch_radius then capture_limit = shared.max_catch_radius end
  if capture_limit < shared.min_catch_radius then capture_limit = shared.min_catch_radius end

  lightning_energy = math.floor(math.random(100*power_level, 500*power_level) * set_energy_cf) * MJ
  if power_level >= 4 then
    tint = {1, 0.9, 0.8, 1}
  elseif power_level >= 3 then
    tint = {1, 0.9, 0.9, 1}
  elseif power_level >= 2 then
    volume = 0.85
    tint = {1, 1, 0.9, 1}
  else
    volume = 0.7
    tint = {0.9, 0.9, 1, 1}
  end

  local capture_prob = math.pow(0.95, power_level)

  for _, name in pairs(rod_protos_ordered) do
    subtype = rod_protos[name]
    toCheck = {
      {area.left_top.x-capture_limit, area.left_top.y-capture_limit},
      {area.right_bottom.x+capture_limit, area.right_bottom.y+capture_limit}}
    rods = surface.find_entities_filtered{area=toCheck, name=name}
    shared.ShuffleInPlace(rods)

    if subtype == subtype_accum then
      for _, entity in shared.spairs(rods, order_by_empty_acc) do
        captured = math.random() < capture_prob * (1 - entity.energy / entity.electric_buffer_size)
        target = entity
        position = entity.position
        if captured then
          lightning_energy = math.min(
            target.electric_buffer_size - target.energy,
            lightning_energy)
          target.energy = target.energy + lightning_energy
          surface.play_sound{path="tsl-charging", position=position, volume_modifier=volume}
          break
        end
      end
    else
      for _, entity in pairs(rods) do
        captured = math.random() < capture_prob
        target = entity
        position = entity.position
        if captured then
          surface.play_sound{path="tsl-charging", position=position, volume_modifier=0.8*volume}
          break
        end
      end
    end
    if captured then break end
  end

  if not captured then
    -- Rods can miss yet guide lightnings leading to damage
    if target == nil then
      position = {
        math.random(area.left_top.x, area.right_bottom.x),
        math.random(area.left_top.y, area.right_bottom.y)
      }
    else
      position = {
        target.position.x-4+math.random(0, 8),
        target.position.y-4+math.random(0, 8)
      }
    end
    make_damage(surface, position, power_level)
  end

  draw_lightning(surface, position, tint)
end

local function make_lightning_inner(surface, chunk_info)
  make_lightning(surface, chunk_info[1].area, chunk_info[2])
end

function get_max_power_level(currSurfSettings, chunk)
  --- TODO: add semi-random offset for different surfaces
  --- TODO: add offset by time scale
  local value = perlin.noise(chunk.x/5, chunk.y/5)
  value = (value+1) /2 -0.6
  value = math.ceil(value *15 *currSurfSettings.scale)
  value = math.clamp(value, 0, global_max_power_level)
  return value
end

function get_random_power_level(currSurfSettings, chunk)
  if currSurfSettings.scale < 0.1 then return 0 end
  return math.random(0, get_max_power_level(currSurfSettings, chunk))
end

local function get_surface_chunks(surface)
  return shared.Iter2Array(surface.get_chunks())
end

function chunk_filter_iter(surface, border, ar)
  if ar == nil then ar = get_surface_chunks(surface) end
  local i = 0
  local n = #ar
  local chunk, use
  return function()
    while i < n do
      i = i + 1
      chunk = ar[i]
      --- I hate fcking nasted ifs, where is the continue keyword...
      use = true
      if use then use = not shared.chunk_is_border(surface, chunk, border) end
      -- if use and use_prob > 0 then use = math.random() < chunk_use_prob end
      if use then return chunk end
    end
  end
end

local function make_chunks_cache(surface)
  local cache = {}
  local total = 0
  local active = 0
  for chunk in chunk_filter_iter(surface, 5) do
    total = total + 1
    power_level = get_max_power_level(currSurfSettings, chunk)
    if power_level > 0 then
      active = active + 1
      if cache ~= nil then
        cache[#cache+1] = {chunk, power_level}
      end
    end
  end
  script_data.surfSettings[surface.name].cache_created = game.ticks_played
  script_data.surfSettings[surface.name].cache = cache
  debug_print("TLS chunks cache: "..active.." of "..total)
end

local function _handle_chunk(chunks_todo, chunk, power_level)
  --- Small chance of higher level
  if math.random() < 0.03 then power_level = power_level + 1 end
  if math.random() < 0.03 then power_level = power_level + 1 end
  if math.random() < 0.03 then power_level = power_level + 1 end
  power_level = math.clamp(power_level, 0, global_max_power_level)
  --- Save into todo list with prob according to level
  for i = 1, power_level do
    chunks_todo[#chunks_todo + 1] = {chunk, power_level}
  end
end

local function process_surface(surface, currSurfSettings)
  --- surface: https://lua-api.factorio.com/latest/LuaSurface.html
  --- chunk: https://lua-api.factorio.com/latest/Concepts.html#ChunkPositionAndArea

  local chunks_todo = {}
  local todo_number = 0
  local power_level

  if currSurfSettings.base < 1 then
    local cache_empty = script_data.surfSettings[surface.name].cache == nil
    local cache_expired = script_data.surfSettings[surface.name].cache_created ~= nil and game.ticks_played - script_data.surfSettings[surface.name].cache_created > chunk_cache_ttl
    if cache_empty or cache_expired then
      -- perf_print("TLS cache is empty or expired: "..serpent.line(cache_empty).." "..serpent.line(cache_expired))
      make_chunks_cache(surface)
    end
  else
    script_data.surfSettings[surface.name].cache = nil
  end

  if script_data.surfSettings[surface.name].cache ~= nil then

    --- Optimise base==0 surfaces with cache of lightning-active regions
    local total = 0
    for _, chunk_info in pairs(script_data.surfSettings[surface.name].cache) do
      total = total + 1
      power_level = math.random(0, chunk_info[2])
      _handle_chunk(chunks_todo, chunk_info[1], power_level)
    end
    todo_number = #chunks_todo
    perf_print("TLS process_surface with cache: "..total.." chunks, "..#chunks_todo.." todo")

  else
    --- Optimise other surfaces with chunk usage probability
    --- TODO: maybe also use cache for random power level to reduce noise calc?
    local chunks = get_surface_chunks(surface)
    local border, chunk_use_prob
    --- The chunk_use_prob should be at least >1/chunk_lightning_rate ~= 1/300 to keep calc robust
    --- More for better distribution
    if #chunks < 2000 then
      border = 3
      chunk_use_prob = 0.1
    elseif #chunks < 5000 then
      border = 5
      chunk_use_prob = 0.05
    elseif #chunks < 10000 then
      border = 7
      chunk_use_prob = 0.025
    else
      border = 10
      chunk_use_prob = 0.01
    end
    for chunk in chunk_filter_iter(surface, border, chunks) do
      if math.random() < chunk_use_prob then
        power_level = currSurfSettings.base + get_random_power_level(currSurfSettings, chunk)
        _handle_chunk(chunks_todo, chunk, power_level)
      end
    end
    --- Normalise frequence for further probability calculation
    todo_number = #chunks_todo / chunk_use_prob
    perf_print("TLS process_surface direct: "..#chunks.." chunks, "..#chunks_todo.." todo")
  end

  local surface_event_number = todo_number * lightning_update_rate / chunk_lightning_rate
  surface_event_number = math.min(surface_event_number, #chunks_todo)
  if surface_event_number < 1 then
    if math.random() < surface_event_number then
      make_lightning_inner(surface, chunks_todo[math.random(#chunks_todo)])
    end
  end
  surface_event_number = math.floor(surface_event_number + 0.5)
  if surface_event_number == 1 then
    make_lightning_inner(surface, chunks_todo[math.random(#chunks_todo)])
  end
  if surface_event_number > 1 then
    shared.ShuffleInPlace(chunks_todo)
    for i = 1, surface_event_number do
      make_lightning_inner(surface, chunks_todo[i])
    end
  end
end

local function process_lightnings()
  local profiler = set_perf_debug and game.create_profiler() or nil
  local surface
  --- TODO: shift surfaces on different calls/ticks; use buckets?
  for surface_name, currSurfSettings in pairs(script_data.surfSettings) do
    if currSurfSettings.base > 0 or currSurfSettings.scale > 0 then
      surface = game.surfaces[surface_name]
      process_surface(surface, currSurfSettings)
    end
  end
  if profiler then perf_print{"", "TLS main process: ", profiler, "\n"} end
end

local function process_a_rod(currSurfSettings, rod_entity)
  local surface = rod_entity.surface
  local power_level = currSurfSettings.base + get_max_power_level(currSurfSettings, {
    x=math.floor(rod_entity.position.x / chunk_size),
    y=math.floor(rod_entity.position.y / chunk_size)
  })
  power_level = math.clamp(power_level, 0, 5)
  if power_level >= 1 and power_level <= 5 then
    rendering.draw_sprite{
      sprite="tsl-energy-"..power_level, x_scale=1, y_scale=1,
      render_layer="light-effect", only_in_alt_mode=true,
      target=rod_entity, target_offset={0, 0}, surface=surface, time_to_live=entity_update_rate+1
    }
  end
end

local function process_entities(event)
  for surface_name, surface_bucket in pairs(script_data.rods_by_surface) do
    -- game.print(serpent.line(script_data.surfSettings))
    currSurfSettings = script_data.surfSettings[surface_name]
    local bucket = surface_bucket[event.tick % entity_update_rate]
    if not bucket then return end
    for unit_number, rod_entity in pairs(bucket) do
      if rod_entity.valid then
        process_a_rod(currSurfSettings, rod_entity)
      else
        table.remove(bucket, unit_number)
      end
    end
  end
end

local function on_init()
  global.script_data = global.script_data or script_data
  reset_global()
end

local function on_load()
  script_data = global.script_data or script_data
end

local function update_configuration()
  global.script_data = script_data
  clean_drawings()
  reset_global()
  rods_reload()
end

script.on_init(on_init)
script.on_load(on_load)
script.on_event(defines.events.on_runtime_mod_setting_changed, update_runtime_settings)
script.on_configuration_changed(update_configuration)

script.on_event({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}, on_any_built)

script.on_nth_tick(lightning_update_rate, process_lightnings)
script.on_event(defines.events.on_tick, process_entities)

commands.add_command(
  "tsl-clean",
  "Remove all TSL drawings",
  clean_drawings
)
commands.add_command(
  "tsl-reload",
  "Reload all TSL chests",
  rods_reload
)
