require("__core__.lualib.util") -- for table.deepcopy
math2d = require("math2d")
shared = require("shared")

UPS = 60

heavy_debugging = false
-- heavy_debugging = true

bucks = {}

function bucks.save(buckets_table, total_number, index, value)
  local bucket = buckets_table[index % total_number]
  if not bucket then
    bucket = {}
    buckets_table[index % total_number] = bucket
  end
  bucket[index] = value
end

function bucks.get_bucket(buckets_table, total_number, index)
  return buckets_table[index % total_number]
end

function bucks.get(buckets_table, total_number, index)
  local bucket = buckets_table[index % total_number]
  if bucket then
    return bucket[index]
  end
  return nil
end

function bucks.remove(buckets_table, total_number, index)
  local bucket = buckets_table[index % total_number]
  if bucket then
    bucket[index] = nil
  end
end

function bucks.total_count(buckets_table)
  local result = 0
  for _, bucket in pairs(buckets_table) do
    for _, value in pairs(bucket or {}) do
      result = result + 1
    end
  end
  return result
end


function preprocess_ingredients()
  -- Replaces Bridge item objects with names
  if not global.active_mods_cache then return end
  -- log("preprocess_ingredients, active_mods_cache: "..serpent.line(global.active_mods_cache))
  afci_bridge.active_mods_cache = global.active_mods_cache
  local item
  for _, titan_type in pairs(shared.titan_type_list) do
    for _, stack in pairs(titan_type.ingredients) do
      if stack[1].is_bridge_item then
        item = stack[1]
        item.getter() -- preprocessing
        stack[1] = item.name
      end
    end
  end
  for _, weapon_type in pairs(shared.weapons) do
    for _, stack in pairs(weapon_type.ingredients) do
      if stack[1].is_bridge_item then
        item = stack[1]
        item.getter() -- preprocessing
        stack[1] = item.name
      end
    end
  end
end

function remove_ingredients_doubles(ingredients)
  local indices = {}
  local result = {}
  local prev, name, count
  for _, couple in pairs(ingredients) do
    name = couple[1] or couple.name
    count = couple[2] or couple.count
    if indices[name] then
      prev = result[indices[name]]
      prev.count = prev.count + count
    else
      indices[name] = #result + 1
      table.insert(result, {name=name, count=count})
    end
  end
  return result
end

function points_to_orientation(a, b)
  return 0.25 +math.atan2(b.y-a.y, b.x-a.x) /math.pi /2
end

function orientation_diff(src, dst)
  if dst - src > 0.5 then src = src + 1 end
  if src - dst > 0.5 then dst = dst + 1 end
  return dst - src
end

function point_orientation_shift(ori, oris, length)
  ori = -ori -oris +0.25
  ori = ori * 2 * math.pi
  return {length*math.cos(ori), -length*math.sin(ori)}
end

function math.clamp(v, mn, mx)
  return math.max(math.min(v, mx), mn)
end

function table.extend(ar1, ar2)
  for _, v in pairs(ar2) do
    table.insert(ar1, v)
  end
end

function die_all(list, global_storage)
  for _, special_entity in pairs(list) do
    if special_entity.valid then
      if global_storage ~= nil then
        global_storage[special_entity.unit_number] = nil
      end
      special_entity.destroy()
    end
  end
end

function preprocess_entities(list)
  for _, entity in pairs(list) do
    if entity.valid then
      if shared.used_specials then
        shared.used_specials[entity.unit_number] = true
      end
      entity.active = false -- for crafting machines
    end
  end
end

function is_titan(name)
  return name:find(shared.titan_prefix, 1, true)
end

function list_players(values)
  -- values is a list of player/character/nil
  local result = {}
  for _, obj in pairs(values) do
    if obj then
      if obj.object_name == "LuaPlayer" then
        table.insert(result, obj)
      elseif obj.player then
        table.insert(result, obj.player)
      end
    end
  end
  return result
end
