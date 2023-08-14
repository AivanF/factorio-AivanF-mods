local sounds = require("__base__.prototypes.entity.sounds")
local shared = require("shared")

local name = shared.art2
local icon = "__Lightning__/graphics/icons/arty2.png"
local icon_size = 64
local icon_mipmaps = 3
local acc_input = "200MW"
local acc_capacity = "50GJ"

local ingredients = {
  {"steel-plate", 2000},
  {"copper-plate", 2000},
  {"coal", 200},
  {"plastic-bar", 400},
  {"battery", 5000},
  {"processing-unit", 100},
}

if settings.startup["af-tsl-support-recipes"].value then
  if mods[shared.SE] then
    ingredients = {
      {"steel-plate", 2000},
      {"copper-plate", 2000},
      {"se-holmium-cable", 200},
      {"battery", 5000},
      {"processing-unit", 100},
    }
    -- Replace with se-holmium-solenoid or se-superconductive-cable???
  end
end

local picture_base = {
  layers = {
    {
      filename = "__Lightning__/graphics/entity/arty2.png",
      width = 400,
      height = 533,
      scale = 0.8,
      shift = {0, -3.3},
      hr_version = {
        filename = "__Lightning__/graphics/entity/arty2-hr.png",
        width = 800,
        height = 1067,
        scale = 0.4,
        shift = {0, -3.3},
      },
    },
    {
      filename = "__Lightning__/graphics/entity/arty2-shadow.png",
      width = 570,
      height = 320,
      scale = 0.8,
      shift = {4.5, -0.5},
      draw_as_shadow = true,
      hr_version = {
        filename = "__Lightning__/graphics/entity/arty2-shadow-hr.png",
        width = 1140,
        height = 640,
        scale = 0.4,
        shift = {4.5, -0.5},
        draw_as_shadow = true,
      },
    },
  }
}
local picture_no = {
  filename = "__Lightning__/graphics/entity/handler.png",
  width = 1,
  height = 1,
  frame_count = 1,
  shift = {0, 0},
  priority = "low",
}

data:extend({
  {
    type = "item",
    name = name,
    icon = icon,
    icon_size = icon_size, icon_mipmaps = icon_mipmaps,
    subgroup = "defensive-structure",
    order = "b[turret]-e[lightning]-a[arty-2]",
    place_result = name,
    stack_size = 1,
  },
  {
    type = "recipe",
    name = name,
    enabled = false,
    ingredients = ingredients,
    result = name,
  },
  {
    type = "roboport",
    name = name,
    icon = icon,
    icon_size = icon_size, icon_mipmaps = icon_mipmaps,
    flags = {"placeable-player", "player-creation"},
    minable = {hardness = 0.75, mining_time = 2, result = name},
    max_health = 5000,
    resistances = {
      { type = "physical", decrease=50, percent=50 },
      { type = "impact", decrease=50, percent=50 },
      { type = "fire", decrease=100, percent=99 },
      { type = "acid", decrease=50, percent=50 },
      { type = "poison", decrease=200, percent=99 },
      { type = "explosion", decrease=50, percent=50 },
      { type = "laser", decrease=20, percent=20 },
      { type = "electric", decrease=80, percent=80 },
    },
    collision_box = {{-2.7, -2.7}, {2.7, 2.7}},
    selection_box = {{-3, -3}, {3, 3}},
    dying_explosion = "medium-explosion",
    energy_source = {
      type = "electric",
      usage_priority = "secondary-input",
      input_flow_limit = acc_input,
      output_flow_limit = "0KW",
      buffer_capacity = acc_capacity
    },
    recharge_minimum = "20MJ",
    energy_usage = "50kW",
    charging_energy = "1.5MW",
    logistics_radius = 0,
    construction_radius = 0,
    charge_approach_distance = 3.5,
    robot_slots_count = 0,
    material_slots_count = 0,
    stationing_offset = {0, -2},
    charging_offsets = {},
    recharging_light = {intensity = 0.6, size = 5},
    request_to_open_door_timeout = 15,
    spawn_and_station_height = -0.1,

    base = picture_base,
    base_patch = picture_no,
    base_animation = picture_no,
    door_animation_up = picture_no,
    door_animation_down = picture_no,
    recharging_animation = picture_base,

    vehicle_impact_sound = sounds.generic_impact,
    open_sound = sounds.electric_network_open,
    close_sound = sounds.electric_network_close,
    working_sound = {
      sound = { filename = "__base__/sound/accumulator-working.ogg", volume = 0.65 },
      max_sounds_per_type = 3,
      audible_distance_modifier = 0.5,
      probability = 1 / (5 * 60)
    },
  },
})
