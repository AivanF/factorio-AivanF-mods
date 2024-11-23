local lib_ttn = require("script/titan")
local lib_spl = require("script/supplier")
local lib_asmb = require("script/assemble")
local lib_ruins = require("script/ruins")
local lib_exc = require("script/exc")
local lib_tech = require("script/tech")
local lib_gen = require("script/gen_ui")

local Lib = require("script/event_lib")
local lib = Lib.new()

local blank_ctrl_data = {
  assembler_buckets = {}, -- uid => bucket => assembler
  assembler_index = {}, -- entity.unit_number => assembler
  -- assembler_entities = {}, -- bunker parts, entity.unit_number => {assembler=, index=[0:6]}
  assembler_gui = {}, -- player.index => {player=, main_frame=, assembler=}

  titans = {},
  titan_gui = {}, -- player.index => {player=, main_frame=, titan_info=, guns=}
  foots = {},
  by_player = {}, -- player.index => user settings

  excavator_buckets = {}, -- unit_number => bucket => exc_info
  excavator_index = {}, -- unit_number => exc_info

  supplier_buckets = {}, -- unit_number => bucket => supplier_info
  supplier_index = {}, -- unit_number => supplier_info
  supplier_gui = {},

  gen_ui = {}, -- player.index => {player=, main_frame=}

  ruins = {}, -- materialised corpses, unit_number => ruin_info
  by_surface = nil, -- surface.index => world settings
  by_zones = nil, -- mod name => mod's zone index => world settings

  researches = {}, -- force_index => tech_name => level
}
ctrl_data = table.deepcopy(blank_ctrl_data)


local function on_any_built(event)
  local entity = event.created_entity or event.entity or event.destination
  if not (entity and entity.valid) then return end
  if is_titan(entity.name) then
    lib_ttn.register_titan(entity)
  elseif entity.name == shared.bunker_minable then
    lib_asmb.register_bunker(entity)
  elseif entity.name == shared.excavator then
    lib_exc.register_excavator(entity)
  elseif is_supplier(entity.name) then
    lib_spl.register_supplier(entity)
  end
end


local function on_any_remove(event)
  local unit_number
  local entity = event.entity
  if entity and entity.valid then
    unit_number = entity.unit_number
  else
    entity = nil
  end
  unit_number = unit_number or event.unit_number
  if not unit_number then return end
  local is_death = event.name == defines.events.on_entity_died

  -- game.print("on_any_remove: "..serpent.line({name=entity.name, is_death=is_death}))

  if ctrl_data.titans[unit_number] then
    lib_ttn.titan_removed_by_number(unit_number, is_death)
  end

  if ctrl_data.supplier_index[unit_number] then
    lib_spl.supplier_removed_by_number(unit_number, is_death)
  end

  if ctrl_data.excavator_index[unit_number] then
    lib_exc.excavator_removed(unit_number)
  end

  if ctrl_data.ruins[unit_number] then
    lib_ruins.ruin_removed(unit_number)
  end

  if ctrl_data.assembler_index[unit_number] then
    if event.name ~= defines.events.script_raised_destroy then
      lib_asmb.bunker_removed(ctrl_data.assembler_index[unit_number])
    end
    ctrl_data.assembler_index[unit_number] = nil
  end
end


local function reveng_set_value(item_name, tech_name, price)
  remote.call("reverse_labs", "add_override_item", item_name, {
    ingredients = {shared.sp},
    price = price,
    prob = price,
    tech_name = tech_name,
  })
end


local function reveng_multiply_value(item_name, cf, silent)
    local item_info = remote.call("reverse_labs", "get_item", item_name)
    if item_info == nil then
      -- if not silent and settings.global["wh40k-titans-debug-info"].value then
      --   error(serpent.line({
      --     error="No item worth",
      --     item_name=item_name,
      --   }))
      -- else
        return false
      -- end
    end
    item_info.price = item_info.price * cf
    item_info.prob = item_info.prob * cf
    remote.call("reverse_labs", "add_override_item", item_name, item_info)
    return true
end


local ammo_prices = {
  [shared.big_bolt] = 0.5,
  [shared.flamer_ammo] = 0.5,
  [shared.laser_ammo] = 0.5,
  [shared.plasma_ammo] = 1,
  [shared.melta_ammo] = 1.5,
  [shared.hell_ammo] = 6,
  [shared.doom_missile_ammo] = 3,
  [shared.plasma_missile_ammo] = 5,
  [shared.warp_missile_ammo] = 10,
}


remote.add_interface(shared.titan_prefix.."main", {
  on_entity_replaced = function(data)
    -- AAI Programmable Vehicles integration

    -- game.print("Titans.on_entity_replaced: "..serpent.line(data))

    if ctrl_data.titans[data.old_entity.unit_number] then
      lib_ttn.titan_entity_replaced(data.old_entity, data.new_entity)
    end

    if ctrl_data.supplier_index[data.old_entity.unit_number] then
      lib_spl.supplier_entity_replaced(data.old_entity, data.new_entity)
    end
  end,

  -- reverse_engineering_pre_calc = function()
  --   game.print("// WH40k RevEng Pre")
  -- end,

  reverse_engineering_post_calc = function()
    --[[
    Adjust details prices.
    It's tricky, RevEng assignes values dynamically,
    and it varies a lot for different overhaul mods.
    ]]--
    local tech_name = shared.mod_prefix.."production"
    -- Body
    _ = reveng_multiply_value(shared.servitor,    0.2) or reveng_set_value(shared.servitor, tech_name, 0.1);
    _ = reveng_multiply_value(shared.brain,       2.0) or reveng_set_value(shared.brain, tech_name, 7);
    _ = reveng_multiply_value(shared.energy_core, 0.8) or reveng_set_value(shared.energy_core, tech_name, 3);
    _ = reveng_multiply_value(shared.void_shield, 0.8) or reveng_set_value(shared.void_shield, tech_name, 5);
    _ = reveng_multiply_value(shared.frame_part,  0.3) or reveng_set_value(shared.frame_part, tech_name, 0.5);
    _ = reveng_multiply_value(shared.motor,       0.3) or reveng_set_value(shared.motor, tech_name, 0.5);
    -- Common
    _ = reveng_multiply_value(shared.antigraveng, 1.0) or reveng_set_value(shared.antigraveng, tech_name, 5);
    _ = reveng_multiply_value(shared.realityctrl, 2.0) or reveng_set_value(shared.realityctrl, tech_name, 10);
    -- Weapons
    _ = reveng_multiply_value(shared.barrel,      0.2) or reveng_set_value(shared.barrel, tech_name, 0.2);
    _ = reveng_multiply_value(shared.proj_engine, 0.5) or reveng_set_value(shared.proj_engine, tech_name, 0.25);
    _ = reveng_multiply_value(shared.melta_pump,  0.5) or reveng_set_value(shared.melta_pump, tech_name, 0.25);
    -- From the Bridge
    -- reveng_multiply_value(afci_bridge.get.emfc().name, 1);
    -- reveng_multiply_value(afci_bridge.get.he_emitter().name, 1);
    reveng_multiply_value(afci_bridge.get.ehe_emitter().name, 2);
    -- reveng_multiply_value(afci_bridge.get.rocket_engine().name, 1);

    for name, price in pairs(ammo_prices) do
      remote.call("reverse_labs", "add_override_item", name, {
        ingredients = {shared.sp},
        price = price,
        prob = price,
        tech_name = shared.mod_prefix.."ammo",
      })
    end
    -- game.print("// WH40k RevEng Post")
  end,
})


local function total_reload()
  local titan_count = 0
  local bunker_count = 0
  local special_removed = 0
  local special_saved = 0
  shared.used_specials = {}

  for _, surface in pairs(game.surfaces) do
    for _, titan_class in pairs(shared.titan_types) do
      for _, entity in pairs (surface.find_entities_filtered{name=titan_class.entity}) do
        lib_ttn.register_titan(entity)
        titan_count = titan_count + 1
      end
    end

    for _, entity in pairs (surface.find_entities_filtered{name=shared.bunker_minable}) do
      lib_asmb.register_bunker(entity)
      bunker_count = bunker_count + 1
    end

    for _, entity in pairs (surface.find_entities_filtered{name=shared.bunker_active}) do
      lib_asmb.register_bunker(entity)
      bunker_count = bunker_count + 1
    end

    for _, name in pairs(shared.special_entities) do
      for _, entity in pairs (surface.find_entities_filtered{name=name}) do
        if shared.used_specials[entity.unit_number] then
          special_saved = special_saved + 1
        else
          -- TODO: replace non-empty storages with temp containers!
          entity.destroy()
          special_removed = special_removed + 1
        end
      end
    end
  end
  shared.used_specials = nil

  lib_tech.update_configuration()

  local txt = "WH40k_Titans.reload: "..table.concat({
      "Ti="..titan_count,
      "Bn="..bunker_count,
      "SpRm="..special_removed,
      "SpSv="..special_saved,
    }, ", ")
  if special_removed > 0 then
    game.print(txt)
  end
  log(txt)
  if titan_count > 0 or bunker_count > 0 then
    game.print({"WH40k-Titans-gui.ads"})
  end
end


local function cache_tiles()
  ctrl_data.tile_fuilds = {}
  for name, proto in pairs(prototypes.tile) do
    if proto.fluid then
      ctrl_data.tile_fuilds[proto.fluid.name] = ctrl_data.tile_fuilds[proto.fluid.name] or {}
      ctrl_data.tile_fuilds[proto.fluid.name][name] = true
    end
  end
end


local function on_init()
  storage.active_mods_cache = script.active_mods
  storage.ctrl_data = table.deepcopy(blank_ctrl_data)
  ctrl_data = storage.ctrl_data
  cache_tiles()
  preprocess_ingredients()
  lib_ruins.initial_index()
end

local function on_load()
  -- log("WH40k_Titans.on_load: "..serpent.block(storage.ctrl_data))
  ctrl_data = storage.ctrl_data
  preprocess_ingredients()
end

local function clean_drawings()
  local ids = rendering.get_all_ids(shared.mod_name)
  for _, id in pairs(ids) do
    if rendering.is_valid(id) then
      rendering.destroy(id)
    end
  end
end

local function update_configuration()
  -- game.print("Titans.update_configuration")
  storage.active_mods_cache = script.active_mods

  storage.ctrl_data = merge(storage.ctrl_data or {}, blank_ctrl_data, false)
  ctrl_data = storage.ctrl_data
  preprocess_ingredients()
  cache_tiles()

  -- TODO: correct them to work with assemblers, excavators, ruins
  -- clean_drawings()
  total_reload()

  if ctrl_data.by_surface == nil then
    lib_ruins.initial_index()
  end

  for _, player in pairs(game.players) do
    lib_gen.setup_gui_btn(player.index)
  end
end

local function fulfill_ammo_cmd(cmd)
  local player = game.players[cmd.player_index]
  if not player.admin then
    player.print({"cant-run-command-not-admin", "Fulfill ammo"})
    return
  end
  if player.vehicle and player.vehicle.valid then
    local unit_number = player.vehicle.unit_number
    if ctrl_data.titans[unit_number] then
      lib_ttn.titan_ammo_fulfill(ctrl_data.titans[unit_number])
      return
    elseif ctrl_data.supplier_index[unit_number] then
      lib_spl.supplier_ammo_fulfill(ctrl_data.supplier_index[unit_number])
      return
    end
  end
  player.print("Seems like you are not driving a Titan nor Supplier...")
  return
end

local function clear_ammo_cmd(cmd)
  local player = game.players[cmd.player_index]
  if not player.admin then
    player.print({"cant-run-command-not-admin", "Clear ammo"})
    return
  end
  if player.vehicle and player.vehicle.valid then
    local unit_number = player.vehicle.unit_number
    if ctrl_data.titans[unit_number] then
      lib_ttn.titan_ammo_clear(ctrl_data.titans[unit_number])
      player.print("Done")
      return

    elseif ctrl_data.supplier_index[unit_number] then
      lib_spl.supplier_ammo_clear(ctrl_data.supplier_index[unit_number])
      player.print("Done")
      return
    end
  end
  player.print("Seems like you are not driving a Titan nor Supplier...")
  return
end


lib:on_init(on_init)
lib:on_load(on_load)
-- lib.on_event(defines.events.on_runtime_mod_setting_changed, update_runtime_settings)
lib:on_configuration_changed(update_configuration)

lib:on_any_built(on_any_built)
lib:on_any_remove(on_any_remove)

commands.add_command(
  "titans-reload",
  "Reload all WH40k Titans",
  update_configuration
)

commands.add_command(
  "titans-fulfill",
  "Fulfill current vehicle ammo (Titan or Supplier)",
  fulfill_ammo_cmd
)

commands.add_command(
  "titans-clear",
  "Clear current vehicle ammo (Titan or Supplier)",
  clear_ammo_cmd
)

return lib