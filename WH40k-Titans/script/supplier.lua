local lib_ruins = require("script/ruins")

local Lib = require("script/event_lib")
lib_spl = Lib.new()

local supplier_update_rate = UPS
local supplier_base_max_weight = 5 * 1000
local supplying_radius = 20


function lib_spl.register_supplier(entity)
  if ctrl_data.titans[entity.unit_number] then
    return ctrl_data.titans[entity.unit_number]
  end

  local supplier_info = {
    unit_number = entity.unit_number,
    entity = entity,
    force = entity.force,
    surface = entity.surface,
    inventory = {}, -- ammo_name => count
    disabled_ammo = {}, -- ammo_name => bool; nil==false
    supplying = false,
  }

  bucks.save(ctrl_data.supplier_buckets, supplier_update_rate, entity.unit_number, supplier_info)
  ctrl_data.supplier_index[entity.unit_number] = supplier_info

  -- game.print("register_supplier "..entity.unit_number)

  return supplier_info
end


local function supplier_death(supplier_info)
  local details = {}
  local ammo = {}
  for _, obj in pairs(prototypes.recipe[shared.aircraft_supplier].ingredients) do
    table.insert(details, {obj.name, obj.amount})
  end
  for ammo_name, ammo_count in pairs(supplier_info.inventory) do
    table.insert(ammo, {name=ammo_name, count=ammo_count})
  end
  lib_ruins.spawn_ruin(supplier_info.surface, {
    position = supplier_info.entity.position,
    img = shared.mod_prefix.."corpse-supplier",
    details = merge_ingredients_doubles(details),
    ammo = merge_ingredients_doubles(ammo),
  })
end


function lib_spl.supplier_removed_by_number(unit_number, is_death)
  local supplier_info = ctrl_data.supplier_index[unit_number]
  if supplier_info == nil then return end
  lib_spl.supplier_removed(supplier_info, is_death)
end


function lib_spl.supplier_removed(supplier_info, is_death)
  local unit_number = supplier_info.entity.unit_number

  if is_death then
    supplier_death(supplier_info)
  end

  lib_spl.remove_supplier_gui_by_supplier(supplier_info)

  ctrl_data.supplier_index[unit_number] = nil
  bucks.remove(ctrl_data.supplier_buckets, supplier_update_rate, unit_number)
end


lib_spl:on_event(defines.events.script_raised_destroy, function(event)
  lib_spl.supplier_removed_by_number(event.entity.unit_number)
end)


function lib_spl.supplier_entity_replaced(old_entity, new_entity)
  local supplier_info = ctrl_data.supplier_index[old_entity.unit_number]
  -- game.print("supplier_entity_replaced "..old_entity.unit_number.." to "..new_entity.unit_number.." as "..serpent.line(supplier_info))
  if supplier_info == nil then return end

  supplier_info.entity = new_entity
  supplier_info.unit_number = new_entity.unit_number

  ctrl_data.supplier_index[old_entity.unit_number] = nil
  bucks.remove(ctrl_data.supplier_buckets, supplier_update_rate, old_entity.unit_number)

  bucks.save(ctrl_data.supplier_buckets, supplier_update_rate, new_entity.unit_number, supplier_info)
  ctrl_data.supplier_index[new_entity.unit_number] = supplier_info
end


function lib_spl.supplier_ammo_fulfill(supplier_info)
  for _, ammo_name in ipairs(shared.ammo_list) do
    supplier_info.inventory[ammo_name] = math.floor(supplier_base_max_weight / shared.ammo_weights[ammo_name])
  end
end


function lib_spl.supplier_ammo_clear(supplier_info)
  for _, ammo_name in ipairs(shared.ammo_list) do
    supplier_info.inventory[ammo_name] = 0
  end
end


function lib_spl.count_weight(supplier_info)
  local total_count = 0
  for ammo_name, count in pairs(supplier_info.inventory) do
    total_count = total_count + (shared.ammo_weights[ammo_name] or 0) * count
  end
  return total_count
end

function lib_spl.get_max_weight(supplier_info)
  return supplier_base_max_weight * (1 + lib_tech.get_research_level(supplier_info.entity.force.index, shared.supplier_cap_research))
end

function lib_spl.count_free_weight(supplier_info)
  return lib_spl.get_max_weight(supplier_info) - lib_spl.count_weight(supplier_info)
end


local function find_titans_guns(supplier_info)
  local options = supplier_info.surface.find_entities_filtered{
    position=supplier_info.position, radius=supplying_radius,
    type=shared.titan_base_type, force=supplier_info.force,
  }
  local fill_targets = {} -- ammo_name => int => {gun_info=gun_info, need=int}
  local titan_info, weapon_type, ammo_need
  for _, titan_entity in pairs(options) do
    titan_info = ctrl_data.titans[titan_entity.unit_number]
    if titan_info then
      for _, gun_info in ipairs(titan_info.guns) do
        weapon_type = shared.weapons[gun_info.name]
        ammo_need = weapon_type.inventory and (weapon_type.inventory - gun_info.ammo_count) or 0
        if ammo_need > 0 then
          fill_targets[weapon_type.ammo] = fill_targets[weapon_type.ammo] or {}
          table.append(fill_targets[weapon_type.ammo], {gun_info=gun_info, need=ammo_need, entity=titan_info.entity})
        end
      end
    end
  end
  return fill_targets
end


local function get_supplier_transfer_limit(supplier_info)
  return shared.supplier_exch_by_level[lib_tech.get_research_level(supplier_info.entity.force.index, shared.supplier_cap_research)]
end


local function process_single_supplier(supplier_info)
  supplier_info.position = supplier_info.entity.position

  supplier_info.supplying = false
  local fill_targets = find_titans_guns(supplier_info)
  local ammo_fill_targets, transfer_now, ammo_got

  for ammo_name, ammo_count in pairs(supplier_info.inventory) do
    ammo_fill_targets = fill_targets[ammo_name]
    if ammo_count > 0 and ammo_fill_targets ~= nil then
      supplier_info.supplying = true
      transfer_now = math.min(
        math.floor(get_supplier_transfer_limit(supplier_info) / (shared.ammo_weights[ammo_name] or 1)),
        math.ceil(ammo_count / #ammo_fill_targets)
      )
      for _, ammo_fill_target_info in ipairs(ammo_fill_targets) do
        ammo_got = math.min(transfer_now, ammo_fill_target_info.need, ammo_count)
        ammo_fill_target_info.gun_info.ammo_count = ammo_fill_target_info.gun_info.ammo_count + ammo_got
        ammo_count = ammo_count - ammo_got
        show_ammo_transfer(supplier_info.entity, ammo_fill_target_info.entity, ammo_name, got_ammo, 4)
      end
    end
    if ammo_count <= 0 then
      supplier_info.inventory[ammo_name] = nil
    else
      supplier_info.inventory[ammo_name] = ammo_count
    end
  end
end


local function process_suppliers()
  if not storage.active_mods_cache then
    storage.active_mods_cache = script.active_mods
    preprocess_ingredients()
  end

  local bucket = bucks.get_bucket(ctrl_data.supplier_buckets, supplier_update_rate, game.tick)
  if not bucket then return end
  for uid, supplier_info in pairs(bucket) do
    if supplier_info.entity and supplier_info.entity.valid then
      process_single_supplier(supplier_info)
    end
  end
end


lib_spl:on_event(defines.events.on_tick, process_suppliers)

require("script/supplier_ui")
return lib_spl