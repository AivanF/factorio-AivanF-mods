require("script/common")
local math2d = require("math2d")
local titan = require("script/titan")

local Lib = require("script/event_lib")
local lib = Lib.new()

building_update_rate = 60
local quick_mode = true
local required_ammo_ratio = 0.1

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
local bunker_init_time = quick_mode and 5 or 60

local function check_entity_has_ingredients(entity, ingredients)
  for _, stack in pairs(ingredients) do
    if entity.get_item_count(stack[1]) < stack[2] then return false end
  end
  return true
end

local function draw_assembler_lamp(assembler, k, lamp_color)
  rendering.draw_light{
    surface=assembler.surface, sprite=shared.mod_prefix.."light", scale=1,
    intensity=2, minimum_darkness=0, color=lamp_color, time_to_live=building_update_rate,
    target={x=assembler.position.x+bunker_lamps[k][1], y=assembler.position.y+bunker_lamps[k][2]},
  }
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
  lamp_color = color_green
  if not titan_type then
    set_message(assembler, "Titan class is not set")
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
    lamp_color = color_gold
  end
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
      elseif weapon_type and not (weapon_type ~= titan_type.guns[k].grade or weapon_type ~= titan_type.guns[k].grade-1) then
        set_message(assembler, "improper weapon grade")
        weapon_fine = false
        lamp_color = color_red
      end
    end
    if not assembler.wstore[k] then
      set_message(assembler, "improper bunker setup 2")
      weapon_fine = false
    end
    if weapon_type then
      -- Set recipe to assembler.wrecipe[k] ?
      if not check_entity_has_ingredients(assembler.wstore[k], weapon_type.ingredients) then
        set_message(assembler, "not enough weapon details for "..weapon_type.name)
        weapon_fine = false
        lamp_color = color_orange
      end
      if assembler.wstore[k].get_item_count(weapon_type.ammo) < weapon_type.inventory*required_ammo_ratio-1 then
        set_message(assembler, "not enough ammo for "..weapon_type.name)
        weapon_fine = false
        lamp_color = color_gold
      end
      if not lamp_color then
        lamp_color = color_green
      end
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
      todo = todo and (not entity.get_main_inventory() or entity.get_main_inventory().get_item_count() == 0)
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
  for key, stack in pairs(items) do
    done = entity.insert({name=stack[1], count=stack[2]})
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
    finished = finished and put_items_to_entity(assembler.wstore[k], assembler.items_guns[k])
  end
  return finished
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

  local bucket = ctrl_data.assembler_buckets[uid % building_update_rate]
  if not bucket then
    bucket = {}
    ctrl_data.assembler_buckets[uid % building_update_rate] = bucket
  end
  local assembler = bucket[uid] or {
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
    items_main = {},
    items_guns = {},

    -- Bunker entities
    wentity = wentity, -- weak, mainable entity
    sentity = sentity, -- stable, strong entity
    lamps = {},
    wstore = {},
    wrecipe = {},
    bstore = nil,
    brecipe = nil,
  }
  bucket[uid] = assembler
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




----- MAIN -----

local state_handler = {}

function state_handler.disabled(assembler)
  -- Pass, state changing handled by GUI
end

function state_handler.initialising(assembler)
  assembler.init_progress = assembler.init_progress + 1
  if assembler.init_progress < bunker_init_time then
    update_assembler_guis(assembler)
  else
    -- Change entity to not minable, stable/active
    ctrl_data.assembler_index[assembler.wentity.unit_number] = nil
    assembler.wentity.destroy()
    assembler.sentity = assembler.surface.create_entity{
      name=shared.bunker_active, position=assembler.position, force=assembler.force,
    }
    ctrl_data.assembler_index[assembler.sentity.unit_number] = assembler
    change_assembler_state(assembler, states.idle)
  end
end

function state_handler.deactivating(assembler)
  assembler.init_progress = assembler.init_progress - 1
  if assembler.init_progress > 0 then
    update_assembler_guis(assembler)
  else
    if assembler.sentity then
      -- Change entity to minable
      ctrl_data.assembler_index[assembler.sentity.unit_number] = nil
      assembler.sentity.destroy()
      assembler.wentity = assembler.surface.create_entity{
        name=shared.bunker_minable, position=assembler.position, force=assembler.force,
      }
      ctrl_data.assembler_index[assembler.wentity.unit_number] = assembler
    end
    change_assembler_state(assembler, states.disabled)
  end
end

function state_handler.idle(assembler)
  -- Pass, state changing handled by GUI
end

function state_handler.prepare_assembly(assembler)
  if check_bunker_correct_details(assembler) and (assembler.auto_build or true) then
    collect_bunker_details(assembler)
    assembler.assembly_progress = 0
    assembler.assembly_progress_max = get_titan_assembly_time(assembler.class_recipe)
    change_assembler_state(assembler, states.assembling)
  else
    -- update_assembler_guis(assembler)
  end
end

function state_handler.assembling(assembler)
  assembler.assembly_progress = assembler.assembly_progress + 1
  if assembler.assembly_progress < assembler.assembly_progress_max then
    update_assembler_guis(assembler)
  else
    local titan_type = shared.titan_types[assembler.class_recipe]
    assembler.force.print("Placing titan "..titan_type.name) -- TODO: translate
    titan_entity = assembler.surface.create_entity{
      name=titan_type.entity, force=assembler.force, position=assembler.position,
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
  local titan_entity = find_titan(assembler, empty)
  local titan_info = titan_entity and ctrl_data.titans[titan_entity.unit_number]
  if titan_entity and titan_info then
    local titan_type = shared.titan_types[titan_entity.name]
    assembler.force.print("Disassembling titan "..titan_type.name) -- TODO: translate
    titan_to_bunker_internal(assembler, titan_info)
    titan_entity.destroy({raise_destroy=true})
    assembler.assembly_progress_max = get_titan_assembly_time(titan_info.class)
    assembler.assembly_progress = assembler.assembly_progress_max
    change_assembler_state(assembler, states.disassembling)
  end
end

function state_handler.disassembling(assembler)
  assembler.assembly_progress = assembler.assembly_progress - 1
  if assembler.assembly_progress > 0 then
    update_assembler_guis(assembler)
  else
    if bunker_internal_to_outer(assembler) then
      change_assembler_state(assembler, states.idle)
    end
  end
end

function state_handler.restock(assembler)
  local titan_entity = find_titan(assembler, empty)
  local titan_info = titan_entity and ctrl_data.titans[titan_entity.unit_number]

  if titan_entity and titan_info then
    local weapon_type, cannon, need_ammo, got_ammo
    for k, _ in pairs(titan_type.guns) do
      cannon = titan_info.guns[k]
      weapon_type = shared.weapons[cannon.name]
      need_ammo = weapon_type.inventory - cannon.ammo_count
      got_ammo = assembler.wstore[k].remove_item({name=weapon_type.ammo, count=need_ammo})
      cannon.ammo_count = cannon.ammo_count + got_ammo
      -- TODO: if got_ammo > 0 then increase stats?
    end
  end
end

local function process_assemblers()
  if not global.active_mods_cache then
    global.active_mods_cache = game.active_mods
    preprocess_ingredients()
  end

  local bucket = ctrl_data.assembler_buckets[game.tick % building_update_rate]
  if not bucket then return end
  for uid, assembler in pairs(bucket) do
    -- game.print("Handling "..assembler.state.." for assembler "..assembler.uid)
    state_handler[assembler.state](assembler)

    if true
      and assembler.state ~= states.prepare_assembly
      and assembler.state ~= states.assembling
      and assembler.state ~= states.waiting_disassembly
      and assembler.state ~= states.disassembling
    then
      -- TODO: shine lamps if chests aren't empty!
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

local gui_maker = {}

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

function gui_maker.prepare_assembly(assembler, main_frame)
  main_frame.status_line.add{type="sprite-button", index=1, tags={action=act_change_state, state=states.idle}, sprite="virtual-signal/signal-grey", tooltip={"WH40k-Titans-gui.assembly-act-cancel"} }
  -- TODO: add auto-build setting, show button for states.assembling
  -- TODO: show expected assembly time

  main_frame.main_room.add{
    type="label", name="label",
    caption="Status: "..(assembler.message or "unknown")
  }

  local has_character = not not game.get_player(main_frame.player_index).character
  function try_limit(filters)
    if has_character then
      table.insert(filters, {filter="enabled", mode="and"})
    end
    return filters
  end

  local grid = main_frame.main_room.add{ type="frame", direction="horizontal" }
  local btn
  btn = grid.add{
    type="choose-elem-button", name="", elem_type="recipe",
    elem_filters = try_limit{{filter="category", category = shared.craftcat_titan}},
    recipe = assembler.class_recipe,
    tags={action=act_set_class},
  }
  local titan_type, weapon_type
  if assembler.class_recipe then
    titan_type = shared.titan_types[assembler.class_recipe]
  end
  for k = 1, 6 do
    btn = grid.add{
      type="choose-elem-button", elem_type="recipe",
      elem_filters = try_limit{{filter="category", category = shared.craftcat_weapon}},
      recipe = assembler.weapon_recipes[k],
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
end

function gui_maker.assembling(assembler, main_frame)
  main_frame.status_line.add{type="sprite-button", index=1, tags={action=act_change_state, state=states.disassembling}, sprite="virtual-signal/signal-red", tooltip={"WH40k-Titans-gui.assembly-act-cancel"} }
  main_frame.main_room.add{ type="progressbar", name=main_frame_assembly_progress, direction="horizontal", value=assembler.assembly_progress/assembler.assembly_progress_max }
  -- TODO: show class, weapons
end

function gui_maker.waiting_disassembly(assembler, main_frame)
  main_frame.status_line.add{type="sprite-button", index=1, tags={action=act_change_state, state=states.idle}, sprite="virtual-signal/signal-grey", tooltip={"WH40k-Titans-gui.assembly-act-cancel"} }
end

function gui_maker.disassembling(assembler, main_frame)
  main_frame.main_room.add{ type="progressbar", name=main_frame_assembly_progress, direction="horizontal", value=assembler.assembly_progress/assembler.assembly_progress_max }
  -- TODO: show class, weapons
end

function gui_maker.restock(assembler, main_frame)
  main_frame.status_line.add{type="sprite-button", index=1, tags={action=act_change_state, state=states.idle}, sprite="virtual-signal/signal-grey", tooltip={"WH40k-Titans-gui.assembly-act-cancel"} }
end

local function create_assembly_gui(player, assembler)
  if player.gui.screen[main_frame_name] then
    if ctrl_data.assembler_gui[player.index].assembler == assembler then
      lib.update_assembler_gui(ctrl_data.assembler_gui[player.index])
      return
    else
    player.gui.screen[main_frame_name].destroy()
    end
  end

  local main_frame = player.gui.screen.add{ type="frame", name=main_frame_name, direction="vertical", }
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

  main_frame.add{ type="flow", name="status_line", direction="horizontal" }
  main_frame.add{ type="flow", name="main_room", direction="vertical" }

  local gui_info = { assembler=assembler, main_frame=main_frame, player_index=player.index }
  ctrl_data.assembler_gui[player.index] = gui_info
  lib.update_assembler_gui(ctrl_data.assembler_gui[player.index])
end

function lib.update_assembler_gui(gui_info)
  gui_info.main_frame.status_line.clear()
  gui_info.main_frame.status_line.add{ type="label", name="label" }
  gui_info.main_frame.status_line.label.caption = {"WH40k-Titans-gui.assembly-state-"..gui_info.assembler.state}

  gui_info.main_frame.main_room.clear()
  gui_maker[gui_info.assembler.state](gui_info.assembler, gui_info.main_frame)
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

  if event.element.tags.action == act_main_frame_close then
    if player.gui.screen[main_frame_name] then
      player.gui.screen[main_frame_name].destroy()
      ctrl_data.assembler_gui[event.player_index] = nil
    end
  elseif event.element.tags.action == act_change_state then
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
  if event.element and event.element.name == main_frame_name then
    -- TODO: save values? Use some gui_closer
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
    assembler_count = get_in_buckets_count(ctrl_data.assembler_buckets),
    entity_count = #get_keys(ctrl_data.assembler_index),
  }))
end

commands.add_command(
  "bunkers-debug",
  "Prints some debug info",
  bunkers_debug_cmd
)


return lib