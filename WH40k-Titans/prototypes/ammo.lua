local shared = require("shared")
local bridge = require("__Common-Industries__.export")

-- local rocket_lift_weight = data.raw["utility-constants"]["default"].rocket_lift_weight
local rocket_lift_weight = 1000000


bridge.add_item({
  short_name = "big_bolt",
  name = shared.big_bolt,
  icon = shared.media_prefix.."graphics/icons/weapons/Bolt-Big.png",
  icon_size = 64, icon_mipmaps = 3,
  prereq = nil,
  subgroup = shared.subg_ammo,
  order = "a-1-bolt-big",
  allow_productivity = true,
  ingredients = {
    {type="item", name="explosives", amount=2},
    {type="item", name="steel-plate", amount=2},
    {type="item", name="electronic-circuit", amount=1},
  },
  modded = {
    {
      mod = bridge.mods.sa,
      ingredients = {
        {type="item", name="explosives", amount=1},
        {type="item", name="tungsten-plate", amount=1},
        {type="item", name="electronic-circuit", amount=1},
        -- {type="item", name="supercapacitor", amount=1},
      },
    },
  },
  energy_required = 10,
  stack_size = 100,
  weight = rocket_lift_weight / 500,
  category = "advanced-crafting",
  bridge_force_create = true,
}).data_getter()


-- data:extend({
  -- Quake projectile
  -- {
  --   type = "item",
  --   name = shared.quake_proj,
  --   icon = icon,
  --   icon_size = 64, icon_mipmaps = 3,
  --   subgroup = shared.subg_ammo,
  --   order = "a-4-quake",
  --   stack_size = 10,
  -- },
  -- {
  --   type = "recipe",
  --   name = shared.quake_proj,
  --   enabled = false,
  --   ingredients = {
  --     {type="item", name="explosives", amount=50},
  --     {type="item", name="steel-plate", amount=100},
  --     {type="item", name="radar", amount=12},
  --     {type="item", name="processing-unit", amount=10},
  --   category = "advanced-crafting",
  --   },
  --   results = {{type="item", name=shared.quake_proj, amount=1}},
  -- },
-- })


-- Empty Ballistic Missile

bridge.add_item({
  short_name = "empty_missile",
  name = shared.empty_missile_ammo,
  icon = shared.media_prefix.."graphics/icons/weapons/Missile-Empty.png",
  icon_size = 64, icon_mipmaps = 3,
  prereq = nil,
  subgroup = shared.subg_ammo,
  order = "a-5-empty-missile",
  allow_productivity = false,
  ingredients = {
    {type="item", name="artillery-shell", amount=1},
    -- Add a strong metal?
    {type="item", name="processing-unit", amount=1},
    {type="item", name=afci_bridge.get.rocket_engine().name, amount=1},
    {type="item", name="rocket-fuel", amount=50},
  },
  stack_size = 5,
  weight = rocket_lift_weight / 200,
  energy_required = 120,
  category = "advanced-crafting",
  bridge_force_create = true,
}).data_getter()


-- DeathStrike Missile / Doom Rocket

bridge.add_item({
  short_name = "doom_missile",
  name = shared.doom_missile_ammo,
  icon = shared.media_prefix.."graphics/icons/weapons/Missile-DeathStrike.png",
  icon_size = 64, icon_mipmaps = 3,
  prereq = nil,
  subgroup = shared.subg_ammo,
  order = "a-6-doom-missile",
  allow_productivity = false,
  ingredients = {
    {type="item", name=shared.empty_missile_ammo, amount=1},
    {type="item", name="uranium-235", amount=50},
    {type="item", name="explosives", amount=10},
  },
  stack_size = 1,
  weight = rocket_lift_weight / 100,
  energy_required = 120,
  category = "advanced-crafting",
  bridge_force_create = true,
}).data_getter()


-- Plasma Missile

bridge.add_item({
  short_name = "plasma_missile",
  name = shared.plasma_missile_ammo,
  icon = shared.media_prefix.."graphics/icons/weapons/Missile-Plasma.png",
  icon_size = 64, icon_mipmaps = 3,
  prereq = nil,
  subgroup = shared.subg_ammo,
  order = "a-7-plasma-missile",
  allow_productivity = false,
  ingredients = {
    {type="item", name=shared.empty_missile_ammo, amount=5},
    {type="item", name=afci_bridge.get.he_emitter().name, amount=1},
    {type="item", name=afci_bridge.get.emfc().name, amount=1},
    {type="item", name=shared.plasma_ammo, amount=12 * 5},
  },
  result_count = 5,
  stack_size = 1,
  weight = rocket_lift_weight / 100,
  energy_required = 120 * 5 * 2,
  category = "advanced-crafting",
  bridge_force_create = true,
}).data_getter()


-- Warp Missile

bridge.add_item({
  short_name = "warp_missile",
  name = shared.warp_missile_ammo,
  icon = shared.media_prefix.."graphics/icons/weapons/Missile-Warp.png",
  icon_size = 64, icon_mipmaps = 3,
  prereq = nil,
  subgroup = shared.subg_ammo,
  order = "a-8-warp-missile",
  allow_productivity = false,
  ingredients = {
    {type="item", name=afci_bridge.get.empty_missile().name, amount=5},
    {type="item", name=shared.realityctrl, amount=1},
  },
  result_count = 5,
  stack_size = 1,
  weight = rocket_lift_weight / 100,
  energy_required = 120 * 5 * 4,
  category = "advanced-crafting",
  bridge_force_create = true,
}).data_getter()


-- Plasma ammo

bridge.add_item({
  short_name = "plasma_fuel",
  name = shared.plasma_ammo,
  icon = shared.media_prefix.."graphics/icons/weapons/Plasma-Ammo.png",
  icon_size = 64, icon_mipmaps = 3,
  prereq = nil,
  subgroup = shared.subg_ammo,
  order = "c-3-plasma-fuel",
  allow_productivity = true,
  ingredients = {
    {type="fluid", name="water", amount=200},
    -- {type="item", name="battery", amount=2},
    {type="item", name="steel-plate", amount=4},
    {type="item", name="advanced-circuit", amount=1},
  },
  energy_required = 30,
  stack_size = 100,
  weight = rocket_lift_weight / 400,
  -- results = {{type="item", name="iron-ore", amount=1}, {type="item", name="copper-ore", amount=1},},
  category = "chemistry",
  bridge_force_create = true,
  modded = {
    {
      mod = bridge.mods.sa,
      ingredients = {
        {type="item", name="supercapacitor", amount=1},
        {type="item", name="steel-plate", amount=2},
        {type="fluid", name="water", amount=200},
      },
      category = "electromagnetics",
    },
    {
      mod = bridge.mods.k2,
      prereq = "kr-atmosphere-condensation",
      ingredients = {
        {type="fluid", name="hydrogen", amount=200},
        {type="item", name="steel-plate", amount=4},
        {type="item", name="advanced-circuit", amount=1},
      },
    },
    {
      mod = bridge.mods.se,
      prereq = "se-space-plasma-generator",
      ingredients = {
        {type="fluid", name="se-plasma-stream", amount=100},
        {type="item", name="steel-plate", amount=4},
        {type="item", name="advanced-circuit", amount=1},
      },
      -- results = { {type="item", name="se-scrap", amount=4}, },
    },
    {
      mod = bridge.mods.ir3,
      -- prereq = "ir-hydrogen-battery",
      -- name = "charged-hydrogen-battery",
      -- prereq = "ir-natural-gas-processing",
      prereq = "ir-cryogenics",
      ingredients = {
        {type="fluid", name="hydrogen-fluid", amount=200},
        {type="item", name="steel-plate", amount=4},
        {type="item", name="advanced-circuit", amount=1},
      },
    },
    {
      mod = bridge.mods.exind,
      prereq = "ei_ammonia",
      ingredients = {
        {type="fluid", name="ei_hydrogen-gas", amount=200},
        {type="item", name="steel-plate", amount=4},
        {type="item", name="advanced-circuit", amount=1},
      },
    },
    {
      mod = bridge.mods.angelspetrochem,
      prereq = "water-chemistry-2",
      ingredients = {
        {type="fluid", name="gas-deuterium", amount=200},
        {type="item", name="steel-plate", amount=4},
        {type="item", name="advanced-circuit", amount=1},
      },
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
        {type="item", name="steel-plate", amount=4},
        {type="item", name="advanced-circuit", amount=1},
      },
    },
    {
      mod = bridge.mods.yit,
      prereq = "yi-capsule",
      continue = true,
    }, {
      mod = bridge.mods.yi,
      ingredients = {
        {type="item", name="y-raw-fuelnium", amount=3},
        {type="item", name="steel-plate", amount=4},
        {type="item", name="advanced-circuit", amount=1},
      },
    },
  },
}).data_getter()


-- Laser ammo

bridge.add_item({
  short_name = "laser_ammo",
  name = shared.laser_ammo,
  icon = shared.media_prefix.."graphics/icons/weapons/Laser-Ammo.png",
  icon_size = 64, icon_mipmaps = 3,
  prereq = nil,
  subgroup = shared.subg_ammo,
  order = "c-1-laser-ammo",
  allow_productivity = true,
  ingredients = {
    {type="item", name="battery", amount=2},
    {type="item", name="electronic-circuit", amount=1},
    {type="item", name="steel-plate", amount=1},
  },
  modded = {
    {
      mod = bridge.mods.sa,
      ingredients = {
        {type="item", name="supercapacitor", amount=1},
        {type="item", name="steel-plate", amount=1},
      },
      category = "electromagnetics",
    },
    {
      mod = bridge.mods.k2,
      ingredients = {
        {type="item", name="lithium-sulfur-battery", amount=2},
        {type="item", name="electronic-circuit", amount=1},
        {type="item", name="steel-plate", amount=1},
      },
    },
    {
      mod = bridge.mods.py_alt,
      ingredients = {
        {"battery-mk01", 2},
        {type="item", name="electronic-circuit", amount=1},
        {type="item", name="steel-plate", amount=1},
      },
    },
  },
  energy_required = 30,
  stack_size = 100,
  weight = rocket_lift_weight / 500,
  category = "advanced-crafting",
  bridge_force_create = true,
}).data_getter()


-- Melta ammo

bridge.add_item({
  short_name = "melta_ammo",
  name = shared.melta_ammo,
  icon = shared.media_prefix.."graphics/icons/weapons/Melta-Ammo.png",
  icon_size = 64, icon_mipmaps = 3,
  prereq = nil,
  subgroup = shared.subg_ammo,
  order = "c-2-melta-ammo",
  allow_productivity = true,
  ingredients = {
    {type="item", name="uranium-fuel-cell", amount=1},
    {type="item", name="rocket-fuel", amount=1},
    {type="item", name="advanced-circuit", amount=1},
    {type="item", name="steel-plate", amount=1},
  },
  energy_required = 30,
  stack_size = 100,
  weight = rocket_lift_weight / 200,
  category = "advanced-crafting",
  bridge_force_create = true,
}).data_getter()


-- HellStorm ammo

bridge.add_item({
  short_name = "hell_ammo",
  name = shared.hell_ammo,
  icon = shared.media_prefix.."graphics/icons/weapons/Hell-Ammo.png",
  icon_size = 64, icon_mipmaps = 3,
  prereq = nil,
  subgroup = shared.subg_ammo,
  order = "c-4-hellstorm-ammo",
  allow_productivity = true,
  ingredients = {
    {type="item", name=shared.plasma_ammo, amount=1},
    {type="item", name=shared.melta_ammo, amount=1},
    {type="item", name=shared.laser_ammo, amount=1},
    {type="item", name=bridge.get.best_fuel().name, amount=1},
  },
  energy_required = 120,
  stack_size = 50,
  weight = rocket_lift_weight / 100,
  category = "advanced-crafting",
  bridge_force_create = true,
}).data_getter()


-- World Breaker tool

bridge.add_item({
  short_name = "worldbreaker",
  name = shared.worldbreaker,
  item_prototype = "selection-tool",
  icon = shared.media_prefix.."graphics/icons/WorldBreaker.png",
  icon_size = 64, icon_mipmaps = 3,
  prereq = nil,
  subgroup = shared.subg_build,
  order = "z-worldbreaker",
  ingredients = {
    {type="item", name=shared.frame_part, amount=3},
    {type="item", name=afci_bridge.get.he_emitter().name, amount=5},
    {type="item", name=afci_bridge.get.emfc().name, amount=5},
    {type="item", name=shared.laser_ammo, amount=100},
  },
  energy_required = 120,
  stack_size = 1,
  weight = rocket_lift_weight / 100,
  category = "advanced-crafting",
  bridge_force_create = true,
  item_data = {
    -- https://wiki.factorio.com/Prototype/SelectionTool#selection_mode
    stackable = false,
    select = {
      border_color = {r = 0.9, g = 0.5, b = 0.1},
      mode = {"not-same-force"},
      cursor_box_type = "entity",
    },
    alt_select = {
      border_color = {r = 0.9, g = 0.5, b = 0.1},
      mode = {"not-same-force"},
      cursor_box_type = "entity",
    },
  },
}).data_getter()
