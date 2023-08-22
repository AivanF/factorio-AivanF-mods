local shared = require("shared")
-- Void shield activator
data:extend({
  --- Category
  {
    type = "equipment-category",
    name = shared.equicat
  },
  --- Equipment object
  {
    type = "energy-shield-equipment",
    name = shared.vsa,
    sprite = {
      filename = "__base__/graphics/equipment/energy-shield-mk2-equipment.png",
      width = 64,
      height = 64,
      priority = "medium",
      hr_version = {
        filename = "__base__/graphics/equipment/hr-energy-shield-mk2-equipment.png",
        width = 128,
        height = 128,
        priority = "medium",
        scale = 0.5
      }
    },
    shape = {
      width = 1,
      height = 2,
      type = "full"
    },
    max_shield_value = 5000,
    energy_per_shield = "1MJ",
    energy_source = {
      type = "void",
      buffer_capacity = "1000MJ",
      input_flow_limit = "0kW",
      usage_priority = "primary-input"
    },
    categories = {shared.equicat}
  },
  --- Equipment item
  {
    type = "item",
    name = shared.vsa,
    icon = "__base__/graphics/icons/energy-shield-mk2-equipment.png",
    icon_size = 64, icon_mipmaps = 4,
    placed_as_equipment_result = shared.vsa,
    flags = {},
    subgroup = shared.subg_titans,
    order = "z-vsa-equip",
    stack_size = 20,
  },
  --- Equipment recipe
  {
    type = "recipe",
    name = shared.vsa,
    enabled = true,
    ingredients = {
      {"steel-plate", 2},
      {"processing-unit", 1},
    },
    result = shared.vsa,
  },
  --- Grids
  {
    type = "equipment-grid",
    name = "wh40k-titan-c1-egrid",
    width = 1,
    height = 2,
    equipment_categories = {shared.equicat}
  },
  {
    type = "equipment-grid",
    name = "wh40k-titan-c2-egrid",
    width = 2,
    height = 2,
    equipment_categories = {shared.equicat}
  },
  {
    type = "equipment-grid",
    name = "wh40k-titan-c3-egrid",
    width = 2,
    height = 4,
    equipment_categories = {shared.equicat}
  },
  {
    type = "equipment-grid",
    name = "wh40k-titan-c4-egrid",
    width = 3,
    height = 4,
    equipment_categories = {shared.equicat}
  },
  {
    type = "equipment-grid",
    name = "wh40k-titan-c5-egrid",
    width = 6,
    height = 4,
    equipment_categories = {shared.equicat}
  },
})