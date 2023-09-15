local titan = require("script/titan")
local assemble = require("script/assemble")

local Lib = require("script/event_lib")
local lib = Lib.new()


local function on_any_built(event)
  local entity = event.created_entity or event.entity or event.destination
  if not (entity and entity.valid) then return end
  if is_titan(entity.name) then
    titan.register_titan(entity)
  elseif entity.name == shared.bunker then
    assemble.register_bunker(entity)
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
      titan.titan_death(titan_info)
    end
    remove_titan_gui_by_titan(titan_info)
    die_all(titan_info.foots)
    ctrl_data.titans[unit_number] = nil
  end

  local bucket = ctrl_data.bunkers[unit_number % building_update_rate]
  if bucket and bucket[unit_number] then
    local bunker = bucket[unit_number]
    -- TODO: replace non-empty storages with temp containers!
    die_all(bunker.lamps)
    die_all(bunker.wstore)
    die_all(bunker.wrecipe)
    die_all({bunker.brecipe, bunker.bstore})
    ctrl_data.bunkers[unit_number % building_update_rate] = nil
  end
end


local function total_reload()
  local titan_count = 0
  local bunker_count = 0
  local special_removed = 0
  local special_saved = 0
  used_specials = {}

  for _, surface in pairs(game.surfaces) do
    for _, titan_class in pairs(shared.titan_types) do
      for _, entity in pairs (surface.find_entities_filtered{name=titan_class.entity}) do
        titan.register_titan(entity)
        titan_count = titan_count + 1
      end
    end

    for _, entity in pairs (surface.find_entities_filtered{name=shared.bunker}) do
      assemble.register_bunker(entity)
      bunker_count = bunker_count + 1
    end

    for _, name in pairs(shared.special_entities) do
      for _, entity in pairs (surface.find_entities_filtered{name=name}) do
        if used_specials[entity.unit_number] then
          special_saved = special_saved + 1
        else
          -- TODO: replace non-empty storages with temp containers!
          entity.destroy()
          special_removed = special_removed + 1
        end
      end
    end
  end
  used_specials = {}

  local txt = "WH40k-Titans reload: "..table.concat({
      "Ti="..titan_count,
      "Bn="..bunker_count,
      "SpRm="..special_removed,
      "SpSv="..special_saved,
    }, ", ")
  game.print(txt)
  log(txt)
end


local function on_init()
  global.ctrl_data = table.deepcopy(blank_ctrl_data)
end

local function on_load()
  ctrl_data = global.ctrl_data
end

local function clean_drawings()
  local ids = rendering.get_all_ids(mod_name)
  for _, id in pairs(ids) do
    if rendering.is_valid(id) then
      rendering.destroy(id)
    end
  end
end

local function update_configuration()
  global.ctrl_data = merge(global.ctrl_data or {}, blank_ctrl_data, false)
  ctrl_data = global.ctrl_data
  clean_drawings()
  total_reload()
end


lib:on_init(on_init)
lib:on_load(on_load)
-- lib.on_event(defines.events.on_runtime_mod_setting_changed, update_runtime_settings)
lib:on_configuration_changed(update_configuration)

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

commands.add_command(
  "titans-clean-draw",
  "Remove all WH40k Titans drawings",
  clean_drawings
)
commands.add_command(
  "titans-reload",
  "Reload all WH40k Titans",
  update_configuration
)


return lib