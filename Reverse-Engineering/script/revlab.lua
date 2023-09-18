local Lib = require("script/event_lib")
local lib = Lib.new()

local lab_update_rate = 15
local name_main = "af-reverse-lab"
local name_chest = name_main.."-chest"

function merge(a, b, over)
  for k, v in pairs(b) do
    if a[k] == nil or over then
      a[k] = v
    end
  end
  return a
end

function shuffle(t)
  for i = #t, 2, -1 do
    local j = math.random(i)
    t[i], t[j] = t[j], t[i]
  end
end

local function on_any_built(event)
  local entity = event.created_entity or event.entity or event.destination
  if not (entity and entity.valid) then return end

  if entity.name == name_main then
    local unit_number = entity.unit_number
    local bucket = global.reverse_labs[unit_number % lab_update_rate]
    if not bucket then
      bucket = {}
      global.reverse_labs[unit_number % lab_update_rate] = bucket
    end
    local surface = entity.surface
    local position = entity.position
    local input = surface.create_entity{
      name=name_chest, force="neutral",
      position={x=position.x-0.5, y=position.y},
    }
    local output_packs = surface.create_entity{
      name=name_chest, force="neutral",
      position={x=position.x+0.5, y=position.y-1},
    }
    local output_other = surface.create_entity{
      name=name_chest, force="neutral",
      position={x=position.x+0.5, y=position.y+1},
    }
    bucket[unit_number] = {
      force = entity.force,
      main = entity,
      input = input,
      output_packs = output_packs,
      output_other = output_other,
    }
  end
end

local function on_any_remove(event)
  if event.entity.name == name_main then
    local unit_number = event.entity.unit_number
    local bucket = global.reverse_labs[unit_number % lab_update_rate]
    if bucket and bucket[unit_number] then
      local info = bucket[unit_number]
      if info.input.valid then info.input.destroy() end
      if info.output_packs.valid then info.output_packs.destroy() end
      if info.output_other.valid then info.output_other.destroy() end
      bucket[unit_number] = nil
    end
  end
end

local function get_final_price(prices)
  local result = 1
  for _, value in pairs(prices) do
    value = math.min(5, math.max(1, math.floor(value)))
    result = math.max(result, value)
  end
  return result
end

local function cache_data()
  local total = 0
  local item_info, prices, total_price, ingredients
  for tech_name, tech_data in pairs(game.technology_prototypes) do
    for _, modifier in pairs(tech_data.effects) do
      if modifier.type == "unlock-recipe" then
        for _, prod in pairs(game.recipe_prototypes[modifier.recipe].products) do
          if prod.type == "item" then
            total = total + 1
            item_info = global.reverse_items[prod.name] or {}
            global.reverse_items[prod.name] = item_info
            total_price = 0
            ingredients = {}
            for _, ingr in pairs(tech_data.research_unit_ingredients) do
              if ingr.type == "item" then
                table.insert(ingredients, ingr.name)
                total_price = total_price + ingr.amount
              end
            end
            prices = {
              1 / (prod.probability or 1),
              math.log10(total_price / 3),
            }
            item_info[tech_name] = {
              price = get_final_price(prices),
              ingredients = ingredients,
            }
          end
        end
      end
    end
  end
  game.print("Cached "..total.." items")
end

local function get_item_tech(item_name)
  if global.reverse_items[item_name] then
    local item_info = global.reverse_items[item_name]
    -- TODO: if multiple, return smallest one!
    for tech_name, tech_data in pairs(item_info) do
      return tech_name, tech_data.ingredients
    end
  end
  return nil, nil
end

local function process_labs()
  if not global.reverse_labs then global.reverse_labs = {} end
  if not global.reverse_items then
    global.reverse_items = {}
    cache_data()
  end

  local bucket = global.reverse_labs[game.tick % lab_update_rate]
  if not bucket then return end
  for unit_number, info in pairs(bucket) do
    if info.main.valid then
      -- TODO: check chests are valid
      -- TODO: check and manage electricity
      local tech_name, packs
      for item_name, count in pairs(info.input.get_inventory(defines.inventory.chest).get_contents()) do
        tech_name, packs = get_item_tech(item_name)
        if tech_name then
          shuffle(packs)
          -- if tech_name is researched by this force, give less items
          local pack = {name=packs[1], count=1} -- TODO: pick multiple by price
          if info.output_packs.can_insert(pack) then
            info.output_packs.insert(pack)
            info.input.remove_item({name=item_name, count=1})
          end
        else
          if info.output_other.can_insert({name=item_name, count=1}) then
            info.output_other.insert({name=item_name, count=1})
            info.input.remove_item({name=item_name, count=1})
          end
        end
      end
    else
      game.print("Got invalid Reverse Lab :(")
      if info.input.valid then info.input.destroy() end
      if info.output_packs.valid then info.output_packs.destroy() end
      if info.output_other.valid then info.output_other.destroy() end
      bucket[unit_number] = nil
    end
  end
end

lib:on_event(defines.events.on_tick, process_labs)

lib:on_event({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}, on_any_built)

lib:on_event({
  defines.events.on_player_mined_entity,
  defines.events.on_robot_mined_entity,
  defines.events.on_entity_died,
  defines.events.script_raised_destroy,
}, on_any_remove)

-- lib:on_init(function()
--   global.reverse_labs = {}
--   global.reverse_items = {}
-- end)

-- lib:on_configuration_changed(function()
--   global.reverse_labs = {}
--   global.reverse_items = {}
-- end)


return lib