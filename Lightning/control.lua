script_data = {}
require("scripts/common")
require("scripts/surface")
require("scripts/lightning")
require("scripts/arty")
require("scripts/technologies")


local settings_nauvis_changed = false
local settings_presets_changed = false


local function on_any_built(event)
  local entity = event.created_entity or event.entity or event.destination
  if not (entity and entity.valid) then return end
  if rod_protos[entity.name] then
    register_rod(entity)
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
  script_data.objects[unit_number] = nil
  script_data.arty_tasks[unit_number] = nil
end

local function reset_global()
  debug_print("TSL reset_global")
  script_data.rods_by_surface = {}
  script_data.surfSettings = {
    [1] = setup_preset(shared.PRESET_HOME, 0),
  }
  script_data.objects = {}  -- by unit_number
  script_data.arty_tasks = {}  -- by unit_number
  script_data.arty_lvl_stri = {}  -- by player_index
  script_data.arty_lvl_bomb = {}  -- by player_index
  script_data.technologies = {}  -- name => force => value
  if settings.startup["af-tsl-support-surfaces"].value then
    if game.active_mods[SE] then se_add_zones() end
  end

  reset_technologies()
end

function clean_drawings()
  local ids = rendering.get_all_ids(mod_name)
  for _, id in pairs(ids) do
    if rendering.is_valid(id) then
      rendering.destroy(id)
    end
  end
end

local function on_init()
  global.script_data = global.script_data or script_data
  reset_global()
end

local function on_load()
  script_data = global.script_data or script_data
end

local function update_configuration()
  global.script_data = script_data
  clean_drawings()
  reset_global()
  rods_reload()
end

local function process_min()
  if game.active_mods[SE] and game.tick > second_ticks then
    --- Tried defines.events.on_surface_created
    --- But seems like during the event, SE doesn't have surface linked to zone yet
    for _, surface in pairs(game.surfaces) do
      if not script_data.surfSettings[surface.index] then
        se_register_zone(surface.index)
      end
    end
  end
end

local function process_sec()
  if settings_nauvis_changed then
    settings_nauvis_changed = false
    update_nauvis_settings()
  end

  if settings_presets_changed then
    debug_print("TSL settings_presets_changed")
    settings_presets_changed = false
    reload_preset_mappings()
    apply_updated_mappings()
  end

  update_arty_tasks()
end


local function update_runtime_settings(event)
  --- Common values
  if event.setting:find("af-tsl-", 1, true) then
    set_energy_cf = settings.global["af-tsl-energy-cf"].value
    set_rate_cf = settings.global["af-tsl-rate-cf"].value
    chunk_lightning_rate = minute_ticks /1 /set_rate_cf
    set_extra_reduct = settings.global["af-tsl-extra-reduct"].value
    set_fire_lvl = settings.global["af-tsl-fire-from-level"].value
  end

  --- Homeworld preset
  if event.setting:find("af-tsl-nauvis-", 1, true) then
    settings_nauvis_changed = true
  end

  --- Mappings
  if event.setting:find("af-tsl-preset-for-", 1, true) then
    settings_presets_changed = true
  end
end


script.on_init(on_init)
script.on_load(on_load)
script.on_event(defines.events.on_runtime_mod_setting_changed, update_runtime_settings)
script.on_configuration_changed(update_configuration)

script.on_event({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}, on_any_built)

script.on_event({
  defines.events.on_player_mined_entity,
  defines.events.on_robot_mined_entity,
  defines.events.on_entity_died,
  defines.events.script_raised_destroy,
}, on_any_remove)

script.on_nth_tick(minute_ticks, process_min)
script.on_nth_tick(second_ticks, process_sec)
script.on_event(defines.events.on_tick, process_entities)


commands.add_command(
  "tsl-clean-draw",
  "Remove all TSL drawings",
  clean_drawings
)
commands.add_command(
  "tsl-rods-reload",
  "Reload all TSL rods",
  rods_reload
)
commands.add_command(
  "tsl-clean-cache",
  "Reload all TSL surface cache",
  cache_clean
)

remote.add_interface(mod_name, {
  list_surf_settings = function()
    return script_data.surfSettings
  end,
  set_surf_settings = function(surface_index, new_settings)
    shared.tableOverride(script_data.surfSettings[surface_index], new_settings)
  end,
})
