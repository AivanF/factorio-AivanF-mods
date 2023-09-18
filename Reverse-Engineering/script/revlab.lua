require("__core__.lualib.util")
require("script.worth")
local Lib = require("event_lib")
local lib = Lib.new()

local lab_update_rate = 15
local name_main = "af-reverse-lab"

function shuffle(t)
  for i = #t, 2, -1 do
    local j = math.random(i)
    t[i], t[j] = t[j], t[i]
  end
end

local function correct_chests(rlab)
  rlab.input = rlab.input or rlab.surface.create_entity{
    name=name_main.."-chest-input", force="neutral",
    position={x=rlab.position.x-1, y=rlab.position.y},
  }
  rlab.output_packs = rlab.output_packs or rlab.surface.create_entity{
    name=name_main.."-chest-packs", force="neutral",
    position={x=rlab.position.x+1, y=rlab.position.y-1},
  }
  rlab.output_other = rlab.output_other or rlab.surface.create_entity{
    name=name_main.."-chest-other", force="neutral",
    position={x=rlab.position.x+1, y=rlab.position.y+1},
  }
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
    local rlab = {
      force = entity.force,
      surface = entity.surface,
      position = entity.position,
      main = entity,
      input = nil,
      output_packs = nil,
      output_other = nil,
    }
    correct_chests(rlab)
    bucket[unit_number] = rlab
  end
end

local function on_any_remove(event)
  if event.entity.name == name_main then
    local unit_number = event.entity.unit_number
    local bucket = global.reverse_labs[unit_number % lab_update_rate]
    if bucket and bucket[unit_number] then
      local rlab = bucket[unit_number]
      if rlab.input.valid then rlab.input.destroy() end
      if rlab.output_packs.valid then rlab.output_packs.destroy() end
      if rlab.output_other.valid then rlab.output_other.destroy() end
      bucket[unit_number] = nil
    end
  end
end

local function try_add_pack(rlab, name, count, anyway)
  local pack = {name=name, count=count}
  if anyway or rlab.output_packs.can_insert(pack) then
    rlab.output_packs.insert(pack)
    -- game.print("Putting "..name.." x"..count)
    return true
  end
  return false
end

local function play_prob_small(rlab, item_info, prob)
  local done = false
  -- game.print("play_prob_small for "..item_info.item_name.." with prob="..prob)
  for index, name in pairs(item_info.ingredients) do
    if prob > 1 then
      done = try_add_pack(rlab, name, 1, done)
      prob = prob - 1
      if not done then break end
    elseif math.random() < prob then
      done = try_add_pack(rlab, name, 1, done)
      break
    else
      break
    end
  end
  return done
end

local function play_prob_big(rlab, item_info, prob)
  local done = false
  -- game.print("play_prob_big for "..item_info.item_name.." with prob="..prob)
  local each_prob = prob / #item_info.ingredients
  local each_count = math.floor(each_prob)
  each_prob = each_prob - each_count
  for index, name in pairs(item_info.ingredients) do
    done = try_add_pack(rlab, name, each_count + ((math.random() < each_prob) and 1 or 0), done)
    if not done then break end
  end
  return done
end

local function handle_input(rlab, item_info)
  shuffle(item_info.ingredients)
  local prob = item_info.prob
  local tech = rlab.force.technologies[item_info.tech_name]
  if tech.researched then
    prob = prob / 2
  end
  local done = false
  if prob <= #item_info.ingredients then
    done = play_prob_small(rlab, item_info, prob)
  else
    done = play_prob_big(rlab, item_info, prob)
  end
  if done then
    if math.random() < item_info.prob/200 then
      local candidates = {tech}
      merge(candidates, tech.prerequisites)
      for index, name in pairs(item_info.ingredients) do
        if global.reverse_items[name] then
          table.insert(candidates, rlab.force.technologies[global.reverse_items[name].tech_name])
        end
      end
      shuffle(candidates)
      for _, tech in pairs(candidates) do
        if not tech.researched then
          rlab.force.play_sound{path = "utility/research_completed"}
          rlab.force.print({"af-reverse-lab-researched", tech.name})
          tech.researched = true
          break
        end
      end
    end
  end
  return done
end

local function process_a_lab(rlab)
  if not rlab.input.valid then rlab.input = nil end
  if not rlab.output_packs.valid then rlab.output_packs = nil end
  if not rlab.output_other.valid then rlab.output_other = nil end
  correct_chests(rlab)

  -- TODO: check and manage electricity
  local item_info, pack
  for item_name, have in pairs(rlab.input.get_inventory(defines.inventory.chest).get_contents()) do
    item_info = not global.add_ignore_items[item_name] and (global.add_override_items[item_name] or global.reverse_items[item_name])
    if item_info then
      if have >= item_info.need and handle_input(rlab, item_info)then
        rlab.input.remove_item({name=item_name, count=item_info.need})
      end
    elseif scipacks[item_name] then
      local done = rlab.output_packs.insert({name=item_name, count=have})
      rlab.input.remove_item({name=item_name, count=done})
    else
      local done = rlab.output_other.insert({name=item_name, count=have})
      rlab.input.remove_item({name=item_name, count=done})
    end
  end
end

local function correct_global()
  if not global.add_ignore_items then global.add_ignore_items = {} end
  if not global.add_override_items then global.add_override_items = {} end
  if not global.reverse_labs then global.reverse_labs = {} end
  if not global.reverse_items and game then
    global.reverse_items = {}
    cache_data()
  end
end

local function process_labs()
  correct_global()
  local bucket = global.reverse_labs[game.tick % lab_update_rate]
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

lib:on_configuration_changed(function()
  global.reverse_items = nil
  global.add_ignore_items = nil
  global.add_override_items = nil
end)


local interface = {
  add_ignore_items = function(names)
    deep_merge(global.add_ignore_items, from_key_list(names, true))
  end,
  add_override_item = function(item_name, item_info)
    global.add_override_items[item_name] = item_info
  end,
  hide_pots = function()
    return mining_depot.hide_pots()
  end,
}

if not remote.interfaces["reverse_labs"] then
  remote.add_interface("reverse_labs", interface)
end

return lib