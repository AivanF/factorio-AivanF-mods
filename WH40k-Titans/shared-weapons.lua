local shared = require("shared-base")

--------- Titan weapon parts items
shared.barrel      = shared.mod_prefix.."barrel"
shared.proj_engine = shared.mod_prefix.."projectile-engine"  -- for bolters
shared.he_emitter  = shared.mod_prefix.."he-emitter"  -- high energy for lasers
shared.ehe_emitter = shared.mod_prefix.."ehe-emitter" -- extra high energy for melta and hell cannon
-- TODO: add electro-magnetic manipulator for plasma guns and hell cannon

-- Aliases
shared.bolter_engine = shared.proj_engine
shared.rocket_engine = shared.proj_engine
shared.quake_engine  = shared.proj_engine
shared.las_engine    = shared.he_emitter
shared.melta_engine  = shared.he_emitter
shared.plasma_engine = shared.he_emitter
shared.hell_engine   = shared.ehe_emitter

--------- Titan weapon ammo
-- Custom
shared.big_bolt = shared.mod_prefix.."big-bolt"
shared.huge_bolt = shared.mod_prefix.."huge-bolt"
shared.quake_proj = shared.mod_prefix.."quake-projectile"
-- Builtin usage
shared.laser_ammo = "battery"
shared.plasma_ammo = "nuclear-fuel"
shared.melta_ammo = "nuclear-fuel"
shared.hell_ammo = "nuclear-fuel"
shared.missile_ammo = "explosive-rocket"

--------- Titan weapon scaling
-- Specified size also allows to use 1 grade lower
shared.gun_grade_small = 1
shared.gun_grade_medium = 2
shared.gun_grade_big = 3
shared.gun_grade_huge = 4

--------- Weapon classes
-- NOTE: number can be changed, shouldn't go to save files
shared.wc_rocket = 01
shared.wc_bolter = 02
shared.wc_quake  = 03
shared.wc_laser  = 11
shared.wc_plasma = 12
shared.wc_melta  = 13
shared.wc_hell   = 14

--------- Weapon types
shared.weapons = {}
local dst_s, dst_m, dst_l, dst_xl
dst_s, dst_m, dst_l, dst_xl = 64, 96, 160, 256
local wname = nil
local order_index = 1

--------- Small

wname = "vulcan-mega-bolter"  -- 2 guns with 6 big bolters
shared.weapon_megabolter = wname
shared.weapons[wname] = {
  name = wname,
  grade = shared.gun_grade_small,
  class = shared.wc_bolter,
  min_dst = 2, max_dst = dst_s, spd=3, dmg=1,
  ammo = shared.big_bolt,
  per_shot = 1, inventory = 2000,
  ingredients = {
    {shared.bolter_engine, 2},
    {shared.barrel, 10},
    {shared.frame_part, 2},
  },
  icon = "__base__/graphics/icons/gun-turret.png",
  icon_size = 64, icon_mipmaps = 4,
  animation = nil,  -- TODO: here!
  order_index = order_index,
}
order_index = order_index + 1

wname = "mauler-bolt-cannon"  -- 1 huge bolter
shared.weapon_boltcannon = wname
shared.weapons[wname] = {
  name = wname,
  grade = shared.gun_grade_small,
  class = shared.wc_bolter,
  min_dst = 4, max_dst = dst_s, spd=1, dmg=1,
  ammo = shared.huge_bolt,
  per_shot = 1, inventory = 500,
  ingredients = {
    {shared.bolter_engine, 3},
    {shared.barrel, 4},
    {shared.frame_part, 3},
  },
  icon = "__base__/graphics/icons/gun-turret.png",
  icon_size = 64, icon_mipmaps = 4,
  animation = nil,  -- TODO: here!
  order_index = order_index,
}
order_index = order_index + 1

wname = "missile-launcher"
shared.weapon_missiles = wname
shared.weapons[wname] = {
  name = wname,
  grade = shared.gun_grade_small,
  class = shared.wc_rocket,
  min_dst = 8, max_dst = dst_m, spd=1, dmg=1,
  ammo = shared.missile_ammo,
  per_shot = 1, inventory = 1000,
  ingredients = {
    {shared.rocket_engine, 4},
    {shared.barrel, 4},
    {shared.frame_part, 2},
  },
  icon = "__base__/graphics/icons/rocket-launcher.png",
  icon_size = 64, icon_mipmaps = 4,
  animation = nil,  -- TODO: here!
  order_index = order_index,
}
order_index = order_index + 1

wname = "lascannon"
shared.weapon_lascannon = wname
shared.weapons[wname] = {
  name = wname,
  grade = shared.gun_grade_small,
  class = shared.wc_laser,
  min_dst = 6, max_dst = dst_s, spd=1, dmg=1,
  ammo = shared.laser_ammo,
  per_shot = 2, inventory = 1000,
  ingredients = {
    {shared.las_engine, 1},
    {shared.barrel, 2},
    {shared.frame_part, 2},
  },
  icon = shared.media_prefix.."graphics/icons/weapons/LasCannon.png",
  icon_size = 64, icon_mipmaps = 3,
  animation = shared.mod_prefix.."LasCannon",
  order_index = order_index,
}
order_index = order_index + 1

wname = "plasma-destructor"
shared.weapon_plasma_destructor = wname
shared.weapons[wname] = {
  name = wname,
  grade = shared.gun_grade_small,
  class = shared.wc_plasma,
  min_dst = 6, max_dst = dst_s, spd=1, dmg=1,
  ammo = shared.plasma_ammo,
  per_shot = 3, inventory = 150,
  ingredients = {
    {shared.plasma_engine, 3},
    {shared.barrel, 4},
    {shared.frame_part, 2},
  },
  icon = "__base__/graphics/icons/flamethrower.png",
  icon_size = 64, icon_mipmaps = 4,
  animation = shared.mod_prefix.."Plasma-Destructor",
  order_index = order_index,
}
order_index = order_index + 1

--------- Medium

wname = "apocalypse-missiles"
shared.weapon_apocalypse_missiles = wname  -- faster & farther rockets
shared.weapons[wname] = {
  name = wname,
  grade = shared.gun_grade_medium,
  class = shared.wc_rocket,
  min_dst = 8, max_dst = dst_l, spd=2, dmg=1,
  ammo = shared.missile_ammo,
  per_shot = 1, inventory = 2000,
  ingredients = {
    {shared.rocket_engine, 10},
    {shared.barrel, 8},
    {shared.frame_part, 5},
  },
  icon = "__base__/graphics/icons/rocket-launcher.png",
  icon_size = 64, icon_mipmaps = 4,
  animation = nil,  -- TODO: here!
  order_index = order_index,
}
order_index = order_index + 1

wname = "turbo-laser-destructor"  -- 2 lasers
shared.weapon_turbolaser = wname
shared.weapons[wname] = {
  name = wname,
  grade = shared.gun_grade_medium,
  class = shared.wc_laser,
  min_dst = 8, max_dst = dst_m, spd=1.5, dmg=1.5,
  ammo = shared.laser_ammo,
  per_shot = 4, inventory = 4000,
  ingredients = {
    {shared.las_engine, 2},
    {shared.barrel, 4},
    {shared.frame_part, 5},
  },
  icon = shared.media_prefix.."graphics/icons/weapons/Turbo-Laser.png",
  icon_size = 64, icon_mipmaps = 3,
  animation = shared.mod_prefix.."Turbo-Laser",
  order_index = order_index,
}
order_index = order_index + 1

wname = "gatling-blaster"  -- 3 huge bolters
shared.weapon_gatling_blaster = wname
shared.weapons[wname] = {
  name = wname,
  grade = shared.gun_grade_medium,
  class = shared.wc_bolter,
  min_dst = 4, max_dst = dst_m, spd=3, dmg=1,
  ammo = shared.huge_bolt,
  per_shot = 1, inventory = 1000,
  ingredients = {
    {shared.bolter_engine, 9},
    {shared.barrel, 12},
    {shared.frame_part, 4},
  },
  icon = "__base__/graphics/icons/gun-turret.png",
  icon_size = 64, icon_mipmaps = 4,
  animation = nil,  -- TODO: here!
  order_index = order_index,
}
order_index = order_index + 1

-- wname = "quake-cannon"
-- shared.weapon_quake_cannon = wname
-- shared.weapons[wname] = {
--   name = wname,
--   grade = shared.gun_grade_medium,
--   class = shared.wc_quake,
--   min_dst = 8, max_dst = dst_m, spd=0.5, dmg=1,
--   ammo = shared.quake_proj,
--   per_shot = 1, inventory = 200,
--   ingredients = {
--     {shared.quake_engine, 3},
--     {shared.barrel, 4},
--     {shared.frame_part, 5},
--   },
--   icon = "__base__/graphics/icons/grenade.png",
--   icon_size = 64, icon_mipmaps = 4,
--   animation = nil,  -- TODO: here!
--   order_index = order_index,
-- }
-- order_index = order_index + 1

wname = "volcano-cannon"
shared.weapon_volcano_cannon = wname
shared.weapons[wname] = {
  name = wname,
  grade = shared.gun_grade_medium,
  class = shared.wc_hell,
  min_dst = 6, max_dst = dst_m, spd=1, dmg=1,
  ammo = shared.hell_ammo,
  ingredients = {
    {shared.hell_engine, 3},
    {shared.barrel, 4},
    {shared.frame_part, 5},
  },
  per_shot = 2, inventory = 500,
  icon = "__base__/graphics/icons/flamethrower-turret.png",
  icon_size = 64, icon_mipmaps = 4,
  animation = nil,  -- TODO: here!
  order_index = order_index,
}
order_index = order_index + 1

--------- Big

-- wname = "graviton-ruinator"
-- shared.weapon_graviton_ruinator = wname
-- shared.weapons[wname] = {
--   name = wname,
--   grade = shared.gun_grade_big,
--   class = shared.wc_quake,
--   min_dst = 8, max_dst = dst_l, spd=0.5, dmg=2,
--   ammo = shared.laser_ammo,
--   per_shot = 200, inventory = 1000,
--   ingredients = {
--     {shared.ehe_emitter, 6},
--     {shared.barrel, 4},
--     {shared.frame_part, 5},
--   },
--   icon = "__base__/graphics/icons/inserter.png",
--   icon_size = 64, icon_mipmaps = 4,
--   animation = nil,  -- TODO: here!
--   order_index = order_index,
-- }
-- order_index = order_index + 1

wname = "volkite-destructor"  -- quick big melta, short-range
shared.weapon_volkite_destructor = wname
shared.weapons[wname] = {
  name = wname,
  grade = shared.gun_grade_big,
  class = shared.wc_melta,
  min_dst = 4, max_dst = dst_m, spd=1, dmg=1,
  ammo = shared.melta_ammo,
  per_shot = 1, inventory = 500,
  ingredients = {
    {shared.melta_engine, 6},
    {shared.barrel, 8},
    {shared.frame_part, 10},
  },
  icon = "__base__/graphics/icons/flamethrower-turret.png",
  icon_size = 64, icon_mipmaps = 4,
  animation = nil,  -- TODO: here!
  order_index = order_index,
}
order_index = order_index + 1

wname = "plasma-annihilator"
shared.weapon_plasma_annihilator = wname
shared.weapons[wname] = {
  name = wname,
  grade = shared.gun_grade_big,
  class = shared.wc_plasma,
  min_dst = 8, max_dst = dst_l, spd=1, dmg=2,
  ammo = shared.plasma_ammo,
  per_shot = 10, inventory = 500,
  ingredients = {
    {shared.plasma_engine, 6},
    {shared.barrel, 10},
    {shared.frame_part, 6},
  },
  icon = "__base__/graphics/icons/flamethrower.png",
  icon_size = 64, icon_mipmaps = 4,
  animation = shared.mod_prefix.."Plasma-Destructor",  -- TODO: replace
  order_index = order_index,
}
order_index = order_index + 1

--------- Huge

wname = "hellstorm-cannon"
shared.weapon_hellstorm_cannon = wname
shared.weapons[wname] = {
  name = wname,
  grade = shared.gun_grade_huge,
  class = shared.wc_hell,
  min_dst = 8, max_dst = dst_l, spd=0.2, dmg=10,
  ammo = shared.hell_ammo,
  per_shot = 12, inventory = 1000,
  ingredients = {
    {shared.hell_engine, 12},
    {shared.barrel, 30},
    {shared.frame_part, 19},
  },
  icon = "__base__/graphics/icons/flamethrower-turret.png",
  icon_size = 64, icon_mipmaps = 4,
  animation = nil,  -- TODO: here!
  order_index = order_index,
}
order_index = order_index + 1
