local bridge = require("item-utils")

local add_item = bridge.add_item
local prerequisite = bridge.empty
local subgroup = bridge.subg_early

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
      prereq = bridge.empty,
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
      prereq = bridge.empty,
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
