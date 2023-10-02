local shared = require("shared")
local misc = {}
misc.empty_sprite = {
  filename = shared.media_prefix.."graphics/empty.png",
  width = 1,
  height = 1,
  line_length = 1,
  frame_count = 1,
  direction_count = 1,
  shift = { 0, 0 },
}
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