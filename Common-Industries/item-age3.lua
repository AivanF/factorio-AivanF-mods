local bridge = require("item-utils")

local add_item = bridge.add_item
local prerequisite = bridge.tech.lategame.name
local subgroup = bridge.subg_late

-- local rocket_lift_weight = data.raw["utility-constants"]["default"].rocket_lift_weight
local rocket_lift_weight = 1000000

-- TODO: make nano-factory with steel, pipes, fast-inserter, glass.name, electric-engine-unit, laser-turret
--[[
mod = bridge.mods.exind,
cat_nano_crafting = "ei_nano-factory",
prerequisite = "ei_nano-factory",

mod = bridge.mods.py_fus
cat_nano_crafting = "nmf",
prerequisite = "aramid",

mod = bridge.mods._248k
cat_nano_crafting = "fi_compound_machine_category",
prerequisite = "fi_materials_tech",
]]

add_item({
  short_name = "brain",
  name = bridge.prefix.."brain",
  icon = bridge.media_path.."icons/brain.png",
  icon_size = 64, icon_mipmaps = 1,
  prereq = prerequisite,
  subgroup = subgroup,
  allow_productivity = true,
  ingredients = {
    { bridge.item.meat, 4 },
    -- { "advanced-circuit", 1 },
    {"processing-unit", 1},
  },
  energy_required = 5,
  stack_size = 10,
  weight = rocket_lift_weight / 100,
  category = bridge.config.cat_org_crafting,
  modded = {
    {
      mod = bridge.mods.sa,
      prereq = "agricultural-science-pack",
      ingredients = {
        { "nutrients", 50, },
        { "bioflux", 50, },
        { "copper-bacteria", 10, },
      },
      category = "organic",
    },
    {
      mod = bridge.mods.se,
      prereq = "se-space-genetics-laboratory",
      ingredients = {{type="fluid", name="se-neural-gel", amount=50}},
    },
    {
      mod = bridge.mods.py_life,
      name = "brain",
      prereq = "organ-printing-mk02",
      -- prereq = "rendering",
    },
    {
      mod = bridge.mods.pbb,
      prereq = bridge.empty,
    },
    {
      mod = bridge.mods.om_cry,
      ingredients = {
        { "electrocrystal", 1, },
        { type="fluid", name="omniston", amount=100 },
      },
      category = "omniplant",
    },
    {
      mod = bridge.mods.om_mat,
      ingredients = {
        { type="fluid", name="omniston", amount=200 },
      },
      category = "omnite-extraction-both",
    },
  },
})

add_item({
  short_name = "rocket_engine",
  name = bridge.prefix.."rocket-engine",
  -- name = "engine-unit",
  icon = bridge.media_path.."icons/rocket-engine.png",
  icon_size = 64, icon_mipmaps = 3,
  prereq = prerequisite,
  subgroup = subgroup,
  allow_productivity = true,
  ingredients = {
    {bridge.item.heavy_material, 9},
    {"pump", 3},
    {"engine-unit", 6},
    {"processing-unit", 1},
  },
  energy_required = 10,
  category = "advanced-crafting",
  modded = {
    {
      mod = bridge.mods.sa,
      name = "thruster",
      prereq = "space-platform-thruster",
    },
    -- {
    --   -- This one is too advanced?
    --   mod = bridge.mods.se,
    --   name = "se-spaceship-rocket-engine",
    --   prereq = "se-spaceship",
    -- },
    -- {
    --   -- This one is too simple
    --   mod = bridge.mods.bobwar,
    --   name = "rocket-engine",
    --   prereq = "rocket-silo",
    -- },
  },
})

add_item({
  short_name = "carbon_fiber",
  name = bridge.prefix.."carbon-fiber",
  icon = bridge.media_path.."icons/carbon-fiber.png",
  icon_size = 64, icon_mipmaps = 3,
  prereq = prerequisite,
  subgroup = subgroup,
  allow_productivity = true,
  ingredients = {{"coal", 2}},
  stack_size = 100,
  energy_required = 10,
  category = bridge.config.cat_nano_crafting,
  modded = {
    {
      mod = bridge.mods.sa,
      name = "carbon-fiber",
      prereq = "carbon-fiber",
    },
    {
      mod = bridge.mods.ir3,
      name = "carbon-foil",
      prereq = "ir-graphene",
    },
    {
      mod = bridge.mods._248k,
      name = "fu_materials_carbon_fiber",
      prereq = "fu_KFK_tech",
    },
    {
      mod = bridge.mods.exind,
      name = "ei_carbon-nanotube",
      prereq = "ei_nano-factory",
    },
    {
      mod = bridge.mods.py_alt,
      name = "carbon-nanotube",
      prereq = "carbon-nanotube",
    },
    {
      mod = bridge.mods.bzcarbon,
      name = "nanotubes",
      prereq = "nanotubes",
    },
    {
      mod = bridge.mods.angelsbio,
      ingredients = {{"solid-carbon", 2}},
      prereq = "bio-wood-processing-2",
    },
  },
})

add_item({
  short_name = "sc_cable",
  name = bridge.prefix.."superconductive-cable",
  icon = bridge.media_path.."icons/cable-super.png",
  icon_size = 64, icon_mipmaps = 1,
  prereq = prerequisite,
  subgroup = subgroup,
  allow_productivity = true,
  ingredients = {
    {bridge.item.carbon_fiber, 2},
    {bridge.item.dense_cable, 1},
  },
  energy_required = 2,
  category = "advanced-crafting",
  stack_size = 100,
  modded = {
    {
      mod = bridge.mods.sa,
      name = "superconductor",
      prereq = "electromagnetic-plant",
    },
    {
      mod = bridge.mods.se,
      name = "se-superconductive-cable",
      prereq = "se-superconductive-cable",
    },
    {
      mod = bridge.mods.k2,
      prereq = "kr-imersium-processing",
      ingredients = {
        {"imersium-plate", 2},
        {"copper-cable", 10},
        {"plastic-bar", 2},
      },
    },
    {
      mod = bridge.mods.py_fus,
      name = "sc-wire",
      prereq = "magnetic-core",
    },
    -- {
    --   mod = bridge.mods.om_cry,
    --   ingredients = {
    --     {"electrocrystal", 1},
    --     {"copper-cable", 10},
    --     {"plastic-bar", 2},
    --   },
    -- },
  },
})

add_item({
  short_name = "advanced_solenoid",
  name = bridge.prefix.."advanced-solenoid",
  icon = bridge.media_path.."icons/solenoid-super.png",
  icon_size = 64, icon_mipmaps = 1,
  prereq = prerequisite,
  subgroup = subgroup,
  allow_productivity = true,
  ingredients = {
    {"steel-plate", 2},
    {bridge.item.sc_cable, 10},
    {"battery", 5},
  },
  -- results = {{"iron-ore", 1}, {"copper-ore", 1}},
  category = "advanced-crafting",
  stack_size = 100,
  modded = {
    {
      mod = bridge.mods.sa,
      name = "supercapacitor",
      prereq = "electromagnetic-plant",
    },
    {
      mod = bridge.mods.se,
      name = "se-holmium-solenoid",
      prereq = "se-holmium-solenoid",
    },
    {
      mod = bridge.mods.ir3,
      prereq = "ir-force-fields",
      name = "carbon-coil",
    },
    {
      mod = bridge.mods.exind,
      name = "ei_magnet",
      prereq = "ei_high-tech-parts",

      -- prereq = "ei_neodium-refining",
      -- ingredients = {
      --   {"ei_neodym-plate", 5},
      --   {"copper-cable", 80},
      -- },
    },
    {
      mod = bridge.mods._248k,
      prereq = "gr_magnet_tech",
      name = "gr_materials_magnet",
    },
    {
      mod = bridge.mods.py_fus,
      prereq = "magnetic-core",
      name = "sc-coil",
    },
    {
      mod = bridge.mods.yit,
      prereq = "yi-intermediates",
      continue = true,
    }, {
      mod = bridge.mods.yi,
      name = "y-conductive-coil-1",
    },
  },
})

add_item({
  short_name = "nano_mat",
  name = bridge.prefix.."nano-material",
  icon = bridge.media_path.."icons/nanomat.png",
  icon_size = 64, icon_mipmaps = 1,
  prereq = prerequisite,
  subgroup = subgroup,
  allow_productivity = true,
  ingredients = {
    {"low-density-structure", 10},
    {bridge.item.glass, 10},
    {bridge.item.carbon_fiber, 10},
  },
  result_count = 10,
  stack_size = 100,
  weight = rocket_lift_weight / 1000,
  energy_required = 60,
  category = bridge.config.cat_nano_crafting,
  modded = {
    {
      mod = bridge.mods.sa,
      ingredients = {
        {"holmium-plate", 10},
        {bridge.item.carbon_fiber, 10},
      },
    },
    {
      mod = bridge.mods.se,
      name = "se-nanomaterial",
      prereq = "se-nanomaterial",
    },
    {
      mod = bridge.mods.ir3,
      name = "nanoglass",
      prereq = "ir-graphene",
    },
    {
      mod = bridge.mods.exind,
      name = "ei_carbon-structure",
      prereq = "ei_nano-factory",
    },
    {
      mod = bridge.mods.bzcarbon,
      prereq = "graphene",
      ingredients = {
        {"low-density-structure", 10},
        {bridge.item.carbon_fiber, 10},
      },
    },
    {
      mod = bridge.mods.k2,
      prereq = "kr-imersium-processing",
      ingredients = {
        {"low-density-structure", 10},
        {"imersium-plate", 10},
        {"silicon", 10},
      },
    },
    {
      mod = bridge.mods.bzcarbon,
      prereq = "graphene",
      ingredients = {
        {bridge.item.glass, 10},
        {"graphene", 10},
        {"low-density-structure", 10},
      },
    },
    {
      mod = bridge.mods.py_alt,
      name = "ns-material",
      prereq = "intermetallics-mk03",
      -- name = "nano-mesh",
      -- prereq = "nano-mesh",
    },
    {
      mod = bridge.mods._248k,
      ingredients = {
        {"fu_materials_TIM", 10}, -- Titanium composite
        {bridge.item.glass, 10},
        {bridge.item.carbon_fiber, 10},
      },
    },
    {
      mod = bridge.mods.yi,
      ingredients = {
        {"low-density-structure", 10},
        {"y_quantrinum_infused", 1}
      },
    },
  },
})

add_item({
  minor = true,
  short_name = "quantum_transistor",
  name = bridge.prefix.."quantum-transistor",
  icon = bridge.media_path.."icons/transistor-quantum.png",
  icon_size = 64, icon_mipmaps = 1,
  prereq = prerequisite,
  subgroup = subgroup,
  allow_productivity = true,
  ingredients = {
    {bridge.item.carbon_fiber, 12},
    {bridge.item.glass, 4},
    {bridge.item.faraday_cage, 1},
  },
  result_count = 4,
  stack_size = 100,
  energy_required = 10,
  category = bridge.config.cat_nano_crafting,
  modded = {
    {
      mod = bridge.mods.bzaluminum,
      -- prereq = "laser",
      ingredients = {
        {bridge.item.carbon_fiber, 12},
        {"ti-sapphire", 1},
        {bridge.item.faraday_cage, 1},
      },
    },
  }
})

add_item({
  short_name = "quantum_chip",
  name = bridge.prefix.."quantum-chip",
  icon = bridge.media_path.."icons/chip-quantum.png",
  icon_size = 64, icon_mipmaps = 1,
  prereq = prerequisite,
  subgroup = subgroup,
  allow_productivity = true,
  ingredients = {
    {bridge.item.quantum_transistor, 64},
    {bridge.item.sc_cable, 4},
    {bridge.item.optic_cable, 4},
    {"plastic-bar", 4},
    -- {"steel-plate", 4},
  },
  stack_size = 10,
  energy_required = 8,
  category = bridge.config.cat_nano_crafting,
  modded = {
    {
      mod = bridge.mods.sa,
      name = "quantum-processor",
      prereq = "quantum-processor",
    },
    {
      mod = bridge.mods.se,
      name = "se-quantum-processor",
      prereq = "se-quantum-processor",
    },
    {
      mod = bridge.mods.k2,
      name = "kr-quantum-computer",
      prereq = "kr-quantum-computer",
    },
    {
      mod = bridge.mods.exind,
      -- name = "ei_eu-circuit",
      -- prereq = "ei_high-tech-parts",
      name = "ei_quantum-computer",
      prereq = "ei_quantum-computer",
    },
    {
      mod = bridge.mods.py_ht,
      name = "quantum-computer",
      prereq = "quantum",
    },
    {
      mod = bridge.mods.ir3,
      name = "computer-mk3",
      prereq = "ir-electronics-3",
    },
    {
      mod = bridge.mods.bobelectronics,
      name = "advanced-processing-unit",
      prereq = "advanced-electronics-3",
    },
    {
      mod = bridge.mods.yit,
      -- This is moved to prerequisites of custom tech
      -- prereq = "yi-advanced-machines",
      continue = true,
    }, {
      mod = bridge.mods.yi,
      ingredients = {
        {"y_crystal2_combined", 32},
        {"y-conductive-coil-1", 8},
        {"y_structure_electric", 4},
      },
    },
  },
})

add_item({
  short_name = "optic_emitter",
  name = bridge.prefix.."optic-emitter",
  icon = bridge.media_path.."icons/laser.png",
  icon_size = 64, icon_mipmaps = 1,
  prereq = prerequisite,
  subgroup = subgroup,
  allow_productivity = true,
  ingredients = {
    {bridge.item.optic_cable, 2},
    {"advanced-circuit", 1},
  },
  energy_required = 10,
  category = bridge.config.cat_nano_crafting,
  stack_size = 50,
  modded = {
    -- {
    --   mod = bridge.mods.sa,
    --   name = "se-dynamic-emitter",
    --   prereq = "se-dynamic-emitter",
    -- },
    {
      mod = bridge.mods.se,
      name = "se-dynamic-emitter",
      prereq = "se-dynamic-emitter",
    },
    {
      mod = bridge.mods.k2,
      ingredients = {
        {bridge.item.optic_cable, 2},
        {"quartz", 1},
        {"advanced-circuit", 1},
      },
    },
    {
      mod = bridge.mods.ir3,
      name = "helium-laser",
      prereq = "laser-2",
    },
    {
      mod = bridge.mods.bzaluminum,
      name = "ti-sapphire",
      prereq = "laser",
    },
    {
      mod = bridge.mods._248k,
      name = "fu_materials_energy_crystal",
      prereq = "fu_crystal_tech",
    },
    {
      mod = bridge.mods.exind,
      -- prereq = "ei_electronic-parts",
      -- prereq = "ei_fusion-drive",
      -- ingredients = {
      --   {"ei_electronic-parts", 50},
      --   {"ei_fusion-drive", 6},
      -- },
      name = "ei_high-energy-crystal",
      prereq = "ei_high-energy-crystal",
    },
    {
      mod = bridge.mods.py_ht,
      name = "parametric-oscilator",
      prereq = "parametric-oscilator",
    },
    {
      mod = bridge.mods.om_cry,
      name = "basic-oscillo-crystallonic",
      prereq = "omnitech-crystallonics-2",
    },
  },
})

add_item({
  short_name = "emfc",
  name = bridge.prefix.."emfc",
  icon = bridge.media_path.."icons/emfc.png",
  icon_size = 64, icon_mipmaps = 1,
  prereq = prerequisite,
  subgroup = subgroup,
  allow_productivity = true,
  ingredients = {
    {bridge.item.advanced_solenoid, 6},
    {bridge.item.nano_mat, 24},
    {"processing-unit", 1},
  },
  energy_required = 10,
  category = bridge.config.cat_nano_crafting,
  stack_size = 50,
  weight = rocket_lift_weight / 100,
  modded = {
    {
      mod = bridge.mods.sa,
      -- TODO: update with bridge.config.cat_he_crafting
      category = "electromagnetics",
    },
    {
      mod = bridge.mods.k2,
      name = "energy-control-unit",
      prereq = "kr-energy-control-unit",
    },
    {
      mod = bridge.mods.se,
      prereq = bridge.item.nano_mat,
    },
    {
      mod = bridge.mods.ir3,
      name = "field-effector",
      prereq = "ir-force-fields",
    },
    {
      mod = bridge.mods.exind,
      name = "ei_eu-magnet",
      prereq = "ei_high-tech-parts",
    },
    {
      mod = bridge.mods.py_fus,
      -- name = "magnetic-core",
      -- prereq = "magnetic-core",
      name = "sc-unit",
      prereq = "sc-unit",
    },
    {
      mod = bridge.mods.yit,
      prereq = "yi-intermediates",
      continue = true,
    }, {
      mod = bridge.mods.yi,
      ingredients = {
        {bridge.item.advanced_solenoid, 6},
        {"yi_magnetron", 6},
        {"y_structure_element", 10},
      },
    },
    {
      mod = bridge.mods.om_cry,
      name = "electrocrystal",
      prereq = "omnitech-crystallonics-3",
    },
  },
})

add_item({
  short_name = "he_emitter",
  name = bridge.prefix.."high-energy-emitter",
  icon = bridge.media_path.."icons/emitter-he.png",
  icon_size = 64, icon_mipmaps = 1,
  prereq = prerequisite,
  subgroup = subgroup,
  allow_productivity = true,
  ingredients = {
    {bridge.item.emfc, 3},
    {bridge.item.optic_emitter, 3},
    {bridge.item.sc_cable, 5},
    {"processing-unit", 1},
  },
  energy_required = 30,
  stack_size = 20,
  weight = rocket_lift_weight / 50,
  category = bridge.config.cat_nano_crafting,
  modded = {
    {
      mod = bridge.mods.sa,
      -- TODO: update with bridge.config.cat_he_crafting
      category = "electromagnetics",
    },
    {
      mod = bridge.mods.exind,
      prereq = "ei_fusion-drive",
      ingredients = {
        {bridge.item.emfc, 3},
        {bridge.item.optic_emitter, 3},
        {bridge.item.sc_cable, 5},
        {"processing-unit", 1},
        {"ei_fusion-drive", 1},
      },
    },
    {
      mod = bridge.mods.yit,
      prereq = "yi-atomics",
      continue = true,
    }, {
      mod = bridge.mods.yi,
      ingredients = {
        {bridge.item.emfc, 3},
        {bridge.item.optic_emitter, 3},
        {bridge.item.sc_cable, 5},
        {"processing-unit", 1},
        {"y_quantrinum_infused", 6}
      },
    },
  },
})


-- Aliases, fully transparent items without new objects nor recipes
add_item({
  short_name = "best_energy_provider",
  name = "fission-reactor-equipment",
  prereq = "fission-reactor-equipment",
  modded = {
    {
      mod = bridge.mods.ev_pe,
      name = "77-fusion-reactor-mk6-equipment",
      prereq = "77-fusion-reactor-mk6-equipment",
    },
    {
      mod = bridge.mods.sa,
      name = "fusion-reactor-equipment",
      prereq = "fusion-reactor-equipment",
    },
    {
      mod = bridge.mods.k2,
      -- name = "kr-antimatter-reactor",
      name = "antimatter-reactor-equipment",
      prereq = "kr-antimatter-reactor",
    },
    {
      mod = bridge.mods.bobequip,
      name = "fusion-reactor-equipment-4",
      prereq = "earnshaw-theorem",
    },
    {
      mod = bridge.mods.py_ht,
      name = "antimatter",
      prereq = "earnshaw-theorem",
    },
  },
})

add_item({
  short_name = "best_fuel",
  name = "nuclear-fuel",
  prereq = "kovarex-enrichment-process",
  modded = {
    {
      mod = bridge.mods.sa,
      name = "fusion-power-cell",
      prereq = "fusion-reactor",
    },
    {
      mod = bridge.mods.k2,
      -- Or krastorio.recipes.changed_names["charged-antimatter-fuel-cell"] ?!
      name = "charged-antimatter-fuel-cell",
      prereq = "kr-antimatter-reactor",
    },
    -- TODO: check out other mods!
  },
})

add_item({
  short_name = "best_shield",
  name = "energy-shield-mk2-equipment",
  prereq = "energy-shield-mk2-equipment",
  modded = {
    {
      mod = bridge.mods.ev_pe,
      name = "77-energy-shield-mk5-equipment",
      prereq = "77-energy-shield-mk5-equipment",
    },
    {
      mod = bridge.mods.se,
      name = "energy-shield-mk6-equipment",
      prereq = "energy-shield-mk6-equipment",
    },
    {
      mod = bridge.mods.k2,
      name = "energy-shield-mk4-equipment",
      prereq = "kr-energy-shield-mk4-equipment",
    },
    -- TODO: check out other mods!
  },
})
