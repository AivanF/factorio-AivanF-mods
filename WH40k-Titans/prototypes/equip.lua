local shared = require("shared")

data.raw.item[shared.energy_core].placed_as_equipment_result = shared.energy_core
data.raw.item[shared.void_shield].placed_as_equipment_result = shared.void_shield
data.raw.item[shared.antigraveng].placed_as_equipment_result = shared.antigraveng
data.raw.item[shared.motor].placed_as_equipment_result = shared.motor

data:extend({
  {
    type = "equipment-grid",
    name = shared.mod_prefix.."t1",
    width = 8,
    height = 4,
    equipment_categories = {shared.equip_cat}
  },
  {
    type = "equipment-grid",
    name = shared.mod_prefix.."t2",
    width = 8,
    height = 8,
    equipment_categories = {shared.equip_cat}
  },
  {
    type = "equipment-grid",
    name = shared.mod_prefix.."t3",
    width = 16,
    height = 8,
    equipment_categories = {shared.equip_cat}
  },
  {
    type = "equipment-grid",
    name = shared.mod_prefix.."t4",
    width = 16,
    height = 16,
    equipment_categories = {shared.equip_cat}
  },
  {
    type = "equipment-grid",
    name = shared.mod_prefix.."t5",
    width = 24,
    height = 16,
    equipment_categories = {shared.equip_cat}
  },
  {
    type = "equipment-category",
    name = shared.mod_prefix,
  },

  {
    type = "generator-equipment",
    name = shared.energy_core,
    sprite = {
      filename = shared.media_prefix.."graphics/icons/details/energy-core.png",
      width = 64, height = 64,
      -- hr_version = {
      --   filename = "__base__/graphics/equipment/hr-fusion-reactor-equipment.png",
      --   width = 256,
      --   height = 256,
      --   scale = 0.5
      -- }
    },
    shape = {
      width = 4,
      height = 4,
      type = "full"
    },
    energy_source = {
      type = "electric",
      usage_priority = "primary-output"
    },
    power = "10MW",
    categories = {shared.equip_cat}
  },

  {
    name = shared.void_shield,
    type = "energy-shield-equipment",
    sprite = {
      filename = shared.media_prefix.."graphics/icons/details/void-shield-gen.png",
      width = 64, height = 64,
    },
    shape = {
      width = 4,
      height = 4,
      type = "full"
    },
    max_shield_value = 1000,
    energy_source = {
      type = "electric",
      buffer_capacity = "10MJ",
      input_flow_limit = "4MW",
      usage_priority = "primary-input"
    },
    energy_per_shield = "100kJ",
    categories = {shared.equip_cat}
  },

  {
    name = shared.motor,
    type = "movement-bonus-equipment",
    sprite =
    {
      filename = shared.media_prefix.."graphics/icons/details/titanic-motor.png",
      width = 64, height = 64,
    },
    shape = {
      width = 2,
      height = 2,
      type = "full"
    },
    energy_source = {
      type = "electric",
      usage_priority = "secondary-input"
    },
    energy_consumption = "2MW",
    movement_bonus = 0.1,
    categories = {shared.equip_cat}
  },

  {
    name = shared.antigraveng,
    type = "movement-bonus-equipment",
    sprite =
    {
      filename = shared.media_prefix.."graphics/icons/details/antigraveng.png",
      width = 64, height = 64,
    },
    shape = {
      width = 4,
      height = 4,
      type = "full"
    },
    energy_source = {
      type = "electric",
      usage_priority = "secondary-input"
    },
    energy_consumption = "10MW",
    movement_bonus = 0.6,
    categories = {shared.equip_cat}
  },
})
