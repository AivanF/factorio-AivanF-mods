local shared = require("shared")

local hit_effects = require ("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")

local tint = { r = 8, g = .5, b = .7, a = 1}

data:extend({
  {
    type = "tool",
    name = shared.sp,
    icon = shared.media_prefix.."graphics/icons/datacard-titan.png",
    icon_size = 64, icon_mipmaps = 4,
    subgroup = "science-pack",
    order = "z-wh40k",
    stack_size = 200,
    durability = 1,
    durability_description_key = "description.science-pack-remaining-amount-key",
    durability_description_value = "description.science-pack-remaining-amount-value",
  },
  {
    type = "recipe",
    name = shared.sp,
    enabled = false,
    ingredients = {
      {"automation-science-pack", 10},
      {"logistic-science-pack", 10},
      {"military-science-pack", 10},
      {"chemical-science-pack", 10},
      {"utility-science-pack", 10},
      {"production-science-pack", 10},
      {"space-science-pack", 10},
    },
    result = shared.sp,
  },

  {
    type = "item",
    name = shared.lab,
    icon = shared.media_prefix.."graphics/icons/lab.png",
    icon_size = 64, icon_mipmaps = 4,
    subgroup = shared.subg_build,
    order = "a[lab]",
    place_result = shared.lab,
    stack_size = 10,
  },
  {
    type = "lab",
    name = shared.lab,
    icon = shared.media_prefix.."graphics/icons/lab.png",
    icon_size = 64, icon_mipmaps = 4,
    flags = {"placeable-player", "player-creation"},
    minable = {mining_time = 0.5, result = shared.lab},
    max_health = 1000,
    corpse = "lab-remnants",
    dying_explosion = "lab-explosion",
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    damaged_trigger_effect = hit_effects.entity(),
    on_animation = {
      layers = {
        {
          filename = "__base__/graphics/entity/lab/lab.png",
          width = 98,
          height = 87,
          frame_count = 33,
          line_length = 11,
          animation_speed = 1 / 3,
          shift = util.by_pixel(0, 1.5),
          tint = tint,
          hr_version = {
            filename = "__base__/graphics/entity/lab/hr-lab.png",
            width = 194,
            height = 174,
            frame_count = 33,
            line_length = 11,
            animation_speed = 1 / 3,
            shift = util.by_pixel(0, 1.5),
            scale = 0.5,
            tint = tint,
          }
        },
        {
          filename = "__base__/graphics/entity/lab/lab-integration.png",
          width = 122,
          height = 81,
          frame_count = 1,
          line_length = 1,
          repeat_count = 33,
          animation_speed = 1 / 3,
          shift = util.by_pixel(0, 15.5),
          tint = tint,
          hr_version = {
            filename = "__base__/graphics/entity/lab/hr-lab-integration.png",
            width = 242,
            height = 162,
            frame_count = 1,
            line_length = 1,
            repeat_count = 33,
            animation_speed = 1 / 3,
            shift = util.by_pixel(0, 15.5),
            scale = 0.5,
            tint = tint,
          }
        },
        {
          filename = "__base__/graphics/entity/lab/lab-light.png",
          blend_mode = "additive",
          draw_as_light = true,
          width = 106,
          height = 100,
          frame_count = 33,
          line_length = 11,
          animation_speed = 1 / 3,
          shift = util.by_pixel(-1, 1),
          tint = tint,
          hr_version = {
            filename = "__base__/graphics/entity/lab/hr-lab-light.png",
            blend_mode = "additive",
            draw_as_light = true,
            width = 216,
            height = 194,
            frame_count = 33,
            line_length = 11,
            animation_speed = 1 / 3,
            shift = util.by_pixel(0, 0),
            scale = 0.5,
            tint = tint,
          }
        },
        {
          filename = "__base__/graphics/entity/lab/lab-shadow.png",
          width = 122,
          height = 68,
          frame_count = 1,
          line_length = 1,
          repeat_count = 33,
          animation_speed = 1 / 3,
          shift = util.by_pixel(13, 11),
          draw_as_shadow = true,
          tint = tint,
          hr_version = {
            filename = "__base__/graphics/entity/lab/hr-lab-shadow.png",
            width = 242,
            height = 136,
            frame_count = 1,
            line_length = 1,
            repeat_count = 33,
            animation_speed = 1 / 3,
            shift = util.by_pixel(13, 11),
            scale = 0.5,
            draw_as_shadow = true,
            tint = tint,
          }
        }
      }
    },
    off_animation = {
      layers = {
        {
          filename = "__base__/graphics/entity/lab/lab.png",
          width = 98,
          height = 87,
          frame_count = 1,
          shift = util.by_pixel(0, 1.5),
          tint = tint,
          hr_version = {
            filename = "__base__/graphics/entity/lab/hr-lab.png",
            width = 194,
            height = 174,
            frame_count = 1,
            shift = util.by_pixel(0, 1.5),
            scale = 0.5,
            tint = tint,
          }
        },
        {
          filename = "__base__/graphics/entity/lab/lab-integration.png",
          width = 122,
          height = 81,
          frame_count = 1,
          shift = util.by_pixel(0, 15.5),
          tint = tint,
          hr_version = {
            filename = "__base__/graphics/entity/lab/hr-lab-integration.png",
            width = 242,
            height = 162,
            frame_count = 1,
            shift = util.by_pixel(0, 15.5),
            scale = 0.5,
            tint = tint,
          }
        },
        {
          filename = "__base__/graphics/entity/lab/lab-shadow.png",
          width = 122,
          height = 68,
          frame_count = 1,
          shift = util.by_pixel(13, 11),
          draw_as_shadow = true,
          tint = tint,
          hr_version = {
            filename = "__base__/graphics/entity/lab/hr-lab-shadow.png",
            width = 242,
            height = 136,
            frame_count = 1,
            shift = util.by_pixel(13, 11),
            draw_as_shadow = true,
            scale = 0.5,
            tint = tint,
          }
        }
      }
    },
    working_sound = {
      sound = {
        filename = "__base__/sound/lab.ogg",
        volume = 0.7
      },
      audible_distance_modifier = 0.7,
      fade_in_ticks = 4,
      fade_out_ticks = 20
    },
    vehicle_impact_sound = sounds.generic_impact,
    open_sound = sounds.machine_open,
    close_sound = sounds.machine_close,
    energy_source = {
      type = "electric",
      usage_priority = "secondary-input"
    },
    energy_usage = "50MW",
    researching_speed = 1,
    inputs = { shared.sp },
    module_specification = {
      module_slots = 3,
      module_info_icon_shift = {0, 0.9}
    }
  },
  {
    type = "recipe",
    name = shared.lab,
    enabled = false,
    ingredients = {
      {"lab", 1},
      {"steel-plate", 100},
      {"processing-unit", 100},
    },
    result = shared.lab,
  },
})
