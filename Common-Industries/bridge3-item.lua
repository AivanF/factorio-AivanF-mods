local bridge = require("bridge2-tech")

bridge.group_name = "afci-common-industries"
bridge.subg_early = "afci-early"
bridge.subg_mid   = "afci-midgame"
bridge.subg_late  = "afci-lategame"
bridge.subg_end   = "afci-endgame"


-- TODO: add 2 own recipe categories & related buildings
local cat_nano_crafting = "advanced-crafting"
local cat_he_crafting = "chemistry"
local cat_org_crafting = "chemistry"

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


-- Items
bridge.item = {}
local ordered = 0

-- Generate items API, `bridge.get[short_name]()` returns item_info
local function add_item(item_info)
  ordered = ordered + 1

  item_info.is_bridge_item = true
  item_info.updated = bridge.not_updated
  item_info.order = "abc-"..ordered
  item_info.prerequisite = item_info.prereq -- original custom prereq
  bridge.item[item_info.short_name] = item_info

  item_info.getter = function()
    if item_info.done then
      if item_info.done == bridge.empty then
        error("Recursive add_item "..item_info.short_name)
      end
      return item_info
    end
    bridge.preprocess(item_info)
    -- True prototype name isn't available before preprocessing
    bridge.item[item_info.name] = item_info
    item_info.done = bridge.empty -- Aka false, just to prevent recursion

    -- Materialize required components if needed
    local ing_info
    if bridge.is_new(item_info.name) then
      for _, row in pairs(item_info.ingredients) do
        -- Array, and 1st is an item_info
        if row[1] and row[1].is_bridge_item then
          ing_info = row[1]
          if bridge.is_new(ing_info.name) then
            ing_info.getter()
          end
          row[1] = ing_info.name
        end
        -- Dict, and name is an item_info
        if row.name and row.name.is_bridge_item then
          ing_info = row.name
          if bridge.is_new(ing_info.name) then
            ing_info.getter()
          end
          row[1] = ing_info.name
        end
      end
    end

    -- Preprocess required tech research
    if item_info.prereq.is_bridge_item then
      -- Prerequisite can be a string or another item
      -- If so, let's recursively preprocess it and take its prerequisite
      ing_info = item_info.prereq
      if bridge.is_new(ing_info.name) then
        ing_info.getter()
      end
      item_info.prereq = ing_info.prereq
    end
    -- Materialize required tech research if needed
    if bridge.is_new(item_info.prerequisite) then
      bridge.setup[bridge.tech[item_info.prerequisite].short_name]()
    end
    -- if bridge.is_new(item_info.prereq) then
    --   bridge.setup[bridge.tech[item_info.prereq].short_name]()
    -- end

    -- Adjust results
    local results = item_info.results
    if results then
      table.insert(results, 1, {item_info.name, item_info.result_count or 1})
    end
    -- TODO: remove ores/scrap(SE)/slag(248k) if related startup setting is set

    -- Make actual item + recipe
    if bridge.is_new(item_info.name) then
      if data and data.raw and not data.raw.item[item_info.name] then
        log(bridge.log_prefix.."creating "..item_info.short_name)
        data:extend({
          {
            type = "item",
            name = item_info.name,
            icon = item_info.icon,
            icon_size = item_info.icon_size,
            icon_mipmaps = item_info.icon_mipmaps,
            subgroup = item_info.subgroup,
            order = item_info.order,
            place_result = item_info.place_result,
            stack_size = item_info.stack_size or 20,
          },
          {
            type = "recipe",
            name = item_info.name,
            enabled = item_info.prerequisite == bridge.empty,
            energy_required = item_info.energy_required or 1,
            ingredients = item_info.ingredients,
            result_count = item_info.result_count,
            result = item_info.name,
            results = results,
            main_product = item_info.name,
            category = item_info.category or "crafting",
          },
        })
        -- Note: tech research effects are added in data-final-fixes
        if item_info.builder and bridge.is_new(item_info.builder) then
          -- TODO: materialize builder entity; maybe it's better to consider crafting category
        end
      end
    end

    item_info.done = true
    bridge.item[item_info.name] = item_info
    return item_info
  end
  bridge.get[item_info.short_name] = item_info.getter
end

--[[

Ingredients names and prerequisite can be set as another
previously defined item_info via `bridge.item.NAME`

The modded sections should either:
1. Replace item specifying `name` + `prerequisite`
2. Adjust recipe specifying anything fields excepting name

If ingredients of an item already replaced/adjusted for other mods,
there may be no need to replace item name or adjust ingredients,
however, changing of prerequisite name is recommended to prevent
creation of additional technology research.

Note that no-prerequisite is set by empty string,
this approach is chosen due to stupid `nil` behaviour of Lua.

]]
local prerequisite, subgroup

--- 0. Start
prerequisite = bridge.empty
subgroup = bridge.subg_early
add_item({
  short_name = "sand",
  name = bridge.prefix.."sand",
  icon = bridge.media_path.."icons/sand.png",
  icon_size = 64, icon_mipmaps = 1,
  prereq = prerequisite,
  subgroup = subgroup,
  ingredients = {{ "stone", 1 }},
  result_count = 2,
  stack_size = 100,
  modded = {
    {
      mod = bridge.mods.aaind,
      name = "sand",
      prereq = "sand-processing",
    },
    {
      mod = bridge.mods.k2,
      name = "sand",
      prereq = "kr-stone-processing",
    },
    {
      mod = bridge.mods.bobores,
      name = "quartz",
      prereq = "",
    },
    {
      mod = bridge.mods.exind,
      name = "si_sand",
      prereq = "ei_glass",
    },
    {
      mod = bridge.mods.ir3,
      name = "silica",
      prereq = bridge.empty,
    },
    {
      mod = bridge.mods.py_cp,
      name = "crushed-quartz",
      prereq = "quartz-mk01",
    },
    {
      mod = bridge.mods.py_raw,
      name = "ore-quartz",
      prereq = bridge.empty,
    },
    {
      mod = bridge.mods.bzsilicon,
      name = "silica",
      prereq = "silica-processing",
    },
    {
      mod = bridge.mods._248k,
      name = "fi_crushed_glass_item",
      prereq = "fi_glass_tech",
    },
    {
      mod = bridge.mods.spl_res,
      name = "sand",
      prereq = "",
    },
    {
      mod = bridge.mods.yit,
      prereq = "yi-crushing",
      continue = true,
    }, {
      mod = bridge.mods.yi,
      name = "y_steinmehl",
    },
    {
      mod = bridge.mods.om_mat,
      name = "pulverized-stone",
      prereq = "omnitech-base-impure-extraction",
    },
  },
})


--- 1. Early-game, old technologies, hand crafting
prerequisite = bridge.tech.early.name
subgroup = bridge.subg_early
add_item({
  short_name = "glass",
  name = bridge.prefix.."glass",
  icon = bridge.media_path.."icons/glass.png",
  icon_size = 64, icon_mipmaps = 1,
  prereq = prerequisite,
  subgroup = subgroup,
  ingredients = {{ bridge.item.sand, 4 }},
  stack_size = 100,
  category = "smelting",
  modded = {
    {
      mod = bridge.mods.aaind,
      name = "glass",
      prereq = "glass-processing",
    },
    {
      mod = bridge.mods.angelssmelting,
      name = "glass",
      prereq = "angels-glass-smelting-1",
    },
    {
      mod = bridge.mods.k2,
      name = "glass",
      prereq = "kr-stone-processing",
    },
    {
      mod = bridge.mods.ir3,
      name = "glass",
      prereq = "ir-glass-milestone",
    },
    {
      mod = bridge.mods.exind,
      name = "ei_glass",
      prereq = "ei_glass",
    },
    {
      mod = bridge.mods.py_raw,
      name = "glass",
      prereq = "glass",
    },
    {
      mod = bridge.mods.py_cp,
      name = "flask",
      prereq = "quartz-mk01",
    },
    {
      mod = bridge.mods._248k,
      name = "fi_materials_glass",
      prereq = "fi_glass_tech",
    },
    {
      mod = bridge.mods.spl_res,
      name = "glass",
      prereq = "",
    },
    -- { -- Decided to leave custom glass
    --   mod = bridge.mods.om_cry,
    --   name = "quasi-solid-omnistal",
    --   prereq = "omnitech-crystallonics-2",
    -- },
    -- {
    --   mod = bridge.mods.yit,
    --   prereq = "yi-raw-materials",
    --   continue = true,
    --   -- TODO: I forgot to add the item itself??
    -- },
  },
})
add_item({
  short_name = "wooden_wheel",
  name = bridge.prefix.."wooden-wheel",
  icon = bridge.media_path.."icons/wooden-wheel.png",
  icon_size = 64, icon_mipmaps = 1,
  prereq = prerequisite,
  subgroup = subgroup,
  stack_size = 100,
  ingredients = {{ "wood", 8 }, { "iron-plate", 4 }, { "copper-cable", 8 }},
})
add_item({
  short_name = "metal_wheel",
  name = bridge.prefix.."metal-wheel",
  icon = bridge.media_path.."icons/metal-wheel.png",
  icon_size = 64, icon_mipmaps = 1,
  prereq = prerequisite,
  subgroup = subgroup,
  stack_size = 100,
  ingredients = {{ "steel-plate", 5 }, { "iron-stick", 10 }, { "copper-cable", 10 }},
})
add_item({
  short_name = "faraday_cage",
  name = bridge.prefix.."faraday-cage",
  icon = bridge.media_path.."icons/faraday-cage.png",
  icon_size = 64, icon_mipmaps = 1,
  prereq = prerequisite,
  subgroup = subgroup,
  ingredients = {{ "iron-stick", 20 }, { "copper-cable", 20 }},
  modded = {
    {
      mod = bridge.mods.aaind,
      prereq = "electricity",
    },
    {
      mod = bridge.mods._248k,
      prereq = "electronics",
    },
  },
})


--- 2. Mid-game: more modern technologies, steam-punk, advanced metal alloys
prerequisite = bridge.tech.midgame.name
subgroup = bridge.subg_mid

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
    { type="fluid", name="water", amount=50 },
    -- {type="fluid", name="light-oil", amount=50},
  },
  result_count = 4,
  stack_size = 100,
  category = cat_org_crafting,
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
      prereq = "",
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
  short_name = "brain",
  name = bridge.prefix.."brain",
  icon = bridge.media_path.."icons/brain.png",
  icon_size = 64, icon_mipmaps = 1,
  prereq = prerequisite,
  subgroup = subgroup,
  stack_size = 100,
  ingredients = {
    { bridge.item.meat, 4 },
    { "advanced-circuit", 1 }
  },
  category = cat_org_crafting,
  modded = {
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
      prereq = "",
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
  ingredients = {{ "copper-cable", 8 }, { "plastic-bar", 1 }},
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
  ingredients = {{bridge.item.strong_alloy_powder, 1}},
  stack_size = 100,
  energy_required = 5,
  category = "smelting",
  modded = {
    {
      mod = bridge.mods.se,
      -- name = "se-iridium-plate",
      -- prereq = "se-processing-iridium",
      name = "se-heavy-composite",
      prereq = "se-heavy-composite",
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


--- 3. Late-game: nano-technologies, high-energy, sci-fi
prerequisite = bridge.tech.lategame.name
subgroup = bridge.subg_late

add_item({
  -- Ammo could be used in runtime scripts, so the name must not be changed
  short_name = "plasma_fuel",
  name = bridge.prefix.."plasma-fuel",
  icon = bridge.media_path.."icons/plasma-fuel.png",
  icon_size = 64, icon_mipmaps = 4,
  prereq = prerequisite,
  subgroup = subgroup,
  ingredients = {
    {type="fluid", name="water", amount=500},
    {"battery", 5},
    {"steel-plate", 4}
  },
  -- results = {{"iron-ore", 1}, {"copper-ore", 1},},
  category = "chemistry",
  modded = {
    {
      mod = bridge.mods.k2,
      prereq = "kr-atmosphere-condensation",
      ingredients = {
        {type="fluid", name="hydrogen", amount=500},
        {"steel-plate", 4}
      },
    },
    {
      mod = bridge.mods.se,
      prereq = "se-space-plasma-generator",
      ingredients = {
        {type="fluid", name="se-plasma-stream", amount=500},
        {"steel-plate", 4}
      },
      -- results = { {"se-scrap", 4}, },
    },
    {
      mod = bridge.mods.ir3,
      -- prereq = "ir-hydrogen-battery",
      -- name = "charged-hydrogen-battery",
      -- prereq = "ir-natural-gas-processing",
      prereq = "ir-cryogenics",
      ingredients = {
        {type="fluid", name="hydrogen-fluid", amount=500},
        {"steel-plate", 4}
      },
      results = {},
    },
    {
      mod = bridge.mods.exind,
      prereq = "ei_ammonia",
      ingredients = {
        {type="fluid", name="ei_hydrogen-gas", amount=500},
        {"steel-plate", 4}
      },
      results = {},
    },
    {
      mod = bridge.mods.angelspetrochem,
      prereq = "water-chemistry-2",
      ingredients = {
        {type="fluid", name="gas-deuterium", amount=500},
        {"steel-plate", 4}
      },
      results = {},
    },
    {
      mod = bridge.mods.py_alt,
      prereq = "nuclear-power-mk03",
    },
    {
      mod = bridge.mods._248k,
      prereq = "fu_hydrogen_1_tech",
      ingredients = {
        {type="fluid", name="fu_hydrogen", amount=500},
        {"steel-plate", 4}
      },
      results = {},
    },
    {
      mod = bridge.mods.yit,
      prereq = "yi-capsule",
      continue = true,
    }, {
      mod = bridge.mods.yi,
      ingredients = {
        {"y-raw-fuelnium", 3},
        {"steel-plate", 4}
      },
      results = {},
    },
  },
})
add_item({
  short_name = "he_provider",
  -- name = bridge.prefix.."high-energy-provider",
  name = "fusion-reactor-equipment",
  prereq = "fusion-reactor-equipment",
  modded = {
    {
      mod = bridge.mods.py_ht,
      name = "antimatter",
      prereq = "earnshaw-theorem",
    },
  },
})
add_item({
  short_name = "carbon_fiber",
  name = bridge.prefix.."carbon-fiber",
  icon = bridge.media_path.."icons/carbon-fiber.png",
  icon_size = 64, icon_mipmaps = 1,
  prereq = prerequisite,
  subgroup = subgroup,
  ingredients = {{"coal", 10},},
  stack_size = 100,
  energy_required = 10,
  category = cat_nano_crafting,
  modded = {
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
  },
})
add_item({
  short_name = "sc_cable",
  name = bridge.prefix.."superconductive-cable",
  icon = bridge.media_path.."icons/cable-super.png",
  icon_size = 64, icon_mipmaps = 1,
  prereq = prerequisite,
  subgroup = subgroup,
  ingredients = {
    {bridge.item.carbon_fiber, 3},
    {"copper-cable", 10},
    {"plastic-bar", 2},
  },
  energy_required = 2,
  category = "advanced-crafting",
  stack_size = 100,
  modded = {
    {
      mod = bridge.mods.se,
      name = "se-superconductive-cable",
      prereq = "se-superconductive-cable",
    },
    {
      mod = bridge.mods.k2,
      prereq = "kr-imersium-processing",
      ingredients = {
        {"imersium-plate", 3},
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
  ingredients = {
    {"low-density-structure", 10},
    {bridge.item.glass, 10},
    {bridge.item.carbon_fiber, 10},
  },
  result_count = 10,
  energy_required = 10,
  category = cat_nano_crafting,
  modded = {
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
        {"imersium-plate", 4},
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
  ingredients = {
    {bridge.item.carbon_fiber, 12},
    {bridge.item.glass, 4},
    {bridge.item.faraday_cage, 1},
  },
  stack_size = 100,
  result_count = 4,
  energy_required = 10,
  category = cat_nano_crafting,
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
  ingredients = {
    {bridge.item.quantum_transistor, 64},
    {bridge.item.sc_cable, 16},
    {"plastic-bar", 4},
    {"steel-plate", 4},
  },
  energy_required = 8,
  category = cat_nano_crafting,
  modded = {
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
      results = {},
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
  ingredients = {
    {bridge.item.advanced_solenoid, 6},
    {bridge.item.nano_mat, 24},
    {"advanced-circuit", 1},
  },
  energy_required = 10,
  category = cat_nano_crafting,
  stack_size = 50,
  modded = {
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
  short_name = "optic_emitter",
  name = bridge.prefix.."optic-emitter",
  icon = bridge.media_path.."icons/laser.png",
  icon_size = 64, icon_mipmaps = 1,
  prereq = prerequisite,
  subgroup = subgroup,
  ingredients = {
    {bridge.item.optic_cable, 3},
    {"advanced-circuit", 1},
  },
  energy_required = 10,
  category = cat_nano_crafting,
  stack_size = 50,
  modded = {
    {
      mod = bridge.mods.se,
      name = "se-dynamic-emitter",
      prereq = "se-dynamic-emitter",
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
  short_name = "he_emitter",
  name = bridge.prefix.."high-energy-emitter",
  icon = bridge.media_path.."icons/emitter-he.png",
  icon_size = 64, icon_mipmaps = 1,
  prereq = prerequisite,
  subgroup = subgroup,
  ingredients = {
    {bridge.item.emfc, 3},
    {bridge.item.optic_emitter, 3},
    {bridge.item.sc_cable, 5},
    {"processing-unit", 1},
  },
  energy_required = 30,
  category = cat_nano_crafting,
  modded = {
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
      results = {},
    },
  },
})


--- 4. End-game: extra-high-energy, space-time warping, pure sci-fi
prerequisite = bridge.tech.endgame.name
subgroup = bridge.subg_end

-- TODO: add high-energy factory with 30 nano_mat, 6 quantum_chip, 12 he_emitter

add_item({
  short_name = "st_operator",
  name = bridge.prefix.."space-time-operator",
  icon = bridge.media_path.."icons/spacetime-operator.png",
  icon_size = 64, icon_mipmaps = 1,
  prereq = prerequisite,
  subgroup = subgroup,
  ingredients = {
    {bridge.item.he_emitter, 3},
    {bridge.item.quantum_chip, 5},
    {bridge.item.nano_mat, 8},
  },
  energy_required = 60,
  category = cat_he_crafting,
  modded = {
    {
      mod = bridge.mods.se,
      -- name = "se-naquium-tesseract",
      -- name = "se-naquium-cube",
      prereq = "se-naquium-cube",
      ingredients = {
        {"se-naquium-cube", 1},
        {bridge.item.he_emitter, 3},
        {bridge.item.quantum_chip, 5},
        {bridge.item.nano_mat, 8},
      },
    },
    {
      mod = bridge.mods.ir3,
      -- name = "quantum-ring",
      prereq = "ir-research-2",
      ingredients = {
        {"quantum-ring", 6},
        {bridge.item.he_emitter, 3},
        {bridge.item.quantum_chip, 5},
        {bridge.item.nano_mat, 8},
      },
    },
    {
      mod = bridge.mods.exind,
      prereq = "ei_matter-stabilizer",
      -- name = "ei_matter-stabilizer",
      ingredients = {
        {"ei_matter-stabilizer", 3},
        {bridge.item.he_emitter, 3},
        {bridge.item.quantum_chip, 5},
        {bridge.item.nano_mat, 8},
      },
    },
    {
      mod = bridge.mods.k2,
      prereq = "kr-matter-processing",
      -- name = "matter-stabilizer",
      ingredients = {
        {"matter-stabilizer", 3},
        {bridge.item.he_emitter, 3},
        {bridge.item.quantum_chip, 5},
        {bridge.item.nano_mat, 8},
      },
    },
  },
})
add_item({
  short_name = "ehe_emitter",
  name = bridge.prefix.."extra-high-energy-emitter",
  icon = bridge.media_path.."icons/emitter-ehe.png",
  icon_size = 64, icon_mipmaps = 1,
  prereq = prerequisite,
  subgroup = subgroup,
  ingredients = {
    {bridge.item.st_operator, 5},
    {bridge.item.he_emitter, 3},
  },
  energy_required = 60,
  category = cat_he_crafting,
  modded = {
    {
      mod = bridge.mods.se,
      prereq = bridge.item.st_operator,
    },
    -- {
    --   mod = bridge.mods.ir3,
    --   -- prereq = "ir-transmat",
    --   -- prereq = "ir-research-2",
    -- },
  },
})
add_item({
  short_name = "inter_dim_chip",
  name = bridge.prefix.."inter-dimensional-processor",
  icon = bridge.media_path.."icons/chip-quantum.png", -- TODO: replace
  icon_size = 64, icon_mipmaps = 1,
  prereq = prerequisite,
  subgroup = subgroup,
  ingredients = {
    {bridge.item.st_operator, 1},
    {bridge.item.quantum_chip, 4},
  },
  energy_required = 60,
  category = cat_he_crafting,
  modded = {
    {
      mod = bridge.mods.se,
      name = "se-naquium-processor",
      prereq = "se-naquium-processor",
    },
    {
      mod = bridge.mods.ir3,
      prereq = "ir-research-2",
      ingredients = {
        {bridge.item.st_operator, 1},
        {bridge.item.quantum_chip, 4},
      },
    },
  },
})


return bridge