local shared = {}
shared.rod1 = "lightning-rod-1"
shared.rod2 = "lightning-rod-2-accumulator"
shared.rod3 = "lightning-rod-3-mighty"
shared.arty1 = "lightning-arty-1"
shared.arty2 = "lightning-arty-2"
shared.remote_name = "lightning-arty-remote"

shared.tech_catch_energy = "af-tsl-catch-energy"
shared.tech_catch_prob = "af-tsl-catch-prob"
shared.tech_range = "af-tsl-arty-range"

shared.mod_name = "Lightning"
shared.SE = "space-exploration"
shared.PRESET_NIL    = "nil"
shared.PRESET_HOME   = "home"
shared.PRESET_MOVING = "move"
shared.PRESET_TOTAL  = "total"
shared.allowed_presets = {shared.PRESET_NIL, shared.PRESET_HOME, shared.PRESET_MOVING, shared.PRESET_TOTAL}
shared.default_presets = {
  {"iron-ore", shared.PRESET_TOTAL},
  {"copper-ore", nil},
  {"uranium-ore", nil},
  {"se-holmium-ore", shared.PRESET_TOTAL},
  {"se-beryllium-ore", nil},
  {"se-iridium-ore", nil},
  -- Other
  {"stone", nil},
  {"coal", nil},
  {"crude-oil", nil},
  {"se-vitamelange", nil},
  {"se-cryonite", shared.PRESET_MOVING},
  {"se-vulcanite", shared.PRESET_MOVING},
}

shared.animations_seeds = {4, 5, 9}
shared.animations_length = 10
shared.animation_ttl = 30
shared.animation_speed = shared.animations_length / shared.animation_ttl

function shared.get_seed_animation_name(seed)
  return "tsl-lightning-"..seed
end

shared.big_animation_name = "tsl-lightning-big"

function shared.preset_setting_name_for_resource(resource)
  return "af-tsl-preset-for-"..resource
end

function math.clamp(x, min, max)
  return math.max(math.min(x, max), min)
end

function shared.ShuffleInPlace(t)
  for i = #t, 2, -1 do
    local j = math.random(i)
    t[i], t[j] = t[j], t[i]
  end
end

function shared.spairs(t, order)
  -- From here: https://stackoverflow.com/a/15706820/5308802

  -- collect the keys
  local keys = {}
  for k in pairs(t) do keys[#keys+1] = k end

  -- if order function given, sort by it by passing the table and keys a, b,
  -- otherwise just sort the keys 
  if order then
    table.sort(keys, function(a,b) return order(t, a, b) end)
  else
    table.sort(keys)
  end

  -- return the iterator function
  local i = 0
  return function()
    i = i + 1
    if keys[i] then
      return keys[i], t[keys[i]]
    end
  end
end

function shared.chunk_is_border(surface, chunk, dst)
  if dst == nil then dst = 3 end
  return (
    false
    or not surface.is_chunk_generated({chunk.x+dst, chunk.y})
    or not surface.is_chunk_generated({chunk.x, chunk.y+dst})
    or not surface.is_chunk_generated({chunk.x-dst, chunk.y})
    or not surface.is_chunk_generated({chunk.x, chunk.y-dst})
  )
end

function shared.split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t={}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

function shared.Iter2Array(...)
  local arr = {}
  for v in ... do
    arr[#arr + 1] = v
  end
  return arr
end

function shared.tableOverride(dst, src)
  for k, v in pairs(src) do
    dst[k] = v
  end
  return dst
end

return shared