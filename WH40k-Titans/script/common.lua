require("__core__.lualib.util") -- for table.deepcopy
math2d = require("math2d")
shared = require("shared")
collision_mask_util_extended = require("cmue.collision-mask-util-control")

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

function merge_ingredients_doubles(ingredients)
  local indices = {}
  local result = {}
  local prev, name, count
  for _, obj in pairs(ingredients) do
    name = obj[1] or obj.name
    if not name then
      error("Got nil name in: "..serpent.line(ingredients))
    end
    count = math.floor(obj[2] or obj.count)
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

function orientation_to_radians(ori)
  -- https://lua-api.factorio.com/latest/concepts.html#RealOrientation
  --[[
  The smooth orientation is a float in the range [0, 1), starting at the top and going clockwise.
  This means a value of 0 indicates "north", a value of 0.5 indicates "south".
  ]]--
  return (ori-0.25) * 2 * math.pi
end

function points_to_orientation(a, b)
  return 0.25 +math.atan2(b.y-a.y, b.x-a.x) /math.pi /2
end

function orientation_diff(src, dst)
  if dst - src > 0.5 then src = src + 1 end
  if src - dst > 0.5 then dst = dst + 1 end
  return dst - src
end

function point_orientation_shift(ori, length)
  ori = -ori +0.25
  ori = ori * 2 * math.pi
  return {length*math.cos(ori), -length*math.sin(ori)}
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

function is_supplier(name)
  return name:find(shared.aircraft_supplier, 1, true)
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

math2d.bounding_box.random_point = function(box)
  return {
    math.random(box.left_top.x, box.right_bottom.x),
    math.random(box.left_top.y, box.right_bottom.y)
  }
end

function position_scatter(source, scatter)
  return math2d.position.add(
    source, {math.random(-scatter, scatter), math.random(-scatter, scatter)}
  )
end

function show_ammo_transfer(entity_from, entity_to, ammo_name, ammo_count, scatter)
  entity_to.surface.create_entity{
    name="flying-text", position=position_scatter(entity_to.position, scatter),
    -- text="[item="..ammo_name.."]",
    text={"item-name."..ammo_name},
  }

  entity_from.surface.create_entity{
    name = shared.item_proj,
    position = entity_from.position,
    target = position_scatter(entity_to.position, scatter),
    speed = 0.2 + math.random() * 0.3,
  }
end

function make_titled_text(title, text)
  return {"?",
    {"", "[font=default-bold]", title, "[/font]\n", text},
    {"", "[font=default-bold]", title, "[/font]"},
  }
end
