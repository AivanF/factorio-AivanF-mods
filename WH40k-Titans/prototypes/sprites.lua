local shared = require("shared")

for _, titan_type in ipairs(shared.titan_classes) do
  if titan_type.plane then
    data:extend({
      {
        type="animation",
        name=titan_type.name,
        filename=titan_type.plane,
        frame_count=1,
        width=1024,
        height=1024,
        shift=util.by_pixel(0, -64),
      },
      {
        type="animation",
        name=titan_type.name.."-shadow",
        filename=titan_type.plane,
        frame_count=1,
        width=1024,
        height=1024,
        shift=util.by_pixel(0, -64),
        draw_as_shadow=true,
      },
    })
  end
end

data:extend({
  -- https://wiki.factorio.com/Prototype/Sprite
  -- https://lua-api.factorio.com/latest/Concepts.html#SpritePath
  {
    type="sprite",
    name=shared.mod_prefix.."light",
    filename=shared.media_prefix.."graphics/fx/light.png",
    width=360,
    height=360,
    shift=util.by_pixel(0, 0),
  },

  -- https://wiki.factorio.com/Prototype/Animation
  {
    type="animation",
    name=shared.mod_prefix.."class3",
    filename=shared.media_prefix.."graphics/titans/class3.png",
    frame_count=1,
    width=1024,
    height=1024,
    shift=util.by_pixel(0, -64),
  },
  {
    type="animation",
    name=shared.mod_prefix.."class3-shadow",
    filename=shared.media_prefix.."graphics/titans/class3.png",
    frame_count=1,
    width=1024,
    height=1024,
    shift=util.by_pixel(0, -64),
    draw_as_shadow=true,
  },
  {
    type="animation",
    name=shared.mod_prefix.."foot-small",
    filename=shared.media_prefix.."graphics/titans/foot-small.png",
    frame_count=1,
    width=256,
    height=256,
    shift=util.by_pixel(0, 0),
  },
  {
    type="animation",
    name=shared.mod_prefix.."step-small",
    filename=shared.media_prefix.."graphics/titans/step-small.png",
    frame_count=1,
    width=256,
    height=256,
    shift=util.by_pixel(0, 0),
  },
  {
    type="animation",
    name=shared.mod_prefix.."foot-big",
    filename=shared.media_prefix.."graphics/titans/foot-big.png",
    frame_count=1,
    width=256,
    height=256,
    shift=util.by_pixel(0, 0),
  },
  {
    type="animation",
    name=shared.mod_prefix.."step-big",
    filename=shared.media_prefix.."graphics/titans/step-big.png",
    frame_count=1,
    width=279,
    height=279,
    shift=util.by_pixel(0, 0),
  },
  -- TODO: load weapon sprites from common W dataset
  {
    type="animation",
    name=shared.mod_prefix.."Turbo-Laser",
    filename=shared.media_prefix.."graphics/weapons/Turbo-Laser.png",
    frame_count=1,
    width=256,
    height=512,
    shift=util.by_pixel(0, -130),
  },
  {
    type="animation",
    name=shared.mod_prefix.."LasCannon",
    filename=shared.media_prefix.."graphics/weapons/LasCannon.png",
    frame_count=1,
    width=256,
    height=512,
    shift=util.by_pixel(0, -130),
  },
  {
    type="animation",
    name=shared.mod_prefix.."Plasma-Destructor",
    filename=shared.media_prefix.."graphics/weapons/Plasma-Destructor.png",
    frame_count=1,
    width=240,
    height=560,
    shift=util.by_pixel(0, -140),
  },
})
