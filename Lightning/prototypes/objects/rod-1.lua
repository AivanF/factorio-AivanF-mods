local sounds = require("__base__.prototypes.entity.sounds")
local shared = require("shared")

local name = shared.rod1
local icon = "__Lightning__/graphics/icons/rod1.png"
local icon_size = 64
local icon_mipmaps = 3

ingredients = {
  {"iron-plate", 20},
  {"copper-plate", 30},
}

if settings.startup["af-tsl-support-recipes"].value then
  if mods[shared.IR] then
    ingredients = {
      {"bronze-rod", 6},
      {"copper-plate", 20},
    }
  end
end

data:extend({
  {
    type = "item",
    name = name,
    icon = icon,
    icon_size = icon_size, icon_mipmaps = icon_mipmaps,
    subgroup = "energy-pipe-distribution",
    order = "z[lightning-1rod-1]",
    place_result = name,
    stack_size = 50,
  },
  {
    type = "recipe",
    name = name,
    enabled = false,
    ingredients = ingredients,
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
    fast_replaceable_group = "tsl-rod",
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
          filename = "__Lightning__/graphics/entity/rod.png",
          priority = "extra-high",
          width = 64,
          height = 128,
          scale = 0.8,
          shift = util.by_pixel(0, -36),
          hr_version = {
            filename = "__Lightning__/graphics/entity/rod-hr.png",
            priority = "extra-high",
            width = 128,
            height = 256,
            scale = 0.4,
            shift = util.by_pixel(0, -36),
          },
        },
        {
          filename = "__Lightning__/graphics/entity/rod-shadow.png",
          priority = "extra-high",
          width = 128,
          height = 64,
          scale = 0.8,
          shift = util.by_pixel(28, 0),
          draw_as_shadow = true,
          hr_version = {
            filename = "__Lightning__/graphics/entity/rod-shadow-hr.png",
            priority = "extra-high",
            width = 256,
            height = 128,
            scale = 0.4,
            shift = util.by_pixel(28, 0),
            draw_as_shadow = true,
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
