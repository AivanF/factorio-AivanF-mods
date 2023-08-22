local shared = require("shared")

data:extend({
  -- Big bolt
  {
    type = "item",
    name = shared.big_bolt,
    icon = icon,
    icon_size = 64, icon_mipmaps = 4,
    subgroup = "energy-pipe-distribution",
    order = "z[lightning-rod-1]",
    place_result = shared.big_bolt,
    stack_size = 50,
  },
  {
    type = "recipe",
    name = shared.big_bolt,
    enabled = false,
    ingredients = {
      {"explosive", 2},
      {"steel-plate", 2},
      {"electronic-circuit", 1},
    },
    result = shared.big_bolt,
  },

  -- Huge bolt
  {
    type = "item",
    name = shared.huge_bolt,
    icon = icon,
    icon_size = 64, icon_mipmaps = 4,
    subgroup = "energy-pipe-distribution",
    order = "z[lightning-rod-1]",
    place_result = shared.huge_bolt,
    stack_size = 20,
  },
  {
    type = "recipe",
    name = shared.huge_bolt,
    enabled = false,
    ingredients = {
      {"explosive", 10},
      {"steel-plate", 10},
      {"copper-plate", 5},
      {"electronic-circuit", 3},
    },
    result = shared.huge_bolt,
  },

  -- Quake projectile
  {
    type = "item",
    name = shared.quake_proj,
    icon = icon,
    icon_size = 64, icon_mipmaps = 4,
    subgroup = "energy-pipe-distribution",
    order = "z[lightning-rod-1]",
    place_result = shared.quake_proj,
    stack_size = 10,
  },
  {
    type = "recipe",
    name = shared.quake_proj,
    enabled = false,
    ingredients = {
      {"explosive", 50},
      {"steel-plate", 100},
      {"radar", 12},
      {"processing-unit", 10},
    },
    result = shared.quake_proj,
  },
})
