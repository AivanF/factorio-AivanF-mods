local sounds = require("__base__.prototypes.entity.sounds")
local shared = require("shared")

local special_flags = {
  "not-rotatable", "placeable-neutral", --"placeable-off-grid",
  "not-blueprintable", "not-deconstructable", "not-flammable",
}

local drill_animation = {{
  animated_shift = true,
  always_draw = true,
  north_animation = {
    layers = {
      electric_mining_drill_animation(),
      electric_mining_drill_shadow_animation()
    }
  },
  east_animation = {
    layers = {
      electric_mining_drill_horizontal_animation(),
      electric_mining_drill_horizontal_shadow_animation()
    }
  },
  south_animation = {
    layers = {
      electric_mining_drill_animation(),
      electric_mining_drill_shadow_animation()
    }
  },
  west_animation = {
    layers = {
      electric_mining_drill_horizontal_animation(),
      electric_mining_drill_horizontal_shadow_animation()
    }
  }
}}

data:extend({
  {
    type = "assembling-machine",
    name = shared.excavator,
    -- name = shared.excavator_active,

    icon = shared.mock_icon.icon, icon_size = shared.mock_icon.icon_size, icon_mipmaps = shared.mock_icon.icon_mipmaps,
    flags = special_flags,
    max_health = 3000,
    resistances = strong_resistances,
    corpse = "electric-mining-drill-remnants",
    dying_explosion = "massive-explosion",
    collision_box = {{ -1.4, -1.4}, {1.4, 1.4}},
    selection_box = {{ -1.5, -1.5}, {1.5, 1.5}},
    vehicle_impact_sound = sounds.generic_impact,
    open_sound = sounds.electric_network_open,
    close_sound = sounds.electric_network_close,
    minable = {mining_time = 2.0, result = shared.excavator},

    working_sound = {
      sound = {
        filename = "__base__/sound/electric-mining-drill.ogg",
        volume = 1
      },
      audible_distance_modifier = 0.6,
      fade_in_ticks = 4,
      fade_out_ticks = 20
    },
    working_visualisations = drill_animation,
    module_specification = {
      module_slots = 0,
    },
    crafting_speed = 0.01,
    crafting_categories = {shared.craftcat_empty},
    energy_source = {
      type = "electric",
      emissions_per_minute = 2,
      usage_priority = "secondary-input",
      buffer_capacity = "50MJ",
      input_flow_limit = "25MW",
      drain = "1MW",
    },
    energy_usage = "20MW",
    fixed_recipe = shared.excavation_recipe,
  },
  -- {
  --   type = "container",
  --   name = shared.excavator,

  --   icon = shared.mock_icon.icon, icon_size = shared.mock_icon.icon_size, icon_mipmaps = shared.mock_icon.icon_mipmaps,
  --   flags = special_flags,
  --   max_health = 3000,
  --   resistances = strong_resistances,
  --   corpse = "electric-mining-drill-remnants",
  --   dying_explosion = "massive-explosion",
  --   collision_box = {{ -1.4, -1.4}, {1.4, 1.4}},
  --   selection_box = {{ -1.5, -1.5}, {1.5, 1.5}},
  --   vehicle_impact_sound = sounds.generic_impact,
  --   open_sound = sounds.electric_network_open,
  --   close_sound = sounds.electric_network_close,
  --   minable = {mining_time = 2.0, result = shared.excavator},

  --   inventory_size = 10,
  --   picture = {
  --     layers = {
  --       electric_mining_drill_animation(),
  --     }
  --   },
  -- },
  {
    type = "item",
    name = shared.excavator,
    icon = shared.mock_icon.icon, icon_size = shared.mock_icon.icon_size, icon_mipmaps = shared.mock_icon.icon_mipmaps,
    subgroup = shared.subg_build,
    order = "c[excavator]",
    place_result = shared.excavator,
    stack_size = 1,
  },
  {
    type = "recipe",
    name = shared.excavator,
    enabled = false,
    energy_required = 10,
    ingredients = {
      {"electric-mining-drill", 20},
      {"laser-turret", 20},
      {"filter-inserter", 20},
      {"processing-unit", 10},
    },
    result = shared.excavator,
    category = "crafting",
  },
  {
    type = "recipe",
    icon = shared.mock_icon.icon, icon_size = shared.mock_icon.icon_size, icon_mipmaps = shared.mock_icon.icon_mipmaps,
    name = shared.excavation_recipe,
    subgroup = shared.subg_parts,
    enabled = false,
    energy_required = 60*60*24,
    ingredients = {},
    results = {},
    category = shared.craftcat_empty,
  },
})