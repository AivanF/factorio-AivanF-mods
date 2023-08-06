local sounds = require("__base__.prototypes.entity.sounds")
local shared = require("shared")

local name = shared.art1
local icon = "__Lightning__/graphics/icons/arty1.png"
local icon_size = 64
local icon_mipmaps = 3
local acc_input = "20MW"
local acc_capacity = "5GJ"

local picture_base = {
  layers = {
    {
      filename = "__Lightning__/graphics/entity/arty1.png",
      width = 170,
      height = 266,
      scale = 0.8,
      shift = {0, -1.8},
      hr_version = {
        filename = "__Lightning__/graphics/entity/arty1-hr.png",
        width = 340,
        height = 531,
        scale = 0.4,
        shift = {0, -1.8},
      },
    },
    {
      filename = "__Lightning__/graphics/entity/arty1-shadow.png",
      width = 256,
      height = 128,
      scale = 1.2,
      shift = {3, 0},
      draw_as_shadow = true,
      hr_version = {
        filename = "__Lightning__/graphics/entity/arty1-shadow-hr.png",
        width = 512,
        height = 256,
        scale = 0.6,
        shift = {3, 0},
        draw_as_shadow = true,
      },
    },
  }
}
local picture_no = {
  filename = "__Lightning__/graphics/entity/arty1.png",
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
    order = "z[lightning-arty-1]",
    place_result = name,
    stack_size = 10,
  },
  {
    type = "recipe",
    name = name,
    enabled = false,
    ingredients = {
      {"steel-plate", 300},
      {"copper-plate", 400},
      {"battery", 4000},
      {"advanced-circuit", 100},
    },
    result = name,
  },
  {
    type = "roboport",
    name = name,
    icon = icon,
    icon_size = icon_size, icon_mipmaps = icon_mipmaps,
    flags = {"placeable-player", "player-creation"},
    minable = {hardness = 0.5, mining_time = 1, result = name},
    max_health = 500,
    resistances = {
      { type = "physical", decrease=10, percent=50 },
      { type = "impact", decrease=10, percent=50 },
      { type = "explosion", decrease=20, percent=50 },
      { type = "poison", decrease=100, percent=99 },
      { type = "electric", decrease=50, percent=80 },
    },
    corpse = "big-electric-pole-remnants",
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
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
