local shared = require("shared")

local hit_effects = require ("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")

local tint = { r = .8, g = .7, b = .7, a = 1}

local ingredients = {  -- 7
  {type="item", name="automation-science-pack", amount=10},
  {type="item", name="logistic-science-pack", amount=10},
  {type="item", name="military-science-pack", amount=10},
  {type="item", name="chemical-science-pack", amount=10},
  {type="item", name="utility-science-pack", amount=10},
  {type="item", name="production-science-pack", amount=10},
  {type="item", name="space-science-pack", amount=10},
}

if mods[shared.SE] and mods[shared.K2] then
  ingredients = {  -- 8
    {type="item", name="military-science-pack", amount=10},
    -- {type="item", name="space-science-pack", amount=10},
    {type="item", name="utility-science-pack", amount=10},
    {type="item", name="production-science-pack", amount=10},

    {type="item", name="se-deep-space-science-pack-1", amount=10},
    {type="item", name="se-energy-science-pack-4", amount=10},
    {type="item", name="se-material-science-pack-4", amount=10},
    {type="item", name="matter-tech-card", amount=10}, -- aka Matter science 1
    -- {type="item", name="se-kr-matter-science-pack-2", amount=10}, -- aka Matter science 2
    {type="item", name="advanced-tech-card", amount=10}, -- aka Advanced science 1
    -- {type="item", name="singularity-tech-card", amount=10}, -- aka Advanced science 2
  }

elseif mods[shared.SE] then
  ingredients = {  -- 7
    -- {type="item", name="automation-science-pack", amount=10},
    -- {type="item", name="logistic-science-pack", amount=10},
    {type="item", name="military-science-pack", amount=10},
    -- {type="item", name="chemical-science-pack", amount=10},
    -- {type="item", name="se-rocket-science-pack", amount=10},
    {type="item", name="space-science-pack", amount=10},
    {type="item", name="utility-science-pack", amount=10},
    {type="item", name="production-science-pack", amount=10},
    {type="item", name="se-energy-science-pack-4", amount=10},
    {type="item", name="se-material-science-pack-4", amount=10},
    {type="item", name="se-deep-space-science-pack-1", amount=10},
  }

elseif mods[shared.K2] then
  ingredients = {  -- 6
    {type="item", name="production-science-pack", amount=10},
    {type="item", name="utility-science-pack", amount=10},
    {type="item", name="space-science-pack", amount=10},
    {type="item", name="matter-tech-card", amount=10},
    {type="item", name="advanced-tech-card", amount=10},
    {type="item", name="singularity-tech-card", amount=10},
  }
end

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
    ingredients = ingredients,
    results = {{type="item", name=shared.sp, amount=1}},
    energy_required = 100,
  },

  {
    type = "item",
    name = shared.lab,
    icon = shared.media_prefix.."graphics/icons/lab.png",
    icon_size = 64, icon_mipmaps = 4,
    subgroup = shared.subg_build,
    order = "a[lab]",
    place_result = shared.lab,
    stack_size = 4,
  },
  {
    type = "lab",
    name = shared.lab,
    se_allow_in_space = true,
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
    -- TODO: use advanced labs from K2, SE, etc.?
    type = "recipe",
    name = shared.lab,
    enabled = false,
    ingredients = {
      {type="item", name="lab", amount=1},
      {type="item", name="steel-plate", amount=100},
      {type="item", name="processing-unit", amount=100},
    },
    allow_productivity = true,
    afci_bridged = true,
    energy_required = 10,
    results = {{type="item", name=shared.lab, amount=1}}
  },
})
