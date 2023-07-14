local perlin = require("perlin")
local shared = require("shared")

local mod_name = shared.mod_name
local global_max_power_level = 4
local script_data = {}
local SE = shared.SE

local set_nauvis_base = settings.global["af-tls-nauvis-base"].value
local set_nauvis_scale = settings.global["af-tls-nauvis-scale"].value
local set_nauvis_size = settings.global["af-tls-nauvis-size"].value
local set_nauvis_zspeed = settings.global["af-tls-nauvis-zspeed"].value
local set_energy_cf = settings.global["af-tls-energy-cf"].value
local set_rate_cf = settings.global["af-tls-rate-cf"].value
local set_extra_reduct = settings.global["af-tls-extra-reduct"].value
local set_base_capture_prob = settings.global["af-tls-capture-prob"].value
local set_main_debug = false --settings.global["af-tls-debug-main"].value
local set_perf_debug = false --settings.global["af-tls-debug-perf"].value

local settings_nauvis_changed = false
local settings_presets_changed = false

local function perf_print(txt)
  if set_perf_debug then
    log(txt)
    game.print(txt)
  end
end

local function debug_print(txt)
  log(txt)
  if set_main_debug then
    game.print(txt)
  end
end

---- Helpful Factorio constants
local MJ = 1000 * 1000
local chunk_size = 32
local second_ticks = 60
local minute_ticks = second_ticks * 60

-- Lightning calc delay. Less frequent for debug to not drown under spamming messages
local lightning_update_rate = settings.startup["af-tls-update-delay"].value * (set_perf_debug and 6 or 1)
-- Lightning delay per chunk
local chunk_lightning_rate = minute_ticks /1 /set_rate_cf
-- For stickers
local entity_update_rate = second_ticks * 2
-- Used to reduce Perlin noise calc per step
local chunk_cache_ttl = minute_ticks * 2

local subtype_accum = 2
local subtype_simple = 1
local rod_protos = {
    ["lightning-rod-3-mighty"] = subtype_accum,
    ["lightning-rod-2-accumulator"] = subtype_accum,
    ["lightning-rod-1"] = subtype_simple,
}
-- Priority list, to be used with ipairs
local rod_protos_ordered = {
  {name="lightning-rod-3-mighty", limit_cf=1.5, add_capture_prob=0.8,},
  {name="lightning-rod-2-accumulator", limit_cf=1, add_capture_prob=0.1,},
  {name="lightning-rod-1", limit_cf=1,},
}

local surfPresets = {
  [shared.PRESET_HOME]   = {
    base=set_nauvis_base, scale=set_nauvis_scale,
    size=set_nauvis_size, zspeed=set_nauvis_zspeed,
  },
  [shared.PRESET_MOVING] = { base=0, scale=2, size=2, zspeed=0.1 },
  [shared.PRESET_TOTAL]  = { base=1, scale=0, size=0, zspeed=0 },
}

local zone_ore_to_preset = {}
local function reload_preset_mappings()
  local preset_name
  for index, info in ipairs(shared.default_presets) do
    preset_name = settings.global[shared.preset_setting_name_for_resource(info[1])].value
    if preset_name == shared.PRESET_NIL then preset_name = nil end
    zone_ore_to_preset[info[1]] = preset_name
  end
end
reload_preset_mappings()

local function setup_preset(name, seed)
  local preset = surfPresets[name]
  if not preset then
    error("No preset named "..serpent.line(name))
  end
  local currSurfSettings = {}
  -- Instance values
  currSurfSettings.preset_name = name
  currSurfSettings.seed = math.fmod(seed, 1000)
  currSurfSettings.active = true
  currSurfSettings.changed = false
  -- Copy preset values
  currSurfSettings.base = preset.base
  currSurfSettings.scale = preset.scale
  currSurfSettings.size = preset.size
  currSurfSettings.zspeed = preset.zspeed
  -- TODO: add coefficients for day/night, darkness/daytime?
  return currSurfSettings
end

local function se_zone_to_preset(zone)
  local preset_name = zone_ore_to_preset[zone.primary_resource]
  if zone.is_homeworld then preset_name = shared.PRESET_HOME end
  if zone.type ~= "planet" and zone.type ~= "moon" then return nil end
  if not preset_name then return nil end
  return preset_name
end

local function apply_updated_mappings()
  local preset_name, surface_index
  if game.active_mods[SE] then
    for _, zone in pairs(remote.call(SE, "get_zone_index", {})) do
      surface_index = zone.surface_index
      preset_name = zone.surface_index and se_zone_to_preset(zone) or nil

      if script_data.surfSettings[surface_index] then
        if preset_name == nil then
          --- Mapping removed
          script_data.surfSettings[surface_index] = nil
        else
          if script_data.surfSettings[surface_index].preset_name ~= preset_name then
            --- Mapping changed
            shared.tableOverride(script_data.surfSettings[surface_index], setup_preset(preset_name, zone.seed))
          end
        end

      else
        if preset_name == nil then
          --- Nothing to do
        else
          --- Mapping created
          script_data.surfSettings[surface_index] = setup_preset(preset_name, zone.seed)
        end
      end
    end
  end
end

local function apply_preset(surface_index, preset_name, seed)
  seed = seed or surface_index * 314
  local currSurfSettings = setup_preset(preset_name, seed)
  -- TODO: try to save important values like seed
  if script_data.surfSettings[surface_index] then
    shared.tableOverride(script_data.surfSettings[surface_index], currSurfSettings)
  else
    script_data.surfSettings[surface_index] = currSurfSettings
  end
end

local function se_register_zone(surface_index)
  local zone = remote.call(SE, "get_zone_from_surface_index", {surface_index=surface_index})
  if zone then
    local preset_name = se_zone_to_preset(zone)
    -- debug_print("TLS se_register_zone, index: "..surface_index..", type: "..serpent.line(zone.type)..", preset: "..serpent.line(preset_name))
    if not preset_name then return false end
    -- if name == shared.PRESET_NIL then return false end  -- Should be handled by reload_preset_mappings
    apply_preset(surface_index, preset_name, zone.seed)
    return true
  end
  return false
end

local function se_add_zones()
  local done = 0
  for _, surface in pairs(game.surfaces) do
    done = done + (se_register_zone(surface.index) and 1 or 0)
  end
  debug_print("TLS+SE added "..done.." surfaces of "..#game.surfaces)
end

local function apply_updated_preset(preset_name)
  for surface_index, currSurfSettings in pairs(script_data.surfSettings) do
    if currSurfSettings.preset_name == preset_name then
      shared.tableOverride(currSurfSettings, setup_preset(preset_name, currSurfSettings.seed))
    end
  end
end


local function reset_global()
  debug_print("TLS reset_global")
  script_data.rods_by_surface = {}
  script_data.surfSettings = {
    [1] = setup_preset(shared.PRESET_HOME, 0),
  }
  if settings.startup["af-tsl-support-surfaces"].value then
    if game.active_mods[SE] then se_add_zones() end
  end
end


local function update_runtime_settings(event)
  --- Common values
  if event.setting:find("af-tls-", 1, true) then
    set_base_capture_prob = settings.global["af-tls-capture-prob"].value
    set_energy_cf = settings.global["af-tls-energy-cf"].value
    set_rate_cf = settings.global["af-tls-rate-cf"].value
    chunk_lightning_rate = minute_ticks /1 /set_rate_cf
    set_extra_reduct = settings.global["af-tls-extra-reduct"].value
  end

  --- Homeworld preset
  if event.setting:find("af-tls-nauvis-", 1, true) then
    settings_nauvis_changed = true
  end

  --- Mappings
  if event.setting:find("af-tls-preset-for-", 1, true) then
    settings_presets_changed = true
  end
end


local function register_rod(entity)
  local surface_index = entity.surface.index
  local unit_number = entity.unit_number
  local surface_bucket = script_data.rods_by_surface[surface_index]
  if not surface_bucket then
    surface_bucket = {}
    script_data.rods_by_surface[surface_index] = surface_bucket
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


function draw_lightning(surface, position, power_level)
  -- game.print("Lightning: [gps="..position[1]..","..position[2]..","..surface.index.."]")
  -- TODO: add small random rotation

  local animation
  if power_level >= 3 then
    animation = shared.big_animation_name
  else
    animation = shared.get_seed_animation_name(
      shared.animations_seeds[math.random(1, #shared.animations_seeds)]
    )
  end

  local tint
  -- Gold sprite
  if power_level >= 5 then
    tint = {1, 0.8, 0.9, 1}
  elseif power_level >= 4 then
    tint = {1, 1, 1, 1}
  elseif power_level >= 3 then
    tint = {1, 0.9, 0.8, 1}
  -- Cold sprite
  elseif power_level >= 2 then
    volume = 0.85
    tint = {1, 1, 1, 1}
  else
    volume = 0.7
    tint = {0.7, 0.7, 1, 1}
  end

  rendering.draw_animation{
    animation=animation,
    x_scale=1-2*math.random(1), y_scale=1, tint=tint, render_layer="light-effect",
    animation_speed=shared.animation_speed, time_to_live=shared.animation_ttl,
    animation_offset=-(game.ticks_played * shared.animation_speed) % shared.animations_length,
    target=position, target_offset={0, 0}, surface=surface,
  }

  local scale = 1 + power_level * 3
  rendering.draw_light{
    sprite="tsl-light", scale=scale/2, intensity=1, minimum_darkness=0, color=tint,
    target=position, target_offset={0, 0}, surface=surface, time_to_live=second_ticks/3,
  }
  rendering.draw_light{
    sprite="tsl-light", scale=scale, intensity=0.5, minimum_darkness=0, color=tint,
    target=position, target_offset={0, 0}, surface=surface, time_to_live=second_ticks/2,
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
  local toCheck, rods, lightning_energy, volume
  local position = nil
  local target = nil
  local captured = false
  local volume = 1

  if capture_limit == nil then capture_limit = shared.max_catch_radius end
  if capture_limit > shared.max_catch_radius then capture_limit = shared.max_catch_radius end
  if capture_limit < shared.min_catch_radius then capture_limit = shared.min_catch_radius end

  lightning_energy = math.floor(math.random(100*power_level, 500*power_level) * set_energy_cf) * MJ
  -- TODO: add extra loud sounds for 3+ level
  if power_level >= 3 then
    volume = 1
  elseif power_level >= 2 then
    volume = 0.85
  else
    volume = 0.7
  end

  local capture_prob = math.pow(set_base_capture_prob, power_level)

  for _, rod_class_info in pairs(rod_protos_ordered) do
    subtype = rod_protos[rod_class_info.name]
    toCheck = {
      {area.left_top.x-capture_limit*rod_class_info.limit_cf, area.left_top.y-capture_limit*rod_class_info.limit_cf},
      {area.right_bottom.x+capture_limit*rod_class_info.limit_cf, area.right_bottom.y+capture_limit*rod_class_info.limit_cf}}
    rods = surface.find_entities_filtered{area=toCheck, name=rod_class_info.name}
    shared.ShuffleInPlace(rods)

    if subtype == subtype_accum then
      for _, entity in shared.spairs(rods, order_by_empty_acc) do
        captured = math.random() < capture_prob * (1 - entity.energy / entity.electric_buffer_size) + rod_class_info.add_capture_prob
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

  draw_lightning(surface, position, power_level)
end

local function make_lightning_inner(surface, chunk_info)
  make_lightning(surface, chunk_info[1].area, chunk_info[2])
end

function get_max_power_level(currSurfSettings, chunk)
  local value
  local x = currSurfSettings.size * chunk.x/5 + currSurfSettings.seed*127
  local y = currSurfSettings.size * chunk.y/5 - currSurfSettings.seed*271
  if currSurfSettings.zspeed == 0 then
    -- It's 18% faster
    value = perlin.noise2d(x, y)
  else
    local z = currSurfSettings.seed*37 + currSurfSettings.zspeed*game.ticks_played/minute_ticks
    value = perlin.noise2d(x, y, z)
  end
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

local function get_reduction_cfs(chunks_number, shift)
  if shift == nil then shift = 0 end
  local reduction

  if chunks_number < 2000 then
    reduction = 1
  elseif chunks_number < 5000 then
    reduction = 2
  elseif chunks_number < 10000 then
    reduction = 3
  else
    reduction = 4
  end

  reduction = reduction + shift + set_extra_reduct

  local border, chunk_use_prob
  --- The chunk_use_prob should be at least >1/chunk_lightning_rate ~= 1/300 to keep calc robust
  --- More for better distribution
  if reduction <= 1 then
    border = 3
    chunk_use_prob = 0.1
  elseif reduction == 2 then
    border = 5
    chunk_use_prob = 0.05
  elseif reduction == 3 then
    border = 7
    chunk_use_prob = 0.025
  elseif reduction == 4 then
    border = 10
    chunk_use_prob = 0.01
  elseif reduction == 5 then
    border = 15
    chunk_use_prob = 0.003
  else
    border = 20
    chunk_use_prob = 0.001
  end
  return border, chunk_use_prob
end

local function make_chunks_cache(surface, currSurfSettings)
  local chunks = get_surface_chunks(surface)
  local border, chunk_use_prob = get_reduction_cfs(#chunks, -1)
  local cache = {}
  local total = 0
  local active = 0
  for chunk in chunk_filter_iter(surface, border, chunks) do
    total = total + 1
    power_level = get_max_power_level(currSurfSettings, chunk)
    if power_level > 0 then
      active = active + 1
      if cache ~= nil then
        cache[#cache+1] = {chunk, power_level}
      end
    end
  end
  currSurfSettings.cache_created = game.ticks_played
  currSurfSettings.cache = cache
  debug_print("TLS chunks cache: "..active.." of "..total)
end

local function _handle_chunk(chunks_tasks, chunk, power_level)
  --- Small chance of higher level
  if math.random() < 0.03 then power_level = power_level + 1 end
  if math.random() < 0.03 then power_level = power_level + 1 end
  if math.random() < 0.03 then power_level = power_level + 1 end
  power_level = math.clamp(power_level, 0, global_max_power_level)
  
  if power_level > 0 then chunks_tasks[#chunks_tasks + 1] = {chunk, power_level} end
  --- Save into tasks list with prob according to level
  -- for i = 1, power_level do chunks_tasks[#chunks_tasks + 1] = {chunk, power_level} end
end

local function process_surface(surface, currSurfSettings)
  --- surface: https://lua-api.factorio.com/latest/LuaSurface.html
  --- chunk: https://lua-api.factorio.com/latest/Concepts.html#ChunkPositionAndArea

  local chunks_tasks = {}
  local tasks_number = 0
  local power_level

  if currSurfSettings.base < 1 and currSurfSettings.zspeed == 0 then
    local cache_empty = currSurfSettings.cache == nil
    local cache_expired = currSurfSettings.cache_created ~= nil and game.ticks_played - currSurfSettings.cache_created > chunk_cache_ttl
    if cache_empty or cache_expired then
      perf_print("TLS cache is empty or expired: "..serpent.line(cache_empty).." "..serpent.line(cache_expired))
      make_chunks_cache(surface, currSurfSettings)
    end
  else
    script_data.surfSettings[surface.index].cache = nil
  end

  if script_data.surfSettings[surface.index].cache ~= nil then

    --- Optimise base==0 surfaces with cache of lightning-active regions
    local cache = script_data.surfSettings[surface.index].cache
    local border, chunk_use_prob = get_reduction_cfs(#cache, -1)
    for _, chunk_info in pairs(cache) do
      if math.random() < chunk_use_prob then
        power_level = math.random(0, chunk_info[2])
        _handle_chunk(chunks_tasks, chunk_info[1], power_level)
      end
    end
    --- Normalise frequence for further probability calculation
    tasks_number = #chunks_tasks / chunk_use_prob
    perf_print("TLS process_surface with cache: "..#cache.." chunks, "..#chunks_tasks.." tasks")

  else
    --- Optimise other surfaces with chunk usage probability
    local chunks = get_surface_chunks(surface)
    local border, chunk_use_prob = get_reduction_cfs(#chunks)

    for chunk in chunk_filter_iter(surface, border, chunks) do
      if math.random() < chunk_use_prob then
        power_level = currSurfSettings.base + get_random_power_level(currSurfSettings, chunk)
        _handle_chunk(chunks_tasks, chunk, power_level)
      end
    end
    --- Normalise frequence for further probability calculation
    tasks_number = #chunks_tasks / chunk_use_prob
    perf_print("TLS process_surface direct: "..#chunks.." chunks, "..#chunks_tasks.." tasks")
  end

  local surface_event_number = tasks_number * lightning_update_rate / chunk_lightning_rate
  perf_print("TLS surface_event_number: "..surface_event_number)
  surface_event_number = math.min(surface_event_number, #chunks_tasks)

  if surface_event_number < 1 then
    if math.random() < surface_event_number then
      make_lightning_inner(surface, chunks_tasks[math.random(#chunks_tasks)])
    end
  end
  surface_event_number = math.floor(surface_event_number + 0.5)
  if surface_event_number == 1 then
    make_lightning_inner(surface, chunks_tasks[math.random(#chunks_tasks)])
  end
  if surface_event_number > 1 then
    shared.ShuffleInPlace(chunks_tasks)
    for i = 1, surface_event_number do
      make_lightning_inner(surface, chunks_tasks[i])
    end
  end
end

local function process_lightnings()
  local profiler = set_perf_debug and game.create_profiler() or nil
  --- TODO: Shift surfaces on different calls/ticks. Use buckets or mod by surface index?
  for surface_index, currSurfSettings in pairs(script_data.surfSettings) do
    if currSurfSettings.active and currSurfSettings.base > 0 or currSurfSettings.scale > 0 then
      process_surface(game.surfaces[surface_index], currSurfSettings)
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
  for surface_index, surface_bucket in pairs(script_data.rods_by_surface) do
    -- game.print(serpent.line(script_data.surfSettings))
    currSurfSettings = script_data.surfSettings[surface_index]
    if currSurfSettings ~= nil then
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
end

local function surface_clean_cmd(command)
  -- TODO: check if player is admin or nil
  local surface_name = tonumber(command.parameter) or command.parameter
  local surface = game.surfaces[surface_name]
  if not surface then
    game.get_player(command.player_index).print("No surface '"..surface_name.."'")
    return
  end

  if script_data.surfSettings[surface.index] then
    script_data.surfSettings[surface.index] = nil
    game.get_player(command.player_index).print("Cleaned surface '"..surface_name.."'")
  else
    game.get_player(command.player_index).print("Surface '"..surface_name.."' exists but not registered")
  end
end

local function surface_add_cmd(command)
  -- TODO: check if player is admin or nil
  local args = shared.split(command.parameter or "")

  if #args < 1 or #args > 2 then
    game.get_player(command.player_index).print("Bad arguments number")
    return
  end

  local surface_name = tonumber(args[1]) or args[1]
  local surface = game.surfaces[surface_name]
  if not surface then
    game.get_player(command.player_index).print("No surface '"..surface_name.."'")
    return
  end

  local preset_name = args[2] or shared.PRESET_HOME
  apply_preset(surface.index, preset_name)
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

local function cache_clean()
  for surface_index, currSurfSettings in pairs(script_data.surfSettings) do
    currSurfSettings.cache = nil
  end
end

local function process_rare()
  if game.active_mods[SE] and game.tick > second_ticks then
    --- Tried defines.events.on_surface_created
    --- But seems like during the event, SE doesn't have surface linked to zone yet
    for _, surface in pairs(game.surfaces) do
      if not script_data.surfSettings[surface.index] then
        se_register_zone(surface.index)
      end
    end
  end
end

local function process_sometimes()
  if settings_nauvis_changed then
    debug_print("TLS settings_nauvis_changed")
    settings_nauvis_changed = false
    set_nauvis_base = settings.global["af-tls-nauvis-base"].value
    set_nauvis_scale = settings.global["af-tls-nauvis-scale"].value
    set_nauvis_size = settings.global["af-tls-nauvis-size"].value
    set_nauvis_zspeed = settings.global["af-tls-nauvis-zspeed"].value
    surfPresets[shared.PRESET_HOME].base = set_nauvis_base
    surfPresets[shared.PRESET_HOME].scale = set_nauvis_scale
    surfPresets[shared.PRESET_HOME].size = set_nauvis_size
    surfPresets[shared.PRESET_HOME].zspeed = set_nauvis_zspeed
    apply_updated_preset(shared.PRESET_HOME)
  end

  if settings_presets_changed then
    debug_print("TLS settings_presets_changed")
    settings_presets_changed = false
    reload_preset_mappings()
    apply_updated_mappings()
  end
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
script.on_nth_tick(minute_ticks, process_rare)
script.on_nth_tick(second_ticks, process_sometimes)
script.on_event(defines.events.on_tick, process_entities)


commands.add_command(
  "tsl-clean-draw",
  "Remove all TSL drawings",
  clean_drawings
)
commands.add_command(
  "tsl-rods-reload",
  "Reload all TSL rods",
  rods_reload
)
commands.add_command(
  "tsl-clean-cache",
  "Reload all TSL surface cache",
  cache_clean
)
commands.add_command(
  "tsl-remove-surface",
  "Remove lightnings from a surface",
  surface_clean_cmd
)
commands.add_command(
  "tsl-add-surface",
  "Add lightnings to a surface",
  surface_add_cmd
)

remote.add_interface(mod_name, {
  list_surf_settings = function()
    return script_data.surfSettings
  end,
  set_surf_settings = function(surface_index, new_settings)
    shared.tableOverride(script_data.surfSettings[surface_index], new_settings)
  end,
})
