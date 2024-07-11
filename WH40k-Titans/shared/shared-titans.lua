local shared = require("shared.shared-base")

----- Titan types
-- Scout grade
shared.titan_warhound  = "warhound"
shared.class_warhound  = 10
shared.titan_direwolf  = "direwolf"
shared.class_direwolf  = 11
-- Battle grade
shared.titan_reaver    = "reaver"
shared.class_reaver    = 20
shared.titan_warlord   = "warlord"
shared.class_warlord   = 30
-- Heavy grade
shared.titan_warmaster = "warmaster"
shared.class_warmaster = 40
-- Emperor / super heavy grade
shared.titan_imperator = "imperator"
shared.class_imperator = 50
shared.titan_warmonger = "warmonger"
shared.class_warmonger = 55


-- Foots/tracks, auxiliary turrets
shared.titan_foot_small = shared.mod_prefix.."foot-small"
shared.titan_foot_big   = shared.mod_prefix.."foot-big"
shared.titan_aux_laser  = shared.mod_prefix.."aux-turret-laser"


-- Render layers
--[[
https://lua-api.factorio.com/latest/Concepts.html#RenderLayer
"air-object" = 145
"light-effect" = 148
"selection-box" = 187
"projectile" = 143
]]--
shared.rl_track = 122
shared.rl_foot = 124 -- ="lower-object"

--- Above aircrafts and projectiles, bad for shoulder weapons
shared.rl_shadow = 144
shared.rl_arm = 169
shared.rl_body = 170
shared.rl_shoulder = 171
shared.rl_shield = 172

--- Under aircrafts, projectiles, explosions, bad for non-shoudler weapons
-- shared.rl_shadow = 136 -- ="wires-above"
-- shared.rl_arm = 139
-- shared.rl_body = 140
-- shared.rl_shoulder = 141
-- shared.rl_shield = 145

shared.titan_base_type = "car"

shared.titan_type_list = {
  {
    name = shared.titan_warhound,
    class = shared.class_warhound,
    dst = 1, dmg = 1, spd = 12,
    ingredients = {
      {shared.energy_core, 1},
      {shared.servitor,    1},
      {shared.void_shield, 1},
      {shared.brain,       1},
      {shared.motor,       6},
      {shared.frame_part, 10},
      {shared.antigraveng, 1},
    },
    foot = shared.titan_foot_small,
    entity = shared.titan_prefix..shared.titan_warhound,
    health = 10*1000,
    max_shield = 1*5000,
    kill_cliffs = false,
    over_water = false,
    icon = shared.media_prefix.."graphics/icons/titan-1.png",
    icon_size = 64, icon_mipmaps = 3,
    plane = shared.media_prefix.."graphics/titans/class1.png",
    guns = {
      [1] = { oris=-0.25, shift=7, layer=shared.rl_arm, grade=1 },
      [2] = { oris= 0.25, shift=7, layer=shared.rl_arm, grade=1 },
    },
    aux_laser = {
      {1, 0},
    },
  },
  {
    name = shared.titan_direwolf,
    class = shared.class_direwolf,
    dst = 1, dmg = 1, spd = 10,
    ingredients = {
      {shared.energy_core, 2},
      {shared.servitor,    1},
      {shared.void_shield, 1},
      {shared.brain,       1},
      {shared.motor,       6},
      {shared.frame_part, 15},
      {shared.antigraveng, 1},
    },
    foot = shared.titan_foot_small,
    entity = shared.titan_prefix..shared.titan_direwolf,
    health = 15*1000,
    max_shield = 1*5000,
    kill_cliffs = false,
    over_water = false,
    icon = shared.media_prefix.."graphics/icons/titan-1-dw.png",
    icon_size = 64, icon_mipmaps = 3,
    plane = shared.media_prefix.."graphics/titans/class1-dw.png",
    guns = {
      [1] = { oris=-0.25, shift=8, layer=shared.rl_arm, grade=0 },
      [2] = { oris= 0.25, shift=8, layer=shared.rl_arm, grade=0 },
      [3] = { oris= 0,    shift=0, layer=shared.rl_shoulder, grade=2, is_top=true },
    },
    aux_laser = {
      {1, 0},
    },
  },
  {
    name = shared.titan_reaver,
    class = shared.class_reaver,
    dst = 1.25, dmg = 1.25, spd = 9,
    ingredients = {
      {shared.energy_core, 3},
      {shared.servitor,    2},
      {shared.void_shield, 2},
      {shared.brain,       3},
      {shared.motor,      20},
      {shared.frame_part, 25},
      {shared.antigraveng, 2},
    },
    foot = shared.titan_foot_big,
    entity = shared.titan_prefix..shared.titan_reaver,
    health = 20*1000,
    max_shield = 2*5000,
    kill_cliffs = false,
    over_water = false,
    icon = shared.media_prefix.."graphics/icons/titan-2.png",
    icon_size = 64, icon_mipmaps = 3,
    plane = shared.media_prefix.."graphics/titans/class2.png",
    guns = {
      [1] = { oris=-0.2, shift=8, layer=shared.rl_arm, grade=2 },
      [2] = { oris= 0.2, shift=8, layer=shared.rl_arm, grade=2 },
      [3] = { oris= 0,   shift=2, layer=shared.rl_shoulder, grade=2, is_top=true },
    },
    aux_laser = {
      {2, 0.25},
      {2,-0.25},
    },
  },
  {
    name = shared.titan_warlord,
    class = shared.class_warlord,
    dst = 1.5, dmg = 1.5, spd = 8,
    ingredients = {
      {shared.energy_core, 5},
      {shared.servitor,    4},
      {shared.void_shield, 4},
      {shared.brain,       5},
      {shared.motor,      35},
      {shared.frame_part, 40},
      {shared.antigraveng, 3},
    },
    foot = shared.titan_foot_big,
    entity = shared.titan_prefix..shared.titan_warlord,
    health = 30*1000,
    max_shield = 4*5000,
    kill_cliffs = true,
    over_water = false,
    icon = shared.media_prefix.."graphics/icons/titan-3.png",
    icon_size = 64, icon_mipmaps = 3,
    plane = shared.media_prefix.."graphics/titans/class3.png",
    guns = {
      [1] = { oris=-0.2, shift=11, layer=shared.rl_arm, grade=2 },
      [2] = { oris= 0.2, shift=11, layer=shared.rl_arm, grade=2 },
      [3] = { oris=-0.25, shift=6, layer=shared.rl_shoulder, grade=2, is_top=true },
      [4] = { oris= 0.25, shift=6, layer=shared.rl_shoulder, grade=2, is_top=true },
    },
    aux_laser = {
      {3, 0.25},
      {2, 0},
      {3,-0.25},
    },
  },
  {
    name = shared.titan_warmaster,
    class = shared.class_warmaster,
    dst = 1.75, dmg = 1.75, spd = 7,
    ingredients = {
      {shared.energy_core, 7},
      {shared.servitor,    6},
      {shared.void_shield, 6},
      {shared.brain,       8},
      {shared.motor,      60},
      {shared.frame_part, 80},
      {shared.antigraveng, 6},
    },
    foot = shared.titan_foot_big,
    entity = shared.titan_prefix..shared.titan_warmaster,
    health = 60*1000,
    max_shield = 6*5000,
    kill_cliffs = true,
    over_water = false,
    icon = shared.media_prefix.."graphics/icons/titan-4.png",
    icon_size = 64, icon_mipmaps = 3,
    guns = {
      [1] = { oris=-0.24, shift=10, layer=shared.rl_arm, grade=3 },
      [2] = { oris= 0.24, shift=10, layer=shared.rl_arm, grade=3 },
      [3] = { oris=-0.26, shift=10, layer=shared.rl_shoulder, grade=2, is_top=true },
      [4] = { oris= 0.26, shift=10, layer=shared.rl_shoulder, grade=2, is_top=true },
      [5] = { oris=-0.24, shift=8, layer=shared.rl_arm, grade=1 },
      [6] = { oris= 0.24, shift=8, layer=shared.rl_arm, grade=1 },
    },
    aux_laser = {
      {4, 0.15},
      {4,-0.15},
      {4, 0.35},
      {4,-0.35},
    },
  },
  {
    name = shared.titan_imperator,
    class = shared.class_imperator,
    dst = 2, dmg = 2, spd = 7,
    ingredients = {
      {shared.energy_core, 15},
      {shared.servitor,    12},
      {shared.void_shield, 12},
      {shared.brain,       10},
      {shared.motor,      100},
      {shared.frame_part, 150},
      {shared.antigraveng, 10},
    },
    foot = shared.titan_foot_big,
    entity = shared.titan_prefix..shared.titan_imperator,
    health = 120*1000,
    max_shield = 12*5000,
    kill_cliffs = true,
    over_water = true,
    icon = shared.media_prefix.."graphics/icons/titan-5.png",
    icon_size = 64, icon_mipmaps = 3,
    guns = {
      [1] = { oris=-0.24, shift=10, layer=shared.rl_arm, grade=3 },
      [2] = { oris= 0.24, shift=10, layer=shared.rl_arm, grade=3 },
      [3] = { oris=-0.26, shift=10, layer=shared.rl_shoulder, grade=2, is_top=true },
      [4] = { oris= 0.26, shift=10, layer=shared.rl_shoulder, grade=2, is_top=true },
      [5] = { oris=-0.24, shift=8, layer=shared.rl_arm, grade=1 },
      [6] = { oris= 0.24, shift=8, layer=shared.rl_arm, grade=1 },
    },
    aux_laser = {
      {4, 0.15},
      {4,-0.15},
      {4, 0.35},
      {4,-0.35},
      {6, 0.25},
      {6,-0.25},
    },
  },
  -- {
  --   name = shared.titan_warmonger,
  --   class = shared.class_warmonger,
  --   dst = 2, dmg = 2, spd = 6,
  --   ingredients = {
  --     {shared.energy_core, 15},
  --     {shared.servitor,    12},
  --     {shared.void_shield, 10},
  --     {shared.brain,       10},
  --     {shared.motor,      100},
  --     {shared.frame_part, 150},
  --     {shared.antigraveng, 10},
  --   },
  --   foot = shared.titan_foot_big,
  --   entity = shared.titan_prefix..shared.titan_warmonger,
  --   health = 120*1000,
  --   max_shield = 10*5000,
  --   kill_cliffs = true,
  --   over_water = true,
  --   icon = shared.media_prefix.."graphics/icons/titan-5.png",
  --   icon_size = 64, icon_mipmaps = 3,
  --   guns = {
  --     [1] = { oris=-0.24, shift=10, layer=shared.rl_arm, grade=3 },
  --     [2] = { oris= 0.24, shift=10, layer=shared.rl_arm, grade=3 },
  --     [3] = { oris=-0.26, shift=10, layer=shared.rl_shoulder, grade=2, is_top=true },
  --     [4] = { oris= 0.26, shift=10, layer=shared.rl_shoulder, grade=2, is_top=true },
  --     [5] = { oris=-0.24, shift=8, layer=shared.rl_arm, grade=2, is_top=true },
  --     [6] = { oris= 0.24, shift=8, layer=shared.rl_arm, grade=2, is_top=true },
  --   },
  --   aux_laser = {
  --     {4, 0.15},
  --     {4,-0.15},
  --     {4, 0.35},
  --     {4,-0.35},
  --   },
  -- },
}
shared.titan_types = {}

for _, titan_type in pairs(shared.titan_type_list) do
  titan_type.available = not not titan_type.plane
  shared.titan_types[titan_type.class]  = titan_type
  shared.titan_types[titan_type.name]   = titan_type
  shared.titan_types[titan_type.entity] = titan_type
end
