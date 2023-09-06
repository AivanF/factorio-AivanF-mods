local shared = require("shared-base")

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


-- Foots / tracks
shared.titan_foot_small = shared.mod_prefix.."foot-small"
shared.titan_foot_big   = shared.mod_prefix.."foot-big"


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

--- Above aircrafts and projectiles, but for shoulder weapons
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


shared.titan_type_list = {
  {
    name = shared.titan_warhound,
    class = shared.class_warhound,
    dst = 1, dmg = 1, spd = 5,
    arms = shared.gun_grade_small,
    carapace1 = nil,
    carapace2 = nil,
    carapace3 = nil,
    carapace4 = nil,
    ingredients = {
      [shared.energy_core] = 1,
      [shared.servitor]    = 1,
      [shared.void_shield] = 1,
      [shared.brain]       = 1,
      [shared.motor]       = 6,
      [shared.frame_part]  = 10,
      [shared.antigraveng] = 1,
    },
    foot = shared.titan_foot_small,
    entity = shared.titan_prefix..shared.titan_warhound,
    health = 10*1000,
    kill_cliffs = false,
    over_water = false,
    icon = shared.media_prefix.."graphics/icons/titan-1.png",
    icon_size = 64, icon_mipmaps = 3,
    plane = shared.media_prefix.."graphics/titans/class1.png",
    guns = {
      [1] = { oris=-0.25, shift=7, layer=shared.rl_arm, grade=1 },
      [2] = { oris= 0.25, shift=7, layer=shared.rl_arm, grade=1 },
    },
  },
  {
    name = shared.titan_direwolf,
    class = shared.class_direwolf,
    dst = 1, dmg = 1, spd = 4,
    arms = shared.gun_grade_small,
    carapace1 = nil,
    carapace2 = nil,
    carapace3 = nil,
    carapace4 = nil,
    ingredients = {
      [shared.energy_core] = 2,
      [shared.servitor]    = 1,
      [shared.void_shield] = 1,
      [shared.brain]       = 1,
      [shared.motor]       = 6,
      [shared.frame_part]  = 15,
      [shared.antigraveng] = 1,
    },
    foot = shared.titan_foot_small,
    entity = shared.titan_prefix..shared.titan_direwolf,
    health = 15*1000,
    kill_cliffs = false,
    over_water = false,
    icon = shared.media_prefix.."graphics/icons/titan-1.png",
    icon_size = 64, icon_mipmaps = 3,
    plane = shared.media_prefix.."graphics/titans/class1.png",
    guns = {
      [1] = { oris=-0.25, shift=8, layer=shared.rl_arm, grade=1 },
      [2] = { oris= 0.25, shift=8, layer=shared.rl_arm, grade=1 },
      [3] = { oris= 0,    shift=0, layer=shared.rl_shoulder, grade=1, is_shoulder=true },
    },
  },
  {
    name = shared.titan_reaver,
    class = shared.class_reaver,
    dst = 1.25, dmg = 1.25, spd = 4,
    arms = shared.gun_grade_medium,
    carapace1 = shared.gun_grade_small,
    carapace2 = nil,
    carapace3 = nil,
    carapace4 = nil,
    ingredients = {
      [shared.energy_core] = 3,
      [shared.servitor]    = 2,
      [shared.void_shield] = 2,
      [shared.brain]       = 2,
      [shared.motor]       = 20,
      [shared.frame_part]  = 25,
      [shared.antigraveng] = 2,
    },
    foot = shared.titan_foot_big,
    entity = shared.titan_prefix..shared.titan_reaver,
    health = 20*1000,
    kill_cliffs = false,
    over_water = false,
    icon = shared.media_prefix.."graphics/icons/titan-2.png",
    icon_size = 64, icon_mipmaps = 3,
    guns = {
      [1] = { oris=-0.25, shift=8, layer=shared.rl_arm, grade=2 },
      [2] = { oris= 0.25, shift=8, layer=shared.rl_arm, grade=2 },
      [3] = { oris= 0,    shift=2, layer=shared.rl_shoulder, grade=2, is_shoulder=true },
    },
  },
  {
    name = shared.titan_warlord,
    class = shared.class_warlord,
    dst = 1.5, dmg = 1.5, spd = 3,
    arms = shared.gun_grade_big,
    carapace1 = shared.gun_grade_medium,
    carapace2 = shared.gun_grade_medium,
    carapace3 = nil,
    carapace4 = nil,
    ingredients = {
      [shared.energy_core] = 5,
      [shared.servitor]    = 4,
      [shared.void_shield] = 4,
      [shared.brain]       = 3,
      [shared.motor]       = 40,
      [shared.frame_part]  = 40,
      [shared.antigraveng] = 3,
    },
    foot = shared.titan_foot_big,
    entity = shared.titan_prefix..shared.titan_warlord,
    health = 30*1000,
    kill_cliffs = true,
    over_water = false,
    icon = shared.media_prefix.."graphics/icons/titan-3.png",
    icon_size = 64, icon_mipmaps = 3,
    plane = shared.media_prefix.."graphics/titans/class3.png",
    guns = {
      [1] = { oris=-0.22, shift=10, layer=shared.rl_arm, grade=2 },
      [2] = { oris= 0.22, shift=10, layer=shared.rl_arm, grade=2 },
      [3] = { oris=-0.25, shift=6, layer=shared.rl_shoulder, grade=2, is_shoulder=true },
      [4] = { oris= 0.25, shift=6, layer=shared.rl_shoulder, grade=2, is_shoulder=true },
    },
  },
  {
    name = shared.titan_warmaster,
    class = shared.class_warmaster,
    dst = 1.75, dmg = 1.75, spd = 2,
    arms = shared.gun_grade_big,
    carapace1 = shared.gun_grade_medium,
    carapace2 = shared.gun_grade_medium,
    carapace3 = shared.gun_grade_small,
    carapace4 = shared.gun_grade_small,
    ingredients = {
      [shared.energy_core] = 7,
      [shared.servitor]    = 6,
      [shared.void_shield] = 6,
      [shared.brain]       = 4,
      [shared.motor]       = 60,
      [shared.frame_part]  = 80,
      [shared.antigraveng] = 6,
    },
    foot = shared.titan_foot_big,
    entity = shared.titan_prefix..shared.titan_warmaster,
    health = 60*1000,
    kill_cliffs = true,
    over_water = false,
    icon = shared.media_prefix.."graphics/icons/titan-4.png",
    icon_size = 64, icon_mipmaps = 3,
    guns = {
      [1] = { oris=-0.24, shift=10, layer=shared.rl_arm, grade=3 },
      [2] = { oris= 0.24, shift=10, layer=shared.rl_arm, grade=3 },
      [3] = { oris=-0.26, shift=10, layer=shared.rl_shoulder, grade=2, is_shoulder=true },
      [4] = { oris= 0.26, shift=10, layer=shared.rl_shoulder, grade=2, is_shoulder=true },
      [5] = { oris=-0.24, shift=8, layer=shared.rl_arm, grade=1 },
      [6] = { oris= 0.24, shift=8, layer=shared.rl_arm, grade=1 },
    },
  },
  {
    name = shared.titan_imperator,
    class = shared.class_imperator,
    dst = 2, dmg = 2, spd = 2,
    arms = shared.gun_grade_huge,
    carapace1 = shared.gun_grade_big,
    carapace2 = shared.gun_grade_big,
    carapace3 = shared.gun_grade_medium,
    carapace4 = shared.gun_grade_medium,
    ingredients = {
      [shared.energy_core] = 15,
      [shared.servitor]    = 12,
      [shared.void_shield] = 12,
      [shared.brain]       = 10,
      [shared.motor]       = 100,
      [shared.frame_part]  = 150,
      [shared.antigraveng] = 10,
    },
    foot = shared.titan_foot_big,
    entity = shared.titan_prefix..shared.titan_imperator,
    health = 100*1000,
    kill_cliffs = true,
    over_water = true,
    icon = shared.media_prefix.."graphics/icons/titan-5.png",
    icon_size = 64, icon_mipmaps = 3,
    guns = {
      [1] = { oris=-0.24, shift=10, layer=shared.rl_arm, grade=3 },
      [2] = { oris= 0.24, shift=10, layer=shared.rl_arm, grade=3 },
      [3] = { oris=-0.26, shift=10, layer=shared.rl_shoulder, grade=2, is_shoulder=true },
      [4] = { oris= 0.26, shift=10, layer=shared.rl_shoulder, grade=2, is_shoulder=true },
      [5] = { oris=-0.24, shift=8, layer=shared.rl_arm, grade=1 },
      [6] = { oris= 0.24, shift=8, layer=shared.rl_arm, grade=1 },
    },
  },
  {
    name = shared.titan_warmonger,
    class = shared.class_warmonger,
    dst = 2, dmg = 2, spd = 2,
    arms = shared.gun_grade_huge,
    carapace1 = shared.gun_grade_big,
    carapace2 = shared.gun_grade_big,
    carapace3 = shared.gun_grade_medium,
    carapace4 = shared.gun_grade_medium,
    ingredients = {
      [shared.energy_core] = 15,
      [shared.servitor]    = 12,
      [shared.void_shield] = 10,
      [shared.brain]       = 10,
      [shared.motor]       = 100,
      [shared.frame_part]  = 150,
      [shared.antigraveng] = 10,
    },
    foot = shared.titan_foot_big,
    entity = shared.titan_prefix..shared.titan_warmonger,
    health = 120*1000,
    kill_cliffs = true,
    over_water = true,
    icon = shared.media_prefix.."graphics/icons/titan-5.png",
    icon_size = 64, icon_mipmaps = 3,
    guns = {
      [1] = { oris=-0.24, shift=10, layer=shared.rl_arm, grade=3 },
      [2] = { oris= 0.24, shift=10, layer=shared.rl_arm, grade=3 },
      [3] = { oris=-0.26, shift=10, layer=shared.rl_shoulder, grade=2, is_shoulder=true },
      [4] = { oris= 0.26, shift=10, layer=shared.rl_shoulder, grade=2, is_shoulder=true },
      [5] = { oris=-0.24, shift=8, layer=shared.rl_arm, grade=2 },
      [6] = { oris= 0.24, shift=8, layer=shared.rl_arm, grade=2 },
    },
  },
}
shared.titan_types = {}

for _, info in pairs(shared.titan_type_list) do
  info.max_shield = info.ingredients[shared.void_shield] * 5000
  shared.titan_types[info.class] = info
  shared.titan_types[info.name] = info
  shared.titan_types[info.entity] = info
end
