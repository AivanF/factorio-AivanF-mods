local bridge = require("item-utils")

local add_item = bridge.add_item
local prerequisite = bridge.tech.midgame.name
-- local subgroup = bridge.subg_mid
local subgroup = bridge.subg_early

add_item({
  short_name = "meat",
  name = bridge.prefix.."meat",
  icon = bridge.media_path.."icons/meat.png",
  icon_size = 64, icon_mipmaps = 1,
  prereq = prerequisite,
  subgroup = subgroup,
  ingredients = {
    { "wood", 4 },
    { "raw-fish", 4 },
    { type="fluid", name="water", amount=100 },
    -- {type="fluid", name="light-oil", amount=50},
  },
  result_count = 4,
  stack_size = 100,
  energy_required = 5,
  category = bridge.cat_org_crafting,
  modded = {
    {
      mod = bridge.mods.angelsbio,
      name = "bio-raw-meat",
      prereq = "bio-refugium-butchery-1",
    },
    {
      mod = bridge.mods.py_life,
      name = "meat",
      -- prereq = "rendering",
      prereq = "organ-printing",
    },
    {
      mod = bridge.mods.se,
      name = "se-specimen",
      prereq = "se-space-genetics-laboratory",
    },
    {
      mod = bridge.mods.pbb,
      name = "raw-meat",
      prereq = bridge.empty,
    },
    {
      mod = bridge.mods.om_mat,
      ingredients = {
        { type="fluid", name="omniston", amount=100 },
      },
      category = "omnite-extraction-both",
      continue = true,
    },
    {
      mod = bridge.mods.om_cry,
      category = "omniplant",
    },
  },
})

add_item({
  short_name = "solenoid",
  name = bridge.prefix.."solenoid",
  icon = bridge.media_path.."icons/solenoid.png",
  icon_size = 64, icon_mipmaps = 1,
  prereq = prerequisite,
  subgroup = subgroup,
  ingredients = {{ "iron-stick", 4 }, { "copper-cable", 80 }},
  stack_size = 100,
  category = "advanced-crafting",
  modded = {
    {
      mod = bridge.mods.ir3,
      prereq = "ir-steam-power",
      name = "copper-coil",
    },
    {
      mod = bridge.mods._248k,
      prereq = "fu_magnet_tech",
      name = "fu_materials_magnet",
    },
    {
      mod = bridge.mods.py_ht,
      prereq = "basic-electronics",
      continue = true,
    },
    {
      mod = bridge.mods.py_fus,
      name = "ferrite",
    },
    {
      mod = bridge.mods.aaind,
      prereq = "electricity",
    },
  },
})

add_item({
  short_name = "dense_cable",
  name = bridge.prefix.."dense-cable",
  icon = bridge.media_path.."icons/cable-dense.png",
  icon_size = 64, icon_mipmaps = 1,
  prereq = prerequisite,
  subgroup = subgroup,
  ingredients = {{ "copper-cable", 4 }, { "plastic-bar", 1 }},
  stack_size = 100,
  modded = {
    {
      mod = bridge.mods.ir3,
      prereq = "ir-steam-power",
      name = "copper-cable-heavy",
    },
    {
      mod = bridge.mods.exind,
      prereq = "plastics",
      name = "ei_insulated-wire",
    },
    {
      mod = bridge.mods.bzaluminum,
      prereq = "reinforced-cable",
      name = "acsr-cable",
    },
  },
})

add_item({
  short_name = "optic_cable",
  name = bridge.prefix.."optic-cable",
  icon = bridge.media_path.."icons/cable-optic-fiber.png",
  icon_size = 64, icon_mipmaps = 1,
  prereq = prerequisite,
  subgroup = subgroup,
  ingredients = {
    { "copper-cable", 4 },
    { bridge.item.glass, 1 },
    { "plastic-bar", 1 }
  },
  energy_required = 2,
  stack_size = 100,
  modded = {
    {
      mod = bridge.mods.bzsilicon,
      prereq = "fiber-optics",
      name = "optical-fiber",
    },
    {
      mod = bridge.mods.py_cp,
      prereq = "fine-electronics",
      name = "optical-fiber",
    },
    {
      -- FiberGlass reinforced plastic, is it fine?..
      mod = bridge.mods._248k,
      prereq = "fi_materials_tech",
      name = "fi_materials_GFK",
    },
  },
})

add_item({
  short_name = "rubber",
  name = "plastic-bar",
  prereq = "chemical-science-pack",
  category = "chemistry",
  modded = {
    {
      mod = bridge.mods.ir3,
      prereq = "plastics-2",
      name = "rubber",
    },
    {
      mod = bridge.mods.py_pet,
      prereq = "rubber",
      name = "rubber",
    },
  },
})

add_item({
  short_name = "bearing",
  name = "iron-gear-wheel",
  prereq = bridge.empty,
  modded = {
    {
      mod = bridge.mods.se,
      prereq = "se-heavy-bearing",
      name = "se-heavy-bearing",
    },
    {
      mod = bridge.mods.bobplates,
      prereq = "steel-processing",
      name = "steel-bearing",
    },
    {
      mod = bridge.mods.yit,
      prereq = "yi-intermediates",
      continue = true,
    }, {
      mod = bridge.mods.yi,
      name = "y-bluegear",
    },
  },
})

add_item({
  short_name = "car_wheel",
  name = bridge.prefix.."car-wheel",
  icon = bridge.media_path.."icons/car-wheel.png",
  icon_size = 64, icon_mipmaps = 1,
  prereq = prerequisite,
  subgroup = subgroup,
  ingredients = {{ "steel-plate", 8 }, { "plastic-bar", 6 }},
  energy_required = 1,
  category = "advanced-crafting",
})

add_item({
  minor = true,
  short_name = "strong_alloy_powder",
  name = bridge.prefix.."strong-alloy-powder",
  icon = bridge.media_path.."icons/alloy-powder.png",
  icon_size = 64, icon_mipmaps = 1,
  prereq = prerequisite,
  subgroup = subgroup,
  ingredients = {{ "steel-plate", 20 }, { "copper-plate", 4 }, { "sulfur", 1 }, { "coal", 1 }},
  result_count = 20,
  stack_size = 100,
  energy_required = 10,
  category = "chemistry",
  modded = {
    {
      mod = bridge.mods.k2,
      ingredients = {{ "steel-plate", 10 }, { "copper-plate", 4 }, { "imersite-powder", 10 }},
    },
    {
      mod = bridge.mods.exind,
      prereq = "ei_neodium-refining",
      ingredients = {{ "ei_steel-ingot", 15 }, { "ei_lead-ingot", 10 }, { "ei_neodium-ingot", 5 }},
    },
  }
})

add_item({
  short_name = "heavy_material",
  -- name = "steel-plate",
  name = bridge.prefix.."strong-alloy",
  icon = bridge.media_path.."icons/alloy.png",
  icon_size = 64, icon_mipmaps = 1,
  prereq = prerequisite,
  subgroup = subgroup,
  ingredients = {{bridge.item.strong_alloy_powder, 2}},
  stack_size = 100,
  energy_required = 5,
  category = "smelting",
  modded = {
    {
      mod = bridge.mods.se,
      name = "se-iridium-plate",
      prereq = "se-processing-iridium",
      -- name = "se-heavy-composite",
      -- prereq = "se-heavy-composite",
    },
    {
      mod = bridge.mods.ir3,
      name = "electrum-plate-special",
      prereq = "ir-electrum-milestone",
    },
    {
      mod = bridge.mods.angelssmelting,
      name = "invar-alloy",
      prereq = "angels-invar-smelting-1",
    },
    {
      mod = bridge.mods.py_fus,
      name = "super-alloy",
      prereq = "super-alloy",
    },
    {
      mod = bridge.mods.py_raw,
      name = "super-steel",
      prereq = "super-steel-mk01",
    },
    {
      mod = bridge.mods.bztungsten,
      name = "cuw",
      prereq = "tungsten-processing",
    },
    {
      mod = bridge.mods._248k,
      name = "fi_materials_titan",
      prereq = "fi_caster_tech",
    },
    {
      mod = bridge.mods.yit,
      prereq = "yi-intermediates",
      continue = true,
    }, {
      mod = bridge.mods.yi,
      name = "y_structure_element",
    },
    {
      mod = bridge.mods.om_mat,
      name = "omnium-steel-alloy",
      prereq = "steel-processing",
    },
  },
})

add_item({
  short_name = "light_material",
  name = "low-density-structure",
  prereq = "low-density-structure",
  modded = {
    {
      mod = bridge.mods.se,
      name = "se-aeroframe-bulkhead",
      prereq = "se-aeroframe-bulkhead",
    },
    {
      mod = bridge.mods.bzaluminum,
      name = "aluminum-2219",
      prereq = "aerospace-alloys",
    },
    {
      mod = bridge.mods.py_raw,
      name = "duralumin",
      prereq = "alloys-mk02",
    },
    {
      mod = bridge.mods.py_cp,
      name = "kevlar",
      prereq = "kevlar",
    },
    {
      mod = bridge.mods._248k,
      name = "fu_materials_KFK",
      prereq = "fu_KFK_tech",
    },
  },
})

add_item({
  short_name = "advanced_ceramic",
  name = "stone-brick",
  prereq = "low-density-structure",
  modded = {
    {
      mod = bridge.mods.bobplates,
      name = "silicon-nitride",
      prereq = "ceramics",
    },
    {
      mod = bridge.mods.py_ht,
      name = "ceramic",
      prereq = "ceramic",
    },
    {
      mod = bridge.mods.se,
      name = "se-heat-shielding",
      prereq = "se-heat-shielding",
    },
  },
})

add_item({
  short_name = "bci",
  name = bridge.prefix.."brain-computer-interface",
  icon = bridge.media_path.."icons/BCI.png",
  icon_size = 64, icon_mipmaps = 3,
  prereq = prerequisite,
  subgroup = subgroup,
  ingredients = {
    { "low-density-structure", 2 },
    { "advanced-circuit", 5 },
    { bridge.item.dense_cable, 9 },
  },
  energy_required = 5,
  stack_size = 10,
})
