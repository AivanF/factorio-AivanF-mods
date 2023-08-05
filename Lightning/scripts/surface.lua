require("common")
local perlin = require("perlin")

set_nauvis_base = settings.global["af-tsl-nauvis-base"].value
set_nauvis_scale = settings.global["af-tsl-nauvis-scale"].value
set_nauvis_size = settings.global["af-tsl-nauvis-size"].value
set_nauvis_zspeed = settings.global["af-tsl-nauvis-zspeed"].value

local surfPresets = {
  [shared.PRESET_HOME]   = {
    base=set_nauvis_base, scale=set_nauvis_scale,
    size=set_nauvis_size, zspeed=set_nauvis_zspeed,
  },
  [shared.PRESET_MOVING] = { base=0, scale=2, size=2, zspeed=0.1 },
  [shared.PRESET_TOTAL]  = { base=1, scale=0, size=0, zspeed=0 },
}

local zone_ore_to_preset = {}
local function reload_preset_mappings()
  local preset_name
  for index, info in ipairs(shared.default_presets) do
    preset_name = settings.global[shared.preset_setting_name_for_resource(info[1])].value
    if preset_name == shared.PRESET_NIL then preset_name = nil end
    zone_ore_to_preset[info[1]] = preset_name
  end
end
reload_preset_mappings()


function setup_preset(name, seed)
  local preset = surfPresets[name]
  if not preset then
    error("No preset named "..serpent.line(name))
  end
  local currSurfSettings = {}
  -- Instance values
  currSurfSettings.preset_name = name
  currSurfSettings.seed = math.fmod(seed, 1000)
  currSurfSettings.active = true
  currSurfSettings.changed = false
  -- Copy preset values
  currSurfSettings.base = preset.base
  currSurfSettings.scale = preset.scale
  currSurfSettings.size = preset.size
  currSurfSettings.zspeed = preset.zspeed
  -- TODO: add coefficients for day/night, darkness/daytime?
  return currSurfSettings
end

local function se_zone_to_preset(zone)
  local preset_name = zone_ore_to_preset[zone.primary_resource]
  if zone.is_homeworld then preset_name = shared.PRESET_HOME end
  if zone.type ~= "planet" and zone.type ~= "moon" then return nil end
  if not preset_name then return nil end
  return preset_name
end

function apply_updated_mappings()
  local preset_name, surface_index
  if game.active_mods[SE] then
    for _, zone in pairs(remote.call(SE, "get_zone_index", {})) do
      surface_index = zone.surface_index
      preset_name = zone.surface_index and se_zone_to_preset(zone) or nil

      if script_data.surfSettings[surface_index] then
        if preset_name == nil then
          --- Mapping removed
          script_data.surfSettings[surface_index] = nil
        else
          if script_data.surfSettings[surface_index].preset_name ~= preset_name then
            --- Mapping changed
            shared.tableOverride(script_data.surfSettings[surface_index], setup_preset(preset_name, zone.seed))
          end
        end

      else
        if preset_name == nil then
          --- Nothing to do
        else
          --- Mapping created
          script_data.surfSettings[surface_index] = setup_preset(preset_name, zone.seed)
        end
      end
    end
  end
end

local function apply_preset(surface_index, preset_name, seed)
  seed = seed or surface_index * 314
  local currSurfSettings = setup_preset(preset_name, seed)
  -- TODO: try to save important values like seed
  if script_data.surfSettings[surface_index] then
    shared.tableOverride(script_data.surfSettings[surface_index], currSurfSettings)
  else
    script_data.surfSettings[surface_index] = currSurfSettings
  end
end

function se_register_zone(surface_index)
  local zone = remote.call(SE, "get_zone_from_surface_index", {surface_index=surface_index})
  if zone then
    local preset_name = se_zone_to_preset(zone)
    -- debug_print("TSL se_register_zone, index: "..surface_index..", type: "..serpent.line(zone.type)..", preset: "..serpent.line(preset_name))
    if not preset_name then return false end
    -- if name == shared.PRESET_NIL then return false end  -- Should be handled by reload_preset_mappings
    apply_preset(surface_index, preset_name, zone.seed)
    return true
  end
  return false
end

function se_add_zones()
  local done = 0
  for _, surface in pairs(game.surfaces) do
    done = done + (se_register_zone(surface.index) and 1 or 0)
  end
  debug_print("TSL+SE added "..done.." surfaces of "..#game.surfaces)
end

local function apply_updated_preset(preset_name)
  for surface_index, currSurfSettings in pairs(script_data.surfSettings) do
    if currSurfSettings.preset_name == preset_name then
      shared.tableOverride(currSurfSettings, setup_preset(preset_name, currSurfSettings.seed))
    end
  end
end

function update_nauvis_settings()
  debug_print("TSL settings_nauvis_changed")
  set_nauvis_base = settings.global["af-tsl-nauvis-base"].value
  set_nauvis_scale = settings.global["af-tsl-nauvis-scale"].value
  set_nauvis_size = settings.global["af-tsl-nauvis-size"].value
  set_nauvis_zspeed = settings.global["af-tsl-nauvis-zspeed"].value
  surfPresets[shared.PRESET_HOME].base = set_nauvis_base
  surfPresets[shared.PRESET_HOME].scale = set_nauvis_scale
  surfPresets[shared.PRESET_HOME].size = set_nauvis_size
  surfPresets[shared.PRESET_HOME].zspeed = set_nauvis_zspeed
  apply_updated_preset(shared.PRESET_HOME)
end

local function surface_clean_cmd(command)
  -- TODO: check if player is admin or nil
  local surface_name = tonumber(command.parameter) or command.parameter
  local surface = command.parameter and game.surfaces[surface_name]
  if not surface then
    game.get_player(command.player_index).print("No surface '"..serpent.line(surface_name).."'")
    return
  end

  if script_data.surfSettings[surface.index] then
    script_data.surfSettings[surface.index] = nil
    game.get_player(command.player_index).print("Cleaned surface '"..surface_name.."'")
  else
    game.get_player(command.player_index).print("Surface '"..surface_name.."' exists but not registered")
  end
end

function surface_add_cmd(command)
  -- TODO: check if player is admin or nil
  local args = shared.split(command.parameter or "")

  if #args < 1 or #args > 2 then
    game.get_player(command.player_index).print("Bad arguments number")
    return
  end

  local surface_name = tonumber(args[1]) or args[1]
  local surface = game.surfaces[surface_name]
  if not surface then
    game.get_player(command.player_index).print("No surface '"..surface_name.."'")
    return
  end

  local preset_name = args[2] or shared.PRESET_HOME
  apply_preset(surface.index, preset_name)
end

commands.add_command(
  "tsl-remove-surface",
  "Remove lightnings from a surface",
  surface_clean_cmd
)
commands.add_command(
  "tsl-add-surface",
  "Add lightnings to a surface",
  surface_add_cmd
)
