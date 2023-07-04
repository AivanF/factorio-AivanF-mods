local sounds = require("__base__.prototypes.entity.sounds")
local shared = require("shared")

local name = "lightning-rod-2-accumulator"
local icon = "__Lightning__/graphics/icons/robot-charge-port.png"
local icon_size = 64
local icon_mipmaps = 2
local acc_capacity = 500

data:extend({  
  {
    type = "item",
    name = name,
    icon = icon,
    icon_size = icon_size, icon_mipmaps = icon_mipmaps,
    subgroup = "energy-pipe-distribution",
    order = "z[lightning-rod-2]",
    place_result = name,
    stack_size = 10,
  },
  {
    type = "recipe",
    name = name,
    enabled = false,
    ingredients = {
      {"steel-plate", 200},
      {"copper-plate", 50},
      {"battery", 400},
    },
    result = name,
  },
  {
    type = "accumulator",
    name = name,
    icon = icon,
    icon_size = icon_size, icon_mipmaps = icon_mipmaps,
    flags = {"placeable-player", "player-creation"},
    minable = {hardness = 0.5, mining_time = 1, result = name},
    max_health = 500,
    collision_box = {{-0.7, -0.7}, {0.7, 0.7}},
    selection_box = {{-1, -1}, {1, 1}},
    drawing_box = {{-1, -3}, {1, 0.5}},
    -- corpse = "medium-remnants",
    corpse = "big-electric-pole-remnants",
    dying_explosion = "medium-explosion",
    energy_source = {
      type = "electric",
      usage_priority = "primary-output",
      input_flow_limit = "0KW",
      output_flow_limit = "50MW",
      buffer_capacity = acc_capacity.."MJ"
    },
    charge_cooldown = 5,
    discharge_cooldown = 5,
    picture = {
      filename = "__Lightning__/graphics/entity/robot-charge-port.png",
      width = 98,
      height = 164,
      shift = {0, -1.2}
    },
    recharging_animation = {
      filename = "__Lightning__/graphics/entity/roboport-recharging.png",
      priority = "high",
      width = 37,
      height = 35,
      frame_count = 16,
      scale = 1.75,
      animation_speed = 0.85
    },
    vehicle_impact_sound = sounds.generic_impact,
    open_sound = sounds.electric_network_open,
    close_sound = sounds.electric_network_close,
    working_sound = {
      sound = {
        filename = "__base__/sound/accumulator-working.ogg",
        volume = 0.8
      },
      idle_sound = {
        filename = "__base__/sound/accumulator-idle.ogg",
        volume = 0.5
      },
      max_sounds_per_type = 3,
      audible_distance_modifier = 0.5,
      fade_in_ticks = 4,
      fade_out_ticks = 20
    },
    recharging_light = {intensity = 0.6, size = 5},
    radius_visualisation_specification = {
      distance = shared.max_catch_radius,
      sprite = {
        filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-radius-visualization.png",
        height = 10,
        width = 10
      }
    },
  },
})

table.insert(
  data.raw.technology["electric-energy-accumulators"].effects,
  { type = "unlock-recipe", recipe = name }
)
