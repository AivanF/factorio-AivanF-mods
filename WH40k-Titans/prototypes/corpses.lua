local shared = require("shared")

data:extend({
  {
    type = "simple-entity-with-owner",
    name = shared.mod_prefix.."titan-corpse",
    icon = shared.mock_icon.icon, icon_size = shared.mock_icon.icon_size, icon_mipmaps = shared.mock_icon.icon_mipmaps,
    flags = {
      "not-rotatable", "placeable-neutral", "placeable-off-grid",
      "not-blueprintable", "not-deconstructable", "not-flammable",
    },
    health = 10000,
    resistances = technomagic_resistances,
    selectable_in_game = false,
    resistances = full_resistances,
    selection_box = {{-3, -3}, {3, 3}},
    collision_box = {{-3, -3}, {3, 3}},
    collision_mask = {},
    render_layer = "floor",
    picture = {
      filename = shared.media_prefix.."graphics/entity/titan-corpse-mock.png",
      width = 240, height = 240,
    },
  }
})