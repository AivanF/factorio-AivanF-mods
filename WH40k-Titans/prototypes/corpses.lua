local shared = require("shared")
local misc = require("prototypes.misc")

local hsz = 4

data:extend({
  {
    type = "simple-entity-with-owner",
    name = shared.corpse,
    icon = shared.mock_icon.icon, icon_size = shared.mock_icon.icon_size, icon_mipmaps = shared.mock_icon.icon_mipmaps,
    flags = {
      "not-rotatable", "placeable-neutral", "placeable-off-grid",
      "not-blueprintable", "not-deconstructable", "not-flammable",
    },
    health = 10000,
    resistances = technomagic_resistances,
    selectable_in_game = false,
    map_color = {1.0, 0.6, 0.1},
    selection_box = {{-hsz, -hsz}, {hsz, hsz}},
    collision_box = {{-hsz, -hsz}, {hsz, hsz}},
    collision_mask = {},
    render_layer = "floor",
    picture = misc.empty_sprite,
  }
})