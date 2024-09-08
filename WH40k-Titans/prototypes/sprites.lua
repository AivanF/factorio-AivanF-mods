local shared = require("shared")

for _, titan_type in ipairs(shared.titan_type_list) do
  if titan_type.plane then
    data:extend({
      {
        type = "animation",
        name = titan_type.name,
        filename = titan_type.plane,
        frame_count = 1,
        width = titan_type.plane_size or 1024,
        height = titan_type.plane_size or 1024,
        shift = util.by_pixel(0, -64),
      },
      {
        type = "animation",
        name = titan_type.name.."-shadow",
        filename = titan_type.plane,
        frame_count = 1,
        width = titan_type.plane_size or 1024,
        height = titan_type.plane_size or 1024,
        shift = util.by_pixel(0, -64),
        draw_as_shadow = true,
      },
    })
  end
end

data:extend({
  {
    type = "sprite",
    name = shared.mod_prefix.."weight",
    filename = "__core__/graphics/icons/alerts/no-storage-space-icon.png",
    width = 64, height = 64,
  },
  {
    type = "sprite",
    name = shared.mod_prefix.."gui-btn",
    filename = shared.media_prefix.."graphics/icons/legio-titanicus.png",
    width = 64, height = 64, mipmap_count = 1,
  },
  {
    type = "projectile",
    name = shared.item_proj,
    acceleration = 0.02,
    light = {intensity = 0.1, size = 10},
    animation = {
        -- filename = "__base__/graphics/icons/coin.png",
        -- width = 32, height = 32,
        filename = shared.media_prefix.."graphics/icons/details/projectile-engine.png",
        width = 64, height = 64, scale = 0.5,
        frame_count = 1,
    },
    speed = 0.05
  },

  {
    type = "virtual-signal",
    name = shared.mod_prefix.."signal-close",
    icon = shared.media_prefix.."graphics/icons/btns/ic-close.png",
    icon_size = 64, icon_mipmaps = 1,
    subgroup = shared.mod_prefix.."signals",
    order = "a[close]"
  },
  {
    type = "virtual-signal",
    name = shared.mod_prefix.."signal-back",
    icon = shared.media_prefix.."graphics/icons/btns/ic-back.png",
    icon_size = 64, icon_mipmaps = 1,
    subgroup = shared.mod_prefix.."signals",
    order = "b[back]"
  },
  {
    type = "virtual-signal",
    name = shared.mod_prefix.."signal-play",
    icon = shared.media_prefix.."graphics/icons/btns/ic-play.png",
    icon_size = 64, icon_mipmaps = 1,
    subgroup = shared.mod_prefix.."signals",
    order = "c[play]"
  },
  {
    type = "virtual-signal",
    name = shared.mod_prefix.."signal-stop",
    icon = shared.media_prefix.."graphics/icons/btns/ic-stop.png",
    icon_size = 64, icon_mipmaps = 1,
    subgroup = shared.mod_prefix.."signals",
    order = "d[stop]"
  },
  {
    type = "virtual-signal",
    name = shared.mod_prefix.."signal-assembling",
    icon = shared.media_prefix.."graphics/icons/btns/ic-assembling.png",
    icon_size = 64, icon_mipmaps = 1,
    subgroup = shared.mod_prefix.."signals",
    order = "e[assembling-1]"
  },
  {
    type = "virtual-signal",
    name = shared.mod_prefix.."signal-disassembling",
    icon = shared.media_prefix.."graphics/icons/btns/ic-disassembling.png",
    icon_size = 64, icon_mipmaps = 1,
    subgroup = shared.mod_prefix.."signals",
    order = "e[assembling-2]"
  },
  {
    type = "virtual-signal",
    name = shared.mod_prefix.."signal-packing",
    icon = shared.media_prefix.."graphics/icons/btns/ic-packing.png",
    icon_size = 64, icon_mipmaps = 1,
    subgroup = shared.mod_prefix.."signals",
    order = "e[packing-1]"
  },
  {
    type = "virtual-signal",
    name = shared.mod_prefix.."signal-unpacking",
    icon = shared.media_prefix.."graphics/icons/btns/ic-unpacking.png",
    icon_size = 64, icon_mipmaps = 1,
    subgroup = shared.mod_prefix.."signals",
    order = "e[packing-2]"
  },


  -- https://wiki.factorio.com/Prototype/Sprite
  -- https://lua-api.factorio.com/latest/Concepts.html#SpritePath
  {
    type = "sprite",
    name = shared.mod_prefix.."light",
    filename = shared.media_prefix.."graphics/fx/light.png",
    width = 360,
    height = 360,
    shift = util.by_pixel(0, 0),
  },
  {
    type = "sprite",
    name = shared.mod_prefix.."shield",
    filename = shared.media_prefix.."graphics/fx/shield-effect.png",
    width = 800,
    height = 800,
    shift = util.by_pixel(0, 0),
  },
  {
    type = "sprite",
    name = shared.mod_prefix.."corpse-1",
    filename = shared.media_prefix.."graphics/entity/titan-corpse-1.png",
    width = 400,
    height = 400,
  },
  {
    type = "sprite",
    name = shared.mod_prefix.."corpse-3",
    filename = shared.media_prefix.."graphics/entity/titan-corpse-3.png",
    width = 600,
    height = 600,
  },
  {
    type = "sprite",
    name = shared.mod_prefix.."corpse-supplier",
    filename = shared.media_prefix.."graphics/entity/supplier-corpse.png",
    width = 400,
    height = 400,
    scale = 0.5,
  },

  -- https://wiki.factorio.com/Prototype/Animation
  {
    type = "animation",
    name = shared.mod_prefix.."foot-small",
    filename = shared.media_prefix.."graphics/titans/foot-small.png",
    frame_count = 1,
    width = 256,
    height = 256,
    shift = util.by_pixel(0, 0),
  },
  {
    type = "animation",
    name = shared.mod_prefix.."step-small",
    filename = shared.media_prefix.."graphics/titans/step-small.png",
    frame_count = 1,
    width = 256,
    height = 256,
    shift = util.by_pixel(0, 0),
  },
  {
    type = "animation",
    name = shared.mod_prefix.."foot-big",
    filename = shared.media_prefix.."graphics/titans/foot-big.png",
    frame_count = 1,
    width = 256,
    height = 256,
    shift = util.by_pixel(0, 0),
  },
  {
    type = "animation",
    name = shared.mod_prefix.."step-big",
    filename = shared.media_prefix.."graphics/titans/step-big.png",
    frame_count = 1,
    width = 279,
    height = 279,
    shift = util.by_pixel(0, 0),
  },


----- Weapons -----
  {
    type = "animation",
    name = shared.mod_prefix.."Inferno",
    filename = shared.media_prefix.."graphics/weapons/Inferno.png",
    frame_count = 1,
    width = 205,
    height = 410,
    shift = util.by_pixel(0, -110),
  },
  {
    type = "animation",
    name = shared.mod_prefix.."LasCannon",
    filename = shared.media_prefix.."graphics/weapons/LasCannon.png",
    frame_count = 1,
    width = 192,
    height = 384,
    shift = util.by_pixel(0, -130),
  },
  {
    type = "animation",
    name = shared.mod_prefix.."Turbo-Laser",
    filename = shared.media_prefix.."graphics/weapons/Turbo-Laser.png",
    frame_count = 1,
    width = 192,
    height = 384,
    shift = util.by_pixel(0, -130),
  },
  {
    type = "animation",
    name = shared.mod_prefix.."Laser-Blaster",
    filename = shared.media_prefix.."graphics/weapons/Laser-Blaster.png",
    frame_count = 1,
    width = 200,
    height = 400,
    shift = util.by_pixel(0, -150),
  },
  {
    type = "animation",
    name = shared.mod_prefix.."Bolter-Adrex",
    filename = shared.media_prefix.."graphics/weapons/Bolter-Adrex.png",
    frame_count = 1,
    width = 80,
    height = 160,
    shift = util.by_pixel(0, -60),
  },
  {
    type = "animation",
    name = shared.mod_prefix.."Bolter-Vulcan",
    filename = shared.media_prefix.."graphics/weapons/Bolter-Vulcan.png",
    frame_count = 1,
    width = 160,
    height = 320,
    shift = util.by_pixel(0, -120),
  },
  {
    type = "animation",
    name = shared.mod_prefix.."Plasma-BlastGun",
    filename = shared.media_prefix.."graphics/weapons/Plasma-BlastGun.png",
    frame_count = 1,
    width = 256,
    height = 512,
    shift = util.by_pixel(0, -130),
  },
  {
    type = "animation",
    name = shared.mod_prefix.."Plasma-Destructor",
    filename = shared.media_prefix.."graphics/weapons/Plasma-Destructor.png",
    frame_count = 1,
    width = 256,
    height = 512,
    shift = util.by_pixel(0, -130),
  },
  {
    type = "animation",
    name = shared.mod_prefix.."MissileLauncher",
    filename = shared.media_prefix.."graphics/weapons/MissileLauncher.png",
    frame_count = 1,
    width = 256,
    height = 256,
    shift = util.by_pixel(0, 0),
  },
  {
    type = "animation",
    name = shared.mod_prefix.."ApocLauncher",
    filename = shared.media_prefix.."graphics/weapons/ApocLauncher.png",
    frame_count = 1,
    width = 256,
    height = 256,
    shift = util.by_pixel(0, 0),
  },
})

informatron_make_image(shared.mod_prefix.."inf-AT-logo",
  shared.media_prefix.."graphics/informatron/AT-logo.png", 900, 493)

informatron_make_image(shared.mod_prefix.."inf-lore-art",
  shared.media_prefix.."graphics/informatron/lore-art.jpg", 1000, 680)

informatron_make_image(shared.mod_prefix.."inf-extractor",
  shared.media_prefix.."graphics/informatron/extractor.jpg", 900, 580)

informatron_make_image(shared.mod_prefix.."inf-titan-dashboard",
  shared.media_prefix.."graphics/informatron/titan-dashboard.jpg", 228, 172)
