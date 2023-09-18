local sounds = require("__base__.prototypes.entity.sounds")

local name = "af-reverse-lab"
local icon = "__Reverse-Engineering__/graphics/rlab-icon.png"
local icon_size = 64
local icon_mipmaps = 1

local special_flags = {
  "not-rotatable", "placeable-neutral", "placeable-off-grid",
  "not-blueprintable", "not-deconstructable", "not-flammable",
}

local resistances = {
  { type = "impact", decrease=10000, percent=100 },
  { type = "physical", percent=100 },
  { type = "explosion", percent=100 },
  { type = "laser", percent = 100 },
  { type = "fire", percent = 100 },
  { type = "electric", percent=100 },
  { type = "acid", percent=100 },
  { type = "poison", percent=100 },
}

local function box_mult(box, xs, ys)
  box[1][1] = box[1][1] * xs
  box[1][2] = box[1][2] * ys
  box[2][1] = box[2][1] * xs
  box[2][2] = box[2][2] * ys
  return box
end

local chest_base = table.deepcopy(data.raw["container"]["iron-chest"])
chest_base.max_health = 10000
chest_base.healing_per_tick = 10000
chest_base.flags = special_flags
chest_base.collision_mask = {}
chest_base.resistances = resistances
chest_base.next_upgrade = nil
chest_base.minable = nil
chest_base.inventory_size = 20

local chest_input = table.deepcopy(chest_base)
chest_input.name = name.."-chest-input"
chest_input.picture.layers[1].tint = {0.8, 1, 0.9}
chest_input.picture.layers[1].hr_version.tint = chest_input.picture.layers[1].tint
chest_input.selection_box = box_mult(chest_input.selection_box, 1, 3)
chest_input.collision_box = box_mult(chest_input.collision_box, 1, 3)
local chest_packs = table.deepcopy(chest_base)
chest_packs.name = name.."-chest-packs"
chest_packs.picture.layers[1].tint = {0.9, 0.9, 1}
chest_packs.picture.layers[1].hr_version.tint = chest_packs.picture.layers[1].tint
local chest_other = table.deepcopy(chest_base)
chest_other.name = name.."-chest-other"
chest_other.picture.layers[1].tint = {1, 0.8, 0.8}
chest_other.picture.layers[1].hr_version.tint = chest_other.picture.layers[1].tint
data:extend({ chest_input, chest_packs, chest_other })

data:extend({
  {
    -- type = "simple-entity-with-force",
    type = "electric-energy-interface",
    name = name,
    se_allow_in_space = true,
    icon = icon, icon_size = icon_size, icon_mipmaps = icon_mipmaps,
    flags = {
      "not-rotatable", "placeable-neutral", "player-creation",
    },
    max_health = 500,
    corpse = "medium-electric-pole-remnants",
    dying_explosion = "massive-explosion",
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    collision_box = {{-1.5, -1.5}, {1.5, 1.5}},
    collision_mask = {"floor-layer", "item-layer", "object-layer", "water-tile"},
    selection_priority = 40,
    vehicle_impact_sound = sounds.generic_impact,
    open_sound = sounds.electric_network_open,
    close_sound = sounds.electric_network_close,
    energy_source = {
      type = "electric",
      usage_priority = "secondary-input",
      buffer_capacity = "100MJ",
      input_flow_limit = "20MW",
      drain = "1MW",
    },
    render_layer = "floor",
    animations = {
      filename = "__Reverse-Engineering__/graphics/rlab.png",
      width = 98,
      height = 87,
      scale = 0.6666,
      shift = { 0, 0 },
    },
  },
  {
    type = "item",
    name = name,
    icon = icon, icon_size = icon_size, icon_mipmaps = icon_mipmaps,
    subgroup = "production-machine",
    order = "d[af-reverse-lab]",
    place_result = name,
    stack_size = 1,
  },
  {
    type = "recipe",
    name = name,
    enabled = true,
    ingredients = {
      {"iron-chest", 3},
      {"filter-inserter", 5},
      {"assembling-machine-2", 1},
      {"advanced-circuit", 10},
    },
    result = name,
  },
})
