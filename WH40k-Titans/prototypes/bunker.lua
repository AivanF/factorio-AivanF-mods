local sounds = require("__base__.prototypes.entity.sounds")
local shared = require("shared")
local misc = require("prototypes.misc")

local icon = shared.media_prefix.."graphics/icons/bunker.png"
local icon_size = 32
local icon_mipmaps = 1

local special_flags = {
  "not-rotatable", "placeable-neutral", "placeable-off-grid",
  "not-blueprintable", "not-deconstructable", "not-flammable",
}

local bunker_resistances = {
  { type = "impact", decrease=10000, percent=100 },
  { type = "physical", percent=100 },
  { type = "explosion", percent=100 },
  { type = "laser", percent = 100 },
  { type = "fire", percent = 100 },
  { type = "electric", percent=100 },
  { type = "acid", percent=100 },
  { type = "poison", percent=100 },
}

local lamp = table.deepcopy(data.raw["lamp"]["small-lamp"])
lamp.name = shared.bunker_lamp
lamp.max_health = 10000
lamp.healing_per_tick = 10000
lamp.flags = special_flags
lamp.selectable_in_game = false
lamp.collision_mask = {}
lamp.energy_source = { type = "void" }
lamp.resistances = bunker_resistances
lamp.next_upgrade = nil
data:extend({ lamp })

local idle_sprite = {
  filename = shared.media_prefix.."graphics/entity/Bunker.png",
  priority = "extra-high",
  width = 1024,
  height = 1024,
  scale = 0.67,
  shift = util.by_pixel(0, 0),
  frame_count = 1,
}
local idle_layers = {
  idle_sprite,
}
local idle_working_visualisations = {
  {
    always_draw = true,
    render_layer = "object",
    north_animation = {
      layers = idle_layers
    },
    east_animation = {
      layers = idle_layers
    },
    south_animation = {
      layers = idle_layers
    },
    west_animation = {
      layers = idle_layers
    }
  }
}

local empty_working_visualisations = {
  {
    always_draw = true,
    render_layer = "object",
    north_animation = {
      layers = {misc.empty_sprite}
    },
    east_animation = {
      layers = {misc.empty_sprite}
    },
    south_animation = {
      layers = {misc.empty_sprite}
    },
    west_animation = {
      layers = {misc.empty_sprite}
    }
  }
}

data:extend({
  {
    type = "container",
    name = shared.bunker_wstoreh,
    localised_name = {"entity-name.wh40k-titans-assembly-bunker-wstore"},
    localised_description = {"entity-description.wh40k-titans-assembly-bunker-wstore"},
    icon = "__base__/graphics/icons/iron-chest.png",
    icon_size = 64, icon_mipmaps = 4,
    flags = special_flags,
    max_health = 10000,
    healing_per_tick = 10000,
    resistances = bunker_resistances,
    dying_explosion = "iron-chest-explosion",
    open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.43 },
    close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.43 },
    selection_box = {{-2, -1}, {2, 1}},
    collision_box = {{-2, -1}, {2, 1}},
    collision_mask = {},
    inventory_size = 250,
    picture = {
      layers = {
        misc.empty_sprite,
      }
    },
  },
  {
    type = "container",
    name = shared.bunker_wstorev,
    localised_name = {"entity-name.wh40k-titans-assembly-bunker-wstore"},
    localised_description = {"entity-description.wh40k-titans-assembly-bunker-wstore"},
    icon = "__base__/graphics/icons/iron-chest.png",
    icon_size = 64, icon_mipmaps = 4,
    flags = special_flags,
    max_health = 10000,
    healing_per_tick = 10000,
    resistances = bunker_resistances,
    dying_explosion = "iron-chest-explosion",
    open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.43 },
    close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.43 },
    selection_box = {{-1, -2}, {1, 2}},
    collision_box = {{-1, -2}, {1, 2}},
    collision_mask = {},
    inventory_size = 250,
    picture = {
      layers = {
        misc.empty_sprite,
      }
    },
  },
  -- {
  --   type = "assembling-machine",
  --   name = shared.bunker_wrecipeh,
  --   localised_name = {"entity-name.wh40k-titans-assembly-bunker-wrecipe"},
  --   localised_description = {"entity-description.wh40k-titans-assembly-bunker-wrecipe"},
  --   icon = icon, icon_size = icon_size, icon_mipmaps = icon_mipmaps,
  --   flags = special_flags,
  --   max_health = 10000,
  --   resistances = bunker_resistances,
  --   healing_per_tick = 10000,
  --   corpse = "medium-electric-pole-remnants",
  --   dying_explosion = "medium-electric-pole-explosion",
  --   resistances = bunker_resistances,
  --   selection_box = {{-2, -1}, {2, 1}},
  --   collision_box = {{-2, -1}, {2, 1}},
  --   collision_mask = {},
  --   render_layer = "floor",
  --   vehicle_impact_sound = sounds.generic_impact,
  --   open_sound = sounds.electric_network_open,
  --   close_sound = sounds.electric_network_close,
  --   working_visualisations = empty_working_visualisations,
  --   module_specification = {
  --     module_slots = 0,
  --   },
  --   crafting_speed = 0.01,
  --   crafting_categories = {shared.craftcat_weapon},
  --   energy_source = { type = "void" },
  --   energy_usage = "1W",
  -- },
  -- {
  --   type = "assembling-machine",
  --   name = shared.bunker_wrecipev,
  --   localised_name = {"entity-name.wh40k-titans-assembly-bunker-wrecipe"},
  --   localised_description = {"entity-description.wh40k-titans-assembly-bunker-wrecipe"},
  --   icon = icon, icon_size = icon_size, icon_mipmaps = icon_mipmaps,
  --   flags = special_flags,
  --   max_health = 10000,
  --   healing_per_tick = 10000,
  --   resistances = bunker_resistances,
  --   corpse = "medium-electric-pole-remnants",
  --   dying_explosion = "medium-electric-pole-explosion",
  --   selection_box = {{-1, -2}, {1, 2}},
  --   collision_box = {{-1, -2}, {1, 2}},
  --   collision_mask = {},
  --   render_layer = "floor",
  --   vehicle_impact_sound = sounds.generic_impact,
  --   open_sound = sounds.electric_network_open,
  --   close_sound = sounds.electric_network_close,
  --   working_visualisations = empty_working_visualisations,
  --   module_specification = {
  --     module_slots = 0,
  --   },
  --   crafting_speed = 0.01,
  --   crafting_categories = {shared.craftcat_weapon},
  --   energy_source = { type = "void" },
  --   energy_usage = "1W",
  -- },

  {
    type = "container",
    name = shared.bunker_bstore,
    localised_name = {"entity-name.wh40k-titans-assembly-bunker-bstore"},
    localised_description = {"entity-description.wh40k-titans-assembly-bunker-bstore"},
    icon = "__base__/graphics/icons/iron-chest.png",
    icon_size = 64, icon_mipmaps = 4,
    flags = special_flags,
    max_health = 20000,
    healing_per_tick = 20000,
    resistances = bunker_resistances,
    dying_explosion = "iron-chest-explosion",
    open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.43 },
    close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.43 },
    selection_box = {{-4, -2}, {4, 2}},
    collision_box = {{-4, -2}, {4, 2}},
    collision_mask = {},
    inventory_size = 350,
    picture = {
      layers = {
        misc.empty_sprite,
      }
    },
  },
  {
    type = "assembling-machine",
    name = shared.bunker_center,
    localised_name = {"entity-name.wh40k-titans-assembly-bunker-center"},
    localised_description = {"entity-description.wh40k-titans-assembly-bunker-center"},
    icon = icon, icon_size = icon_size, icon_mipmaps = icon_mipmaps,
    flags = special_flags,
    max_health = 20000,
    healing_per_tick = 20000,
    corpse = "medium-electric-pole-remnants",
    dying_explosion = "medium-electric-pole-explosion",
    resistances = bunker_resistances,
    selection_box = {{-4, -4}, {4, 4}},
    collision_box = {{-4, -4}, {4, 4}},
    collision_mask = {"floor-layer", "item-layer", "object-layer", "water-tile"},
    render_layer = "floor",
    vehicle_impact_sound = sounds.generic_impact,
    open_sound = sounds.electric_network_open,
    close_sound = sounds.electric_network_close,
    working_visualisations = empty_working_visualisations,
    module_specification = {
      module_slots = 0,
    },
    crafting_speed = 0.01,
    crafting_categories = {shared.craftcat_empty},
    energy_source = { type = "void" },
    energy_usage = "1W",
  },

  {
    type = "item",
    name = shared.bunker_minable,
    localised_name = {"entity-name.wh40k-titans-assembly-bunker-minable"},
    localised_description = {"entity-description.wh40k-titans-assembly-bunker-minable"},
    icon = icon, icon_size = icon_size, icon_mipmaps = icon_mipmaps,
    subgroup = shared.subg_build,
    order = "a[assembly-bunker]",
    place_result = shared.bunker_minable,
    stack_size = 1,
  },
  {
    type = "recipe",
    name = shared.bunker_minable,
    enabled = false,
    ingredients = {
      {"steel-chest", 150},
      {"assembling-machine-2", 40},
      {"stack-filter-inserter", 50},
      {"small-lamp", 12},
      {"processing-unit", 200},
    },
    result = shared.bunker_minable,
  },
})


local base_bunker = {
  type = "simple-entity-with-force",
  -- type = "assembling-machine",
  -- type = "roboport",
  localised_name = {"entity-name.wh40k-titans-assembly-bunker"},
  localised_description = {"entity-description.wh40k-titans-assembly-bunker"},
  icon = icon,
  icon_size = icon_size, icon_mipmaps = icon_mipmaps,
  flags = {
    "not-rotatable", "placeable-neutral", "player-creation",
  },
  -- is_military_target = true,
  max_health = 10000,
  -- corpse = "big-remnants",
  corpse = "rocket-silo-remnants",
  dying_explosion = "massive-explosion",
  resistances = {
    { type = "impact", decrease=1000, percent=100 },
    { type = "poison", decrease=1000, percent=100 },
    { type = "fire", decrease=1000, percent=100 },
    { type = "laser", decrease=50, percent=50 },
    { type = "electric", decrease=50, percent=50 },
    { type = "physical", decrease=50, percent=50 },
    { type = "explosion", decrease=50, percent=50 },
    { type = "acid", decrease=50, percent=50 },
  },
  selection_box = {{-11, -11}, {11, 11}},
  collision_box = {{-11, -11}, {11, 11}},
  collision_mask = {"floor-layer", "item-layer", "object-layer", "water-tile"},
  selection_priority = 10,
  render_layer = "floor",
  vehicle_impact_sound = sounds.generic_impact,
  open_sound = sounds.electric_network_open,
  close_sound = sounds.electric_network_close,

  working_visualisations = idle_working_visualisations,
  module_specification = {
    module_slots = 0,
  },
  crafting_speed = 0.01,
  crafting_categories = {shared.craftcat_titan},
  energy_source = { type = "void" },
  energy_usage = "1W",

  render_layer = "floor",
  animations = idle_sprite,
}

local bunker_minable = table.deepcopy(base_bunker)
bunker_minable.name = shared.bunker_minable
bunker_minable.minable = {mining_time = 2.0, result = shared.bunker_minable}
bunker_minable.localised_name = {"entity-name."..shared.bunker_minable}
bunker_minable.localised_description = {"entity-description."..shared.bunker_minable}

local bunker_active = table.deepcopy(base_bunker)
bunker_active.name = shared.bunker_active
bunker_active.crafting_speed = 1
bunker_active.localised_name = {"entity-name."..shared.bunker_active}
bunker_active.localised_description = {"entity-description."..shared.bunker_active}

data:extend({ bunker_minable, bunker_active })

