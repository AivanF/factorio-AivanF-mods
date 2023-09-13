local bridge = require("bridge2-tech")

bridge.group_name = "afci-common-industries"
bridge.subg_early = "afci-early"
bridge.subg_mid   = "afci-midgame"
bridge.subg_late  = "afci-lategame"
bridge.subg_end   = "afci-endgame"


-- TODO: add 2 own recipe categories & related buildings
local cat_nano_crafting = "chemistry"
local cat_he_crafting = "chemistry"

-- TODO: make nano-factory with steel, pipes, fast-inserter, glass.name, electric-engine-unit, laser-turret
--[[
mod = bridge.mods.exind,
cat_nano_crafting = "ei_nano-factory",
prerequisite = "ei_nano-factory",

mod = bridge.mods.py_fus
cat_nano_crafting = "nmf",
prerequisite = "aramid",
]]


-- Items
bridge.item = {}

-- Generate items API, `bridge.get[short_name]()` returns item_info
local function add_item(item_info)
  item_info.is_bridge_item = true
  item_info.updated = "none"
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
    if item_info.prerequisite.is_bridge_item then
      -- Prerequisite coule be a string or another item,
      -- if so, let's recursively preprocess it and take its prerequisite
      ing_info = item_info.prerequisite
      if bridge.is_new(ing_info.name) then
          ing_info.getter()
        end
      item_info.prerequisite = ing_info.prerequisite
    end
    -- Materialize required tech research if needed
    if bridge.is_new(item_info.prerequisite) then
      bridge.setup[bridge.tech[item_info.prerequisite].short_name]()
    end

    -- Adjust results
    -- Make actual item + recipe
    local results = item_info.results
    if results then
      table.insert(results, 1, {item_info.name, item_info.result_count or 1})
    end
    -- TODO: remove scrap+ore if startup setting is set

    -- Make actual item + recipe
    if bridge.is_new(item_info.name) then
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
      -- Note: tech research effects are done in data-updates
      if item_info.builder and bridge.is_new(item_info.builder) then
        -- TODO: materialize builder entity; maybe it's better to consider crafting category
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
  prerequisite = prerequisite,
  subgroup = subgroup,
  ingredients = {{ "stone", 1 }},
  result_count = 2,
  stack_size = 100,
  modded = {
    {
      mod = bridge.mods.aaind,
      name = "sand",
      prerequisite = "sand-processing",
    },
    {
      mod = bridge.mods.k2,
      name = "sand",
      prerequisite = "kr-stone-processing",
    },
    {
      mod = bridge.mods.exind,
      name = "si_sand",
      prerequisite = "ei_glass",
    },
    {
      mod = bridge.mods.ir3,
      name = "silica",
      prerequisite = bridge.empty,
    },
    {
      mod = bridge.mods.py_cp,
      name = "crushed-quartz",
      prerequisite = "quartz-mk01",
    },
    {
      mod = bridge.mods.py_raw,
      name = "ore-quartz",
      prerequisite = bridge.empty,
    },
    {
      mod = bridge.mods.bzsilicon,
      name = "silica",
      prerequisite = "silica-processing",
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
  prerequisite = prerequisite,
  subgroup = subgroup,
  ingredients = {{ bridge.item.sand, 4 }},
  stack_size = 100,
  category = "smelting",
  modded = {
    {
      mod = bridge.mods.aaind,
      name = "glass",
      prerequisite = "glass-processing",
    },
    {
      mod = bridge.mods.k2,
      name = "glass",
      prerequisite = "kr-stone-processing",
    },
    {
      mod = bridge.mods.ir3,
      name = "glass",
      prerequisite = "ir-glass-milestone",
    },
    {
      mod = bridge.mods.exind,
      name = "ei_glass",
      prerequisite = "ei_glass",
    },
    {
      mod = bridge.mods.py_raw,
      name = "glass",
      prerequisite = "glass",
    },
    {
      mod = bridge.mods.py_cp,
      name = "flask",
      prerequisite = "quartz-mk01",
    },
  },
})
add_item({
  short_name = "wooden_wheel",
  name = bridge.prefix.."wooden-wheel",
  icon = bridge.media_path.."icons/wooden-wheel.png",
  icon_size = 64, icon_mipmaps = 1,
  prerequisite = prerequisite,
  subgroup = subgroup,
  stack_size = 100,
  ingredients = {{ "wood", 8 }, { "iron-plate", 4 }, { "copper-cable", 8 }},
})
add_item({
  short_name = "metal_wheel",
  name = bridge.prefix.."metal-wheel",
  icon = bridge.media_path.."icons/metal-wheel.png",
  icon_size = 64, icon_mipmaps = 1,
  prerequisite = prerequisite,
  subgroup = subgroup,
  stack_size = 100,
  ingredients = {{ "steel-plate", 5 }, { "iron-stick", 10 }, { "copper-cable", 10 }},
})
add_item({
  short_name = "faraday_cage",
  name = bridge.prefix.."faraday-cage",
  icon = bridge.media_path.."icons/faraday-cage.png",
  icon_size = 64, icon_mipmaps = 1,
  prerequisite = prerequisite,
  subgroup = subgroup,
  ingredients = {{ "iron-stick", 20 }, { "copper-cable", 20 }},
  modded = {
    {
      mod = bridge.mods.aaind,
      prerequisite = "electricity",
    },
  },
})


--- 2. Mid-game: more modern technologies, steam-punk, advanced metal alloys
prerequisite = bridge.tech.midgame.name
subgroup = bridge.subg_mid

add_item({
  short_name = "solenoid",
  name = bridge.prefix.."solenoid",
  icon = bridge.media_path.."icons/solenoid.png",
  icon_size = 64, icon_mipmaps = 1,
  prerequisite = prerequisite,
  subgroup = subgroup,
  ingredients = {{ "iron-stick", 4 }, { "copper-cable", 80 }},
  stack_size = 100,
  category = "advanced-crafting",
  modded = {
    {
      mod = bridge.mods.ir3,
      prerequisite = "ir-steam-power",
      name = "copper-coil",
    },
    {
      mod = bridge.mods.aaind,
      prerequisite = "electricity",
    },
  },
})
add_item({
  short_name = "rubber",
  name = "plastic-bar",
  prerequisite = "chemical-science-pack",
  category = "chemistry",
  modded = {
    {
      mod = bridge.mods.ir3,
      prerequisite = "plastics-2",
      name = "rubber",
    },
    {
      mod = bridge.mods.py_pet,
      prerequisite = "rubber",
      name = "rubber",
    },
  },
})
add_item({
  short_name = "bearing",
  name = "iron-gear-wheel",
  prerequisite = bridge.empty,
  modded = {
    -- TODO: add SE!
    {
      mod = bridge.mods.bobplates,
      prerequisite = "steel-processing",
      name = "steel-bearing",
    },
  },
})
add_item({
  short_name = "car_wheel",
  name = bridge.prefix.."car-wheel",
  icon = bridge.media_path.."icons/car-wheel.png",
  icon_size = 64, icon_mipmaps = 1,
  prerequisite = prerequisite,
  subgroup = subgroup,
  ingredients = {{ "steel-plate", 8 }, { "plastic-bar", 6 }},
  category = "advanced-crafting",
})
add_item({
  short_name = "strong_alloy_powder",
  name = bridge.prefix.."strong-alloy-powder",
  icon = bridge.media_path.."icons/alloy-powder.png",
  icon_size = 64, icon_mipmaps = 1,
  prerequisite = prerequisite,
  subgroup = subgroup,
  ingredients = {{ "steel-plate", 20 }, { "copper-plate", 4 }, { "sulfur", 1 }, { "coal", 1 }},
  result_count = 20,
  stack_size = 100,
  energy_required = 10,
  category = "chemistry",
  modded = {
    {
      mod = bridge.mods.exind,
      prerequisite = "ei_neodium-refining",
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
  prerequisite = prerequisite,
  subgroup = subgroup,
  ingredients = {{bridge.item.strong_alloy_powder, 1}},
  stack_size = 100,
  energy_required = 5,
  category = "smelting",
  modded = {
    {
      mod = bridge.mods.se,
      name = "se-iridium-plate",
      prerequisite = "se-processing-iridium",
    },
    {
      mod = bridge.mods.ir3,
      name = "electrum-plate-special",
      prerequisite = "ir-electrum-milestone",
    },
    {
      mod = bridge.mods.angelssmelting,
      name = "invar-alloy",
      prerequisite = "angels-invar-smelting-1",
    },
    {
      mod = bridge.mods.py_fus,
      name = "super-alloy",
      prerequisite = "super-alloy",
    },
    {
      mod = bridge.mods.py_raw,
      name = "super-steel",
      prerequisite = "super-steel-mk01",
    },
    {
      mod = bridge.mods.bztungsten,
      name = "cuw",
      prerequisite = "tungsten-processing",
    },
  },
})
add_item({
  short_name = "light_material",
  name = "low-density-structure",
  prerequisite = "low-density-structure",
  modded = {
    {
      mod = bridge.mods.se,
      name = "se-aeroframe-bulkhead",
      prerequisite = "se-aeroframe-bulkhead",
    },
    {
      mod = bridge.mods.bzaluminum,
      name = "aluminum-2219",
      prerequisite = "aerospace-alloys",
    },
  },
})
add_item({
  short_name = "dense_cable",
  name = bridge.prefix.."dense-cable",
  icon = bridge.media_path.."icons/cable-dense.png",
  icon_size = 64, icon_mipmaps = 1,
  prerequisite = prerequisite,
  subgroup = subgroup,
  ingredients = {{ "copper-cable", 8 }, { "plastic-bar", 1 }},
  stack_size = 100,
  modded = {
    {
      mod = bridge.mods.ir3,
      prerequisite = "ir-steam-power",
      name = "copper-cable-heavy",
    },
    {
      mod = bridge.mods.exind,
      prerequisite = "plastics",
      name = "ei_insulated-wire",
    },
    {
      mod = bridge.mods.bzaluminum,
      prerequisite = "reinforced-cable",
      name = "acsr-cable",
    },
  },
})
add_item({
  short_name = "optic_cable",
  name = bridge.prefix.."optic-cable",
  icon = bridge.media_path.."icons/cable-optic-fiber.png",
  icon_size = 64, icon_mipmaps = 1,
  prerequisite = prerequisite,
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
      prerequisite = "fiber-optics",
      name = "optical-fiber",
    },
    {
      mod = bridge.mods.py_cp,
      prerequisite = "fine-electronics",
      name = "optical-fiber",
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
  prerequisite = prerequisite,
  subgroup = subgroup,
  ingredients = {
    {type="fluid", name="water", amount=50},
    {"battery", 5},
    {"steel-plate", 4}
  },
  -- results = {{"iron-ore", 1}, {"copper-ore", 1},},
  category = "chemistry",
  modded = {
    {
      mod = bridge.mods.k2,
      prerequisite = "kr-atmosphere-condensation",
      ingredients = {
        {type="fluid", name="hydrogen", amount=50},
        {"steel-plate", 4}
      },
    },
    {
      mod = bridge.mods.se,
      -- results = { {"se-scrap", 4}, },
    },
    {
      mod = bridge.mods.ir3,
      -- prerequisite = "ir-hydrogen-battery",
      -- name = "charged-hydrogen-battery",
      -- prerequisite = "ir-natural-gas-processing",
      prerequisite = "ir-cryogenics",
      ingredients = {
        {type="fluid", name="hydrogen-fluid", amount=50},
        {"steel-plate", 4}
      },
      results = {},
    },
    {
      mod = bridge.mods.exind,
      prerequisite = "ei_ammonia",
      ingredients = {
        {type="fluid", name="ei_hydrogen-gas", amount=50},
        {"steel-plate", 4}
      },
      results = {},
    },
    {
      mod = bridge.mods.angelspetrochem,
      prerequisite = "water-chemistry-2",
      ingredients = {
        {type="fluid", name="gas-deuterium", amount=50},
        {"steel-plate", 4}
      },
      results = {},
    },
    {
      mod = bridge.mods.py_alt,
      prerequisite = "nuclear-power-mk03",
    },
  },
})
add_item({
  short_name = "carbon_fiber",
  name = bridge.prefix.."carbon-fiber",
  icon = bridge.media_path.."icons/carbon-fiber.png",
  icon_size = 64, icon_mipmaps = 1,
  prerequisite = prerequisite,
  subgroup = subgroup,
  ingredients = {{"coal", 10},},
  stack_size = 100,
  energy_required = 10,
  category = cat_nano_crafting,
  modded = {
    {
      mod = bridge.mods.ir3,
      name = "carbon-foil",
      prerequisite = "ir-graphene",
    },
    {
      mod = bridge.mods.exind,
      name = "ei_carbon-nanotube",
      prerequisite = "ei_nano-factory",
    },
    {
      mod = bridge.mods.py_alt,
      name = "carbon-nanotube",
      prerequisite = "carbon-nanotube",
    },
    {
      mod = bridge.mods.bzcarbon,
      name = "nanotubes",
      prerequisite = "nanotubes",
    },
  },
})
add_item({
  short_name = "sc_cable",
  name = bridge.prefix.."superconductive-cable",
  icon = bridge.media_path.."icons/cable-super.png",
  icon_size = 64, icon_mipmaps = 1,
  prerequisite = prerequisite,
  subgroup = subgroup,
  ingredients = {
    {bridge.item.carbon_fiber, 3},
    {"copper-cable", 10},
    {"plastic-bar", 2},
  },
  energy_required = 2,
  category = "advanced-crafting",
  modded = {
    {
      mod = bridge.mods.se,
      name = "se-superconductive-cable",
      prerequisite = "se-superconductive-cable",
    },
    {
      mod = bridge.mods.k2,
      prerequisite = "kr-imersium-processing",
      ingredients = {
        {"imersium-plate", 3},
        {"copper-cable", 10},
        {"plastic-bar", 2},
      },
    },
    {
      mod = bridge.mods.py_fus,
      name = "sc-wire",
      prerequisite = "magnetic-core",
    },
  },
})
add_item({
  short_name = "advanced_solenoid",
  name = bridge.prefix.."advanced-solenoid",
  icon = bridge.media_path.."icons/solenoid-advanced.png",
  icon_size = 64, icon_mipmaps = 1,
  prerequisite = prerequisite,
  subgroup = subgroup,
  ingredients = {
    {"steel-plate", 2},
    {bridge.item.sc_cable, 10},
    {"battery", 5},
  },
  -- results = {{"iron-ore", 1}, {"copper-ore", 1}},
  category = "advanced-crafting",
  modded = {
    {
      mod = bridge.mods.se,
      name = "se-holmium-solenoid",
      prerequisite = "se-holmium-solenoid",
    },
    {
      mod = bridge.mods.ir3,
      prerequisite = "ir-force-fields",
      name = "carbon-coil",
    },
    {
      mod = bridge.mods.exind,
      name = "ei_magnet",
      prerequisite = "ei_high-tech-parts",

      -- prerequisite = "ei_neodium-refining",
      -- ingredients = {
      --   {"ei_neodym-plate", 5},
      --   {"copper-cable", 80},
      -- },
    },
    {
      mod = bridge.mods.py_fus,
      prerequisite = "magnetic-core",
      name = "sc-coil",
    },
  },
})
add_item({
  short_name = "nano_mat",
  name = bridge.prefix.."nano-material",
  icon = bridge.media_path.."icons/nanomat.png",
  icon_size = 64, icon_mipmaps = 1,
  prerequisite = prerequisite,
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
      prerequisite = "se-nanomaterial",
    },
    {
      mod = bridge.mods.ir3,
      name = "nanoglass",
      prerequisite = "ir-graphene",
    },
    {
      mod = bridge.mods.exind,
      name = "ei_carbon-structure",
      prerequisite = "ei_nano-factory",
    },
    {
      mod = bridge.mods.k2,
      prerequisite = "kr-imersium-processing",
      ingredients = {
        {"low-density-structure", 10},
        {"imersium-plate", 4},
        {"silicon", 10},
      },
    },
    {
      mod = bridge.mods.bzcarbon,
      prerequisite = "graphene",
      ingredients = {
        {bridge.item.glass, 10},
        {"graphene", 10},
        {"low-density-structure", 10},
      },
    },
    {
      mod = bridge.mods.py_alt,
      name = "nano-mesh",
      prerequisite = "nano-mesh",
    },
  },
})
add_item({
  short_name = "quantum_transistor",
  name = bridge.prefix.."quantum-transistor",
  icon = bridge.media_path.."icons/transistor-quantum.png",
  icon_size = 64, icon_mipmaps = 1,
  prerequisite = prerequisite,
  subgroup = subgroup,
  ingredients = {
    {bridge.item.carbon_fiber, 12},
    {bridge.item.glass, 4},
    {bridge.item.faraday_cage, 1},
  },
  result_count = 4,
  energy_required = 10,
  category = cat_nano_crafting,
})
add_item({
  short_name = "quantum_chip",
  name = bridge.prefix.."quantum-chip",
  icon = bridge.media_path.."icons/chip-quantum.png",
  icon_size = 64, icon_mipmaps = 1,
  prerequisite = prerequisite,
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
      prerequisite = "se-quantum-processor",
    },
    {
      mod = bridge.mods.k2,
      name = "kr-quantum-computer",
      prerequisite = "kr-quantum-computer",
    },
    {
      mod = bridge.mods.exind,
      -- name = "ei_eu-circuit",
      -- prerequisite = "ei_high-tech-parts",
      name = "ei_quantum-computer",
      prerequisite = "ei_quantum-computer",
    },
    {
      mod = bridge.mods.py_ht,
      name = "quantum-computer",
      prerequisite = "quantum",
    },
    {
      mod = bridge.mods.ir3,
      name = "computer-mk3",
      prerequisite = "ir-electronics-3",
    },
    {
      mod = bridge.mods.bobelectronics,
      name = "advanced-processing-unit",
      prerequisite = "advanced-electronics-3",
    },
  },
})
add_item({
  short_name = "emfc",
  name = bridge.prefix.."emfc",
  icon = bridge.media_path.."icons/emfc.png",
  icon_size = 64, icon_mipmaps = 1,
  prerequisite = prerequisite,
  subgroup = subgroup,
  ingredients = {
    {bridge.item.advanced_solenoid, 6},
    {bridge.item.nano_mat, 24},
    {"low-density-structure", 10},
  },
  energy_required = 10,
  modded = {
    {
      mod = bridge.mods.k2,
      name = "energy-control-unit",
      prerequisite = "kr-energy-control-unit",
    },
    {
      mod = bridge.mods.se,
      prerequisite = bridge.item.nano_mat,
    },
    {
      mod = bridge.mods.ir3,
      name = "field-effector",
      prerequisite = "ir-force-fields",
    },
    {
      mod = bridge.mods.exind,
      name = "ei_eu-magnet",
      prerequisite = "ei_high-tech-parts",
    },
    {
      mod = bridge.mods.py_fus,
      -- name = "magnetic-core",
      -- prerequisite = "magnetic-core",
      name = "sc-unit",
      prerequisite = "sc-unit",
    },
  },
  category = cat_nano_crafting,
})
add_item({
  short_name = "he_emitter",
  name = bridge.prefix.."high-energy-emitter",
  icon = bridge.media_path.."icons/emitter-he.png",
  icon_size = 64, icon_mipmaps = 1,
  prerequisite = prerequisite,
  subgroup = subgroup,
  ingredients = {
    {bridge.item.emfc, 5},
    {bridge.item.sc_cable, 30},
    {"processing-unit", 5},
  },
  energy_required = 20,
  category = cat_nano_crafting,
  modded = {
    {
      mod = bridge.mods.se,
      name = "se-dynamic-emitter",
      prerequisite = "se-dynamic-emitter",
    },
    {
      mod = bridge.mods.ir3,
      -- name = "helium-laser",
      -- prerequisite = "laser-2",
      prerequisite = bridge.item.emfc,
      ingredients = {
        {bridge.item.emfc, 5},
        {"helium-laser", 3},
        {"processing-unit", 8},
      },
    },
    {
      mod = bridge.mods.exind,
      -- prerequisite = "ei_electronic-parts",
      prerequisite = "ei_fusion-drive",
      ingredients = {
        {"ei_electronic-parts", 50},
        {"ei_fusion-drive", 6}
      },
      -- name = "ei_high-energy-crystal",
      -- prerequisite = "ei_high-energy-crystal",
    },
    {
      mod = bridge.mods.py_ht,
      -- name = "parametric-oscilator",
      prerequisite = "parametric-oscilator",
      ingredients = {
        {bridge.item.emfc, 3},
        {"parametric-oscilator", 1},
        {"processing-unit", 5},
      },
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
  prerequisite = prerequisite,
  subgroup = subgroup,
  ingredients = {
    {bridge.item.he_emitter, 3},
    {bridge.item.quantum_chip, 5},
    {bridge.item.nano_mat, 8},
  },
  energy_required = 20,
  category = cat_he_crafting,
  modded = {
    {
      mod = bridge.mods.se,
      name = "se-naquium-cube",
      -- name = "se-naquium-tesseract",
      prerequisite = "se-naquium-cube",
    },
    {
      mod = bridge.mods.ir3,
      -- name = "quantum-ring",
      -- prerequisite = "ir-research-2",
      ingredients = {
        {bridge.item.he_emitter, 3},
        {"quantum-ring", 5},
        {bridge.item.nano_mat, 8},
      },
    },
    -- TODO: make matter-stabilizers just ingredients?
    {
      mod = bridge.mods.exind,
      name = "ei_matter-stabilizer",
      prerequisite = "ei_matter-stabilizer",
    },
    {
      mod = bridge.mods.k2,
      name = "matter-stabilizer",
      prerequisite = "kr-matter-processing",
    },
  },
})
add_item({
  short_name = "ehe_emitter",
  name = bridge.prefix.."extra-high-energy-emitter",
  icon = bridge.media_path.."icons/emitter-ehe.png",
  icon_size = 64, icon_mipmaps = 1,
  prerequisite = prerequisite,
  subgroup = subgroup,
  ingredients = {
    {bridge.item.st_operator, 5},
    {bridge.item.he_emitter, 3},
  },
  energy_required = 20,
  category = cat_he_crafting,
  modded = {
    {
      mod = bridge.mods.se,
      prerequisite = bridge.item.st_operator,
    },
    {
      mod = bridge.mods.ir3,
      -- prerequisite = "ir-transmat",
      -- prerequisite = "ir-research-2",
    },
  },
})
add_item({
  short_name = "inter_dim_chip",
  name = bridge.prefix.."inter-dimensional-processor",
  icon = bridge.media_path.."icons/chip-quantum.png", -- TODO: replace
  icon_size = 64, icon_mipmaps = 1,
  prerequisite = prerequisite,
  subgroup = subgroup,
  ingredients = {
    {bridge.item.st_operator, 1},
    {bridge.item.quantum_chip, 4},
  },
  energy_required = 8,
  category = cat_he_crafting,
  modded = {
    {
      mod = bridge.mods.se,
      name = "se-naquium-processor",
      prerequisite = "se-naquium-processor",
    },
    {
      mod = bridge.mods.ir3,
      prerequisite = "ir-research-2",
      ingredients = {
        {bridge.item.st_operator, 1},
        {bridge.item.quantum_chip, 4},
      },
    },
  },
})


return bridge