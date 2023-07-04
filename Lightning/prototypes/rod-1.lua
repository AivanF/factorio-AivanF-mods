local sounds = require("__base__.prototypes.entity.sounds")
local shared = require("shared")

local name = "lightning-rod-1"
local icon = "__Lightning__/graphics/icons/medium-electric-pole.png"
local icon_size = 64
local icon_mipmaps = 4

-- TODO: add energy.png using:
-- https://wiki.factorio.com/Types/IconSpecification
-- https://wiki.factorio.com/Types/IconData

data:extend({  
  {
    type = "item",
    name = name,
    icon = icon,
    icon_size = icon_size, icon_mipmaps = icon_mipmaps,
    subgroup = "energy-pipe-distribution",
    order = "z[lightning-rod-1]",
    place_result = name,
    stack_size = 20,
  },
  {
    type = "recipe",
    name = name,
    enabled = false,
    ingredients = {
      {"steel-plate", 100},
      {"copper-plate", 20},
    },
    result = name,
  },
  {
    type = "simple-entity-with-force",
    name = name,
    icon = icon,
    icon_size = icon_size, icon_mipmaps = icon_mipmaps,
    flags = {"placeable-neutral", "player-creation", "fast-replaceable-no-build-while-moving"},
    minable = {mining_time = 0.1, result = name},
    max_health = 150,
    corpse = "medium-electric-pole-remnants",
    dying_explosion = "medium-electric-pole-explosion",
    track_coverage_during_build_by_moving = true,
    fast_replaceable_group = "electric-pole",
    resistances = {
      {type = "fire", percent = 100}
    },
    collision_box = {{-0.15, -0.15}, {0.15, 0.15}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    drawing_box = {{-0.5, -2.8}, {0.5, 0.5}},
    vehicle_impact_sound = sounds.generic_impact,
    open_sound = sounds.electric_network_open,
    close_sound = sounds.electric_network_close,
    pictures = {
      layers = {
        {
          filename = "__Lightning__/graphics/entity/medium-electric-pole.png",
          priority = "extra-high",
          width = 40,
          height = 124,
          direction_count = 4,
          shift = util.by_pixel(4, -44),
          hr_version = {
            filename = "__Lightning__/graphics/entity/hr-medium-electric-pole.png",
            priority = "extra-high",
            width = 84,
            height = 252,
            direction_count = 4,
            shift = util.by_pixel(3.5, -44),
            scale = 0.5
          }
        },
        {
          filename = "__base__/graphics/entity/medium-electric-pole/medium-electric-pole-shadow.png",
          priority = "extra-high",
          width = 140,
          height = 32,
          direction_count = 4,
          shift = util.by_pixel(56, -1),
          draw_as_shadow = true,
          hr_version = {
            filename = "__base__/graphics/entity/medium-electric-pole/hr-medium-electric-pole-shadow.png",
            priority = "extra-high",
            width = 280,
            height = 64,
            direction_count = 4,
            shift = util.by_pixel(56.5, -1),
            draw_as_shadow = true,
            scale = 0.5
          }
        }
      }
    },
    radius_visualisation_specification = {
      distance = shared.max_catch_radius,
      sprite = {
        filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-radius-visualization.png",
        height = 10,
        width = 10
      }
    },
    water_reflection = {
      pictures = {
        filename = "__base__/graphics/entity/medium-electric-pole/medium-electric-pole-reflection.png",
        priority = "extra-high",
        width = 12,
        height = 28,
        shift = util.by_pixel(0, 55),
        variation_count = 1,
        scale = 5
      },
      rotate = false,
      orientation_to_variation = false
    }
  },
})

table.insert(
  data.raw.technology["electric-energy-distribution-1"].effects,
  { type = "unlock-recipe", recipe = name }
)
