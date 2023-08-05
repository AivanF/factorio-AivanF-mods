local sounds = require("__base__.prototypes.entity.sounds")
local shared = require("shared")

local name = shared.rod2
local icon = "__Lightning__/graphics/icons/2handler.png"
local icon_size = 64
local icon_mipmaps = 3
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
      {"copper-plate", 100},
      {"battery", 400},
      {"electronic-circuit", 100}
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
    resistances = {
      { type = "physical", decrease=10, percent=50 },
      { type = "impact", decrease=10, percent=50 },
      { type = "explosion", decrease=20, percent=50 },
      { type = "poison", decrease=100, percent=99 },
      { type = "electric", decrease=50, percent=80 },
    },
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
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
      layers = {
        {
          filename = "__Lightning__/graphics/entity/handler.png",
          width = 128,
          height = 256,
          scale = 0.8,
          shift = {0, -1.8},
          hr_version = {
            filename = "__Lightning__/graphics/entity/handler-hr.png",
            width = 256,
            height = 512,
            scale = 0.4,
            shift = {0, -1.8},
          },
        },
        {
          filename = "__Lightning__/graphics/entity/handler-shadow.png",
          width = 256,
          height = 128,
          scale = 1.2,
          shift = {3, 0},
          draw_as_shadow = true,
          hr_version = {
            filename = "__Lightning__/graphics/entity/handler-shadow-hr.png",
            width = 512,
            height = 256,
            scale = 0.6,
            shift = {3, 0},
            draw_as_shadow = true,
          },
        },
      }
    },
    -- discharge_animation = {},
    -- recharging_animation = {},
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
