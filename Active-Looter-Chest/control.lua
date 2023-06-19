require "shared"

local radius = 0
local show_circles = false
local max_shift = 0

local chest_entity = nil
local surface = nil
local signal_names = nil
local tx = 0
local ty = 0
local corrected = false
local any_item = false
local enabled = false

local alc_chests = {
  [basic_chest_name] = true,
  [signals_chest_name] = true,
  [logistic_chest_name] = true,
}

local scan_update_rate = settings.startup["af-alc-scan-update-rate"].value
local loot_corpses = settings.startup["af-alc-loot-corpses"].value

local ttl_1 = scan_update_rate + 1
local ttl_2 = 1


local take_item = function(chest_entity, source_entity, stack)
  -- rendering.draw_line{color={r=0.5,g=0.1,b=0.5,a=1}, width=2, from=chest_entity, to=source_entity.position, surface=surface, time_to_live=12, forces={chest_entity.force}}

  if show_circles then
    -- line from chest to the searching area
    rendering.draw_line{color={r=0.5,g=0.1,b=0.5,a=1}, width=2,
      from=chest_entity, to={x=tx,y=ty}, surface=surface, time_to_live=ttl_2, forces={chest_entity.force}}

    -- circles
    -- rendering.draw_circle{color={r=0.5,g=0.1,b=0.5,a=1}, radius=0.5, width=1,
    --   filled=false, target={x=tx,y=ty}, surface=surface, time_to_live=12, forces={chest_entity.force}, draw_on_ground=true, only_in_alt_mode=true}
    rendering.draw_circle{color={r=0.1,g=0.02,b=0.1,a=0.05}, radius=radius, width=1,
      filled=true, target={x=tx,y=ty}, surface=surface, time_to_live=ttl_2, forces={chest_entity.force}, draw_on_ground=true, only_in_alt_mode=true}
  end

  -- new line one
  if corrected then
    rendering.draw_line{color={r=0.5,g=0.1,b=0.5,a=1}, width=2,
      from=chest_entity, to={x=tx,y=ty}, surface=surface, time_to_live=ttl_2, forces={chest_entity.force}}
  end

  -- standard one
  rendering.draw_line{color={r=0.5,g=0.1,b=0.5,a=1}, width=2,
    from={x=tx,y=ty}, to=source_entity.position, surface=surface, time_to_live=ttl_2, forces={chest_entity.force}}

  -- Loot
  chest_entity.insert(stack)
end


function process_a_chest(chest_entity)
  surface = chest_entity.surface

  local signals = chest_entity.get_merged_signals()

  signal_names = {} -- for filters

  -- Target position
  tx = chest_entity.position.x
  ty = chest_entity.position.y
  -- Shifting
  local sx, sy = 0, 0
  local sm = 0 -- X radius
  local sn = 0 -- Y radius
  local sr = 0 -- radius
  local sa = 0 -- alpha, angle from north, it's Factorio

  any_item = false
  enabled = true
  
  if signals then
    for i, signal in pairs (signals) do
      local signalID = signal.signal
      local count = signal.count
      local signal_type = signalID.type
      local signal_name = signalID.name

      if signal_type == "item" then
        -- TODO: treat meat differently?
        signal_names[#signal_names+1] = signal_name

      elseif signal_type == "virtual" then
        if signal_name == "signal-X" then
          sx = sx + count
        elseif signal_name == "signal-Y" then
          sy = sy + count
        elseif signal_name == "signal-M" then
          sm = sm + count
        elseif signal_name == "signal-N" then
          sn = sn + count
        elseif signal_name == "signal-R" then
          sr = sr + count
        elseif signal_name == "signal-A" then
          sa = sa + count
        elseif signal_name == "signal-dot" then
          any_item = count > 0
        elseif signal_name == "signal-check" then
          enabled = count >= 0
        end
      end
    end
  end

  if not enabled then
    return
  end

  any_item = any_item or #signal_names == 0

  if sm == 0 then sm = sr end
  if sn == 0 then sn = sr end

  if sm > 0 or sn > 0 then
    local angle = math.rad(90 - sa)
    sx = sx + sm * math.cos (angle) -- it's easy
    sy = sy - sn * math.sin (angle) -- positive is south in Factorio world
  end

  local sl = math.abs(sx) + math.abs(sy)
  if sl > max_shift then
    local scale = max_shift / sl
    sx = math.floor(sx * scale)
    sy = math.floor(sy * scale)
  end

  local corrected = sx ~= 0 or sy ~= 0
  tx = tx + sx
  ty = ty + sy
  local areaToCheck = {left_top = {tx-radius, ty-radius}, right_bottom = {tx+radius, ty+radius}}
  
  if show_circles then
    rendering.draw_line{color={r=0.5,g=0.1,b=0.5,a=1}, width=2,
      from=chest_entity, to={x=tx,y=ty}, surface=surface, time_to_live=ttl_1, forces={chest_entity.force}, draw_on_ground=true, only_in_alt_mode=true}
    rendering.draw_circle{color={r=0.5,g=0.1,b=0.5,a=1}, radius=radius, width=2,
      filled=false, target={x=tx,y=ty}, surface=surface, time_to_live=ttl_1, forces={chest_entity.force}, draw_on_ground=true, only_in_alt_mode=true}
    -- Show shifted center
    if corrected then
    rendering.draw_circle{color={r=0.5,g=0.1,b=0.5,a=1}, radius=0.5, width=2,
      filled=false, target={x=tx,y=ty}, surface=surface, time_to_live=ttl_1, forces={chest_entity.force}, draw_on_ground=true, only_in_alt_mode=true}
    end
  end

  -- // Debugging //
  -- local player = game.get_player(1)
  -- rendering.draw_text{text="Chests: "..chests_number, target=player.position, surface=player.surface_index,
  --   color={r=1,g=1,b=1,a=1}, time_to_live=ttl_1}
  -- rendering.draw_text{text="Processing "..index.." with "..#loot_items.." items",
  --   target=player.position, surface=player.surface_index,
  --   color={r=1,g=1,b=1,a=1}, time_to_live=30}

  local stack, amount
  local done = 0
  local items_per_tick = settings.global["af-alc-items-per-tick"].value

  if loot_corpses then
    local loot_bodies = surface.find_entities_filtered{area = areaToCheck, type = "corpse"}

    for _, corpse_entity in pairs(loot_bodies) do
      if corpse_entity.valid and corpse_entity.minable then

        -- if not corpse_entity.to_be_deconstructed() then
        --   if not corpse_entity.order_deconstruction(1) then
        --     game.print("Cannot order deconstruction :(")
        --     return
        --   end
        -- end

        -- This works fine, but it's a bit boring approach
        done = done + intify(corpse_entity.mine{inventory=chest_entity.get_output_inventory()})
        if done >= items_per_tick then
          return
        end

      end -- if corpse_entity.valid
    end -- for loot_bodies
  end -- if loot_corpses

  local loot_items = surface.find_entities_filtered{area = areaToCheck, type = "item-entity"}

  for _, item_entity in pairs(loot_items) do
    if item_entity.valid then
      stack = item_entity.stack
      if any_item or is_value_in_list(stack.name, signal_names) then
        if stack.valid then
          if chest_entity.can_insert(stack) then

            take_item(chest_entity, item_entity, stack)
            item_entity.destroy()
            done = done + 1

            if done >= items_per_tick then
              return
            end

          end -- if can_insert
        end -- if if stack.valid
      end -- if any_item or is_value_in_list
    end -- if item_entity.valid
  end -- for loot_items
end


local process_all_chests = function(event)
  max_shift = settings.global["af-alc-max-shift"].value
  radius = settings.global["af-alc-chest-radius"].value
  show_circles = settings.global["af-alc-chest-show"].value

  local bucket = global.looting_chests[event.tick % scan_update_rate]
  if not bucket then return end

  for unit_number, chest_entity in pairs(bucket) do
    if chest_entity.valid then
      process_a_chest(chest_entity)
    else
        table.remove(bucket, unit_number)
    end
  end
end


function register_chest(entity)
  local unit_number = entity.unit_number
  local bucket = global.looting_chests[unit_number % scan_update_rate]
  if not bucket then
    bucket = {}
    global.looting_chests[unit_number % scan_update_rate] = bucket
  end
  bucket[unit_number] = entity
end


function reset_storage()
  global.looting_chests = {}
  -- Create buckets
  for i = 1, scan_update_rate do
    global.looting_chests[i] = {}
  end
end


function chests_reload()
  reset_storage()
  chest_count = 0

  for _, surface in pairs(game.surfaces) do
    for name, _ in pairs(alc_chests) do
      for _, entity in pairs(surface.find_entities_filtered{name=name}) do
        register_chest(entity)
        chest_count = chest_count + 1
      end
    end
  end

  local txt = "ALC AivanF migration: found "..chest_count.." chests"
  game.print(txt)
  log(txt)
end


function clean_drawings()
  local ids = rendering.get_all_ids(mod_name)
  for _, id in pairs (ids) do
    if rendering.is_valid(id) then
      rendering.destroy(id)
    end
  end
end


function on_init()
  if not global.looting_chests then reset_storage() end
end

function on_any_built(event)
  local entity = event.created_entity or event.entity or event.destination
  if not (entity and entity.valid) then return end
  if alc_chests[entity.name] then
    register_chest(entity)
  end
end

function update_configuration()
  clean_drawings()
  chests_reload()
end

script.on_init(on_init)

script.on_configuration_changed(update_configuration)

script.on_event({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}, on_any_built)

-- TODO: add on nth tick lookup for new missed chests?

script.on_event(defines.events.on_tick, process_all_chests)
-- script.on_nth_tick(30, process_all_chests)

commands.add_command(
  "alc-clean",
  "Remove all ALC drawings",
  clean_drawings
)
commands.add_command(
  "alc-reload",
  "Reload all ALC chests",
  chests_reload
)
