local shared = require("shared")

-- local rocket_lift_weight = data.raw["utility-constants"]["default"].rocket_lift_weight
local rocket_lift_weight = 1000000

local parts = {
  {
    name = shared.servitor,
    icon = shared.media_prefix.."graphics/icons/details/servitor.png",
    icon_size = 64, icon_mipmaps = 1,
    ingredients = {
      -- {type="item", name="low-density-structure", amount=20},
      {type="item", name=afci_bridge.get.meat().name, amount=40},
      {type="item", name=afci_bridge.get.brain().name, amount=1},
      {type="item", name="iron-stick", amount=20},
      {type="item", name="iron-gear-wheel", amount=20},
      {type="item", name="copper-cable", amount=40},
      -- {type="item", name="processing-unit", amount=1},
      -- {type="item", name="construction-robot", amount=1},
      {type="item", name="repair-pack", amount=100},
    },
    stack_size = 4,
    weight = rocket_lift_weight / 20,
    order = "a-1",
    place_result = nil,
  },
  {
    name = shared.brain,
    icon = shared.media_prefix.."graphics/icons/details/titanic-brain.png",
    icon_size = 64, icon_mipmaps = 1,
    ingredients = {
      {type="item", name="radar", amount=1},
      {type="item", name=afci_bridge.get.nano_mat().name, amount=24},
      {type="item", name=afci_bridge.get.quantum_chip().name, amount=42},
      -- Titans know the meaning of life, the universe, and everything!
    },
    energy_required = 60,
    weight = rocket_lift_weight / 10,
    order = "a-2",
  },
  {
    name = shared.motor,
    icon = shared.media_prefix.."graphics/icons/details/titanic-motor.png",
    icon_size = 64, icon_mipmaps = 4,
    ingredients = {
      {type="item", name="electric-engine-unit", amount=40},
      -- {type="item", name="iron-gear-wheel", amount=20},
      {type="item", name=afci_bridge.get.bearing().name, amount=20},
      -- {type="item", name="steel-plate", amount=60},
      {type="item", name=afci_bridge.get.heavy_material().name, amount=60},
      {type="item", name=afci_bridge.get.sc_cable().name, amount=30},
    },
    weight = rocket_lift_weight / 20,
    order = "a-3",
  },
  {
    name = shared.frame_part,
    icon = shared.media_prefix.."graphics/icons/details/frame-part.png",
    icon_size = 64, icon_mipmaps = 4,
    ingredients = {
      {type="item", name=afci_bridge.get.heavy_material().name, amount=120},
      {type="item", name=afci_bridge.get.light_material().name, amount=120},
      {type="item", name=afci_bridge.get.bearing().name, amount=24},
      {type="item", name=afci_bridge.get.dense_cable().name, amount=20},
      {type="item", name="processing-unit", amount=1},
    },
    weight = rocket_lift_weight / 20,
    order = "a-4",
  },
  {
    name = shared.energy_core,
    icon = shared.media_prefix.."graphics/icons/details/energy-core.png",
    icon_size = 64, icon_mipmaps = 4,
    ingredients = {
      {type="item", name=afci_bridge.get.best_energy_provider().name, amount=7},
      {type="item", name=afci_bridge.get.emfc().name, amount=6},
      {type="item", name=afci_bridge.get.heavy_material().name, amount=20},
      {type="item", name=afci_bridge.get.dense_cable().name, amount=8},
    },
    weight = rocket_lift_weight / 10,
    order = "a-5",
    place_result = nil,
  },
  {
    name = shared.void_shield,
    icon = shared.media_prefix.."graphics/icons/details/void-shield-gen.png",
    icon_size = 64, icon_mipmaps = 3,
    ingredients = {
      {type="item", name=shared.realityctrl, amount=1},
      -- {"energy-shield-mk2-equipment", 1},
      {type="item", name=afci_bridge.get.best_shield().name, amount=1},
    },
    weight = rocket_lift_weight / 10,
    order = "a-6",
  },


  -- Common details
  {
    name = shared.antigraveng,
    icon = shared.media_prefix.."graphics/icons/details/antigraveng.png",
    icon_size = 64, icon_mipmaps = 3,
    ingredients = {
      {type="item", name=afci_bridge.get.st_operator().name, amount=3},
      {type="item", name=afci_bridge.get.light_material().name, amount=10},
      -- {"energy-shield-mk2-equipment", 1},
    },
    weight = rocket_lift_weight / 20,
    order = "b-1",
  },
  {
    name = shared.realityctrl,
    icon = shared.media_prefix.."graphics/icons/details/reality-ctrl.png",
    icon_size = 64, icon_mipmaps = 3,
    ingredients = {
      {type="item", name=afci_bridge.get.st_operator().name, amount=11},
      {type="item", name=afci_bridge.get.heavy_material().name, amount=17},
      -- {type="item", name=afci_bridge.get.light_material().name, amount=19},
    },
    weight = rocket_lift_weight / 10,
    order = "b-2",
  },

  -- Weapon details
  {
    name = shared.barrel,
    icon = shared.media_prefix.."graphics/icons/details/barrel.png",
    icon_size = 64, icon_mipmaps = 4,
    ingredients = {
      {type="item", name=afci_bridge.get.advanced_ceramic().name, amount=20},
      {type="item", name=afci_bridge.get.heavy_material().name, amount=120},
    },
    allow_decomposition = true,
    weight = rocket_lift_weight / 20,
    order = "c-1",
    place_result = nil,
  },
  {
    name = shared.proj_engine,
    icon = shared.media_prefix.."graphics/icons/details/projectile-engine.png",
    icon_size = 64, icon_mipmaps = 4,
    ingredients = {
      {type="item", name=afci_bridge.get.heavy_material().name, amount=80},
      {type="item", name=afci_bridge.get.bearing().name, amount=18},
      {type="item", name="electric-engine-unit", amount=12},
      {type="item", name="engine-unit", amount=12},
      {type="item", name="processing-unit", amount=1},
    },
    weight = rocket_lift_weight / 20,
    order = "c-2",
    place_result = nil,
  },
  {
    name = shared.melta_pump,
    icon = shared.media_prefix.."graphics/icons/details/melta-pump.png",
    icon_size = 64, icon_mipmaps = 4,
    ingredients = {
      {type="item", name=shared.barrel, amount=4},
      {type="item", name="electric-engine-unit", amount=8},
      {type="item", name="engine-unit", amount=8},
      {type="item", name="processing-unit", amount=1},
    },
    weight = rocket_lift_weight / 20,
    order = "c-3",
    place_result = nil,
  },
}


local results
for _, info in pairs(parts) do
  results = info.results or {}
  -- TODO: add use_recylcing startup setting, remove ores if false
  table.insert(results, 1, {type="item", name=info.name, amount=1})

  data:extend({
    {
      type = "item",
      name = info.name,
      icon = info.icon,
      icon_size = info.icon_size, icon_mipmaps = info.icon_mipmaps,
      subgroup = shared.subg_parts,
      order = info.order,
      place_result = info.place_result,
      stack_size = info.stack_size or 1,
      weight = info.weight,
    },
    {
      type = "recipe",
      name = info.name,
      enabled = false,
      energy_required = info.energy_required or 30,
      ingredients = info.ingredients,
      results = results,
      main_product = info.name,
      category = info.category or "advanced-crafting",
    },
  })
end
