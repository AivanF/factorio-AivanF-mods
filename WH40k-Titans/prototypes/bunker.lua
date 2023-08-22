local sounds = require("__base__.prototypes.entity.sounds")
local shared = require("shared")
local misc = require("prototypes.misc")

local name = shared.bunker
local icon = shared.media_prefix.."graphics/icons/bunker.png"
local icon_size = 32
local icon_mipmaps = 1

local special_flags = {
  "not-rotatable", "placeable-neutral", "placeable-off-grid",
  "not-blueprintable", "not-deconstructable", "not-flammable",
}

local bunker_resistances = {
  { type = "impact", decrease=1000, percent=100 },
  { type = "physical", percent=100 },
  { type = "explosion", percent=100 },
  { type = "fire", percent = 100 },
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
lamp.resistances = bunker_resistances,
data:extend({ lamp })

local idle_sprite = {
  filename = shared.media_prefix.."graphics/entity/Bunker.png",
  priority = "extra-high",
  width = 320,
  height = 320,
  scale = 1,
  shift = util.by_pixel(0, 0),
  frame_count = 1,
  hr_version = {
    filename = shared.media_prefix.."graphics/entity/Bunker-HR.png",
    priority = "extra-high",
    width = 640,
    height = 640,
    scale = 0.5,
    shift = util.by_pixel(0, 0),
    frame_count = 1,
  }
}

local idle_layers = {
  idle_sprite,
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
    selection_box = {{-1, -0.5}, {1, 0.5}},
    collision_box = {{-0.5, -0.5}, {0.5, 0.5}},
    collision_mask = {},
    inventory_size = 50,
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
    selection_box = {{-0.5, -1}, {0.5, 1}},
    collision_box = {{-0.5, -0.5}, {0.5, 0.5}},
    collision_mask = {},
    inventory_size = 50,
    picture = {
      layers = {
        misc.empty_sprite,
      }
    },
  },
  {
    type = "assembling-machine",
    name = shared.bunker_wrecipeh,
    localised_name = {"entity-name.wh40k-titans-assembly-bunker-wrecipe"},
    localised_description = {"entity-description.wh40k-titans-assembly-bunker-wrecipe"},
    icon = icon,
    icon_size = icon_size, icon_mipmaps = icon_mipmaps,
    flags = special_flags,
    max_health = 10000,
    resistances = bunker_resistances,
    healing_per_tick = 10000,
    corpse = "medium-electric-pole-remnants",
    dying_explosion = "medium-electric-pole-explosion",
    resistances = bunker_resistances,
    selection_box = {{-1, -0.5}, {1, 0.5}},
    collision_box = {{-0.5, -0.5}, {0.5, 0.5}},
    collision_mask = {},
    render_layer = "floor",
    vehicle_impact_sound = sounds.generic_impact,
    open_sound = sounds.electric_network_open,
    close_sound = sounds.electric_network_close,
    working_visualisations = empty_working_visualisations,
    module_specification = {
      module_slots = 0,
    },
    crafting_speed = 0.01,
    crafting_categories = {shared.craftcat_weapon},
    energy_source = { type = "void" },
    energy_usage = "1W",
  },
  {
    type = "assembling-machine",
    name = shared.bunker_wrecipev,
    localised_name = {"entity-name.wh40k-titans-assembly-bunker-wrecipe"},
    localised_description = {"entity-description.wh40k-titans-assembly-bunker-wrecipe"},
    icon = icon,
    icon_size = icon_size, icon_mipmaps = icon_mipmaps,
    flags = special_flags,
    max_health = 10000,
    healing_per_tick = 10000,
    resistances = bunker_resistances,
    corpse = "medium-electric-pole-remnants",
    dying_explosion = "medium-electric-pole-explosion",
    selection_box = {{-0.5, -1}, {0.5, 1}},
    collision_box = {{-0.5, -0.5}, {0.5, 0.5}},
    collision_mask = {},
    render_layer = "floor",
    vehicle_impact_sound = sounds.generic_impact,
    open_sound = sounds.electric_network_open,
    close_sound = sounds.electric_network_close,
    working_visualisations = empty_working_visualisations,
    module_specification = {
      module_slots = 0,
    },
    crafting_speed = 0.01,
    crafting_categories = {shared.craftcat_weapon},
    energy_source = { type = "void" },
    energy_usage = "1W",
  },

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
    dying_explosion = "iron-chest-explosion",
    open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.43 },
    close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.43 },
    selection_box = {{-2, -1}, {2, 1}},
    collision_box = {{-0.5, -0.5}, {0.5, 0.5}},
    collision_mask = {},
    inventory_size = 300,
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
    icon = icon,
    icon_size = icon_size, icon_mipmaps = icon_mipmaps,
    flags = special_flags,
    max_health = 20000,
    healing_per_tick = 20000,
    corpse = "medium-electric-pole-remnants",
    dying_explosion = "medium-electric-pole-explosion",
    resistances = bunker_resistances,
    selection_box = {{-2, -2}, {2, 2}},
    collision_box = {{-2, -2}, {2, 2}},
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
    crafting_categories = {shared.craftcat_titan},
    energy_source = { type = "void" },
    energy_usage = "1W",
  },

  {
    type = "item",
    name = name,
    localised_name = {"entity-name.wh40k-titans-assembly-bunker"},
    localised_description = {"entity-description.wh40k-titans-assembly-bunker"},
    icon = icon,
    icon_size = icon_size, icon_mipmaps = icon_mipmaps,
    subgroup = shared.subg_build,
    order = "a[assembly-bunker]",
    place_result = name,
    stack_size = 1,
  },
  {
    type = "recipe",
    name = name,
    enabled = false,
    ingredients = {
      {"steel-chest", 100},
      {"assembling-machine-3", 20},
      {"stack-filter-inserter", 30},
      {"small-lamp", 12},
      {"processing-unit", 100},
    },
    result = name,
  },
  {
    type = "simple-entity-with-force",
    name = name,
    localised_name = {"entity-name.wh40k-titans-assembly-bunker"},
    localised_description = {"entity-description.wh40k-titans-assembly-bunker"},
    icon = icon,
    icon_size = icon_size, icon_mipmaps = icon_mipmaps,
    flags = {
      "not-rotatable", "placeable-neutral", "player-creation",
    },
    minable = {mining_time = 2.0, result = name},
    max_health = 1000,
    corpse = "medium-electric-pole-remnants",
    dying_explosion = "medium-electric-pole-explosion",
    resistances = {
      { type = "impact", decrease=1000, percent=100 },
    },
    selection_box = {{-5, -5}, {5, 5}},
    collision_box = {{-4.5, -4.5}, {4.5, 4.5}},
    collision_mask = {"floor-layer", "item-layer", "object-layer", "water-tile"},
    selection_priority = 10,
    render_layer = "floor",
    vehicle_impact_sound = sounds.generic_impact,
    open_sound = sounds.electric_network_open,
    close_sound = sounds.electric_network_close,

    render_layer = "floor",
    animations = idle_sprite,
  },
})
