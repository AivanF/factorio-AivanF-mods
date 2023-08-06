require("common")
local perlin = require("perlin")

set_energy_cf = settings.global["af-tsl-energy-cf"].value
set_rate_cf = settings.global["af-tsl-rate-cf"].value
set_extra_reduct = settings.global["af-tsl-extra-reduct"].value

-- Lightning calc delay. Less frequent for debug to not drown under spamming messages
lightning_update_rate = settings.startup["af-tsl-update-delay"].value * (set_perf_debug and 6 or 1)
-- Lightning delay per chunk
chunk_lightning_rate = minute_ticks /1 /set_rate_cf
-- For stickers
entity_update_rate = second_ticks * 2
-- Used to reduce Perlin noise calc per step
chunk_cache_ttl = minute_ticks * 2


function register_rod(entity)
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

  script_data.objects[unit_number] = {
    surface_index = surface_index,
    entity = entity,
  }
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
  local txt = "TSL AivanF migration: found "..found.." rods"
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

  local scale = 1 + power_level * 4
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
  return {pos.x+sx, pos.y+sy}
end

local function PosShiftRandom(pos, max)
  return PosShift(pos, math.random(-max, max), math.random(-max, max))
end

local hidden_speed = 0.3
local hidden_shift = -5

local function make_damage(surface, position, power_level)
  local shifted = PosShift(position, 0, hidden_shift)

  if power_level >= 5 then
    surface.create_entity{
      name="tsl-explo-5", force="neutral", speed=1,
      position=shifted, source=shifted, target=position
    }
  
  elseif power_level >= 4 then
    surface.create_entity{
      name="tsl-explo-4", force="neutral", speed=hidden_speed,
      position=shifted, source=shifted, target=position
    }
  
  elseif power_level >= 3 then
    surface.create_entity{
      name="tsl-explo-3", force="neutral", speed=hidden_speed,
      position=shifted, source=shifted, target=position
    }
    -- surface.create_entity{name="fire-flame", position=position, force="neutral"}
  
  elseif power_level >= 2 then
    surface.create_entity{
      name="tsl-explo-2", force="neutral", speed=hidden_speed,
      position=shifted, source=shifted, target=position
    }
  
  elseif power_level >=1 then
    surface.create_entity{
      name="tsl-explo-1", force="neutral", speed=hidden_speed,
      position=shifted, source=shifted, target=position
    }
  
  else
    surface.create_entity{
      name="tsl-explo-0", force="neutral", speed=hidden_speed,
      position=shifted, source=shifted, target=position
    }
  end

  for i = 0, math.random(0, power_level) do
    surface.create_entity{name="fire-flame-on-tree", position=PosShiftRandom(position, 1.5*power_level), force="neutral"}
  end

end


function order_by_empty_acc(ar, i, j)
  local a = ar[i]
  local b = ar[j]
  return (a.electric_buffer_size - a.energy) > (b.electric_buffer_size - b.energy)
end


local pre_capture_prob = {
  [0] = 0.80,
  [1] = 0.85,
  [2] = 0.90,
  [3] = 0.95,
  [4] = 0.97,
  [5] = 0.98,
  [6] = 0.99,
  [7] = 0.999,
}
function get_capture_prob(rod_class_info, entity, power_level)
  local level = math.clamp(script_data.technologies[shared.tech_catch_prob][entity.force_index] or 0, 0, 7)
  local result = math.pow(pre_capture_prob[level] or 0.5, power_level)
  if entity.electric_buffer_size then
    result = result * (1 - entity.energy / entity.electric_buffer_size)
  end
  return result + rod_class_info.add_capture_prob / power_level
end


function make_lightning(surface, place, power_level, capture_limit, energy_cf)
  local toCheck, rods, lightning_energy, volume
  local target = nil
  local captured = false
  local volume = 1

  if energy_cf == nil then energy_cf = 1 end
  if capture_limit == nil then capture_limit = shared.max_catch_radius end
  if capture_limit > shared.max_catch_radius then capture_limit = shared.max_catch_radius end
  if capture_limit < shared.min_catch_radius then capture_limit = shared.min_catch_radius end

  lightning_energy = math.floor(energy_cf * set_energy_cf * math.random(100*power_level, 500*power_level)) * MJ

  -- TODO: add extra loud sounds for 3+ level
  if power_level >= 3 then
    volume = 1
  elseif power_level >= 2 then
    volume = 0.85
  else
    volume = 0.7
  end
  local damage_power_level = power_level

  local position
  if place.left_top then
    position = {
      x=math.random(place.left_top.x, place.right_bottom.x),
      y=math.random(place.left_top.y, place.right_bottom.y)
    }
  elseif place.x ~= nil then
    position = place
  else
    error("Bad lightning place "..serpent.line(place))
  end

  for _, rod_class_info in pairs(rod_protos_ordered) do
    subtype = rod_protos[rod_class_info.name]
    toCheck = {
      left_top    ={position.x-capture_limit*rod_class_info.limit_cf, position.y-capture_limit*rod_class_info.limit_cf},
      right_bottom={position.x+capture_limit*rod_class_info.limit_cf, position.y+capture_limit*rod_class_info.limit_cf}}
    rods = surface.find_entities_filtered{area=toCheck, name=rod_class_info.name}
    shared.ShuffleInPlace(rods)

    if subtype == subtype_accum then
      for _, entity in shared.spairs(rods, order_by_empty_acc) do
        captured = math.random() < get_capture_prob(rod_class_info, entity, power_level)
        target = entity
        position = entity.position
        if captured then
          local cf = 0.5 + 0.1 * (script_data.technologies[shared.tech_catch_energy][entity.force_index] or 0)
          lightning_energy = lightning_energy * cf
          lightning_energy = math.min(
            target.electric_buffer_size - target.energy,
            lightning_energy)
          target.energy = target.energy + lightning_energy
          surface.play_sound{path="tsl-charging", position=position, volume_modifier=volume}
          break
        else
          damage_power_level = math.max(0, damage_power_level-math.random(0, 1))
        end
      end
    else
      for _, entity in pairs(rods) do
        captured = math.random() < get_capture_prob(rod_class_info, entity, power_level)
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
    if target ~= nil then
      position = {
        x=target.position.x-4+math.random(0, 8),
        y=target.position.y-4+math.random(0, 8)
      }
    end
    make_damage(surface, position, damage_power_level)
  end

  draw_lightning(surface, position, damage_power_level)
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
  value = math.clamp(value, 0, max_natural_power_level)
  return value
end


function get_random_power_level(currSurfSettings, chunk)
  if currSurfSettings.scale < 0.1 then return 0 end
  return math.random(0, get_max_power_level(currSurfSettings, chunk))
end


function get_surface_chunks(surface)
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
  debug_print("TSL chunks cache: "..active.." of "..total)
end


local function _handle_chunk(chunks_tasks, chunk, power_level)
  --- Small chance of higher level
  if math.random() < 0.03 then power_level = power_level + 1 end
  if math.random() < 0.03 then power_level = power_level + 1 end
  if math.random() < 0.03 then power_level = power_level + 1 end
  power_level = math.clamp(power_level, 0, max_natural_power_level)
  
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
      perf_print("TSL cache is empty or expired: "..serpent.line(cache_empty).." "..serpent.line(cache_expired))
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
    perf_print("TSL process_surface with cache: "..#cache.." chunks, "..#chunks_tasks.." tasks")

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
    perf_print("TSL process_surface direct: "..#chunks.." chunks, "..#chunks_tasks.." tasks")
  end

  local surface_event_number = tasks_number * lightning_update_rate / chunk_lightning_rate
  perf_print("TSL surface_event_number: "..surface_event_number)
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


function process_lightnings()
  local profiler = set_perf_debug and game.create_profiler() or nil
  --- TODO: Shift surfaces on different calls/ticks. Use buckets or mod by surface index?
  for surface_index, currSurfSettings in pairs(script_data.surfSettings) do
    if currSurfSettings.active and currSurfSettings.base > 0 or currSurfSettings.scale > 0 then
      process_surface(game.surfaces[surface_index], currSurfSettings)
    end
  end
  if profiler then perf_print{"", "TSL main process: ", profiler, "\n"} end
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


function process_entities(event)
  for surface_index, surface_bucket in pairs(script_data.rods_by_surface) do
    -- game.print(serpent.line(script_data.surfSettings))
    currSurfSettings = script_data.surfSettings[surface_index]
    if currSurfSettings ~= nil then
      local bucket = surface_bucket[event.tick % entity_update_rate]
      if not bucket then return end
      for unit_number, rod_entity in pairs(bucket) do
        if rod_entity.valid and rod_protos[rod_entity.name] > 0 then
          process_a_rod(currSurfSettings, rod_entity)
        else
          table.remove(bucket, unit_number)
        end
      end
    end
  end
end
