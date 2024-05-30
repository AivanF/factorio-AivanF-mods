local lib_titan = require("script/titan")
local lib_assemble = require("script/assemble")
local lib_ruins = require("script/ruins")
local lib_exc = require("script/exc")
local lib_tech = require("script/tech")

local Lib = require("script/event_lib")
local lib = Lib.new()

local blank_ctrl_data = {
  assembler_buckets = {}, -- uid => bucket => assembler
  assembler_index = {}, -- entity.unit_number => assembler
  -- assembler_entities = {}, -- bunker parts, entity.unit_number => {assembler=, index=[0:6]}
  assembler_gui = {}, -- player.index => {assembler=, main_frame=}

  titans = {},
  titan_gui = {},
  foots = {},
  by_player = {}, -- player.index => user settings

  by_surface = nil, -- surface.index => world settings
  by_zones = nil, -- mod name => mod's zone index => world settings
  ruins = {}, -- materialised corpses, unit_number => ruin_info

  excavator_buckets = {}, -- unit_number => bucket => exc_info
  excavator_index = {}, -- unit_number => exc_info

  researches = {}, -- force_index => tech_name => level
}
ctrl_data = table.deepcopy(blank_ctrl_data)


local function on_any_built(event)
  local entity = event.created_entity or event.entity or event.destination
  if not (entity and entity.valid) then return end
  if is_titan(entity.name) then
    lib_titan.register_titan(entity)
  elseif entity.name == shared.bunker_minable then
    lib_assemble.register_bunker(entity)
  elseif entity.name == shared.excavator then
    lib_exc.register_excavator(entity)
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
      lib_titan.titan_death(titan_info)
    end
    remove_titan_gui_by_titan(titan_info)
    die_all(titan_info.foots)
    ctrl_data.titans[unit_number] = nil
  end

  if ctrl_data.excavator_index[unit_number] then
    lib_exc.excavator_removed(unit_number)
  end
  if ctrl_data.ruins[unit_number] then
    lib_ruins.ruin_removed(unit_number)
  end

  if event.name ~= defines.events.script_raised_destroy and ctrl_data.assembler_index[unit_number] then
    lib_assemble.bunker_removed(ctrl_data.assembler_index[unit_number])
  end

  ctrl_data.assembler_index[unit_number] = nil
end


local function total_reload()
  local titan_count = 0
  local bunker_count = 0
  local special_removed = 0
  local special_saved = 0
  shared.used_specials = {}

  for _, surface in pairs(game.surfaces) do
    for _, titan_class in pairs(shared.titan_types) do
      for _, entity in pairs (surface.find_entities_filtered{name=titan_class.entity}) do
        lib_titan.register_titan(entity)
        titan_count = titan_count + 1
      end
    end

    for _, entity in pairs (surface.find_entities_filtered{name=shared.bunker_minable}) do
      lib_assemble.register_bunker(entity)
      bunker_count = bunker_count + 1
    end

    for _, entity in pairs (surface.find_entities_filtered{name=shared.bunker_active}) do
      lib_assemble.register_bunker(entity)
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
  log("WH40k_Titans.on_load: "..serpent.block(global.ctrl_data))
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


return lib