require("script/common")
local titan = require("script/titan")

local Lib = require("script/event_lib")
local lib = Lib.new()

building_update_rate = UPS
local quick_mode = heavy_debugging
local required_ammo_ratio = 0.05

local states = {}
states.disabled = "disabled"
states.initialising = "initialising"
states.deactivating = "deactivating"
states.idle = "idle"
states.prepare_assembly = "prepare_assembly"
states.assembling = "assembling"
states.waiting_disassembly = "waiting_disassembly"
states.disassembling = "disassembling"
states.restock = "restock"

local function hor_pos_array(xmax, y)
  local result = {}
  for x = 0, xmax do
    table.insert(result, {x, y})
    if x > 0 then table.insert(result, {-x, y}) end
  end
  return result
end
local function ver_pos_array(x, ymax)
  local result = {}
  for y = 0, ymax do
    table.insert(result, {x, y})
    if y > 0 then table.insert(result, {x, -y}) end
  end
  return result
end
local shifts_up    = hor_pos_array(3, -3)
local shifts_left  = ver_pos_array(-3, 3)
local shifts_right = ver_pos_array(3, 3)
local shifts_down  = hor_pos_array(4, 4)
local bunker_store_shifts = {
  -- w 1, 2
  shifts_up, shifts_up,
  -- w 3, 4
  shifts_left, shifts_right,
  -- w 5, 6
  shifts_left, shifts_right,
  -- body
  shifts_down,
}

local b1, b2 = 9, 6
local bunker_lamps = {
  {-b2, -b1}, -- w1
  { b2, -b1}, -- w2
  {-b1, -b2}, -- w3  
  { b1, -b2}, -- w4
  {-b1,  b2}, -- w5
  { b1,  b2}, -- w6
  {-b2,  b1}, -- b7
  { b2,  b1}, -- b8
  -- 9, 10, 11, 12
  {-b1, -b1}, { b1, -b1},
  {-b1,  b1}, { b1,  b1},
}


local function draw_assembler_lamp(assembler, k, lamp_color)
  local color = table.deepcopy(lamp_color)
  table.insert(color, 0.25)
  rendering.draw_sprite{
    surface=assembler.surface, sprite=shared.mod_prefix.."light", x_scale=1, y_scale=1,
    tint=color, time_to_live=building_update_rate+1, render_layer=145, -- 123 or 145
    target={x=assembler.position.x+bunker_lamps[k][1], y=assembler.position.y+bunker_lamps[k][2]},
  }
end

local function update_assembler_guis(assembler)
  for player_index, gui_info in pairs(ctrl_data.assembler_gui) do
    if gui_info.assembler == assembler then
      lib.update_assembler_gui(gui_info)
    end
  end
end

local function change_assembler_state(assembler, new_state)
  if assembler.state == new_state then return end
  -- TODO: if force has >1 members, do notify them all
  if lib.state_post_handler[assembler.state] then
    lib.state_post_handler[assembler.state](assembler)
  end
  if lib.state_pre_handler[new_state] then
    lib.state_pre_handler[new_state](assembler)
  end
  assembler.state = new_state
  update_assembler_guis(assembler)
end

local function get_titan_assembly_time(titan_class_or_name)
  if quick_mode then
    return 3 + shared.titan_types[titan_class_or_name].health /10000
  else
    return shared.titan_types[titan_class_or_name].health /1000 *10
  end
end
local bunker_init_time = quick_mode and 8 or 40

local function check_entity_has_ingredients(entity, ingredients)
  for _, stack in pairs(ingredients) do
    if entity.get_item_count(stack[1]) < stack[2] then return false end
  end
  return true
end

local function collect_entity_ingredients(entity, ingredients)
  for _, stack in pairs(ingredients) do
    entity.remove_item({name=stack[1], count=stack[2]})
  end
end

local function set_message(assembler, text)
  assembler.message = assembler.message or text
end

local function check_bunker_correct_details(assembler)
  local result = true
  assembler.message = nil

  local titan_type, lamp_color
  if assembler.class_recipe then
    titan_type = shared.titan_types[assembler.class_recipe]
  end
  if not titan_type then
    set_message(assembler, "Titan class is not set")
    result = false
    lamp_color = color_red
  elseif not titan_type.available then
    set_message(assembler, "Titan class is not available")
    result = false
    lamp_color = color_red
  end
  if not assembler.bstore then
    set_message(assembler, "improper bunker setup 1")
    result = false
    lamp_color = color_red
  end
  if titan_type and not check_entity_has_ingredients(assembler.bstore, titan_type.ingredients) then
    set_message(assembler, "not enough body details")
    result = false
    lamp_color = lamp_color or color_gold
  end
  lamp_color = lamp_color or color_green
  draw_assembler_lamp(assembler, 7, lamp_color)
  draw_assembler_lamp(assembler, 8, lamp_color)

  local weapon_type, weapon_fine
  for k = 1, 6 do
    weapon_type = assembler.weapon_recipes[k] and shared.weapons[assembler.weapon_recipes[k]]
    weapon_fine = true
    lamp_color = nil -- disabled
    if titan_type then
      if titan_type.guns[k] and not weapon_type then
        set_message(assembler, "not all weapons specified")
        weapon_fine = false
        lamp_color = color_red
      end
      if weapon_type and not titan_type.guns[k] then
        set_message(assembler, "excessive weapon specified")
        weapon_fine = false
        lamp_color = color_red

      ----- Actual weapon placement rules are here -----
      elseif weapon_type and not (weapon_type.grade == titan_type.guns[k].grade or weapon_type.grade == titan_type.guns[k].grade-1) then
        set_message(assembler, "improper grade of "..weapon_type.name)
        weapon_fine = false
        lamp_color = color_red
      elseif weapon_type and weapon_type.no_top and titan_type.guns[k].is_top then
        set_message(assembler, weapon_type.name.." cannot be place on top")
        weapon_fine = false
        lamp_color = color_red
      elseif weapon_type and weapon_type.top_only and not titan_type.guns[k].is_top then
        set_message(assembler, weapon_type.name.." can be place on top only")
        weapon_fine = false
        lamp_color = color_red
      end
    end
    if not assembler.wstore[k] then
      set_message(assembler, "improper bunker setup 2")
      weapon_fine = false
    end
    if weapon_type then
      if weapon_type.available then
        -- Set recipe to assembler.wrecipe[k] ?
        if not check_entity_has_ingredients(assembler.wstore[k], weapon_type.ingredients) then
          set_message(assembler, "not enough weapon details for "..weapon_type.name)
          weapon_fine = false
          lamp_color = lamp_color or color_orange
        end
        if assembler.wstore[k].get_item_count(weapon_type.ammo) < weapon_type.inventory*required_ammo_ratio-1 then
          set_message(assembler, "not enough ammo for "..weapon_type.name)
          weapon_fine = false
          lamp_color = lamp_color or color_gold
        end
      else
        set_message(assembler, "weapon "..weapon_type.name.." is not available")
        weapon_fine = false
        lamp_color = lamp_color or color_gold
      end
      -- If everything is fine
      lamp_color = lamp_color or color_green
    end
    result = result and weapon_fine
    if lamp_color then
      draw_assembler_lamp(assembler, k, lamp_color)
    end
  end

  if result then
    set_message(assembler, "ready to assemble")
  end
  return result
end

local function collect_bunker_details(assembler)
  local titan_type = shared.titan_types[assembler.class_recipe]
  collect_entity_ingredients(assembler.bstore, titan_type.ingredients)
  assembler.items_main = table.deepcopy(titan_type.ingredients)

  local weapon_type, got_ammo
  for k, _ in pairs(titan_type.guns) do
    weapon_type = assembler.weapon_recipes[k] and shared.weapons[assembler.weapon_recipes[k]]
    collect_entity_ingredients(assembler.wstore[k], weapon_type.ingredients)
    assembler.items_guns[k] = table.deepcopy(weapon_type.ingredients)
    got_ammo = assembler.wstore[k].remove_item({name=weapon_type.ammo, count=weapon_type.inventory})
    table.insert(assembler.items_guns[k], {weapon_type.ammo, got_ammo})
    assembler.items_guns[k].ammo_count = got_ammo
  end
end

local function find_titan(assembler, empty)
  local targets = assembler.surface.find_entities_filtered{
    position=assembler.position, radius=8,
    type=shared.titan_base_type, force=assembler.force,
  }
  local todo
  for _, entity in pairs(targets) do
    todo = true
    todo = todo and is_titan(entity.name)
    if empty then
      todo = todo and not entity.get_driver() and not entity.get_passenger()
      todo = todo and (not entity.get_inventory(defines.inventory.car_trunk) or entity.get_inventory(defines.inventory.car_trunk).get_item_count() == 0)
    end
    if todo then return entity end
  end
  return nil
end

local function titan_to_bunker_internal(assembler, titan_info)
  local titan_type = shared.titan_types[titan_info.class]
  assembler.items_main = table.deepcopy(titan_type.ingredients)
  assembler.class_recipe = titan_type.entity
  assembler.items_guns = {}
  local weapon_type
  for k, _ in pairs(titan_type.guns) do
    weapon_type = shared.weapons[titan_info.guns[k].name]
    assembler.weapon_recipes[k] = weapon_type.entity
    assembler.items_guns[k] = table.deepcopy(weapon_type.ingredients)
    table.insert(assembler.items_guns[k], {weapon_type.ammo, titan_info.guns[k].ammo_count})
  end
end

local function put_items_to_entity(entity, items)
  local finished = true
  local done
  for key, stack in ipairs(items) do
    if stack[2] > 0 then
      done = entity.insert({name=stack[1], count=stack[2]})
    else
      done = 0
    end
    stack[2] = stack[2] - done
    if stack[2] <= 0 then
      items[key] = nil
    else
      finished = false
    end
  end
  return finished
end

local function bunker_internal_to_outer(assembler)
  local finished = true
  finished = finished and put_items_to_entity(assembler.bstore, assembler.items_main)
  for k, _ in pairs(assembler.items_guns) do
    finished = put_items_to_entity(assembler.wstore[k], assembler.items_guns[k]) and finished
  end
  return finished
end

local function safe_destroy_chest(entity, shifts)
  if not entity.valid then return end
  if entity.get_item_count() > 0 then
    local try_pos
    local position = entity.position
    for _, couple in pairs(shifts or {}) do
      try_pos = math2d.position.add(entity.position, couple)
      if entity.surface.can_place_entity{
        name=shared.leftovers_chest, force="neutral", position=try_pos,
      } then
        position = try_pos
        break
      end
    end
    local new = entity.surface.create_entity{
      name=shared.leftovers_chest, force="neutral", position=position,
    }
    for item_name, have in pairs(entity.get_inventory(defines.inventory.chest).get_contents()) do
      new.insert({name=item_name, count=have})
      entity.remove_item({name=item_name, count=done})
    end
  end
  entity.destroy()
end




----- Intro -----

function lib.register_bunker(centity)

  local wentity, sentity, state
  if centity.name == shared.bunker_minable then
    state = states.disabled
    wentity = centity
  elseif centity.name == shared.bunker_active then
    state = states.idle
    sentity = centity
  else
    error("Tried to register not bunker: "..centity.name)
  end
  local force = centity.force
  local surface = centity.surface

  -- Main entity and unit_number can be changed, but UID must stay still
  local uid
  if ctrl_data.assembler_index[centity.unit_number] then
    -- Re-registering the same entity
    uid = ctrl_data.assembler_index[centity.unit_number].uid
  else
    -- Simply a new one, hopefully
    uid = centity.unit_number
  end

  local assembler = bucks.get(ctrl_data.assembler_buckets, building_update_rate, uid) or {
    -- Assembler states
    force = centity.force,
    surface = centity.surface,
    position = centity.position,
    uid = uid,
    state = state,
    init_progress = 0,
    assembly_progress = 0,
    assembly_progress_max = 0,
    class_recipe = nil,
    weapon_recipes = {},
    items_main = {}, -- ingredients array
    items_guns = {}, -- k => union: ingredients array + ammo_count
    auto_build = false,

    -- Bunker entities
    wentity = wentity, -- weak, mainable entity
    sentity = sentity, -- stable, strong entity
    lamps = {},
    wstore = {},
    wrecipe = {},
    bstore = nil,
    brecipe = nil,
  }
  bucks.save(ctrl_data.assembler_buckets, building_update_rate, uid, assembler)
  -- game.print("register_bunker "..uid)
  ctrl_data.assembler_index[centity.unit_number] = assembler

  for i, pos in ipairs(bunker_lamps) do
    assembler.lamps[i] = assembler.lamps[i] or surface.create_entity{
      name=shared.bunker_lamp, force="neutral",
      position={x=centity.position.x+pos[1], y=centity.position.y+pos[2]},
    }
  end
  preprocess_entities(assembler.lamps)

  local b1, b2 = 2.5, 9.5
  assembler.wstore[1] = assembler.wstore[1] or surface.create_entity{
    name=shared.bunker_wstoreh, force=force,
    position={x=centity.position.x-b1, y=centity.position.y-b2},
  }
  assembler.wstore[2] = assembler.wstore[2] or surface.create_entity{
    name=shared.bunker_wstoreh, force=force,
    position={x=centity.position.x+b1, y=centity.position.y-b2},
  }
  assembler.wstore[3] = assembler.wstore[3] or surface.create_entity{
    name=shared.bunker_wstorev, force=force,
    position={x=centity.position.x-b2, y=centity.position.y-b1},
  }
  assembler.wstore[4] = assembler.wstore[4] or surface.create_entity{
    name=shared.bunker_wstorev, force=force,
    position={x=centity.position.x+b2, y=centity.position.y-b1},
  }
  assembler.wstore[5] = assembler.wstore[5] or surface.create_entity{
    name=shared.bunker_wstorev, force=force,
    position={x=centity.position.x-b2, y=centity.position.y+b1},
  }
  assembler.wstore[6] = assembler.wstore[6] or surface.create_entity{
    name=shared.bunker_wstorev, force=force,
    position={x=centity.position.x+b2, y=centity.position.y+b1},
  }
  preprocess_entities(assembler.wstore)

  -- b2 = 7
  -- assembler.wrecipe[1] = assembler.wrecipe[1] or surface.create_entity{
  --   name=shared.bunker_wrecipeh, force=force,
  --   position={x=centity.position.x-b1, y=centity.position.y-b2},
  -- }
  -- assembler.wrecipe[2] = assembler.wrecipe[2] or surface.create_entity{
  --   name=shared.bunker_wrecipeh, force=force,
  --   position={x=centity.position.x+b1, y=centity.position.y-b2},
  -- }
  -- assembler.wrecipe[3] = assembler.wrecipe[3] or surface.create_entity{
  --   name=shared.bunker_wrecipev, force=force,
  --   position={x=centity.position.x-b2, y=centity.position.y-b1},
  -- }
  -- assembler.wrecipe[4] = assembler.wrecipe[4] or surface.create_entity{
  --   name=shared.bunker_wrecipev, force=force,
  --   position={x=centity.position.x+b2, y=centity.position.y-b1},
  -- }
  -- assembler.wrecipe[5] = assembler.wrecipe[5] or surface.create_entity{
  --   name=shared.bunker_wrecipev, force=force,
  --   position={x=centity.position.x-b2, y=centity.position.y+b1},
  -- }
  -- assembler.wrecipe[6] = assembler.wrecipe[6] or surface.create_entity{
  --   name=shared.bunker_wrecipev, force=force,
  --   position={x=centity.position.x+b2, y=centity.position.y+b1},
  -- }
  -- preprocess_entities(assembler.wrecipe)
  -- for index, entity in pairs(assembler.wrecipe) do
  --   ctrl_data.assembler_entities[entity.unit_number] = {assembler=assembler, index=index}
  -- end

  assembler.brecipe = assembler.brecipe or surface.create_entity{
    name=shared.bunker_center, force=force,
    position={x=centity.position.x, y=centity.position.y},
  }
  -- ctrl_data.assembler_entities[assembler.brecipe.unit_number] = {assembler=assembler, index=0}
  ctrl_data.assembler_index[assembler.brecipe.unit_number] = assembler
  assembler.bstore = assembler.bstore or surface.create_entity{
    name=shared.bunker_bstore, force=force,
    position={x=centity.position.x, y=centity.position.y+8.5},
  }
  preprocess_entities({assembler.brecipe, assembler.bstore})
end



----- Outro -----
function lib.bunker_removed(assembler)
  bucks.remove(ctrl_data.assembler_buckets, building_update_rate, assembler.uid)

  -- TODO: add desired shift options, to simplify bunker replacement
  func_maps(safe_destroy_chest, iter_zip{
    iter_chain({assembler.wstore, {assembler.bstore}}),
    bunker_store_shifts
  })

  die_all({assembler.wentity, assembler.sentity}, ctrl_data.assembler_index)
  die_all(assembler.lamps)
  die_all(assembler.wstore)
  die_all(assembler.wrecipe, ctrl_data.entities)
  die_all({assembler.brecipe, assembler.bstore}, ctrl_data.entities)
  for player_index, info in pairs(ctrl_data.assembler_gui) do
    if info.assembler == assembler then
      if info.main_frame.valid then
        info.main_frame.destroy()
      end
      ctrl_data.assembler_gui[player_index] = nil
    end
  end
end




----- MAIN -----

lib.state_handler = {}
lib.state_pre_handler = {}
lib.state_post_handler = {}
local state_handler = lib.state_handler
local state_pre_handler = lib.state_pre_handler
local state_post_handler = lib.state_post_handler

function state_handler.disabled(assembler)
  -- Pass, state changing handled by GUI
end

function state_pre_handler.initialising(assembler)
  if assembler.wentity and assembler.wentity.valid then
    -- Change entity to not minable, stable/active
    -- TODO: copy health!
    ctrl_data.assembler_index[assembler.wentity.unit_number] = nil
    assembler.wentity.destroy()
    assembler.wentity = nil
    assembler.sentity = assembler.surface.create_entity{
      name=shared.bunker_active, position=assembler.position, force=assembler.force,
    }
  end
end

function state_handler.initialising(assembler)
  assembler.init_progress = assembler.init_progress + 1
  if assembler.init_progress < bunker_init_time then
    update_assembler_guis(assembler)
  else
    -- Entity should be already changed
    ctrl_data.assembler_index[assembler.sentity.unit_number] = assembler
    change_assembler_state(assembler, states.idle)
  end
end

function state_post_handler.deactivating(assembler)
  if assembler.sentity and assembler.sentity.valid then
    -- Change entity to minable
    ctrl_data.assembler_index[assembler.sentity.unit_number] = nil
    assembler.sentity.destroy()
    assembler.sentity = nil
    -- TODO: copy health!
    assembler.wentity = assembler.surface.create_entity{
      name=shared.bunker_minable, position=assembler.position, force=assembler.force,
    }
    ctrl_data.assembler_index[assembler.wentity.unit_number] = assembler
  end
end

function state_pre_handler.deactivating(assembler)
  if assembler.init_progress <= 0 or assembler.init_progress > bunker_init_time then
    assembler.init_progress = bunker_init_time
  end
end

function state_handler.deactivating(assembler)
  assembler.init_progress = assembler.init_progress - 2
  if assembler.init_progress > 0 then
    update_assembler_guis(assembler)
  else
    -- if assembler.sentity then
    --   -- Change entity to minable
    --   ctrl_data.assembler_index[assembler.sentity.unit_number] = nil
    --   assembler.sentity.destroy()
    --   assembler.sentity = nil
    --   assembler.wentity = assembler.surface.create_entity{
    --     name=shared.bunker_minable, position=assembler.position, force=assembler.force,
    --   }
    --   ctrl_data.assembler_index[assembler.wentity.unit_number] = assembler
    -- end
    change_assembler_state(assembler, states.disabled)
  end
end

function state_handler.idle(assembler)
  -- Pass, state changing handled by GUI
end

function state_pre_handler.prepare_assembly(assembler)
  assembler.auto_build = false
end

function state_handler.prepare_assembly(assembler)
  if check_bunker_correct_details(assembler) and assembler.auto_build then
    collect_bunker_details(assembler)
    assembler.assembly_progress = 0
    assembler.assembly_progress_max = get_titan_assembly_time(assembler.class_recipe)
    change_assembler_state(assembler, states.assembling)
  else
    update_assembler_guis(assembler)
  end
end

function state_handler.assembling(assembler)
  assembler.assembly_progress = assembler.assembly_progress + 1
  if assembler.assembly_progress < assembler.assembly_progress_max then
    update_assembler_guis(assembler)
  else
    local titan_type = shared.titan_types[assembler.class_recipe]
    assembler.force.print({"WH40k-Titans-gui.msg-titan-created", {"entity-name."..titan_type.entity}})
    local name = titan_type.entity
    -- Try change to AAI Programmable Vehicles
    if game.entity_prototypes[name.."-0"] then
      name = name.."-0"
    end
    titan_entity = assembler.surface.create_entity{
      name=name, force=assembler.force, position=assembler.position, raise_built=true,
    }
    local titan_info = titan.register_titan(titan_entity)
    local weapon_type
    titan_info.guns = {}
    for k, _ in pairs(titan_type.guns) do
      weapon_type = shared.weapons[assembler.weapon_recipes[k]]
      titan_info.guns[k] = titan.init_gun(nil, weapon_type)
      titan_info.guns[k].ammo_count = assembler.items_guns[k].ammo_count
    end
    change_assembler_state(assembler, states.idle)
  end
end

function state_handler.waiting_disassembly(assembler)
  local titan_entity = find_titan(assembler, true)
  local titan_info = titan_entity and ctrl_data.titans[titan_entity.unit_number]
  if titan_entity and titan_info then
    local titan_type = titan.titan_type_by_entity(titan_entity)
    -- local titan_type = shared.titan_types[titan_entity.name]
    assembler.force.print({"WH40k-Titans-gui.msg-titan-removed", {"entity-name."..titan_type.entity}})
    titan_to_bunker_internal(assembler, titan_info)
    titan_entity.destroy({raise_destroy=true})
    assembler.assembly_progress_max = get_titan_assembly_time(titan_info.class)
    assembler.assembly_progress = assembler.assembly_progress_max
    assembler.message = nil
    change_assembler_state(assembler, states.disassembling)
  end
end

function state_handler.disassembling(assembler)
  assembler.assembly_progress = assembler.assembly_progress - 2
  if assembler.assembly_progress > 0 then
    update_assembler_guis(assembler)
  else
    if bunker_internal_to_outer(assembler) then
      change_assembler_state(assembler, states.idle)
    else
      assembler.message = "not enough space!"
    end
  end
end

function state_handler.restock(assembler)
  local titan_entity = find_titan(assembler, false)
  local titan_info = titan_entity and ctrl_data.titans[titan_entity.unit_number]

  if titan_entity and titan_info then
    local titan_type = shared.titan_types[titan_info.name or titan_entity.name]
    local weapon_type, cannon, need_ammo, have_ammo, got_ammo
    local done_ws, done_ammo = 0, 0
    for k, _ in pairs(titan_type.guns) do
      cannon = titan_info.guns[k]
      weapon_type = shared.weapons[cannon.name]
      need_ammo = weapon_type.inventory - cannon.ammo_count
      have_ammo = assembler.wstore[k].get_item_count(weapon_type.ammo)
      got_ammo = math.min(need_ammo, have_ammo)
      if got_ammo > 0 then
        done_ws = done_ws + 1
        done_ammo = done_ammo + got_ammo
        assembler.wstore[k].remove_item({name=weapon_type.ammo, count=need_ammo})
        cannon.ammo_count = cannon.ammo_count + got_ammo
        -- TODO: increase stats?
      end
    end
    if done_ammo > 0 then
      titan.notify_crew(titan_info, {"WH40k-Titans-gui.msg-titan-restock", done_ws, done_ammo})
    end
  end
end


local states_no_need_clean = {}
states_no_need_clean[states.disabled] = true -- disabled is on you own risk!
states_no_need_clean[states.initialising] = true -- just the same
states_no_need_clean[states.deactivating] = true -- just the same
states_no_need_clean[states.prepare_assembly] = true -- this state manages lamps itself
states_no_need_clean[states.assembling] = true -- here, leftovers are fine for a while
states_no_need_clean[states.restock] = true -- TODO: add custom colors for it to depict ammo correctness and amount

local states_for_music = {}
states_for_music[states.initialising] = true
states_for_music[states.deactivating] = true
states_for_music[states.assembling] = true
states_for_music[states.disassembling] = true
-- TODO: dynamically consider game.speed?


local states_to_corner_colors = {}
states_to_corner_colors[states.initialising] = color_green
states_to_corner_colors[states.deactivating] = color_red
states_to_corner_colors[states.assembling] = color_green
states_to_corner_colors[states.disassembling] = color_red
states_to_corner_colors[states.prepare_assembly] = color_blue
states_to_corner_colors[states.waiting_disassembly] = color_purple
states_to_corner_colors[states.restock] = color_orange
states_to_corner_colors[states.idle] = color_ltgrey

local function process_an_assembler(assembler)
  -- game.print("Handling "..assembler.state.." for assembler "..assembler.uid)
  state_handler[assembler.state](assembler)
  if not states_no_need_clean[assembler.state] then
    -- TODO: shine lamps if chests aren't empty!
  end

  local lamp_color = states_to_corner_colors[assembler.state]
  -- if assembler.state==states.restock then
  if lamp_color then
    draw_assembler_lamp(assembler,  9, lamp_color)
    draw_assembler_lamp(assembler, 10, lamp_color)
    draw_assembler_lamp(assembler, 11, lamp_color)
    draw_assembler_lamp(assembler, 12, lamp_color)
  end

  if states_for_music[assembler.state] then
    assembler.music_step = ((assembler.music_step or 0) + 1) % 4
    if assembler.music_step == 1 then
      assembler.surface.play_sound{
        path="wh40k-titans-assembly-main",
        position=assembler.position, volume_modifier=1
      }
    end
    if assembler.music_step == 1 and math.random(0, 1) == 0 then
      assembler.surface.play_sound{
        path="wh40k-titans-random-work",
        position=assembler.position, volume_modifier=1
      }
    end
  else
    assembler.music_step = 0
  end
end

local function process_assemblers()
  if not global.active_mods_cache then
    global.active_mods_cache = game.active_mods
    preprocess_ingredients()
  end

  local bucket = bucks.get_bucket(ctrl_data.assembler_buckets, building_update_rate, game.tick)
  if not bucket then return end
  for uid, assembler in pairs(bucket) do
    if true
      and (not assembler.wentity or not assembler.wentity.valid)
      and (not assembler.sentity or not assembler.sentity.valid)
    then
      log("Missing assembler: "..serpent.block(assembler))
      game.print("Missing assembler "..assembler.uid.." with state "..tostring(assembler.state))
      bucket[uid] = nil
    else
      process_an_assembler(assembler)
    end
  end
end

lib:on_event(defines.events.on_tick, process_assemblers)




----- Visual Interface -----

local main_frame_name = "wh40k_titans_assembly_frame"
local main_frame_buttons_line = "buttons_line"
local main_frame_init_progress = "init_progress"
local main_frame_assembly_progress = "assembly_progress"
local act_main_frame_close = "wh40k-titans-assembly-frame-close"
local act_change_state = "wh40k-titans-assembly-change-state"
local act_set_class = "wh40k-titans-assembly-set-class"
local act_set_weapon = "wh40k-titans-assembly-set-weapon"
local act_toggle_auto = "wh40k-titans-assembly-toggle-auto-build"

local gui_maker = {}
local gui_updater = {}

function gui_maker.disabled(assembler, main_frame)
  main_frame.status_line.add{type="sprite-button", tags={action=act_change_state, state=states.initialising}, sprite="virtual-signal/signal-green", tooltip={"WH40k-Titans-gui.assembly-act-init"} }
end

function gui_maker.initialising(assembler, main_frame)
  main_frame.status_line.add{type="sprite-button", index=1, tags={action=act_change_state, state=states.deactivating, need_confirm=true}, sprite="virtual-signal/signal-red", tooltip={"WH40k-Titans-gui.assembly-act-cancel"} }
  main_frame.main_room.add{ type="progressbar", name=main_frame_init_progress, direction="horizontal", value=assembler.init_progress/bunker_init_time }
end

function gui_maker.deactivating(assembler, main_frame)
  main_frame.main_room.add{ type="progressbar", name=main_frame_init_progress, direction="horizontal", value=assembler.init_progress/bunker_init_time }
end

function gui_maker.idle(assembler, main_frame)
  local top_line = main_frame.main_room.add{ type="flow", name=main_frame_buttons_line, direction="horizontal" }
  top_line.add{type="sprite-button", tags={action=act_change_state, state=states.deactivating, need_confirm=true}, sprite="virtual-signal/signal-red", tooltip={"WH40k-Titans-gui.assembly-act-disable"} }
  top_line.add{type="sprite-button", tags={action=act_change_state, state=states.prepare_assembly}, sprite="virtual-signal/signal-green", tooltip={"WH40k-Titans-gui.assembly-act-prepare-assemble"} }
  top_line.add{type="sprite-button", tags={action=act_change_state, state=states.waiting_disassembly}, sprite="virtual-signal/signal-pink", tooltip={"WH40k-Titans-gui.assembly-act-prepare-disassemble"} }
  top_line.add{type="sprite-button", tags={action=act_change_state, state=states.restock}, sprite="virtual-signal/signal-yellow", tooltip={"WH40k-Titans-gui.assembly-act-restock"} }
end

local no_recipes_filter = {
  {filter="category", category=shared.craftcat_empty, mode="and"},
  {filter="enabled", mode="and"},
}

local function get_category_filters_by_research(player, category, research, mn, mx)
  local has_character = not not player.character
  local filters = {}
  for i = mn, mx do
    if not has_character or player.force.technologies[shared.mod_prefix..i..research].researched then
      table.insert(filters, {filter="category", category=category..i, mode="or"})
    end
  end
  if #filters == 0 then
    filters = no_recipes_filter
  end
  return filters
end

function gui_updater.prepare_assembly(assembler, main_frame)
  -- TODO: update other elements?
  main_frame.main_room.label.caption = {"", "Status: ", assembler.message or "unknown"}
  main_frame.last_line.auto_toggler.sprite = assembler.auto_build and "virtual-signal/signal-green" or "virtual-signal/signal-grey"
end

function gui_maker.prepare_assembly(assembler, main_frame)
  main_frame.status_line.add{type="sprite-button", index=1, tags={action=act_change_state, state=states.idle}, sprite="virtual-signal/signal-grey", tooltip={"WH40k-Titans-gui.assembly-act-cancel"} }
  -- TODO: add auto-build setting, show button for states.assembling
  -- TODO: show expected assembly time

  main_frame.main_room.add{
    type="label", name="label",
    caption={"", "Status: ", assembler.message or "unknown"},
  }

  local player = game.get_player(main_frame.player_index)
  local filters
  local btn
  local grid = main_frame.main_room.add{ type="frame", direction="horizontal" }

  filters = get_category_filters_by_research(player, shared.craftcat_titan, "-class", 1, 5)
  btn = grid.add{
    type="choose-elem-button", name="", elem_type="recipe", elem_filters = filters,
    recipe = assembler.class_recipe,
    tags={action=act_set_class},
  }
  local titan_type, weapon_type
  if assembler.class_recipe then
    titan_type = shared.titan_types[assembler.class_recipe]
  end
  filters = get_category_filters_by_research(player, shared.craftcat_weapon, "-grade", 0, 3)
  for k = 1, 6 do
    btn = grid.add{
      type="choose-elem-button", elem_type="recipe",
      elem_filters=filters, recipe=assembler.weapon_recipes[k],
      tags={action=act_set_weapon, k=k },
    }
    weapon_type = assembler.weapon_recipes[k] and shared.weapons[assembler.weapon_recipes[k]]
    if titan_type then
      if not titan_type.guns[k] and not weapon_type then
        btn.tooltip = {"WH40k-Titans-gui.assembly-blocked-weapon"}
      end
      -- TODO: highlight errors with some colors/styles?
      if titan_type.guns[k] and not weapon_type then
        btn.tooltip = {"WH40k-Titans-gui.assembly-er-weapon-missing"}
      end
      if weapon_type and not titan_type.guns[k] then
        btn.tooltip = {"WH40k-Titans-gui.assembly-er-extra-weapon"}
      elseif weapon_type and not (weapon_type ~= titan_type.guns[k].grade or weapon_type ~= titan_type.guns[k].grade-1) then
        btn.tooltip = {"WH40k-Titans-gui.assembly-er-wrong-grade"}
      end
    end
  end

  main_frame.add{ type="flow", name="last_line", direction="horizontal" }
  main_frame.last_line.add{ type="label", name="label", caption={"WH40k-Titans-gui.assembly-auto"} }
  main_frame.last_line.add{
    type="sprite-button", name="auto_toggler", tags={action=act_toggle_auto},
    sprite=assembler.auto_build and "virtual-signal/signal-green" or "virtual-signal/signal-grey",
  }
end

function gui_maker.assembling(assembler, main_frame)
  main_frame.status_line.add{type="sprite-button", index=1, tags={action=act_change_state, state=states.disassembling}, sprite="virtual-signal/signal-red", tooltip={"WH40k-Titans-gui.assembly-act-cancel"} }
  main_frame.main_room.add{ type="progressbar", name=main_frame_assembly_progress, direction="horizontal", value=assembler.assembly_progress/assembler.assembly_progress_max }
  -- TODO: show class, weapons !
end

function gui_maker.waiting_disassembly(assembler, main_frame)
  main_frame.status_line.add{type="sprite-button", index=1, tags={action=act_change_state, state=states.idle}, sprite="virtual-signal/signal-grey", tooltip={"WH40k-Titans-gui.assembly-act-cancel"} }
end

function gui_maker.disassembling(assembler, main_frame)
  main_frame.main_room.add{ type="progressbar", name=main_frame_assembly_progress, direction="horizontal", value=assembler.assembly_progress/assembler.assembly_progress_max }
  -- TODO: show class, weapons !
end

function gui_maker.restock(assembler, main_frame)
  main_frame.status_line.add{type="sprite-button", index=1, tags={action=act_change_state, state=states.idle}, sprite="virtual-signal/signal-grey", tooltip={"WH40k-Titans-gui.assembly-act-cancel"} }
end

local function create_assembly_gui(player, assembler)
  local main_frame, gui_info
  if player.gui.screen[main_frame_name] then
    if ctrl_data.assembler_gui[player.index].assembler == assembler then
      main_frame = player.gui.screen[main_frame_name]
      gui_info = ctrl_data.assembler_gui[player.index]
      gui_info.state = nil -- Do full reload
      player.opened = main_frame
      main_frame.focus()
      main_frame.bring_to_front()
      lib.update_assembler_gui(gui_info)
      return
    else
    player.gui.screen[main_frame_name].destroy()
    end
  end

  main_frame = player.gui.screen.add{ type="frame", name=main_frame_name, direction="vertical", }
  main_frame.style.minimal_width = 256
  main_frame.style.maximal_width = 640
  main_frame.style.minimal_height = 128
  main_frame.style.maximal_height = 320

  main_frame.auto_center = true
  player.opened = main_frame
  main_frame.focus()
  main_frame.bring_to_front()

  local flowtitle = main_frame.add{ type="flow", name="title" }
  local title = flowtitle.add{ type="label", style="frame_title", caption={"WH40k-Titans-gui.assembly-caption"} }
  title.drag_target = main_frame
  local pusher = flowtitle.add{ type="empty-widget", style="draggable_space_header" }
  pusher.style.vertically_stretchable = true
  pusher.style.horizontally_stretchable = true
  pusher.drag_target = main_frame
  pusher.style.maximal_height = 24
  flowtitle.add{ type="sprite-button", style="frame_action_button", tags={action=act_main_frame_close}, sprite="utility/close_white" }

  if heavy_debugging then
    local tf = main_frame.add{ type="text-box", name="debugging",
      text=table.concat(func_map(serpent.line, {
        {"wentity", assembler.wentity},
        {"is it valid", assembler.wentity and assembler.wentity.valid},
        {"sentity", assembler.sentity},
        {"is it valid", assembler.sentity and assembler.sentity.valid},
      }), "\n") }
    tf.style.minimal_width = 256
  end

  main_frame.add{ type="flow", name="status_line", direction="horizontal" }
  main_frame.add{ type="flow", name="main_room", direction="vertical" }

  gui_info = { assembler=assembler, main_frame=main_frame, player_index=player.index }
  ctrl_data.assembler_gui[player.index] = gui_info
  lib.update_assembler_gui(ctrl_data.assembler_gui[player.index])
end

function lib.update_assembler_gui(gui_info)
  if gui_info.state == gui_info.assembler.state and gui_updater[gui_info.assembler.state] then
    gui_updater[gui_info.assembler.state](gui_info.assembler, gui_info.main_frame)
  else
    gui_info.main_frame.status_line.clear()
    gui_info.main_frame.status_line.add{ type="label", name="label" }
    gui_info.main_frame.status_line.label.caption = {"WH40k-Titans-gui.assembly-state-"..gui_info.assembler.state}
    gui_info.main_frame.main_room.clear()
    gui_maker[gui_info.assembler.state](gui_info.assembler, gui_info.main_frame)
    gui_info.state = gui_info.assembler.state
  end
end



lib:on_event(defines.events.on_gui_opened, function(event)
  local player = game.get_player(event.player_index)
  if event.entity and ctrl_data.assembler_index[event.entity.unit_number] then
    player.opened = nil
    create_assembly_gui(player, ctrl_data.assembler_index[event.entity.unit_number])

  elseif event.entity and (event.entity.name == shared.bunker_minable or event.entity.name == shared.bunker_active) then
    player.print("The bunker is improper, sorry :(")
    player.opened = nil

  elseif event.entity and (event.entity.name == shared.bunker_wrecipeh or event.entity.name == shared.bunker_wrecipev) then
    player.opened = nil
    create_assembly_gui(player, ctrl_data.assembler_index[event.entity.unit_number])
  end
end)

lib:on_event(defines.events.on_gui_click, function(event)
  local player = game.get_player(event.player_index)
  local assembler = nil
  if ctrl_data.assembler_gui[event.player_index] then
    assembler = ctrl_data.assembler_gui[event.player_index].assembler
  end
  local action = event.element and event.element.valid and event.element.tags.action

  if action == act_main_frame_close then
    if player.gui.screen[main_frame_name] and player.gui.screen[main_frame_name].valid then
      player.gui.screen[main_frame_name].destroy()
      ctrl_data.assembler_gui[event.player_index] = nil
    end
  elseif action == act_toggle_auto then
    assembler.auto_build = not assembler.auto_build
  elseif action == act_change_state then
    if event.element.tags.need_confirm then
      -- TODO: save goal, create a model window, return
    end
    if event.element.tags.state and states[event.element.tags.state] then
      change_assembler_state(assembler, event.element.tags.state)
    else
      error("Request for change to unknown state: "..serpent.line(event.element.tags))
    end
  end
end)

lib:on_event(defines.events.on_gui_elem_changed, function(event)
  local player = game.get_player(event.player_index)
  local assembler = nil
  if ctrl_data.assembler_gui[event.player_index] then
    assembler = ctrl_data.assembler_gui[event.player_index].assembler
  else
    return
  end

  -- game.print("Action: "..event.element.tags.action..", recipe: "..serpent.line(event.element.elem_value))
  if event.element.tags.action == act_set_class then
    assembler.class_recipe = event.element.elem_value
  elseif event.element.tags.action == act_set_weapon then
    assembler.weapon_recipes[event.element.tags.k] = event.element.elem_value
  end
  update_assembler_guis(assembler)
end)

lib:on_event(defines.events.on_gui_closed, function(event)
  local player = game.get_player(event.player_index)
  if event.element and event.element.valid and event.element.name == main_frame_name then
    event.element.destroy()
    ctrl_data.assembler_gui[event.player_index] = nil
  end
end)





local function bunkers_debug_cmd(cmd)
  local player = game.players[cmd.player_index]
  if not player.admin then
    player.print("You are not an admin!")
    return
  end

  player.print(serpent.block({
    assembler_count = bucks.total_count(ctrl_data.assembler_buckets),
    entity_count = #get_keys(ctrl_data.assembler_index),
  }))
end

commands.add_command(
  "bunkers-debug",
  "Prints some debug info",
  bunkers_debug_cmd
)


return lib