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
    stack_size = 50,
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
    stack_size = 20,
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
  -- Ammo could be used in runtime scripts, so the name must not be changed
  short_name = "plasma_fuel",
  name = bridge.prefix.."plasma-fuel",
  icon = shared.media_prefix.."graphics/icons/weapons/Plasma-Fuel.png",
  icon_size = 64, icon_mipmaps = 1,
  prereq = nil,
  subgroup = shared.subg_ammo,
  order = "c-1-plasma-fuel",
  ingredients = {
    {type="fluid", name="water", amount=200},
    {"battery", 5},
    {"steel-plate", 4}
  },
  energy_required = 30,
  stack_size = 100,
  -- results = {{"iron-ore", 1}, {"copper-ore", 1},},
  category = "chemistry",
  modded = {
    {
      mod = bridge.mods.k2,
      prereq = "kr-atmosphere-condensation",
      ingredients = {
        {type="fluid", name="hydrogen", amount=200},
        {"steel-plate", 4}
      },
    },
    {
      mod = bridge.mods.se,
      prereq = "se-space-plasma-generator",
      ingredients = {
        {type="fluid", name="se-plasma-stream", amount=100},
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
        {type="fluid", name="hydrogen-fluid", amount=200},
        {"steel-plate", 4}
      },
      results = {},
    },
    {
      mod = bridge.mods.exind,
      prereq = "ei_ammonia",
      ingredients = {
        {type="fluid", name="ei_hydrogen-gas", amount=200},
        {"steel-plate", 4}
      },
      results = {},
    },
    {
      mod = bridge.mods.angelspetrochem,
      prereq = "water-chemistry-2",
      ingredients = {
        {type="fluid", name="gas-deuterium", amount=200},
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
        {type="fluid", name="fu_hydrogen", amount=200},
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
}).data_getter()
