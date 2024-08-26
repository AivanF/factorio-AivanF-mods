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

local lamp = table.deepcopy(data.raw["lamp"]["small-lamp"])
lamp.name = shared.bunker_lamp
lamp.max_health = 10000
lamp.resistances = technomagic_resistances
lamp.flags = special_flags
lamp.selectable_in_game = false
lamp.minable = nil
lamp.collision_mask = {}
lamp.energy_source = { type = "void" }
lamp.next_upgrade = nil
data:extend({ lamp })

local comb = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
comb.name = shared.bunker_comb
comb.max_health = 10000
comb.resistances = technomagic_resistances
comb.flags = special_flags
comb.selection_box = {{-1, -1}, {1, 1}}
comb.collision_mask = {}
comb.selection_priority = 60
comb.energy_source = { type = "void" }
comb.sprites = misc.empty_sprite
comb.activity_led_sprites = misc.empty_sprite
comb.fast_replaceable_group = nil
comb.circuit_wire_max_distance = 16
comb.item_slot_count = shared.bunker_comb_size
comb.minable = nil
data:extend({ comb })

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

local circuit_connector_wstoreh = circuit_connector_definitions.create(
  universal_connector_template,
  {
    { variation = 26,
      main_offset = util.by_pixel(-32, 24),
      shadow_offset = util.by_pixel(7.5, 7.5),
      -- show_shadow = true
    }
  }
)
local circuit_connector_wstorev = circuit_connector_definitions.create(
  universal_connector_template,
  {
    { variation = 26,
      main_offset = util.by_pixel(16, 48),
      shadow_offset = util.by_pixel(7.5, 7.5),
      -- show_shadow = true
    }
  }
)
local circuit_connector_bstore = circuit_connector_definitions.create(
  universal_connector_template,
  {
    { variation = 26,
      main_offset = util.by_pixel(-48, 48),
      shadow_offset = util.by_pixel(7.5, 7.5),
      -- show_shadow = true
    }
  }
)

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
    resistances = technomagic_resistances,
    dying_explosion = "iron-chest-explosion",
    open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.43 },
    close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.43 },
    selection_box = {{-2, -1}, {2, 1}},
    collision_box = {{-2, -1}, {2, 1}},
    collision_mask = {},
    inventory_size = 300,
    picture = {
      layers = {
        misc.empty_sprite,
      }
    },
    circuit_wire_connection_point = circuit_connector_wstoreh.points,
    circuit_connector_sprites = circuit_connector_wstoreh.sprites,
    circuit_wire_max_distance = default_circuit_wire_max_distance,
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
    resistances = technomagic_resistances,
    dying_explosion = "iron-chest-explosion",
    open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.43 },
    close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.43 },
    selection_box = {{-1, -2}, {1, 2}},
    collision_box = {{-1, -2}, {1, 2}},
    collision_mask = {},
    inventory_size = 300,
    picture = {
      layers = {
        misc.empty_sprite,
      }
    },
    circuit_wire_connection_point = circuit_connector_wstorev.points,
    circuit_connector_sprites = circuit_connector_wstorev.sprites,
    circuit_wire_max_distance = default_circuit_wire_max_distance,
  },
  -- {
  --   type = "assembling-machine",
  --   name = shared.bunker_wrecipeh,
  --   localised_name = {"entity-name.wh40k-titans-assembly-bunker-wrecipe"},
  --   localised_description = {"entity-description.wh40k-titans-assembly-bunker-wrecipe"},
  --   icon = icon, icon_size = icon_size, icon_mipmaps = icon_mipmaps,
  --   flags = special_flags,
  --   max_health = 10000,
  --   resistances = technomagic_resistances,
  --   healing_per_tick = 10000,
  --   corpse = "medium-electric-pole-remnants",
  --   dying_explosion = "medium-electric-pole-explosion",
  --   resistances = technomagic_resistances,
  --   selection_box = {{-2, -1}, {2, 1}},
  --   collision_box = {{-2, -1}, {2, 1}},
  --   collision_mask = {},
  --   render_layer = "floor",
  --   vehicle_impact_sound = sounds.generic_impact,
  --   open_sound = sounds.electric_network_open,
  --   close_sound = sounds.electric_network_close,
  --   working_visualisations = misc.empty_4way_animation,
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
  --   resistances = technomagic_resistances,
  --   corpse = "medium-electric-pole-remnants",
  --   dying_explosion = "medium-electric-pole-explosion",
  --   selection_box = {{-1, -2}, {1, 2}},
  --   collision_box = {{-1, -2}, {1, 2}},
  --   collision_mask = {},
  --   render_layer = "floor",
  --   vehicle_impact_sound = sounds.generic_impact,
  --   open_sound = sounds.electric_network_open,
  --   close_sound = sounds.electric_network_close,
  --   working_visualisations = misc.empty_4way_animation,
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
    resistances = technomagic_resistances,
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
    circuit_wire_connection_point = circuit_connector_bstore.points,
    circuit_connector_sprites = circuit_connector_bstore.sprites,
    circuit_wire_max_distance = default_circuit_wire_max_distance,
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
    resistances = technomagic_resistances,
    selection_box = {{-4, -4}, {4, 4}},
    collision_box = {{-4, -4}, {4, 4}},
    collision_mask = {"floor-layer", "item-layer", "object-layer", "water-tile"},
    render_layer = "floor",
    vehicle_impact_sound = sounds.generic_impact,
    open_sound = sounds.electric_network_open,
    close_sound = sounds.electric_network_close,
    working_visualisations = misc.empty_4way_animation,
    module_specification = {
      module_slots = 0,
    },
    crafting_speed = 0.01,
    crafting_categories = {
      shared.craftcat_empty,
      shared.craftcat_titan.."1", shared.craftcat_titan.."2", shared.craftcat_titan.."3",
      shared.craftcat_titan.."4", shared.craftcat_titan.."5",
    },
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
      {"concrete", 1000},
    },
    result = shared.bunker_minable,
    energy_required = 100,
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
  resistances = strong_resistances,
  selection_box = {{-11, -11}, {11, 11}},
  collision_box = {{-11, -11}, {11, 11}},
  collision_mask = {"floor-layer", "item-layer", "object-layer", "water-tile"},
  selection_priority = 10,
  vehicle_impact_sound = sounds.generic_impact,
  open_sound = sounds.electric_network_open,
  close_sound = sounds.electric_network_close,

  working_visualisations = idle_working_visualisations,
  module_specification = {
    module_slots = 0,
  },
  crafting_speed = 0.01,
  crafting_categories = {shared.craftcat_empty},
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

local leftovers_chest = table.deepcopy(data.raw["container"]["iron-chest"])
leftovers_chest.name = shared.leftovers_chest
leftovers_chest.resistances = strong_resistances
leftovers_chest.next_upgrade = nil
leftovers_chest.minable = {mining_time = 3}
leftovers_chest.inventory_size = 350
leftovers_chest.picture.layers[1].filename = shared.media_prefix.."graphics/entity/leftovers-chest.png"
leftovers_chest.picture.layers[1].hr_version.filename = shared.media_prefix.."graphics/entity/leftovers-chest-hr.png"

data:extend({ bunker_minable, bunker_active, leftovers_chest })
