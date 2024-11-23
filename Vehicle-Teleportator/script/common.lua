local math2d = require("__core__.lualib.math2d")

local default_fuel_categories = {
  -- ["chemical"] = true,
  -- ["processed-chemical"] = true,  -- AAI Industry
  -- ["vehicle-fuel"] = true,  -- Krastorio2
  ["nuclear"] = true,
  -- ["fusion"] = true,  -- too expensive without custom remaining_burning_fuel
}

--[[
https://lua-api.factorio.com/latest/classes/LuaEntity.html

https://lua-api.factorio.com/latest/classes/LuaBurner.html
https://lua-api.factorio.com/latest/classes/LuaInventory.html
https://lua-api.factorio.com/latest/classes/LuaItemPrototype.html#fuel_value

https://lua-api.factorio.com/latest/classes/LuaEquipmentGrid.html
https://lua-api.factorio.com/latest/classes/LuaEquipment.html
]]--

-- Do not count too weak fuel to prevent long calculations
-- TODO: optimise algorithm, burn chunks of items at once
local MIN_FUEL_VALUE = 500000  -- at least 50KJ

local function value_threshold(value, threshold)
  if value >= threshold then return value end
  return 0
end

function calc_vehicle_fuel_energy(entity)
  local total, fuel_categories
  if entity.burner then
    total = entity.burner.remaining_burning_fuel
    fuel_categories = entity.burner.fuel_categories
    local fuel_inv = entity.burner and entity.burner.inventory
    if fuel_inv then
      for _, stack in ipairs(fuel_inv.get_contents()) do
        total = total + value_threshold(prototypes.item[stack.name].fuel_value, MIN_FUEL_VALUE) * stack.count
      end
    end
  else
    -- for spidertrons
    total = 0
    fuel_categories = default_fuel_categories
  end
  local trunk = entity.get_inventory(defines.inventory.car_trunk) or entity.get_inventory(defines.inventory.spider_trunk)
  if trunk then
    for _, stack in ipairs(trunk.get_contents()) do
      if fuel_categories[prototypes.item[stack.name].fuel_category] then
        total = total + value_threshold(prototypes.item[stack.name].fuel_value, MIN_FUEL_VALUE) * stack.count
      end
    end
  end
  if prototypes.entity[entity.name].burner_prototype then
    total = total * prototypes.entity[entity.name].burner_prototype.effectivity
  end
  return total
end

local function try_take_a_fuel(inv)
  for _, stack in ipairs(inv.get_contents()) do
    if prototypes.item[stack.name].fuel_value >= MIN_FUEL_VALUE then
      inv.remove({name=stack.name, count=1})
      return stack.name
    end
  end
  return nil
end

local function try_take_a_fuel_filtered(inv, fuel_categories)
  for _, stack in ipairs(inv.get_contents()) do
    if true
      and prototypes.item[stack.name].fuel_value >= MIN_FUEL_VALUE
      and fuel_categories[prototypes.item[stack.name].fuel_category]
    then
      inv.remove({name=stack.name, count=1})
      return stack.name
    end
  end
  return nil
end

function take_vehicle_fuel_energy(entity, total_change)
  local trunk = entity.get_inventory(defines.inventory.car_trunk) or entity.get_inventory(defines.inventory.spider_trunk)
  local fuel_inv = entity.burner and entity.burner.inventory

  if fuel_inv then
    local remaining, new_fuel, old_fuel
    local iterations = 0
    local eff = prototypes.entity[entity.name].burner_prototype.effectivity
    total_change = total_change / eff
    while total_change > 0 do
      iterations = iterations + 1
      if iterations > 5000 then error("StackOverflow :(") end
      remaining = entity.burner.remaining_burning_fuel
      if remaining > 0 then
        if total_change > remaining then
          total_change = total_change - remaining
          entity.burner.remaining_burning_fuel = 0

          old_fuel = entity.burner.currently_burning
          old_fuel = old_fuel and old_fuel.name.name
          old_fuel = old_fuel and prototypes.item[old_fuel].burnt_result
          if old_fuel then
            if entity.burner.burnt_result_inventory.insert({name=old_fuel, count=1}) < 1 then
              trunk.insert({name=old_fuel, count=1})
            end
          end
        else
          entity.burner.remaining_burning_fuel = remaining - total_change
          total_change = 0
        end
      end

      if entity.burner.remaining_burning_fuel < 1 then
        new_fuel = try_take_a_fuel_filtered(trunk, entity.burner.fuel_categories) or try_take_a_fuel(fuel_inv)
        if new_fuel == nil then return false end
        entity.burner.currently_burning = new_fuel
        entity.burner.remaining_burning_fuel = prototypes.item[new_fuel].fuel_value
      end
    end
    return true

  else  -- no burner
    local iterations = 0
    while total_change > 0 do
      iterations = iterations + 1
      if iterations > 5000 then error("StackOverflow :(") end
      local new_fuel = try_take_a_fuel_filtered(trunk, default_fuel_categories)
      if new_fuel then
        local old_fuel = prototypes.item[new_fuel].burnt_result
        if old_fuel then
          trunk.insert({name=old_fuel, count=1})
        end
        -- TODO: calc and store remaining_burning_fuel in car_info?
        total_change = total_change - prototypes.item[new_fuel].fuel_value
      else
        return false
      end
    end
    return true
  end
end


function calc_equipment_energy(grid, prefix)
  local total = 0
  for _, obj in ipairs(grid.equipment) do
    if prefix == nil or obj.name:find(prefix, 1, true) then
      total = total + obj.energy
    end
  end
  return total
end

function calc_equipment_max_energy(grid, prefix, nil_over_zero)
  local total = 0
  for _, obj in ipairs(grid.equipment) do
    if prefix == nil or obj.name:find(prefix, 1, true) then
      total = total + obj.max_energy
    end
  end
  if total == 0 and nil_over_zero then
    return nil
  end
  return total
end

function take_vehicle_equipment_energy(grid, total_change, prefix)
  local total_have = calc_equipment_energy(grid, prefix)
  if total_have < total_change then return false end
  local cf = 1 - total_change / total_have
  for _, obj in ipairs(grid.equipment) do
    if prefix == nil or obj.name:find(prefix, 1, true) then
      obj.energy = obj.energy * cf
    end
  end
  return true
end


function calc_inventory_weight(inventory)
  if inventory == nil then return 0 end
  local total = 0
  for _, stack in ipairs(inventory.get_contents()) do
    total = total + prototypes.item[stack.name].weight * stack.count
  end
  return total
end

function calc_character_weight(entity)
  if entity == nil then return 0 end
  return 50000
    + calc_inventory_weight(entity.get_inventory(defines.inventory.character_main))
    + calc_inventory_weight(entity.get_inventory(defines.inventory.character_trash))
end

function calc_vehicle_weight(entity)
  local total = 0
  -- total = total + math.max(prototypes.entity[entity.name].weight, 500) * 500
  -- TODO: maybe consider equipment grid too?
  -- TODO: consider vehicle+characters ammo
  total = total + calc_inventory_weight(
    entity.get_inventory(defines.inventory.car_trunk) or
    entity.get_inventory(defines.inventory.spider_trunk))
  total = total + calc_character_weight(entity.get_driver())
  total = total + calc_character_weight(entity.get_passenger())
  return total
end


function player_maybe_character(obj)
  if obj == nil then
    return nil
  elseif obj.object_name == "LuaPlayer" then
    return obj
  elseif obj.player then
    return obj.player
  end
  return nil
end


function position_scatter(source, scatter)
  return math2d.position.add(
    source, {math.random(-scatter, scatter), math.random(-scatter, scatter)}
  )
end

function position_to_chunk(position)
  return {
    x=math.floor(position.x / 32),
    y=math.floor(position.y / 32)
  }
end

function make_titled_text(title, text)
  return {"?",
    {"", "[font=default-bold]", title, "[/font]\n", text},
    {"", "[font=default-bold]", title, "[/font]"},
  }
end
