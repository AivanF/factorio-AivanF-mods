local shared = require("shared")
local misc = {}
misc.empty_sprite = {
  filename = shared.media_prefix.."graphics/empty.png",
  width = 1,
  height = 1,
  frame_count = 1,
  line_length = 1,
  shift = { 0, 0 },
}
return misc