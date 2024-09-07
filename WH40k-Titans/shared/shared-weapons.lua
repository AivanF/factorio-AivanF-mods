local shared = require("shared.shared-base")

-- Aliases
shared.bolter_engine = shared.proj_engine
shared.rocketer_engine = shared.proj_engine
shared.quake_engine  = shared.proj_engine
shared.las_engine    = shared.he_emitter
-- shared.melta_engine  = he_emitter + melta_pump
-- shared.plasma_engine = he_emitter + emfc
-- shared.hell_engine   = ehe_emitter + melta_pump

--------- Titan weapon ammo aliases
shared.big_bolt =    shared.mod_prefix.."bolt-big"
shared.huge_bolt =   shared.mod_prefix.."bolt-huge"
-- shared.quake_proj =  shared.mod_prefix.."quake-projectile"
shared.flamer_ammo  = "flamethrower-ammo"
shared.laser_ammo   = shared.mod_prefix.."laser-ammo"
shared.melta_ammo   = shared.mod_prefix.."melta-ammo"
shared.plasma_ammo  = shared.bridge_prefix.."plasma-fuel"
shared.hell_ammo    = shared.mod_prefix.."hellstorm-ammo"
shared.missile_ammo = "explosive-rocket"

shared.ammo_weights = {
  [shared.big_bolt] = 1,
  [shared.huge_bolt] = 2,
  [shared.laser_ammo] = 1,
  [shared.flamer_ammo] = 1,
  [shared.melta_ammo] = 2,
  [shared.missile_ammo] = 1,
  [shared.plasma_ammo] = 2,
  [shared.hell_ammo] = 3,
}

shared.ammo_list = {
  shared.big_bolt, shared.huge_bolt, shared.flamer_ammo, shared.laser_ammo,
  shared.missile_ammo, shared.plasma_ammo, shared.melta_ammo, shared.hell_ammo,
}

--------- Titan weapon scaling
-- Specified size also allows to use 1 grade lower
shared.gun_grade_small  = 0
shared.gun_grade_medium = 1
shared.gun_grade_big    = 2
shared.gun_grade_huge   = 3

--------- Weapon categories
-- NOTE: number can be changed, thus shouldn't go to save files
-- This should be only used for faster runtime indexing
shared.wc_rocket = 01
shared.wc_bolter = 02
shared.wc_quake  = 03
shared.wc_flamer = 11
shared.wc_laser  = 12
shared.wc_plasma = 13
shared.wc_melta  = 14
shared.wc_hell   = 15
shared.wc_melee  = 21

--------- Bolt types
local bolt_types = {}
bolt_types.bolt_big = {
  entity = shared.mod_prefix.."bolt-big",
  single_damage = 1000,
}
bolt_types.bolt_huge = {
  entity = shared.mod_prefix.."bolt-huge",
  single_damage = 3000,
}
bolt_types.bolt_plasma_1 = {
  entity = shared.mod_prefix.."bolt-plasma-1",
  single_damage = 10 *1000,
}
bolt_types.bolt_plasma_2 = {
  entity = shared.mod_prefix.."bolt-plasma-2",
  single_damage = 25 *1000,
}
bolt_types.bolt_plasma_3 = {
  entity = shared.mod_prefix.."bolt-plasma-3",
  single_damage = 100 *1000,
}
bolt_types.bolt_rocket = {
  entity = shared.mod_prefix.."explosive-rocket",
  single_damage = 1000,
}
bolt_types.bolt_fire = {
  entity = "titanic-fire-stream",
  single_damage = 100+50*5,
}
bolt_types.bolt_laser = {
  entity = shared.mod_prefix.."bolt-laser",
  single_damage = 5000,
}

--------- Weapon types
shared.weapons = {}
local dst_s, dst_m, dst_l, dst_xl
dst_s, dst_m, dst_l, dst_xl = 96, 140, 192, 256
local wname = nil
local order_index = 1

local function add_weapon(weapon_type)
  order_index = order_index + 1
  weapon_type.order_index = order_index
  weapon_type.entity = shared.mod_prefix..weapon_type.name
  weapon_type.cd = weapon_type.cd or 3
  weapon_type.attack_size = weapon_type.attack_size or 1
  weapon_type.available = weapon_type.animation and weapon_type.ammo and weapon_type.bolt_type

  shared.weapons[weapon_type.entity] = weapon_type
  shared.weapons[weapon_type.name] = weapon_type
end


--------- 0. Zero

wname = "adrex-mega-bolter"  -- 5 big bolters
shared.weapon_adrexbolter = wname
add_weapon({
  name = wname,
  grade = shared.gun_grade_small,
  category = shared.wc_bolter,
  min_dst = 8, max_dst = dst_s,
  barrel = 6,
  ammo = shared.big_bolt,
  per_shot = 1, inventory = 2500,
  cd = 0.2, attack_size = 5, scatter = 2,
  bolt_type = bolt_types.bolt_big,
  attack_start_sound = "wh40k-titans-bolter-big",
  ingredients = {
    {shared.bolter_engine, 1},
    {shared.barrel, 5},
    {shared.frame_part, 1},
  },
  icon = shared.media_prefix.."graphics/icons/weapons/Bolter-Adrex.png",
  icon_size = 64, icon_mipmaps = 1,
  animation = shared.mod_prefix.."Bolter-Adrex",
})

wname = "lascannon"
shared.weapon_lascannon = wname
add_weapon({
  name = wname,
  grade = shared.gun_grade_small,
  category = shared.wc_laser,
  min_dst = 8, max_dst = dst_m,
  speed = 15, barrel = 12,
  ammo = shared.laser_ammo,
  per_shot = 2, inventory = 3000,
  cd = 0.4,
  bolt_type = bolt_types.bolt_laser,
  attack_sound = "wh40k-titans-laser",
  ingredients = {
    {shared.las_engine, 1},
    {shared.barrel, 2},
    {shared.frame_part, 2},
  },
  icon = shared.media_prefix.."graphics/icons/weapons/LasCannon.png",
  icon_size = 64, icon_mipmaps = 3,
  animation = shared.mod_prefix.."LasCannon",
})


--------- 1. Small

wname = "plasma-blastgun"
shared.weapon_plasma_blastgun = wname
add_weapon({
  name = wname,
  grade = shared.gun_grade_medium,
  category = shared.wc_plasma,
  min_dst = 10, max_dst = dst_s,
  ammo = shared.plasma_ammo,
  speed = 7, barrel = 10,
  per_shot = 2, inventory = 1000,
  cd = 1,
  bolt_type = bolt_types.bolt_plasma_1,
  attack_sound = "wh40k-titans-plasma-1",
  ingredients = {
    -- {shared.melta_pump, 2},
    {shared.he_emitter, 2},
    {shared.emfc, 2},
    {shared.barrel, 4},
    {shared.frame_part, 5},
  },
  icon = shared.media_prefix.."graphics/icons/weapons/Plasma-BlastGun.png",
  icon_size = 64, icon_mipmaps = 3,
  animation = shared.mod_prefix.."Plasma-BlastGun",
})

wname = "inferno"  -- 3 flamers
shared.weapon_inferno = wname
add_weapon({
  name = wname,
  grade = shared.gun_grade_medium,
  no_top = true,
  category = shared.wc_flamer,
  min_dst = 10, max_dst = dst_s,
  speed = 18, barrel = 9,
  ammo = shared.flamer_ammo,
  per_shot = 1, inventory = 4000,
  cd = 0.03, attack_size = 9, scatter = 6,
  bolt_type = bolt_types.bolt_fire,
  ingredients = {
    {shared.melta_pump, 3},
    {shared.barrel, 6},
    {shared.frame_part, 2},
  },
  icon = shared.media_prefix.."graphics/icons/weapons/Inferno.png",
  icon_size = 64, icon_mipmaps = 3,
  animation = shared.mod_prefix.."Inferno",
})

wname = "vulcan-mega-bolter"  -- 2 guns with 5 big bolters
shared.weapon_vulcanbolter = wname
add_weapon({
  name = wname,
  grade = shared.gun_grade_medium,
  category = shared.wc_bolter,
  min_dst = 10, max_dst = dst_m,
  ammo = shared.big_bolt,
  per_shot = 1, inventory = 5000,
  cd = 0.2, attack_size = 5, scatter = 3,
  bolt_type = bolt_types.bolt_big,
  attack_start_sound = "wh40k-titans-bolter-big",
  pre_attack_sound = "wh40k-titans-bolter-big-pre",
  ingredients = {
    {shared.bolter_engine, 2},
    {shared.barrel, 10},
    {shared.frame_part, 2},
  },
  icon = shared.media_prefix.."graphics/icons/weapons/Bolter-Vulcan.png",
  icon_size = 64, icon_mipmaps = 1,
  animation = shared.mod_prefix.."Bolter-Vulcan",
})

wname = "mauler-bolt-cannon"  -- 1 huge bolter
shared.weapon_boltcannon = wname
add_weapon({
  name = wname,
  grade = shared.gun_grade_medium,
  category = shared.wc_bolter,
  min_dst = 10, max_dst = dst_s,
  ammo = shared.huge_bolt,
  per_shot = 1, inventory = 500,
  cd = 0.1,
  bolt_type = bolt_types.bolt_huge,
  attack_sound = "wh40k-titans-bolter-huge",
  ingredients = {
    {shared.bolter_engine, 3},
    {shared.barrel, 4},
    {shared.frame_part, 4},
  },
  icon = "__base__/graphics/icons/gun-turret.png",
  icon_size = 64, icon_mipmaps = 4,
  animation = nil,  -- TODO: here!
})

wname = "turbo-laser-destructor"  -- 2 lasers
shared.weapon_turbolaser = wname
add_weapon({
  name = wname,
  grade = shared.gun_grade_medium,
  category = shared.wc_laser,
  min_dst = 10, max_dst = dst_m, spd=1.5,
  speed = 15, barrel = 12,
  ammo = shared.laser_ammo,
  per_shot = 3, inventory = 8000,
  cd = 0.15, attack_size = 3, scatter = 2,
  bolt_type = bolt_types.bolt_laser,
  attack_sound = "wh40k-titans-laser",
  ingredients = {
    {shared.las_engine, 2},
    {shared.barrel, 4},
    {shared.frame_part, 5},
  },
  icon = shared.media_prefix.."graphics/icons/weapons/Turbo-Laser.png",
  icon_size = 64, icon_mipmaps = 3,
  animation = shared.mod_prefix.."Turbo-Laser",
})

wname = "missile-launcher"
shared.weapon_missiles = wname
add_weapon({
  name = wname,
  grade = shared.gun_grade_medium,
  top_only = true,
  category = shared.wc_rocket,
  min_dst = 10, max_dst = (dst_m+dst_l)/2, max_dst = dst_l,
  speed = 1, barrel = 0,
  ammo = shared.missile_ammo,
  per_shot = 1, inventory = 4000,
  attack_size = 3, scatter = 4,
  cd = 0.3, bolt_type = bolt_types.bolt_rocket,
  start_far = true,
  attack_sound = "wh40k-titans-rocket",
  ingredients = {
    {shared.rocketer_engine, 4},
    {shared.barrel, 4},
    {shared.frame_part, 3},
  },
  icon = shared.media_prefix.."graphics/icons/weapons/MissileLauncher.png",
  icon_size = 64, icon_mipmaps = 3,
  animation = shared.mod_prefix.."MissileLauncher",
})

wname = "apocalypse-missiles"
shared.weapon_apocalypse_missiles = wname  -- faster & farther rockets
add_weapon({
  name = wname,
  grade = shared.gun_grade_big,
  top_only = true,
  category = shared.wc_rocket,
  min_dst = 10, max_dst = dst_l, max_dst = (dst_l+dst_xl)/2,
  speed = 1, barrel = 0,
  ammo = shared.missile_ammo,
  per_shot = 1, inventory = 12000,
  cd = 0.15, attack_size = 8, scatter = 6,
  bolt_type = bolt_types.bolt_rocket,
  start_far = true,
  attack_sound = "wh40k-titans-rocket",
  ingredients = {
    {shared.rocketer_engine, 10},
    {shared.barrel, 10},
    {shared.frame_part, 6},
  },
  icon = shared.media_prefix.."graphics/icons/weapons/ApocLauncher.png",
  icon_size = 64, icon_mipmaps = 3,
  animation = shared.mod_prefix.."ApocLauncher",
})


--------- 2. Medium

-- wname = "laser-blaster"  -- 3 lasers
-- shared.weapon_laserblaster = wname
-- add_weapon({
--   name = wname,
--   grade = shared.gun_grade_big,
--   category = shared.wc_laser,
--   min_dst = 12, max_dst = dst_l, spd=1.5,
--   speed = 20, barrel = 14,
--   ammo = shared.laser_ammo,
--   per_shot = 6, inventory = 15000,
--   cd = 0.1, attack_size = 6, scatter = 5,
--   bolt_type = bolt_types.bolt_laser,
--   attack_sound = "wh40k-titans-laser",
--   ingredients = {
--     {shared.las_engine, 3},
--     {shared.barrel, 6},
--     {shared.frame_part, 9},
--   },
--   icon = shared.media_prefix.."graphics/icons/weapons/Laser-Blaster.png",
--   icon_size = 64, icon_mipmaps = 3,
--   animation = shared.mod_prefix.."Laser-Blaster",
-- })

wname = "plasma-destructor"
shared.weapon_plasma_destructor = wname
add_weapon({
  name = wname,
  grade = shared.gun_grade_big,
  category = shared.wc_plasma,
  min_dst = 12, max_dst = dst_m,
  ammo = shared.plasma_ammo,
  speed = 7, barrel = 12,
  per_shot = 4, inventory = 2000,
  cd = 2,
  bolt_type = bolt_types.bolt_plasma_2,
  pre_attack_sound = "wh40k-titans-plasma-pre",
  attack_sound = "wh40k-titans-plasma-2",
  ingredients = {
    -- {shared.melta_pump, 4},
    {shared.he_emitter, 6},
    {shared.emfc, 6},
    {shared.barrel, 6},
    {shared.frame_part, 5},
  },
  icon = shared.media_prefix.."graphics/icons/weapons/Plasma-Destructor.png",
  icon_size = 64, icon_mipmaps = 3,
  animation = shared.mod_prefix.."Plasma-Destructor",
})

wname = "gatling-blaster"  -- 3 huge bolters
shared.weapon_gatling_blaster = wname
add_weapon({
  name = wname,
  grade = shared.gun_grade_big,
  category = shared.wc_bolter,
  min_dst = 12, max_dst = dst_m,
  ammo = shared.huge_bolt,
  per_shot = 1, inventory = 1000,
  attack_size = 3,
  attack_sound = "wh40k-titans-bolter-huge",
  bolt_type = bolt_types.bolt_huge,
  ingredients = {
    {shared.bolter_engine, 9},
    {shared.barrel, 12},
    {shared.frame_part, 5},
  },
  icon = "__base__/graphics/icons/gun-turret.png",
  icon_size = 64, icon_mipmaps = 4,
  animation = nil,  -- TODO: here!
})

-- wname = "quake-cannon"
-- shared.weapon_quake_cannon = wname
-- add_weapon({
--   name = wname,
--   grade = shared.gun_grade_big,
--   category = shared.wc_quake,
--   min_dst = 12, max_dst = dst_m, spd=0.5,
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
-- })
-- 
-- wname = "graviton-ruinator"
-- shared.weapon_graviton_ruinator = wname
-- add_weapon({
--   name = wname,
--   grade = shared.gun_grade_big,
--   category = shared.wc_quake,
--   min_dst = 12, max_dst = dst_l, spd=0.5,
--   ammo = shared.laser_ammo,
--   per_shot = 200, inventory = 1000,
--   ingredients = {
--     {shared.ehe_emitter, 6},
--     {shared.barrel, 4},
--     {shared.frame_part, 5},
--     {shared.antigraveng, 5},
--   },
--   icon = "__base__/graphics/icons/inserter.png",
--   icon_size = 64, icon_mipmaps = 4,
--   animation = nil,  -- TODO: here!
-- })
-- 
wname = "volkite-destructor"  -- quick big melta, short-range
shared.weapon_volkite_destructor = wname
add_weapon({
  name = wname,
  grade = shared.gun_grade_big,
  category = shared.wc_melta,
  min_dst = 12, max_dst = dst_m,
  ammo = shared.melta_ammo,
  per_shot = 1, inventory = 500,
  attack_size = 5,
  ingredients = {
    {shared.melta_pump, 6},
    {shared.he_emitter, 6},
    {shared.barrel, 8},
    {shared.frame_part, 5},
  },
  icon = "__base__/graphics/icons/flamethrower-turret.png",
  icon_size = 64, icon_mipmaps = 4,
  animation = nil,  -- TODO: here!
})

wname = "volcano-cannon"
shared.weapon_volcano_cannon = wname
add_weapon({
  name = wname,
  grade = shared.gun_grade_big,
  category = shared.wc_hell,
  min_dst = 12, max_dst = dst_l,
  ammo = shared.hell_ammo,
  ingredients = {
    {shared.melta_pump, 3},
    {shared.ehe_emitter, 3},
    {shared.barrel, 4},
    {shared.frame_part, 5},
  },
  per_shot = 2, inventory = 500,
  icon = "__base__/graphics/icons/flamethrower-turret.png",
  icon_size = 64, icon_mipmaps = 4,
  animation = nil,  -- TODO: here!
})


--------- 3. Huge

wname = "plasma-annihilator"
shared.weapon_plasma_annihilator = wname
add_weapon({
  name = wname,
  grade = shared.gun_grade_huge,
  category = shared.wc_plasma,
  min_dst = 20, max_dst = dst_l,
  ammo = shared.plasma_ammo,
  per_shot = 10, inventory = 50000,
  cd = 5,
  bolt_type = bolt_types.bolt_plasma_3,
  attack_sound = "wh40k-titans-plasma-2", -- TODO: replace
  ingredients = {
    -- {shared.melta_pump, 18},
    {shared.he_emitter, 18},
    {shared.emfc, 18},
    {shared.barrel, 10},
    {shared.frame_part, 10},
  },
  icon = shared.media_prefix.."graphics/icons/weapons/Plasma-Destructor.png",  -- TODO: replace
  icon_size = 64, icon_mipmaps = 3,
  animation = shared.mod_prefix.."Plasma-Destructor", -- TODO: replace
})

wname = "hellstorm-cannon"
shared.weapon_hellstorm_cannon = wname
add_weapon({
  name = wname,
  grade = shared.gun_grade_huge,
  category = shared.wc_hell,
  min_dst = 20, max_dst = dst_xl, spd=0.2,
  ammo = shared.hell_ammo,
  per_shot = 12, inventory = 12000,
  cd = 8,
  ingredients = {
    {shared.melta_pump, 12},
    {shared.ehe_emitter, 12},
    {shared.barrel, 30},
    {shared.frame_part, 18},
  },
  icon = "__base__/graphics/icons/flamethrower-turret.png",
  icon_size = 64, icon_mipmaps = 4,
  animation = nil,  -- TODO: here!
})

-- wname = "doomstrike-missiles"
-- shared.weapon_doomstrike_missiles = wname
-- add_weapon({
--   name = wname,
--   grade = shared.gun_grade_huge,
--   category = shared.wc_quake,
--   min_dst = 32, max_dst = dst_xl*1.5, spd=0.2,
--   ammo = shared.doom_rocket,
--   per_shot = 1, inventory = 16,
--   ingredients = {
--     {shared.rocketer_engine, 16},
--     {shared.barrel, 16},
--     {shared.frame_part, 11},
--   },
--   icon = shared.media_prefix.."graphics/icons/weapons/MissileLauncher.png", -- TODO: replace
--   icon_size = 64, icon_mipmaps = 3,
--   animation = shared.mod_prefix.."MissileLauncher", -- TODO: replace
-- })
-- 