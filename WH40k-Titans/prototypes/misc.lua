local shared = require("shared")
local misc = {}
misc.empty_sprite = util.empty_sprite()
misc.empty_4way_animation = {
  {
    render_layer = "object",
    north_animation = {
      layers = {misc.empty_sprite}
    },
    east_animation = {
      layers = {misc.empty_sprite}
    },
    south_animation = {
      layers = {misc.empty_sprite}
    },
    west_animation = {
      layers = {misc.empty_sprite}
    }
  }
}
return misc