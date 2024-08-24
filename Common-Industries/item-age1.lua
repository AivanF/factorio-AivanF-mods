local bridge = require("item-utils")

local add_item = bridge.add_item
local prerequisite = bridge.tech.early.name
local subgroup = bridge.subg_early

add_item({
  short_name = "glass",
  name = bridge.prefix.."glass",
  icon = bridge.media_path.."icons/glass.png",
  icon_size = 64, icon_mipmaps = 1,
  prereq = prerequisite,
  subgroup = subgroup,
  ingredients = {{ bridge.item.sand, 3 }},
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
      prereq = bridge.empty,
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
