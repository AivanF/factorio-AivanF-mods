local shared = require("shared")

local parts = {
  {
    name = shared.servitor,
    icon = shared.media_prefix.."graphics/icons/details/servitor.png",
    icon_size = 64, icon_mipmaps = 1,
    ingredients = {
      -- {"low-density-structure", 20},
      {afci_bridge.get.meat().name, 40},
      {afci_bridge.get.brain().name, 1},
      {"iron-stick", 20},
      {"iron-gear-wheel", 20},
      {"copper-cable", 40},
      -- {"processing-unit", 1},
      -- {"construction-robot", 1},
      {"repair-pack", 100},
    },
    stack_size = 4,
    order = "a-1",
    place_result = nil,
  },
  {
    name = shared.brain,
    icon = shared.media_prefix.."graphics/icons/details/titanic-brain.png",
    icon_size = 64, icon_mipmaps = 1,
    ingredients = {
      {"radar", 1},
      {afci_bridge.get.nano_mat().name, 24},
      {afci_bridge.get.quantum_chip().name, 42},
      -- Titans know the meaning of life, the universe, and everything!
    },
    energy_required = 60,
    order = "a-2",
  },
  {
    name = shared.motor,
    icon = shared.media_prefix.."graphics/icons/details/titanic-motor.png",
    icon_size = 64, icon_mipmaps = 4,
    ingredients = {
      {"electric-engine-unit", 40},
      -- {"iron-gear-wheel", 20},
      {afci_bridge.get.bearing().name, 20},
      -- {"steel-plate", 60},
      {afci_bridge.get.heavy_material().name, 60},
    },
    order = "a-3",
  },
  {
    name = shared.frame_part,
    icon = shared.media_prefix.."graphics/icons/details/frame-part.png",
    icon_size = 64, icon_mipmaps = 4,
    ingredients = {
      {afci_bridge.get.heavy_material().name, 120},
      {afci_bridge.get.light_material().name, 120},
      {afci_bridge.get.bearing().name, 24},
      {afci_bridge.get.dense_cable().name, 20},
      {"processing-unit", 1},
    },
    order = "a-4",
  },
  {
    name = shared.energy_core,
    icon = shared.media_prefix.."graphics/icons/details/energy-core.png",
    icon_size = 64, icon_mipmaps = 4,
    ingredients = {
      {afci_bridge.get.best_energy_provider().name, 7},
      {afci_bridge.get.emfc().name, 6},
      {afci_bridge.get.heavy_material().name, 20},
      {afci_bridge.get.dense_cable().name, 8},
    },
    order = "a-5",
    place_result = nil,
  },
  {
    name = shared.void_shield,
    icon = shared.media_prefix.."graphics/icons/details/void-shield-gen.png",
    icon_size = 64, icon_mipmaps = 3,
    ingredients = {
      {shared.realityctrl, 1},
      -- {"energy-shield-mk2-equipment", 1},
      {afci_bridge.get.best_shield().name, 1},
    },
    order = "a-6",
  },


  -- Common details
  {
    name = shared.antigraveng,
    icon = shared.media_prefix.."graphics/icons/details/antigraveng.png",
    icon_size = 64, icon_mipmaps = 3,
    ingredients = {
      {afci_bridge.get.st_operator().name, 3},
      {afci_bridge.get.light_material().name, 10},
      -- {"energy-shield-mk2-equipment", 1},
    },
    order = "b-1",
  },
  {
    name = shared.realityctrl,
    icon = shared.media_prefix.."graphics/icons/details/reality-ctrl.png",
    icon_size = 64, icon_mipmaps = 3,
    ingredients = {
      {afci_bridge.get.st_operator().name, 11},
      {afci_bridge.get.heavy_material().name, 17},
      -- {afci_bridge.get.light_material().name, 19},
    },
    order = "b-2",
  },

  -- Weapon details
  {
    name = shared.barrel,
    icon = shared.media_prefix.."graphics/icons/details/barrel.png",
    icon_size = 64, icon_mipmaps = 4,
    ingredients = {
      {afci_bridge.get.heavy_material().name, 180},
    },
    order = "c-1",
    place_result = nil,
  },
  {
    name = shared.proj_engine,
    icon = shared.media_prefix.."graphics/icons/details/projectile-engine.png",
    icon_size = 64, icon_mipmaps = 4,
    ingredients = {
      {afci_bridge.get.heavy_material().name, 80},
      {afci_bridge.get.bearing().name, 18},
      {"electric-engine-unit", 12},
      {"engine-unit", 12},
      {"processing-unit", 1},
    },
    order = "c-2",
    place_result = nil,
  },
  {
    name = shared.melta_pump,
    icon = shared.media_prefix.."graphics/icons/details/melta-pump.png",
    icon_size = 64, icon_mipmaps = 4,
    ingredients = {
      {shared.barrel, 4},
      {"electric-engine-unit", 8},
      {"engine-unit", 8},
      {"processing-unit", 1},
    },
    order = "c-3",
    place_result = nil,
  },
}


local results
for _, info in pairs(parts) do
  results = info.results
  -- TODO: add use_recylcing startup setting, remove ores if false
  if results then
    table.insert(results, 1, {info.name, 1})
  end

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
    },
    {
      type = "recipe",
      name = info.name,
      enabled = false,
      energy_required = info.energy_required or 30,
      ingredients = info.ingredients,
      result = info.name,
      results = results,
      main_product = info.name,
      category = info.category or "advanced-crafting",
    },
  })
end
