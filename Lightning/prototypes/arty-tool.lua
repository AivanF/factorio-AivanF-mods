local sounds = require("__base__.prototypes.entity.sounds")
local shared = require("shared")

local icon = "__Lightning__/graphics/icons/arty-remote.png"
local icon_size = 64
local icon_mipmaps = 3

data:extend({
  {
    type = "selection-tool",
    name = shared.remote_name,
    icon = icon,
    icon_size = icon_size, icon_mipmaps = icon_mipmaps,
    capsule_action =
    {
      type = "artillery-remote",
      flare = flare_name
    },
    subgroup = "defensive-structure",
    order = "b[turret]-e[lightning]-3[remote]",
    stack_size = 1,
    stackable = false,
    selection_color = {r = 0.3, g = 0.9, b = 0.3},
    alt_selection_color = {r = 0.9, g = 0.9, b = 0.3},
    -- https://wiki.factorio.com/Prototype/SelectionTool#selection_mode
    selection_mode = {"not-same-force"},
    alt_selection_mode = {"not-same-force"},
    selection_cursor_box_type = "copy",
    alt_selection_cursor_box_type = "entity"
  },
  {
    type = "recipe",
    name = shared.remote_name,
    enabled = false,
    ingredients = {
      {"iron-plate", 20},
      {"copper-plate", 20},
      {"advanced-circuit", 10},
      {"battery", 50},
    },
    result = shared.remote_name,
  },
})

table.insert(
  data.raw.technology["electric-energy-distribution-2"].effects,
  { type = "unlock-recipe", recipe = shared.remote_name }
)