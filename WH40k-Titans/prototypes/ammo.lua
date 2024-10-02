local shared = require("shared")
local bridge = require("__Common-Industries__.export")

data:extend({
  -- Big bolt
  {
    type = "item",
    name = shared.big_bolt,
    icon = shared.media_prefix.."graphics/icons/weapons/Bolt-Big.png",
    icon_size = 64, icon_mipmaps = 3,
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
  --     {"explosives", 50},
  --     {"steel-plate", 100},
  --     {"radar", 12},
  --     {"processing-unit", 10},
  --   category = "advanced-crafting",
  --   },
  --   result = shared.quake_proj,
  -- },
})


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
    {"artillery-shell", 1},
    -- Add a strong metal?
    {"rocket-control-unit", 1},
    {afci_bridge.get.rocket_engine().name, 1},
    {"rocket-fuel", 50},
  },
  stack_size = 5,
  energy_required = 120,
  category = "advanced-crafting",
  afci_bridged = true,
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
    {shared.empty_missile_ammo, 1},
    {"uranium-235", 50},
    {"explosives", 10},
  },
  stack_size = 1,
  energy_required = 120,
  category = "advanced-crafting",
  afci_bridged = true,
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
    {shared.empty_missile_ammo, 5},
    {afci_bridge.get.he_emitter().name, 1},
    {afci_bridge.get.emfc().name, 1},
    {shared.plasma_ammo, 12 * 5},
  },
  result_count = 5,
  stack_size = 1,
  energy_required = 120 * 5 * 2,
  category = "advanced-crafting",
  afci_bridged = true,
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
    {afci_bridge.get.empty_missile().name, 1},
    {shared.realityctrl, 1},
  },
  stack_size = 1,
  energy_required = 120 * 4,
  category = "advanced-crafting",
  afci_bridged = true,
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
    {"battery", 2},
    {"electronic-circuit", 1},
    {"steel-plate", 1},
  },
  modded = {
    {
      mod = bridge.mods.k2,
      ingredients = {
        {"lithium-sulfur-battery", 2},
        {"electronic-circuit", 1},
        {"steel-plate", 1},
      },
    },
    {
      mod = bridge.mods.py_alt,
      ingredients = {
        {"battery-mk01", 2},
        {"electronic-circuit", 1},
        {"steel-plate", 1},
      },
    },
  },
  energy_required = 30,
  stack_size = 100,
  category = "advanced-crafting",
  afci_bridged = true,
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
    {"uranium-fuel-cell", 1},
    {"rocket-fuel", 1},
    {"advanced-circuit", 1},
    {"steel-plate", 1},
  },
  energy_required = 30,
  stack_size = 100,
  category = "advanced-crafting",
  afci_bridged = true,
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
    {shared.plasma_ammo, 1},
    {shared.melta_ammo, 1},
    {shared.laser_ammo, 1},
    {bridge.get.best_fuel().name, 1},
  },
  energy_required = 120,
  stack_size = 20,
  category = "advanced-crafting",
  afci_bridged = true,
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
    {shared.frame_part, 3},
    {afci_bridge.get.he_emitter().name, 5},
    {afci_bridge.get.emfc().name, 5},
    {shared.laser_ammo, 100},
  },
  energy_required = 120,
  stack_size = 1,
  category = "advanced-crafting",
  afci_bridged = true,
  item_data = {
    -- https://wiki.factorio.com/Prototype/SelectionTool#selection_mode
    stackable = false,
    selection_color = {r = 0.9, g = 0.5, b = 0.1},
    alt_selection_color = {r = 0.9, g = 0.5, b = 0.1},
    selection_mode = {"not-same-force"},
    alt_selection_mode = {"not-same-force"},
    selection_cursor_box_type = "copy",
    alt_selection_cursor_box_type = "entity"
  },
}).data_getter()
