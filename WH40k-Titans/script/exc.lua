require("script/common")
local lib_ruins = require("script/ruins")
local Lib = require("script/event_lib")
local lib = Lib.new()

exc_update_rate = UPS
local exc_unit_time = heavy_debugging and 5 or 60
local exc_half_size = 2

function lib.register_excavator(entity)
  local world, sector, ruin_entity, ruin_info
  ruin_entity = entity.surface.find_entity(shared.mod_prefix.."titan-corpse", entity.position)
  world = ctrl_data.by_surface[entity.surface.index]
  sector = lib_ruins.get_sector(world, entity.position)

  if world and ruin_entity then
    ruin_info = ctrl_data.ruins[ruin_entity.unit_number]
  end
  local exc_info = {
    unit_number = entity.unit_number,
    entity = entity,
    world = world,
    sector = sector,
    ruin_entity = ruin_entity,
    ruin_info = ruin_info,
    progress = 0,
  }
  ctrl_data.excavator_index[entity.unit_number] = exc_info
  bucks.save(ctrl_data.excavator_buckets, exc_update_rate, entity.unit_number, exc_info)
  if ruin_info then
    entity.surface.create_entity{
      name="flying-text", position=entity.position,
      text="Expected details: "..bucks.total_count(ruin_info.details).." ammo: "..bucks.total_count(ruin_info.ammo),
    }
    ruin_info.exc_info = exc_info
  else
    entity.surface.create_entity{
      name="flying-text", position=entity.position,
      text="Placed excavator without a ruin...",
    }
  end
  entity.set_recipe(shared.excavation_recipe)
  entity.recipe_locked = true
  entity.active = false
end

function lib.excavator_removed(unit_number)
  ctrl_data.excavator_index[unit_number] = nil
  bucks.remove(ctrl_data.excavator_buckets, exc_update_rate, unit_number)
end

local function process_an_excavator(exc_info)
  local entity = exc_info.entity
  local recipe = entity.get_recipe()
  if recipe and recipe.name == shared.excavation_recipe then
    if not exc_info.ruin_entity then 
      entity.active = false
      return
    end
    if not exc_info.ruin_entity.valid then
      entity.active = false
      exc_info.ruin_entity = nil
      return
    end

    ----- Doing
    exc_info.progress = exc_info.progress + exc_update_rate/UPS /exc_unit_time
    entity.active = true

    if exc_info.progress >= 1 then
      ----- Done
      local item_name, count = lib_ruins.ruin_extract(exc_info.ruin_info, exc_info.ruin_entity)
      if item_name and count > 0 then
        game.print("excavator done, changing the recipe to "..serpent.line(item_name).." x"..count)
        entity.set_recipe(item_name)
        local inv = entity.get_output_inventory()
        inv.insert({name=item_name, count=count})
      end
      exc_info.progress = 0

      if exc_info.ruin_entity == nil then
        -- TODO: notify force?
        entity.surface.create_entity{
          name="flying-text", position=entity.position,
          text="Excavator finished!",
        }
      end
    end

    entity.crafting_progress = exc_info.progress

  else
    ----- Waiting
    entity.active = false
    local inv = entity.get_output_inventory()
    if inv.get_item_count() < 1 then
      inv = entity.get_inventory(defines.inventory.assembling_machine_input)
      if inv.get_item_count() < 1 then
        entity.surface.create_entity{
          name="flying-text", position=entity.position,
          text="Excavator resterted",
        }
        exc_info.progress = 0
        entity.set_recipe(shared.excavation_recipe)
      end
    end
  end
  -- TODO: update guis?
end

local function process_excavators()
  local bucket = bucks.get_bucket(ctrl_data.excavator_buckets, exc_update_rate, game.tick)
  if not bucket then return end
  for unit_number, exc_info in pairs(bucket) do
    if exc_info.entity.valid then
      process_an_excavator(exc_info)
    else
      lib.excavator_removed(exc_info.unit_number)
    end
  end
end

lib:on_event(defines.events.on_tick, process_excavators)


lib:on_event(defines.events.on_gui_opened, function(event)
  local player = game.get_player(event.player_index)
  if event.entity and ctrl_data.excavator_index[event.entity.unit_number] then
    -- player.opened = nil
    -- TODO: add custom GUI
  end
end)

return lib