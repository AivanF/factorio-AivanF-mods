local sounds = require("__base__.prototypes.entity.sounds")
local shared = require("shared")

local entity_icon = {
  icon = shared.media_prefix.."graphics/icons/excavator.png",
  icon_size = 64,
  icon_mipmaps = 1,
}
local process_icon = {
  icon = shared.media_prefix.."graphics/icons/excavating.png",
  icon_size = 64,
  icon_mipmaps = 1,
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

local patch_sprite = {
  filename = shared.media_prefix.."graphics/entity/Excavator-patch.png",
  priority = "high",
  width = 224,
  height = 224,
  scale = 1,
  shift = util.by_pixel(0, 0),
  frame_count = 1,
}
local integration_patch = {
  north = patch_sprite,
  east = patch_sprite,
  south = patch_sprite,
  west = patch_sprite,
}

local excavator_layers = {
  {
    filename = shared.media_prefix.."graphics/entity/Excavator.png",
    priority = "extra-high",
    width = 448,
    height = 448,
    scale = 0.5,
    shift = util.by_pixel(0, 0),
    frame_count = 1,
  },
}
local excavator_animation = {{
  animated_shift = true,
  always_draw = true,
  north_animation = {
    layers = excavator_layers
  },
  east_animation = {
    layers = excavator_layers
  },
  south_animation = {
    layers = excavator_layers
  },
  west_animation = {
    layers = excavator_layers
  }
}}

data:extend({
  {
    type = "assembling-machine",
    name = shared.excavator,

    icon = entity_icon.icon, icon_size = entity_icon.icon_size, icon_mipmaps = entity_icon.icon_mipmaps,
    -- flags = { "not-rotatable", "not-flammable" },
    max_health = 3000,
    resistances = strong_resistances,
    corpse = "electric-mining-drill-remnants",
    dying_explosion = "massive-explosion",
    collision_box = {{ -3.4, -3.4}, {3.4, 3.4}},
    selection_box = {{ -3.5, -3.5}, {3.5, 3.5}},
    vehicle_impact_sound = sounds.generic_impact,
    open_sound = sounds.electric_network_open,
    close_sound = sounds.electric_network_close,
    minable = {mining_time = 2.0, result = shared.excavator},

    working_sound = {
      sound = {
        filename = shared.media_prefix.."sounds/extracting.wav",
        volume = 0.8,
      },
      audible_distance_modifier = 0.6,
      fade_in_ticks = 4,
      fade_out_ticks = 20
    },
    integration_patch = integration_patch,
    -- working_visualisations = drill_animation,
    working_visualisations = excavator_animation,
    module_specification = {
      module_slots = 0,
    },
    crafting_speed = 0.01,
    crafting_categories = {shared.craftcat_empty},
    energy_source = {
      type = "electric",
      emissions_per_minute = 10,
      usage_priority = "secondary-input",
      buffer_capacity = "50MJ",
      input_flow_limit = "25MW",
      drain = "1MW",
    },
    energy_usage = "20MW",
    fixed_recipe = shared.excavation_recipe,
  },
  {
    type = "item",
    name = shared.excavator,
    icon = entity_icon.icon, icon_size = entity_icon.icon_size, icon_mipmaps = entity_icon.icon_mipmaps,
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
      {"concrete", 400},
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
    icon = process_icon.icon, icon_size = process_icon.icon_size, icon_mipmaps = process_icon.icon_mipmaps,
    name = shared.excavation_recipe,
    subgroup = shared.subg_parts,
    enabled = false,
    energy_required = 60*60*24,
    ingredients = {},
    results = {},
    category = shared.craftcat_empty,
  },
})