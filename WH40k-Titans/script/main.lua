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

  if ctrl_data.titans[unit_number] then
    local titan_info = ctrl_data.titans[unit_number]
    if event.name == defines.events.on_entity_died then
      lib_ttn.titan_death(titan_info)
    end
    lib_ttn.remove_titan_gui_by_titan(titan_info)
    die_all(titan_info.foots)
    ctrl_data.titans[unit_number] = nil
  end

  if ctrl_data.supplier_index[unit_number] then
    lib_spl.supplier_removed(unit_number)
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
  game.print(txt)
  log(txt)
end


local function on_init()
  global.active_mods_cache = game.active_mods
  global.ctrl_data = table.deepcopy(blank_ctrl_data)
  ctrl_data = global.ctrl_data
  preprocess_ingredients()
  lib_ruins.initial_index()
end

local function on_load()
  -- log("WH40k_Titans.on_load: "..serpent.block(global.ctrl_data))
  ctrl_data = global.ctrl_data
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
  global.active_mods_cache = game.active_mods
  preprocess_ingredients()

  global.ctrl_data = merge(global.ctrl_data or {}, blank_ctrl_data, false)
  ctrl_data = global.ctrl_data

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

    elseif ctrl_data.supplier_index[unit_number] then
      lib_spl.supplier_ammo_fulfill(ctrl_data.supplier_index[unit_number])
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