local shared = require("shared-base")

-- Titan body parts items
shared.energy_core = shared.mod_prefix.."energy-core"
shared.servitor    = shared.mod_prefix.."servitor"
shared.void_shield = shared.mod_prefix.."void-shield-gen"
shared.brain       = shared.mod_prefix.."brain"
shared.motor       = shared.mod_prefix.."motor"
shared.frame_part  = shared.mod_prefix.."frame-part"

-- Other
shared.titan_foot_small = shared.mod_prefix.."foot-small"
shared.titan_foot_big   = shared.mod_prefix.."foot-big"

-- Titan types
shared.titan_1warhound  = "1-warhound"
shared.titan_2reaver    = "2-reaver"
shared.titan_3warlord   = "3-warlord"
shared.titan_4warmaster = "4-warmaster"
shared.titan_5emperor   = "5-emperor"

-- TODO: move into shared
local shadow_render_layer = 144
local lower_render_layer = 168
local arm_render_layer = 169
local body_render_layer = 170
local shoulder_render_layer = 171


local titan_class_list = {
  {
    name = shared.titan_1warhound,
    class = 1,
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
    },
    entity = shared.titan_prefix..shared.titan_1warhound,
    health = 10000,
    kill_cliffs = false,
    over_water = false,
    icon = shared.media_prefix.."graphics/icons/titan-1.png",
    icon_size = 64, icon_mipmaps = 3,
    guns = {
      [1] = { oris=-0.25, shift=7, layer=arm_render_layer, grade=1 },
      [2] = { oris= 0.25, shift=7, layer=arm_render_layer, grade=1 },
    },
  },
  {
    name = shared.titan_2reaver,
    class = 2,
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
    },
    entity = shared.titan_prefix..shared.titan_2reaver,
    health = 25000,
    kill_cliffs = false,
    over_water = false,
    icon = shared.media_prefix.."graphics/icons/titan-2.png",
    icon_size = 64, icon_mipmaps = 3,
    guns = {
      [1] = { oris=-0.25, shift = 8, layer=arm_render_layer, grade=2 },
      [2] = { oris= 0.25, shift = 8, layer=arm_render_layer, grade=2 },
      [3] = { oris= 0,    shift = 2, layer=shoulder_render_layer, grade=1, is_shoulder=true },
    },
  },
  {
    name = shared.titan_3warlord,
    class = 3,
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
    },
    entity = shared.titan_prefix..shared.titan_3warlord,
    health = 40000,
    kill_cliffs = true,
    over_water = false,
    icon = shared.media_prefix.."graphics/icons/titan-3.png",
    icon_size = 64, icon_mipmaps = 3,
    guns = {
      [1] = { oris=-0.24, shift=8, layer=arm_render_layer, grade=3 },
      [2] = { oris= 0.24, shift=8, layer=arm_render_layer, grade=3 },
      [3] = { oris=-0.26, shift=8, layer=shoulder_render_layer, grade=2, is_shoulder=true },
      [4] = { oris= 0.26, shift=8, layer=shoulder_render_layer, grade=2, is_shoulder=true },
    },
  },
  {
    name = shared.titan_4warmaster,
    class = 4,
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
    },
    entity = shared.titan_prefix..shared.titan_4warmaster,
    health = 80000,
    kill_cliffs = true,
    over_water = false,
    icon = shared.media_prefix.."graphics/icons/titan-4.png",
    icon_size = 64, icon_mipmaps = 3,
    guns = {
      [1] = { oris=-0.24, shift=10, layer=arm_render_layer, grade=4 },
      [2] = { oris= 0.24, shift=10, layer=arm_render_layer, grade=4 },
      [3] = { oris=-0.26, shift=10, layer=shoulder_render_layer, grade=2, is_shoulder=true },
      [4] = { oris= 0.26, shift=10, layer=shoulder_render_layer, grade=2, is_shoulder=true },
      [5] = { oris=-0.24, shift=8, layer=arm_render_layer, grade=1 },
      [6] = { oris= 0.24, shift=8, layer=arm_render_layer, grade=1 },
    },
  },
  {
    name = shared.titan_5emperor,
    class = 5,
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
    },
    entity = shared.titan_prefix..shared.titan_5emperor,
    health = 150000,
    kill_cliffs = true,
    over_water = true,
    icon = shared.media_prefix.."graphics/icons/titan-5.png",
    icon_size = 64, icon_mipmaps = 3,
    guns = {
      [1] = { oris=-0.24, shift=10, layer=arm_render_layer, grade=4 },
      [2] = { oris= 0.24, shift=10, layer=arm_render_layer, grade=4 },
      [3] = { oris=-0.26, shift=10, layer=shoulder_render_layer, grade=3, is_shoulder=true },
      [4] = { oris= 0.26, shift=10, layer=shoulder_render_layer, grade=3, is_shoulder=true },
      [5] = { oris=-0.24, shift=8, layer=arm_render_layer, grade=2 },
      [6] = { oris= 0.24, shift=8, layer=arm_render_layer, grade=2 },
    },
  },
}
shared.titan_classes = {}

for _, info in pairs(titan_class_list) do
  shared.titan_classes[info.class] = info
  shared.titan_classes[info.name] = info
  shared.titan_classes[info.entity] = info
end
