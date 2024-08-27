local shared = require("shared")
local bridge = require("__Common-Industries__.export")

data:extend({
  -- Big bolt
  {
    type = "item",
    name = shared.big_bolt,
    icon = shared.media_prefix.."graphics/icons/weapons/Bolt-Big.png",
    icon_size = 64, icon_mipmaps = 1,
    subgroup = shared.subg_ammo,
    order = "a-1-bolt-big",
    stack_size = 100,
  },
  {
    type = "recipe",
    name = shared.big_bolt,
    enabled = false,
    ingredients = {
      {"explosives", 2},
      {"steel-plate", 2},
      {"electronic-circuit", 1},
    },
    energy_required = 10,
    result = shared.big_bolt,
    category = "advanced-crafting",
  },

  -- Huge bolt
  {
    type = "item",
    name = shared.huge_bolt,
    icon = shared.media_prefix.."graphics/icons/weapons/Bolt-Huge.png",
    icon_size = 64, icon_mipmaps = 1,
    subgroup = shared.subg_ammo,
    order = "a-2-bolt-huge",
    stack_size = 50,
  },
  {
    type = "recipe",
    name = shared.huge_bolt,
    enabled = false,
    ingredients = {
      {"explosives", 5},
      {"steel-plate", 4},
      {"advanced-circuit", 1},
    },
    energy_required = 30,
    result = shared.huge_bolt,
    category = "advanced-crafting",
  },

  -- Quake projectile
  -- {
  --   type = "item",
  --   name = shared.quake_proj,
  --   icon = icon,
  --   icon_size = 64, icon_mipmaps = 4,
  --   subgroup = shared.subg_ammo,
  --   order = "a-5-quake",
  --   stack_size = 10,
  -- },
  -- {
  --   type = "recipe",
  --   name = shared.quake_proj,
  --   enabled = false,
  --   ingredients = {
  --     {"explosives", 50},
  --     {"steel-plate", 100},
  --     {"radar", 12},
  --     {"processing-unit", 10},
  --   category = "advanced-crafting",
  --   },
  --   result = shared.quake_proj,
  -- },
})


-- Plasma fuel

bridge.add_item({
  short_name = "plasma_fuel",
  name = shared.plasma_ammo,
  icon = shared.media_prefix.."graphics/icons/weapons/Plasma-Fuel.png",
  icon_size = 64, icon_mipmaps = 3,
  prereq = nil,
  subgroup = shared.subg_ammo,
  order = "c-1-plasma-fuel",
  allow_productivity = true,
  ingredients = {
    {type="fluid", name="water", amount=200},
    -- {"battery", 2},
    {"steel-plate", 4},
    {"advanced-circuit", 1},
  },
  energy_required = 30,
  stack_size = 100,
  -- results = {{"iron-ore", 1}, {"copper-ore", 1},},
  category = "chemistry",
  afci_bridged = true,
  modded = {
    {
      mod = bridge.mods.k2,
      prereq = "kr-atmosphere-condensation",
      ingredients = {
        {type="fluid", name="hydrogen", amount=200},
        {"steel-plate", 4},
        {"advanced-circuit", 1},
      },
    },
    {
      mod = bridge.mods.se,
      prereq = "se-space-plasma-generator",
      ingredients = {
        {type="fluid", name="se-plasma-stream", amount=100},
        {"steel-plate", 4},
        {"advanced-circuit", 1},
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
        {type="fluid", name="hydrogen-fluid", amount=200},
        {"steel-plate", 4},
        {"advanced-circuit", 1},
      },
      results = {},
    },
    {
      mod = bridge.mods.exind,
      prereq = "ei_ammonia",
      ingredients = {
        {type="fluid", name="ei_hydrogen-gas", amount=200},
        {"steel-plate", 4},
        {"advanced-circuit", 1},
      },
      results = {},
    },
    {
      mod = bridge.mods.angelspetrochem,
      prereq = "water-chemistry-2",
      ingredients = {
        {type="fluid", name="gas-deuterium", amount=200},
        {"steel-plate", 4},
        {"advanced-circuit", 1},
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
        {type="fluid", name="fu_hydrogen", amount=200},
        {"steel-plate", 4},
        {"advanced-circuit", 1},
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
        {"steel-plate", 4},
        {"advanced-circuit", 1},
      },
      results = {},
    },
  },
}).data_getter()


-- HellStorm fuel

bridge.add_item({
  short_name = "hell_ammo",
  name = shared.hell_ammo,
  icon = shared.media_prefix.."graphics/icons/weapons/Hell-Fuel.png",
  icon_size = 64, icon_mipmaps = 4,
  prereq = nil,
  subgroup = shared.subg_ammo,
  order = "c-2-hellstorm-ammo",
  allow_productivity = true,
  ingredients = {
    {shared.plasma_ammo, 1},
    {shared.melta_ammo, 1},
    {shared.laser_ammo, 1},
    {bridge.get.best_fuel().name, 1},
  },
  energy_required = 60,
  stack_size = 20,
  category = "advanced-crafting",
  afci_bridged = true,
}).data_getter()
