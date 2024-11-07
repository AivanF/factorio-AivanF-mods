require("shared")
require("utils")
require("script.worth")

local Lib = require("event_lib")
local lib = Lib.new()

local lab_update_rate = 30
local base_name = "af-reverse-lab"


local function correct_chests(rlab)
  rlab.center = rlab.center or rlab.surface.create_entity{
    name=rlab.main.name.."-center", force="neutral",
    position={x=rlab.position.x+0.2, y=rlab.position.y},
  }
  rlab.input = rlab.input or rlab.surface.create_entity{
    name=base_name.."-chest-input", force="neutral",
    position={x=rlab.position.x-1, y=rlab.position.y},
  }
  rlab.output_packs = rlab.output_packs or rlab.surface.create_entity{
    name=base_name.."-chest-packs", force="neutral",
    position={x=rlab.position.x+1, y=rlab.position.y-1},
  }
  rlab.output_other = rlab.output_other or rlab.surface.create_entity{
    name=base_name.."-chest-other", force="neutral",
    position={x=rlab.position.x+1, y=rlab.position.y+1},
  }
end


local function on_any_built(event)
  local entity = event.created_entity or event.entity or event.destination
  if not (entity and entity.valid) then return end

  if rlabs[entity.name] then
    local unit_number = entity.unit_number
    local bucket = storage.reverse_labs[unit_number % lab_update_rate]
    if not bucket then
      bucket = {}
      storage.reverse_labs[unit_number % lab_update_rate] = bucket
    end
    local rlab = {
      grade = rlabs[entity.name].grade,
      force = entity.force,
      surface = entity.surface,
      position = entity.position,
      main = entity,
      center = center,
      input = nil,
      output_packs = nil,
      output_other = nil,
    }
    correct_chests(rlab)
    bucket[unit_number] = rlab
  end
end


local function safe_destroy_chest(entity)
  if not entity.valid then return end
  if entity.get_item_count() > 0 then
    local new = entity.surface.create_entity{
      name=base_name.."-chest-corpse", force="neutral",
      position=entity.position,
    }
    for _, stack in pairs(entity.get_inventory(defines.inventory.chest).get_contents()) do
      new.insert(stack)
      entity.remove_item(stack)
    end
  end
  entity.destroy()
end


local function on_any_remove(event)
  if rlabs[event.entity.name] then
    local unit_number = event.entity.unit_number
    local bucket = storage.reverse_labs[unit_number % lab_update_rate]
    if bucket and bucket[unit_number] then
      local rlab = bucket[unit_number]
      if rlab.center.valid then rlab.center.destroy() end
      safe_destroy_chest(rlab.input)
      safe_destroy_chest(rlab.output_packs)
      safe_destroy_chest(rlab.output_other)
      bucket[unit_number] = nil
    end
  end
end


local function try_add_pack(rlab, name, count)
  local pack = {name=name, count=count}
  if rlab.output_packs.can_insert(pack) then
    rlab.output_packs.insert(pack)
    -- game.print("// Putting "..name.." x"..count)
    return true
  end
  return false
end


local function play_prob_small(rlab, item_info, prob)
  local done = false
  -- game.print("// play_prob_small for "..item_info.item_name.." with prob="..prob)
  for index, name in pairs(item_info.ingredients) do
    if prob > 1 then
      done = true
      try_add_pack(rlab, name, 1)
      prob = prob - 1
      if not done then break end
    elseif math.random() < prob then
      done = true
      try_add_pack(rlab, name, 1)
      break
    else
      break
    end
  end
  return done
end


local function play_prob_big(rlab, item_info, prob)
  local done = false
  -- game.print("// play_prob_big for "..item_info.item_name.." with prob="..prob)
  local each_prob = prob / #item_info.ingredients
  local each_count = math.floor(each_prob)
  each_prob = each_prob - each_count
  local count
  for index, name in pairs(item_info.ingredients) do
    count = each_count + ((math.random() < each_prob) and 1 or 0)
    try_add_pack(rlab, name, count)
    done = done or count > 0
  end
  return done
end


local function handle_input(rlab, item_info, prod_bonus)
  shuffle(item_info.ingredients) -- maybe make a deep copy to better prevent desync?
  local tech
  if item_info.tech_name then
    tech = rlab.force.technologies[item_info.tech_name]
  end
  local prob = prob_for_force(item_info, rlab.force) * prod_bonus
  local done = false
  if prob <= #item_info.ingredients then
    done = play_prob_small(rlab, item_info, prob)
  else
    done = play_prob_big(rlab, item_info, prob)
  end
  if done then
    local res_prob = settings.global["af-reverse-lab-research-revprob"].value
    res_prob = (res_prob > 0) and (1 / res_prob) or 0
    if math.random() < item_info.prob*res_prob then
      -- game.print("// Reversely researching "..item_info.tech_name)
      local candidates = {}
      if tech then
        candidates = {tech}
        merge(candidates, tech.prerequisites)
      end
      for index, name in pairs(item_info.ingredients) do
        if storage.reverse_items[name] then
          table.insert(candidates, rlab.force.technologies[storage.reverse_items[name].tech_name])
        end
      end
      shuffle(candidates)
      -- TODO: increase technology research progress instead of instant opening
      for _, tech in pairs(candidates) do
        if not tech.researched then
          rlab.force.play_sound{path = "utility/research_completed"}
          rlab.force.print({"af-reverse-lab.researched", tech.name})
          tech.researched = true
          break
        end
      end
    end
  end
end


local function process_a_lab(rlab)
  if not rlab.input.valid then rlab.input = nil end
  if not rlab.output_packs.valid then rlab.output_packs = nil end
  if not rlab.output_other.valid then rlab.output_other = nil end
  correct_chests(rlab)

  if rlab.main.energy < MW then
    rlab.main.power_usage = 0
    return
  end

  local grade_info = rlabs[rlab.grade]
  local pcs_limit = grade_info.max_pcs
  local power_usage = 0
  local item_info, pcs, item_name, have

  for _, stack_info in ipairs(rlab.input.get_inventory(defines.inventory.chest).get_contents()) do
    item_name = stack_info.name
    have = stack_info.count
    item_info = storage.add_override_items[item_name] or storage.reverse_items[item_name]

    if storage.scipacks[item_name] then
      power_usage = power_usage + 1
      local done = rlab.output_packs.insert({name=item_name, count=have})
      rlab.input.remove_item({name=item_name, count=done})

    elseif item_info then
      pcs = math.min(math.floor(have / item_info.need), pcs_limit)
      pcs_limit = pcs_limit - pcs
      power_usage = power_usage + pcs
      if true
        and have >= item_info.need
        and rlab.output_packs.get_inventory(defines.inventory.chest).count_empty_stacks() >= 1
      then
        handle_input(rlab, item_info, pcs * (grade_info.prod_bonus or 1) * settings.global["af-reverse-lab-prob-mult"].value)
        rlab.input.remove_item({name=item_name, count=item_info.need*pcs})
        local pollution_value = item_info.need * (item_info.price or 1) *0.02
        rlab.surface.pollute(rlab.position, pollution_value)
        game.get_pollution_statistics(rlab.surface).on_flow(grade_info.name, pollution_value)
        if pcs_limit <= 0 then break end
      end

    else
      power_usage = power_usage + 1
      local done = rlab.output_other.insert({name=item_name, count=have})
      rlab.input.remove_item({name=item_name, count=done})
    end
  end

  -- A bit less ugly charts
  rlab.main.power_usage = rlab.main.power_usage * 0.7 + 0.3 * power_usage * grade_info.usage / 60
end


local function process_labs()
  correct_global()
  local bucket = storage.reverse_labs[game.tick % lab_update_rate]
  if not bucket then return end
  for unit_number, rlab in pairs(bucket) do
    if rlab.main.valid then
      process_a_lab(rlab)
    else
      game.print("Got invalid Reverse Lab :(")
      if rlab.input.valid then rlab.input.destroy() end
      if rlab.output_packs.valid then rlab.output_packs.destroy() end
      if rlab.output_other.valid then rlab.output_other.destroy() end
      bucket[unit_number] = nil
    end
  end
end


lib:on_event(defines.events.on_tick, process_labs)
lib:on_any_built(on_any_built)
lib:on_any_remove(on_any_remove)

return lib