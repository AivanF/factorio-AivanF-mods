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
shared.titan_warbringer= "warbringer"
shared.class_warbringer= 29
shared.titan_warlord   = "warlord"
shared.class_warlord   = 30
-- Heavy grade
shared.titan_warmaster = "warmaster"
shared.class_warmaster = 40
-- Emperor / super heavy grade
shared.titan_imperator = "imperator"
shared.class_imperator = 50
shared.titan_warmonger = "warmonger"
shared.class_warmonger = 51


-- Foots/tracks, auxiliary turrets
shared.titan_foot_small = shared.mod_prefix.."foot-small"
shared.titan_foot_big   = shared.mod_prefix.."foot-big"
shared.titan_aux_laser  = shared.mod_prefix.."aux-turret-laser"
shared.titan_aux_laser2 = shared.mod_prefix.."aux-turret-laser-2"


-- Render layers
--[[
https://lua-api.factorio.com/latest/concepts/RenderLayer.html
TODO: rework depths!

"floor-mechanics" = 122
"item"          = 123
"lower-object"  = 124
"object"        = 129
"higher-object-under"    = 131
"higher-object-above"    = 132
"item-in-inserter-hand"  = 134
"wires-above"   = 136
"entity-info-icon"       = 138
"entity-info-icon-above" = 139
"explosion"     = 142
"projectile"    = 143
"smoke"         = 144
"air-object"    = 145
"air-entity-info-icon" = 147
"light-effect"  = 148
"selection-box" = 187
]]--
shared.rl_track = 122
shared.rl_foot = 124

--- Above aircrafts and projectiles, bad for shoulder weapons
-- shared.rl_shadow = 144
-- shared.rl_arm = 169
-- shared.rl_body = 170
-- shared.rl_shoulder1 = 171
-- shared.rl_shoulder2 = 172
-- shared.rl_shoulder3 = 173
-- shared.rl_shield = 174

--- Under aircrafts, projectiles, explosions, bad for non-shoudler weapons
shared.rl_shadow = 136
shared.rl_arm = 139
shared.rl_body = 140
shared.rl_shoulder1 = 142
shared.rl_shoulder1_name = "explosion"
shared.rl_shoulder2 = 143
shared.rl_shoulder2_name = "projectile"
shared.rl_shoulder3 = 144
shared.rl_shoulder3_name = "smoke"
shared.rl_shield = 145

--- For debugging purposes
-- shared.rl_shadow = 122
-- shared.rl_arm = 123
-- shared.rl_body = 124

shared.titan_base_type = "car"
shared.titan_breakable_details = {
  [shared.motor] = true,
  [shared.frame_part] = true,
  ["laser-turret"] = true,
}

shared.titan_type_list = {
  {
    name = shared.titan_warhound,
    class = shared.class_warhound,
    spd = 12,
    ingredients = {
      {shared.bci,         1},
      {shared.energy_core, 1},
      {shared.servitor,    1},
      {shared.void_shield, 1},
      {shared.brain,       1},
      {shared.motor,       6},
      {shared.frame_part, 10},
      {shared.antigraveng, 1},
      {"laser-turret",     2},
    },
    foot = shared.titan_foot_small,
    entity = shared.titan_prefix..shared.titan_warhound,
    health = 10*1000,
    max_shield = 1, -- multiplied by base amount
    kill_cliffs = false,
    over_water = false,
    icon = shared.media_prefix.."graphics/icons/titan-1.png",
    icon_size = 64, icon_mipmaps = 3,
    plane = shared.media_prefix.."graphics/titans/class1.png",
    plane_size = 720,
    mounts = {
      [1] = { oris= 0.25, shift=7, layer=shared.rl_arm, grade=1, is_arm=true },
      [2] = { oris=-0.25, shift=7, layer=shared.rl_arm, grade=1, is_arm=true },
    },
    aux_laser = {
      {2, 0.25},
      {2,-0.25},
    },
  },
  {
    name = shared.titan_direwolf,
    class = shared.class_direwolf,
    spd = 11,
    ingredients = {
      {shared.bci,         1},
      {shared.energy_core, 2},
      {shared.servitor,    1},
      {shared.void_shield, 1},
      {shared.brain,       1},
      {shared.motor,       6},
      {shared.frame_part, 15},
      {shared.antigraveng, 1},
      {"laser-turret",     2},
    },
    foot = shared.titan_foot_small,
    entity = shared.titan_prefix..shared.titan_direwolf,
    health = 15*1000,
    max_shield = 1, -- multiplied by base amount
    kill_cliffs = false,
    over_water = false,
    icon = shared.media_prefix.."graphics/icons/titan-1-dw.png",
    icon_size = 64, icon_mipmaps = 3,
    plane = shared.media_prefix.."graphics/titans/class1-dw.png",
    plane_size = 640,
    mounts = {
      [1] = { oris= 0.25, shift=8, layer=shared.rl_arm, grade=0, is_arm=false },
      [2] = { oris=-0.25, shift=8, layer=shared.rl_arm, grade=0, is_arm=false },
      [3] = { oris= 0,    shift=0, layer=shared.rl_shoulder1, grade=2, is_top=true },
    },
    aux_laser = {
      {2, 0.25},
      {2,-0.25},
    },
  },
  {
    name = shared.titan_reaver,
    class = shared.class_reaver,
    spd = 11,
    ingredients = {
      {shared.bci,         1},
      {shared.energy_core, 3},
      {shared.servitor,    2},
      {shared.void_shield, 2},
      {shared.brain,       3},
      {shared.motor,      20},
      {shared.frame_part, 25},
      {shared.antigraveng, 2},
      {"laser-turret",     3},
    },
    foot = shared.titan_foot_big,
    entity = shared.titan_prefix..shared.titan_reaver,
    health = 20*1000,
    max_shield = 2, -- multiplied by base amount
    kill_cliffs = false,
    over_water = false,
    icon = shared.media_prefix.."graphics/icons/titan-2.png",
    icon_size = 64, icon_mipmaps = 3,
    plane = shared.media_prefix.."graphics/titans/class2.png",
    plane_size = 1024,
    mounts = {
      [1] = { oris= 0.2, shift=8, layer=shared.rl_arm, grade=2, is_arm=true },
      [2] = { oris=-0.2, shift=8, layer=shared.rl_arm, grade=2, is_arm=true },
      [3] = { oris= 0,   shift=2, layer=shared.rl_shoulder1, grade=3, is_top=true },
    },
    aux_laser = {
      {2, 0.25},
      {2, 0},
      {2,-0.25},
    },
  },
  {
    name = shared.titan_warbringer,
    class = shared.class_warbringer,
    spd = 10,
    ingredients = {
      {shared.bci,         1},
      {shared.energy_core, 4},
      {shared.servitor,    3},
      {shared.void_shield, 3},
      {shared.brain,       4},
      {shared.motor,      30},
      {shared.frame_part, 35},
      {shared.antigraveng, 3},
    },
    foot = shared.titan_foot_big,
    entity = shared.titan_prefix..shared.titan_warbringer,
    health = 30*1000,
    max_shield = 3, -- multiplied by base amount
    kill_cliffs = true,
    over_water = false,
    icon = shared.media_prefix.."graphics/icons/titan-3-wb.png",
    icon_size = 64, icon_mipmaps = 3,
    plane = shared.media_prefix.."graphics/titans/class3-wb.png",
    plane_size = 800,
    mounts = {
      [1] = { oris= 0.2, shift=10, layer=shared.rl_arm, grade=2, is_arm=true },
      [2] = { oris=-0.2, shift=10, layer=shared.rl_arm, grade=2, is_arm=true },
      [3] = { oris= 0,   shift=3,  layer=shared.rl_shoulder1, grade=4, is_top=true },
      [4] = { oris= 0.2, shift=9,  layer=shared.rl_shoulder2, grade=1, is_top=true },
      [5] = { oris=-0.2, shift=9,  layer=shared.rl_shoulder2, grade=1, is_top=true },
    },
    aux_laser = {
      {2, 0.15},
      {2,-0.15},
      {3, 0.35},
      {3,-0.35},
    },
  },
  {
    name = shared.titan_warlord,
    class = shared.class_warlord,
    spd = 10,
    ingredients = {
      {shared.bci,         1},
      {shared.energy_core, 5},
      {shared.servitor,    4},
      {shared.void_shield, 4},
      {shared.brain,       5},
      {shared.motor,      35},
      {shared.frame_part, 40},
      {shared.antigraveng, 3},
      {"laser-turret",     4},
    },
    foot = shared.titan_foot_big,
    entity = shared.titan_prefix..shared.titan_warlord,
    health = 40*1000,
    max_shield = 4, -- multiplied by base amount
    kill_cliffs = true,
    over_water = false,
    icon = shared.media_prefix.."graphics/icons/titan-3.png",
    icon_size = 64, icon_mipmaps = 3,
    plane = shared.media_prefix.."graphics/titans/class3.png",
    plane_size = 920,
    mounts = {
      [1] = { oris= 0.15, shift=11, layer=shared.rl_arm, grade=3, is_arm=true },
      [2] = { oris=-0.15, shift=11, layer=shared.rl_arm, grade=3, is_arm=true },
      [3] = { oris= 0.20, shift=6, layer=shared.rl_shoulder1, grade=2, is_top=true },
      [4] = { oris=-0.20, shift=6, layer=shared.rl_shoulder1, grade=2, is_top=true },
    },
    aux_laser = {
      {2, 0.15},
      {2,-0.15},
      {3, 0.35},
      {3,-0.35},
    },
  },
  {
    name = shared.titan_warmaster,
    class = shared.class_warmaster,
    spd = 9,
    ingredients = {
      {shared.bci,         1},
      {shared.energy_core, 7},
      {shared.servitor,    6},
      {shared.void_shield, 6},
      {shared.brain,       8},
      {shared.motor,      60},
      {shared.frame_part, 80},
      {shared.antigraveng, 6},
      {"laser-turret",     5},
    },
    foot = shared.titan_foot_big,
    entity = shared.titan_prefix..shared.titan_warmaster,
    health = 60*1000,
    max_shield = 6, -- multiplied by base amount
    kill_cliffs = true,
    over_water = false,
    icon = shared.media_prefix.."graphics/icons/titan-4.png",
    icon_size = 64, icon_mipmaps = 3,
    plane = shared.media_prefix.."graphics/titans/class4.png",
    plane_size = 1280,
    mounts = {
      [1] = { oris= 0.20, shift=18, layer=shared.rl_arm, grade=4, is_arm=true },
      [2] = { oris=-0.20, shift=18, layer=shared.rl_arm, grade=4, is_arm=true },
      [3] = { oris= 0.24, shift=15, layer=shared.rl_shoulder2, grade=2, is_top=true },
      [4] = { oris=-0.24, shift=15, layer=shared.rl_shoulder2, grade=2, is_top=true },
      [5] = { oris= 0,    shift=1,  layer=shared.rl_shoulder1,  grade=2, is_top=true, top_only=true },
    },
    aux_laser = {
      {4, 0.15},
      {4,-0.15},
      {6, 0.35},
      {6,-0.35},
      {0, 0},
    },
  },
  {
    name = shared.titan_imperator,
    class = shared.class_imperator,
    spd = 9,
    ingredients = {
      {shared.bci,          1},
      {shared.energy_core, 16},
      {shared.servitor,    14},
      {shared.void_shield, 12},
      {shared.brain,       10},
      {shared.motor,      100},
      {shared.frame_part, 180},
      {shared.antigraveng, 12},
      {"laser-turret",     11},
    },
    foot = shared.titan_foot_big,
    entity = shared.titan_prefix..shared.titan_imperator,
    health = 150*1000,
    max_shield = 12, -- multiplied by base amount
    kill_cliffs = true,
    over_water = true,
    icon = shared.media_prefix.."graphics/icons/titan-5.png",
    icon_size = 64, icon_mipmaps = 3,
    plane = nil, -- TODO: here!
    plane_size = nil,
    -- TODO: add towers!
    mounts = {
      [1] = { oris= 0.24, shift=10, layer=shared.rl_arm, grade=5, is_arm=true },
      [2] = { oris=-0.24, shift=10, layer=shared.rl_arm, grade=5, is_arm=true },
      [3] = { oris= 0.26, shift=10, layer=shared.rl_shoulder1, grade=4, is_top=true },
      [4] = { oris=-0.26, shift=10, layer=shared.rl_shoulder1, grade=4, is_top=true },
      [5] = { oris= 0,    shift=8,  layer=shared.rl_arm, grade=3 },
      [6] = { oris= 0,    shift=0,  layer=shared.rl_shoulder2, grade=3, is_top=true, top_only=true },
    },
    aux_laser = {
      {2, 0.25},
      {2,-0.25},
      {0, 0   },

      {5, 0.12},
      {5,-0.12},
      {5, 0.38},
      {5,-0.38},

      {8, 0.17},
      {8,-0.17},
      {8, 0.33},
      {8,-0.33},
    },
  },
  {
    name = shared.titan_warmonger,
    class = shared.class_warmonger,
    spd = 8,
    ingredients = {
      {shared.bci,          1},
      {shared.energy_core, 15},
      {shared.servitor,    12},
      {shared.void_shield, 10},
      {shared.brain,       10},
      {shared.motor,      100},
      {shared.frame_part, 150},
      {shared.antigraveng, 10},
      {"laser-turret",      7},
    },
    foot = shared.titan_foot_big,
    entity = shared.titan_prefix..shared.titan_warmonger,
    health = 120*1000,
    max_shield = 10, -- multiplied by base amount
    kill_cliffs = true,
    over_water = true,
    icon = shared.media_prefix.."graphics/icons/titan-5.png",
    icon_size = 64, icon_mipmaps = 3,
    plane = nil, -- TODO: here!
    plane_size = nil,
    -- TODO: add towers?
    mounts = {
      [1] = { oris= 0.24, shift=10, layer=shared.rl_arm, grade=5, is_arm=true },
      [2] = { oris=-0.24, shift=10, layer=shared.rl_arm, grade=5, is_arm=true },
      [3] = { oris= 0.26, shift=10, layer=shared.rl_shoulder1, grade=4, is_top=true },
      [4] = { oris=-0.26, shift=10, layer=shared.rl_shoulder1, grade=4, is_top=true },
      [5] = { oris= 0.24, shift=8,  layer=shared.rl_shoulder2, grade=4, is_top=true, top_only=true },
      [6] = { oris=-0.24, shift=8,  layer=shared.rl_shoulder2, grade=4, is_top=true, top_only=true },
    },
    aux_laser = {
      {2, 0.25},
      {2,-0.25},
      {0, 0   },

      {5, 0.12},
      {5,-0.12},
      {5, 0.38},
      {5,-0.38},
    },
  },
}
shared.titan_types = {}

for _, titan_type in pairs(shared.titan_type_list) do
  titan_type.available = not not titan_type.plane
  shared.titan_types[titan_type.class]  = titan_type
  shared.titan_types[titan_type.name]   = titan_type
  shared.titan_types[titan_type.entity] = titan_type
end

function shared.get_titan_assembly_time(titan_class_or_name)
  return math.pow(shared.titan_types[titan_class_or_name].health /1000, 1.2) * 10
end
