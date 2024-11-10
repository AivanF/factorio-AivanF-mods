local lib_ttn = require("script/titan")
local lib_spl = require("script/supplier")
local lib_tech = require("script/tech")

local Lib = require("script/event_lib")
lib_asmb = Lib.new()

building_update_rate = UPS
local required_ammo_ratio = 0.05
local gun_chests_number = 6

local supplying_radius = 10

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
states.clearing = "clearing"
lib_asmb.states = states

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
local b1, b2 = 2.5, 7
local bunker_signal_outputs = {
  {-b1, -b2}, -- w1
  { b1, -b2}, -- w2
  {-b2, -b1}, -- w3  
  { b2, -b1}, -- w4
  {-b2,  b1}, -- w5
  { b2,  b1}, -- w6
  {  0,  b2}, -- b
}


local function draw_assembler_lamp(assembler, wi, lamp_color)
  local color = table.deepcopy(lamp_color)
  table.insert(color, 0.25)
  rendering.draw_sprite{
    surface=assembler.surface, sprite=shared.mod_prefix.."light", x_scale=1, y_scale=1,
    tint=color, time_to_live=building_update_rate, render_layer=145, -- 123 or 145
    target={x=assembler.position.x+bunker_lamps[wi][1], y=assembler.position.y+bunker_lamps[wi][2]},
  }
end


function lib_asmb.get_bunker_init_time()
  return settings.global["wh40k-titans-debug-quick"].value and 8 or 40
end


local function get_titan_assembly_time(titan_class_or_name)
  if settings.global["wh40k-titans-debug-quick"].value then
    return 3 + shared.titan_types[titan_class_or_name].health /10000
  else
    return shared.get_titan_assembly_time(titan_class_or_name)
  end
end


function lib_asmb.change_assembler_state(assembler, new_state)
  if assembler.state == new_state then return end
  if lib_asmb.state_post_handler[assembler.state] then
    lib_asmb.state_post_handler[assembler.state](assembler)
  end
  if lib_asmb.state_pre_handler[new_state] then
    lib_asmb.state_pre_handler[new_state](assembler)
  end
  assembler.state = new_state
  lib_asmb.update_assembler_guis(assembler)
end

function lib_asmb:get_assembly_speed(force)
  return shared.assembly_speed_by_level[lib_tech.get_research_level(force.index, shared.assembly_speed_research)]
end


function lib_asmb:estimate_remaining_time(assembler)
  if assembler.state == states.assembling then
    return (assembler.assembly_progress_max - assembler.assembly_progress) / lib_asmb:get_assembly_speed(assembler.force)
  else
    -- Dis-assembling is 2 times faster
    return assembler.assembly_progress / lib_asmb:get_assembly_speed(assembler.force) / 2
  end
end


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


function lib_asmb.check_weapon_is_appropriate(titan_type, wi, weapon_type)
  if not weapon_type then return nil end
  local name = {"item-name."..shared.mod_prefix..weapon_type.name}

  if not (
    weapon_type.grade == titan_type.mounts[wi].grade or
    weapon_type.grade == titan_type.mounts[wi].grade-1
  ) then
    return {"WH40k-Titans-gui.assembly-er-wrong-grade", name}

  elseif weapon_type.no_top and titan_type.mounts[wi].is_top then
    return {"WH40k-Titans-gui.assembly-er-place-cant-be-top", name}

  elseif weapon_type.top_only and not titan_type.mounts[wi].is_top then
    return {"WH40k-Titans-gui.assembly-er-place-must-be-top", name}

  elseif not weapon_type.top_only and titan_type.mounts[wi].top_only then
    return {"WH40k-Titans-gui.assembly-er-weapon-must-be-top", name}
  end
  return nil
end


local function check_bunker_correct_details(assembler)
  local result = true
  assembler.message = nil
  -- TODO: translate texts!

  local titan_type, lamp_color
  if assembler.class_recipe then
    titan_type = shared.titan_types[assembler.class_recipe]
  end
  if not titan_type then
    set_message(assembler, {"WH40k-Titans-gui.assembly-er-no-class-selected"})
    result = false
    lamp_color = color_red
  elseif not titan_type.available then
    set_message(assembler, {"WH40k-Titans-gui.assembly-er-class-not-available"})
    result = false
    lamp_color = color_red
  end
  if not assembler.bstore then
    set_message(assembler, {"WH40k-Titans-gui.assembly-er-improper-bunker", 1})
    result = false
    lamp_color = color_red
  end
  if titan_type and not check_entity_has_ingredients(assembler.bstore, titan_type.ingredients) then
    set_message(assembler, {"WH40k-Titans-gui.assembly-er-not-enough-body"})
    result = false
    lamp_color = lamp_color or color_gold
  end
  lamp_color = lamp_color or color_green
  draw_assembler_lamp(assembler, 7, lamp_color)
  draw_assembler_lamp(assembler, 8, lamp_color)

  local weapon_type, weapon_fine, msg
  for wi = 1, 6 do
    weapon_type = assembler.weapon_recipes[wi] and shared.weapons[assembler.weapon_recipes[wi]]
    weapon_fine = true
    lamp_color = nil -- disabled
    if titan_type then
      if titan_type.mounts[wi] and not weapon_type then
        set_message(assembler, {"WH40k-Titans-gui.assembly-er-no-weapon-selected"})
        weapon_fine = false
        lamp_color = color_red
      end
      if weapon_type and not titan_type.mounts[wi] then
        set_message(assembler, {"WH40k-Titans-gui.assembly-er-extra-weapon-selected"})
        weapon_fine = false
        lamp_color = color_red
      elseif weapon_type then
        msg = lib_asmb.check_weapon_is_appropriate(titan_type, wi, weapon_type)
        if msg then
          set_message(assembler, msg)
          weapon_fine = false
          lamp_color = color_red
        end
      end
    end
    if not assembler.wstore[wi] then
      set_message(assembler, {"WH40k-Titans-gui.assembly-er-improper-bunker", 2})
      weapon_fine = false
    end
    if weapon_type then
      if weapon_type.available then
        -- Set recipe to assembler.wrecipe[wi] ?
        if not check_entity_has_ingredients(assembler.wstore[wi], weapon_type.ingredients) then
          set_message(assembler, {"WH40k-Titans-gui.assembly-er-not-enough-weapon", {"item-name."..shared.mod_prefix..weapon_type.name}})
          weapon_fine = false
          lamp_color = lamp_color or color_orange
        end
        -- if assembler.wstore[wi].get_item_count(weapon_type.ammo) < weapon_type.inventory*required_ammo_ratio-1 then
        --   set_message(assembler, "not enough ammo for "..weapon_type.name)
        --   weapon_fine = false
        --   lamp_color = lamp_color or color_gold
        -- end
      else
        set_message(assembler, {"WH40k-Titans-gui.assembly-er-not-available-weapon", {"item-name."..shared.mod_prefix..weapon_type.name}})
        weapon_fine = false
        lamp_color = lamp_color or color_gold
      end
      -- If everything is fine
      lamp_color = lamp_color or color_green
    end
    result = result and weapon_fine
    if lamp_color then
      draw_assembler_lamp(assembler, wi, lamp_color)
    end
  end

  if result then
    set_message(assembler, {"WH40k-Titans-gui.assembly-ready"})
  end
  return result
end


local function collect_bunker_details(assembler)
  local titan_type = shared.titan_types[assembler.class_recipe]
  collect_entity_ingredients(assembler.bstore, titan_type.ingredients)
  assembler.items_main = table.deepcopy(titan_type.ingredients)

  local weapon_type, got_ammo
  for wi, _ in pairs(titan_type.mounts) do
    weapon_type = assembler.weapon_recipes[wi] and shared.weapons[assembler.weapon_recipes[wi]]
    collect_entity_ingredients(assembler.wstore[wi], weapon_type.ingredients)
    assembler.items_guns[wi] = table.deepcopy(weapon_type.ingredients)
    if weapon_type.ammo then
      got_ammo = assembler.wstore[wi].remove_item({name=weapon_type.ammo, count=weapon_type.inventory})
      table.insert(assembler.items_guns[wi], {weapon_type.ammo, got_ammo})
    end
    assembler.items_guns[wi].ammo_count = got_ammo
  end
end


local function find_titanic(assembler, empty)
  local options = shared.shuffle(assembler.surface.find_entities_filtered{
    position=assembler.position, radius=supplying_radius,
    type=shared.titan_base_type, force=assembler.force,
  })
  local todo
  for _, entity in pairs(options) do
    todo = true
    todo = todo and is_titan(entity.name)
    if empty then
      todo = todo and not entity.get_driver() and not entity.get_passenger()
      todo = todo and (not entity.get_inventory(defines.inventory.car_trunk) or entity.get_inventory(defines.inventory.car_trunk).get_item_count() == 0)
    end
    if todo then return entity, nil end
  end
  for _, entity in pairs(options) do
    if is_supplier(entity.name) then return nil, entity end
  end
  return nil, nil
end


local function titan_to_bunker_internal(assembler, titan_info)
  local titan_type = shared.titan_types[titan_info.class]
  assembler.items_main = table.deepcopy(titan_type.ingredients)
  for item_name, count in pairs(assembler.items_main) do
    if shared.titan_breakable_details[item_name] then
      assembler.items_main[item_name] = math.ceil(count * titan_info.entity.get_health_ratio())
    end
  end
  assembler.class_recipe = titan_type.entity
  assembler.items_guns = {}
  local weapon_type
  for wi, _ in pairs(titan_type.mounts) do
    weapon_type = shared.weapons[titan_info.guns[wi].name]
    assembler.weapon_recipes[wi] = weapon_type.entity
    assembler.items_guns[wi] = table.deepcopy(weapon_type.ingredients)
    if weapon_type.ammo ~= nil then
      table.insert(assembler.items_guns[wi], {weapon_type.ammo, titan_info.guns[wi].ammo_count})
    end
  end
end


local function put_items_to_entity(entity, items)
  local finished = true
  local done
  for key, stack in ipairs(items) do
    if stack[2] == nil then
      error(serpent.line({
        items = items,
        key = key,
      }))
    end
    if stack[2] > 0 then
      done = entity.insert({name=stack[1], count=stack[2]})
    else
      done = 0
    end
    stack[2] = stack[2] - done
    if stack[2] <= 0 then
      -- TODO: this cuts the array, use table.remove(items, key) but iterate backwards
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
  for wi, _ in pairs(assembler.items_guns) do
    finished = put_items_to_entity(assembler.wstore[wi], assembler.items_guns[wi]) and finished
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


local function init_combinators(assembler)
  assembler.output_combinators = assembler.output_combinators or {}
  for i, pos in ipairs(bunker_signal_outputs) do
    assembler.output_combinators[i] = assembler.output_combinators[i] or assembler.surface.create_entity{
      name=shared.bunker_comb, force="neutral",
      position={x=assembler.position.x+pos[1], y=assembler.position.y+pos[2]},
    }
  end
  preprocess_entities(assembler.output_combinators)
end


local function set_signals_from_ingredients(comb, ingredients, ammo)
  return;  -- TODO: replace signals with logistic requests
  -- local ctrl = comb.get_or_create_control_behavior()
  -- for pos = 1, shared.bunker_comb_size do
  --   if ingredients and pos <= #ingredients then
  --     ctrl.set_signal(pos, {signal={type="item", name=ingredients[pos][1]}, count=ingredients[pos][2]})
  --   elseif ammo and ammo[1] and pos == #ingredients+1 then
  --     ctrl.set_signal(pos, {signal={type="item", name=ammo[1]}, count=ammo[2]})
  --   else
  --     ctrl.set_signal(pos, nil)
  --   end
  -- end
end


local function set_all_signals(assembler)
  local titan_type = shared.titan_types[assembler.class_recipe]
  set_signals_from_ingredients(assembler.output_combinators[7], titan_type and titan_type.ingredients or nil)

  for wi = 1, 6 do
    local weapon_type = assembler.weapon_recipes[wi] and shared.weapons[assembler.weapon_recipes[wi]]
    if weapon_type then
      set_signals_from_ingredients(assembler.output_combinators[wi], weapon_type.ingredients, {weapon_type.ammo, weapon_type.inventory})
    else
      set_signals_from_ingredients(assembler.output_combinators[wi])
    end
  end
end


local function clean_all_signals(assembler)
  for _, obj in pairs(assembler.output_combinators) do
    for pos = 1, shared.bunker_comb_size do
      -- TODO: set empty signal!
    end
  end
end




----- Intro -----

function lib_asmb.register_bunker(centity)

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

  init_combinators(assembler)

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
function lib_asmb.bunker_removed(assembler)
  bucks.remove(ctrl_data.assembler_buckets, building_update_rate, assembler.uid)

  func_maps(safe_destroy_chest, iter_zip{
    iter_chain({assembler.wstore, {assembler.bstore}}),
    bunker_store_shifts
  })

  die_all({assembler.wentity, assembler.sentity}, ctrl_data.assembler_index)
  die_all(assembler.lamps)
  die_all(assembler.output_combinators)
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

lib_asmb.state_handler = {}
lib_asmb.state_pre_handler = {}
lib_asmb.state_post_handler = {}
local state_handler = lib_asmb.state_handler
local state_pre_handler = lib_asmb.state_pre_handler
local state_post_handler = lib_asmb.state_post_handler

function state_handler.disabled(assembler)
  -- Pass, state changing handled by GUI
end

function state_pre_handler.initialising(assembler)
  if assembler.wentity and assembler.wentity.valid then
    -- Change entity to not minable, stable/active
    ctrl_data.assembler_index[assembler.wentity.unit_number] = nil
    local health = assembler.wentity.health
    assembler.wentity.destroy()
    assembler.wentity = nil
    assembler.sentity = assembler.surface.create_entity{
      name=shared.bunker_active, position=assembler.position, force=assembler.force,
    }
    assembler.sentity.health = health
  end
end

function state_handler.initialising(assembler)
  assembler.init_progress = assembler.init_progress + 1
  if assembler.init_progress < lib_asmb.get_bunker_init_time() then
    lib_asmb.update_assembler_guis(assembler)
  else
    -- Entity should be already changed
    ctrl_data.assembler_index[assembler.sentity.unit_number] = assembler
    lib_asmb.change_assembler_state(assembler, states.idle)
  end
end

function state_post_handler.deactivating(assembler)
  if assembler.sentity and assembler.sentity.valid then
    -- Change entity to minable
    ctrl_data.assembler_index[assembler.sentity.unit_number] = nil
    local health = assembler.sentity.health
    assembler.sentity.destroy()
    assembler.sentity = nil
    assembler.wentity = assembler.surface.create_entity{
      name=shared.bunker_minable, position=assembler.position, force=assembler.force,
    }
    assembler.wentity.health = health
    ctrl_data.assembler_index[assembler.wentity.unit_number] = assembler
  end
end

function state_pre_handler.deactivating(assembler)
  if assembler.init_progress <= 0 or assembler.init_progress > lib_asmb.get_bunker_init_time() then
    assembler.init_progress = lib_asmb.get_bunker_init_time()
  end
end

function state_handler.deactivating(assembler)
  assembler.init_progress = assembler.init_progress - 2
  if assembler.init_progress > 0 then
    lib_asmb.update_assembler_guis(assembler)
  else
    lib_asmb.change_assembler_state(assembler, states.disabled)
  end
end

function state_handler.idle(assembler)
  -- Pass, state changing handled by GUI
end

function state_pre_handler.prepare_assembly(assembler)
  assembler.auto_build = false
end

function state_handler.prepare_assembly(assembler)
  init_combinators(assembler)
  if check_bunker_correct_details(assembler) and assembler.auto_build then
    collect_bunker_details(assembler)
    assembler.assembly_progress = 0
    assembler.assembly_progress_max = get_titan_assembly_time(assembler.class_recipe)
    lib_asmb.change_assembler_state(assembler, states.assembling)
  else
    lib_asmb.update_assembler_guis(assembler)
    set_all_signals(assembler)
  end
end

function state_post_handler.prepare_assembly(assembler)
  clean_all_signals(assembler)
end

function state_handler.assembling(assembler)
  assembler.assembly_progress = assembler.assembly_progress + 1 * lib_asmb:get_assembly_speed(assembler.force)
  if assembler.assembly_progress < assembler.assembly_progress_max then
    lib_asmb.update_assembler_guis(assembler)
  else
    local titan_type = shared.titan_types[assembler.class_recipe]
    assembler.force.print({"WH40k-Titans-gui.msg-titan-created", {"entity-name."..titan_type.entity}})
    local name = titan_type.entity
    -- Try change to AAI Programmable Vehicles
    if settings.startup["wh40k-titans-aai-vehicle"].value and prototypes.entity[name.."-0"] then
      name = name.."-0"
    end
    titan_entity = assembler.surface.create_entity{
      name=name, force=assembler.force, position=assembler.position, raise_built=true,
    }
    local titan_info = lib_ttn.register_titan(titan_entity)
    local weapon_type
    titan_info.guns = {}
    for wi, _ in pairs(titan_type.mounts) do
      weapon_type = shared.weapons[assembler.weapon_recipes[wi]]
      titan_info.guns[wi] = lib_ttn.init_gun(nil, weapon_type)
      titan_info.guns[wi].ammo_count = assembler.items_guns[wi].ammo_count
    end
    lib_asmb.change_assembler_state(assembler, states.idle)
  end
end

function state_handler.waiting_disassembly(assembler)
  local titan_entity, _ = find_titanic(assembler, true)
  local titan_info = titan_entity and ctrl_data.titans[titan_entity.unit_number]
  if titan_entity and titan_info then
    local titan_type = lib_ttn.titan_type_by_entity(titan_entity)
    -- local titan_type = shared.titan_types[titan_entity.name]
    titan_to_bunker_internal(assembler, titan_info)
    titan_entity.destroy({raise_destroy=true})
    assembler.assembly_progress_max = get_titan_assembly_time(titan_info.class)
    assembler.assembly_progress = assembler.assembly_progress_max
    assembler.message = nil
    lib_asmb.change_assembler_state(assembler, states.disassembling)
    assembler.force.print({"WH40k-Titans-gui.msg-titan-removed", {"entity-name."..titan_type.entity}})
  end
end

function state_handler.disassembling(assembler)
  assembler.assembly_progress = assembler.assembly_progress - 2 * lib_asmb:get_assembly_speed(assembler.force)
  if assembler.assembly_progress > 0 then
    lib_asmb.update_assembler_guis(assembler)
  else
    if bunker_internal_to_outer(assembler) then
      lib_asmb.change_assembler_state(assembler, states.idle)
      assembler.force.print({"WH40k-Titans-gui.msg-titan-disassembled", {"entity-name."..assembler.class_recipe}})
    else
      assembler.message = {"WH40k-Titans-gui.assembly-er-no-space"}
    end
  end
end


function state_handler.restock(assembler)
  -- TODO: restock multiple aircrafts at once
  local titan_entity, supplier_entity = find_titanic(assembler, false)
  local titan_info = titan_entity and ctrl_data.titans[titan_entity.unit_number]
  local supplier_info = supplier_entity and ctrl_data.supplier_index[supplier_entity.unit_number]

  local need_ammo, have_ammo, got_ammo

  if titan_info then
    local titan_type = shared.titan_types[titan_info.name or titan_entity.name]
    local done_ws, done_ammo = 0, 0
    local weapon_type, cannon
    for wi, _ in pairs(titan_type.mounts) do
      cannon = titan_info.guns[wi]
      weapon_type = shared.weapons[cannon.name]
      need_ammo = weapon_type.inventory - cannon.ammo_count
      have_ammo = assembler.wstore[wi].get_item_count(weapon_type.ammo)
      got_ammo = math.min(need_ammo, have_ammo)
      if got_ammo > 0 then
        done_ws = done_ws + 1
        done_ammo = done_ammo + got_ammo
        assembler.wstore[wi].remove_item({name=weapon_type.ammo, count=got_ammo})
        cannon.ammo_count = cannon.ammo_count + got_ammo
        show_ammo_transfer(assembler.sentity, titan_info.entity, weapon_type.ammo, got_ammo, 4)
      end
    end

    if done_ammo > 0 then
      lib_ttn.notify_crew(titan_info, {"WH40k-Titans-gui.msg-titan-restock", done_ws, done_ammo})
    end
  end

  -- TODO: equalise weight limit among all enabled ammo types?
  if supplier_info then
    for _, ammo_name in ipairs(shared.ammo_list) do
      if not supplier_info.disabled_ammo[ammo_name] then
        for k = 1, gun_chests_number do
          have_ammo = assembler.wstore[wi].get_item_count(ammo_name)
          need_ammo = lib_spl.count_free_weight(supplier_info) / shared.ammo_weights[ammo_name]
          got_ammo = math.min(need_ammo, have_ammo)
          if got_ammo > 0 then
            assembler.wstore[wi].remove_item({name=ammo_name, count=need_ammo})
            supplier_info.inventory[ammo_name] = (supplier_info.inventory[ammo_name] or 0) + got_ammo
            show_ammo_transfer(assembler.sentity, supplier_info.entity, ammo_name, got_ammo, 1)
          end
        end
      end
    end
  end
end


local function clear_supplier(assembler, supplier_info)
  local weapon_type, done
  for ammo_name, ammo_count in pairs(supplier_info.inventory) do
    for k = 1, gun_chests_number do
      weapon_type = assembler.weapon_recipes[wi] and shared.weapons[assembler.weapon_recipes[wi]]
      -- Try to find a chest with matching ammo type or just empty recipe set
      if weapon_type == nil or ammo_name == weapon_type.ammo then
        if ammo_count > 0 then
          done = assembler.wstore[wi].insert({name=ammo_name, count=ammo_count})
          ammo_count = ammo_count - done
          if ammo_count > 0 then
            supplier_info.inventory[ammo_name] = ammo_count
          else
            supplier_info.inventory[ammo_name] = nil
          end
        end

      end
    end

    for k = 1, gun_chests_number do
      if ammo_count > 0 then
        done = assembler.wstore[wi].insert({name=ammo_name, count=ammo_count})
        ammo_count = ammo_count - done
        if ammo_count > 0 then
          supplier_info.inventory[ammo_name] = ammo_count
        else
          supplier_info.inventory[ammo_name] = nil
        end
      end
    end
  end
end


function state_handler.clearing(assembler)
  local titan_entity, supplier_entity = find_titanic(assembler, false)
  local titan_info = titan_entity and ctrl_data.titans[titan_entity.unit_number]
  local supplier_info = supplier_entity and ctrl_data.supplier_index[supplier_entity.unit_number]

  -- if titan_info then
  --   local titan_type = shared.titan_types[titan_info.name or titan_entity.name]
  --   local done_ws, done_ammo = 0, 0
  --   local weapon_type, cannon
  --   for wi, _ in pairs(titan_type.mounts) do
  --   end
  -- end

  if supplier_info then
    clear_supplier(assembler, supplier_info)
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

local states_to_corner_colors = {}
states_to_corner_colors[states.initialising] = color_green
states_to_corner_colors[states.deactivating] = color_red
states_to_corner_colors[states.assembling] = color_green
states_to_corner_colors[states.disassembling] = color_red
states_to_corner_colors[states.prepare_assembly] = color_blue
states_to_corner_colors[states.waiting_disassembly] = color_purple
states_to_corner_colors[states.restock] = color_orange
states_to_corner_colors[states.clearing] = color_cyan
states_to_corner_colors[states.idle] = color_ltgrey


local function process_an_assembler(assembler)
  -- game.print("Handling "..assembler.state.." for assembler "..assembler.uid)
  state_handler[assembler.state](assembler)
  if not states_no_need_clean[assembler.state] then
    -- TODO: shine lamps if chests aren't empty?
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
  if not storage.active_mods_cache then
    storage.active_mods_cache = script.active_mods
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

lib_asmb:on_event(defines.events.on_tick, process_assemblers)


local function bunkers_debug_cmd(cmd)
  local player = game.players[cmd.player_index]
  if not player.admin then
    player.print({"cant-run-command-not-admin", "Bunkers debug"})
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


require("script/assemble_ui")
return lib_asmb