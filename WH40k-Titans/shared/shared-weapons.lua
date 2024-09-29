local shared = require("shared.shared-base")
local UPS = 60

shared.worldbreaker = shared.mod_prefix.."worldbreaker"

-- Aliases
shared.bolter_engine = shared.proj_engine
shared.rocketer_engine = shared.proj_engine
shared.quake_engine  = shared.proj_engine
shared.las_engine    = shared.he_emitter
-- shared.melta_engine  = he_emitter + melta_pump
-- shared.plasma_engine = he_emitter + emfc
-- shared.hell_engine   = ehe_emitter + melta_pump

shared.arty = shared.mod_prefix.."artillery-turret"
shared.arty_invsz = 10

shared.titan_arm_length = 6.5

--------- Titan weapon ammo aliases
shared.big_bolt     = shared.mod_prefix.."bolt-big"
shared.huge_bolt    = shared.mod_prefix.."bolt-huge"  -- DEPRECATED!
shared.cannon_shell = "explosive-cannon-shell"
-- shared.quake_proj   = shared.mod_prefix.."quake-projectile"
shared.flamer_ammo  = "flamethrower-ammo"
shared.laser_ammo   = shared.mod_prefix.."laser-ammo"
shared.melta_ammo   = shared.mod_prefix.."melta-ammo"
shared.plasma_ammo  = shared.bridge_prefix.."plasma-fuel"
shared.hell_ammo    = shared.mod_prefix.."hellstorm-ammo"
shared.missile_ammo = "explosive-rocket"

shared.empty_missile_ammo = shared.mod_prefix.."empty-missile"
shared.doom_missile_ammo = shared.mod_prefix.."doom-missile"
shared.plasma_missile_ammo = shared.mod_prefix.."plasma-missile"
shared.warp_missile_ammo = shared.mod_prefix.."warp-missile"

shared.ammo_weights = {
  [shared.big_bolt] = 1,
  -- [shared.huge_bolt] = 2,
  [shared.cannon_shell] = 1,
  [shared.laser_ammo] = 1,
  [shared.flamer_ammo] = 1,
  [shared.melta_ammo] = 2,
  [shared.missile_ammo] = 1,
  [shared.plasma_ammo] = 2,
  [shared.hell_ammo] = 3,
  [shared.doom_missile_ammo] = 5,
  [shared.plasma_missile_ammo] = 5,
  [shared.warp_missile_ammo] = 5,
}

shared.ammo_list = {
  shared.big_bolt, shared.flamer_ammo, shared.laser_ammo,
  shared.missile_ammo, shared.plasma_ammo, shared.melta_ammo, shared.hell_ammo,
  shared.doom_missile_ammo, shared.plasma_missile_ammo, shared.warp_missile_ammo,
}

--------- Titan weapon scaling
-- Specified size also allows to use 1 grade lower
shared.gun_grade_0m = 0 -- Minimalis
shared.gun_grade_1v = 1 -- Validus
shared.gun_grade_2s = 2 -- Solidus
shared.gun_grade_3f = 3 -- Fortis
shared.gun_grade_4m = 4 -- Magnus
shared.gun_grade_5g = 5 -- Grandis

--------- Weapon categories
-- NOTE: number can be changed, thus shouldn't go to save files
-- This should be only used for faster runtime index lookups
shared.wc_rocket = 01
shared.wc_bolter = 02
shared.wc_quake  = 03
shared.wc_flamer = 11
shared.wc_laser  = 12
shared.wc_plasma = 13
shared.wc_melta  = 14
shared.wc_hell   = 15
shared.wc_arty   = 21
shared.wc_melee  = 31

--------- Bolt types
local bolt_types = {}
bolt_types.bolt_melee = {
  entity = shared.mod_prefix.."bolt-melee",
  single_damage = 10 *1000,
}
bolt_types.bolt_big = {
  entity = shared.mod_prefix.."bolt-big",
  single_damage = 1000,
}
-- bolt_types.bolt_huge = {
--   entity = shared.mod_prefix.."bolt-huge",
--   single_damage = 3000,
-- }
bolt_types.cannon_shell = {
  entity = shared.mod_prefix.."cannon-shell",
  single_damage = 4000,
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
  single_damage = 50 *1000,
}
bolt_types.bolt_plasma_4 = {
  entity = shared.mod_prefix.."bolt-plasma-4",
  single_damage = 120 *1000,
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
  single_damage = 5 *1000,
}
bolt_types.bolt_volcano = {
  entity = shared.mod_prefix.."bolt-volcano",
  single_damage = 25 *1000,
}
shared.bolt_types = bolt_types

--------- Weapon types
shared.weapons = {}
local dst_s, dst_m, dst_l, dst_xl
dst_s, dst_m, dst_l, dst_xl = 96, 140, 192, 256
local wname = nil
local order_index = 1


local function add_weapon_cannon(weapon_type)
  weapon_type.cd = weapon_type.cd or 3
  weapon_type.per_shot = weapon_type.per_shot or 1
  weapon_type.attack_size = weapon_type.attack_size or 1

  weapon_type.available = true
    and weapon_type.animation
    and (weapon_type.bolt_type and weapon_type.ammo or weapon_type.ammo_category)
end

local function add_weapon_melee(weapon_type)
  -- Convert from Factorio ori to radians
  weapon_type.arc_angle = weapon_type.half_angle * math.pi * 4

  weapon_type.attack_ticks = {}
  for i = 1, weapon_type.attack_size do
    table.insert(weapon_type.attack_ticks, math.floor(weapon_type.usage_time/4 + weapon_type.usage_time/2 * i/weapon_type.attack_size))
  end

  weapon_type.available = weapon_type.animation and weapon_type.usage_time
end


local wc_define = {}
wc_define[shared.wc_melee] = add_weapon_melee

local function add_weapon(weapon_type)
  order_index = order_index + 1
  weapon_type.order_index = order_index
  weapon_type.entity = shared.mod_prefix..weapon_type.name;

  (wc_define[weapon_type.category] or add_weapon_cannon)(weapon_type);

  shared.weapons[weapon_type.entity] = weapon_type
  shared.weapons[weapon_type.name] = weapon_type
end


--------- 0. Zero

wname = "adrex-mega-bolter"  -- 5 big bolters
shared.weapon_adrexbolter = wname
add_weapon({
  name = wname,
  grade = shared.gun_grade_0m,
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
  icon_size = 64, icon_mipmaps = 3,
  animation = shared.mod_prefix.."Bolter-Adrex",
})

wname = "lascannon"
shared.weapon_lascannon = wname
add_weapon({
  name = wname,
  grade = shared.gun_grade_0m,
  category = shared.wc_laser,
  min_dst = 8, max_dst = dst_m,
  speed = 15, barrel = 8,
  ammo = shared.laser_ammo,
  per_shot = 2, inventory = 3000,
  cd = 0.6,
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
  grade = shared.gun_grade_1v,
  category = shared.wc_plasma,
  min_dst = 10, max_dst = dst_s,
  ammo = shared.plasma_ammo,
  speed = 7, barrel = 10,
  per_shot = 2, inventory = 1000,
  cd = 1,
  bolt_type = bolt_types.bolt_plasma_1,
  attack_sound = "wh40k-titans-plasma-1",
  ingredients = {
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
  grade = shared.gun_grade_1v,
  -- no_top = true,
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
  grade = shared.gun_grade_1v,
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

-- wname = "mauler-bolt-cannon"  -- 1 huge bolter
-- shared.weapon_boltcannon = wname
-- add_weapon({
--   name = wname,
--   grade = shared.gun_grade_1v,
--   category = shared.wc_bolter,
--   min_dst = 10, max_dst = dst_m,
--   ammo = shared.huge_bolt,
--   per_shot = 1, inventory = 1000,
--   cd = 0.1,
--   bolt_type = bolt_types.bolt_huge,
--   attack_sound = "wh40k-titans-bolter-huge",
--   ingredients = {
--     {shared.bolter_engine, 3},
--     {shared.barrel, 4},
--     {shared.frame_part, 4},
--   },
--   icon = "__base__/graphics/icons/gun-turret.png",
--   icon_size = 64, icon_mipmaps = 4,
--   animation = nil,  -- TODO: here!
-- })

wname = "turbo-laser-destructor"  -- 2 lasers
shared.weapon_turbolaser = wname
add_weapon({
  name = wname,
  grade = shared.gun_grade_1v,
  category = shared.wc_laser,
  min_dst = 10, max_dst = dst_m, spd=1.5,
  speed = 15, barrel = 8,
  ammo = shared.laser_ammo,
  per_shot = 1, inventory = 8000,
  cd = 0.4, attack_size = 3, scatter = 2,
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
  grade = shared.gun_grade_1v,
  top_only = true,
  category = shared.wc_rocket,
  min_dst = 16, max_dst = (dst_m+dst_l)/2, max_dst = dst_l, max_orid = 0.03,
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
  grade = shared.gun_grade_2s,
  top_only = true,
  category = shared.wc_rocket,
  min_dst = 16, max_dst = dst_l, max_dst = (dst_l+dst_xl)/2, max_orid = 0.03,
  speed = 1, barrel = 0,
  ammo = shared.missile_ammo,
  per_shot = 1, inventory = 12000,
  cd = 0.15, attack_size = 8, scatter = 8,
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

wname = "laser-blaster"  -- 3 lasers
shared.weapon_laserblaster = wname
add_weapon({
  name = wname,
  grade = shared.gun_grade_2s,
  category = shared.wc_laser,
  min_dst = 12, max_dst = dst_l, spd=1.5,
  speed = 20, barrel = 8,
  ammo = shared.laser_ammo,
  per_shot = 1, inventory = 12000,
  cd = 0.2, attack_size = 6, scatter = 6,
  bolt_type = bolt_types.bolt_laser,
  attack_sound = "wh40k-titans-laser",
  ingredients = {
    {shared.las_engine, 3},
    {shared.barrel, 6},
    {shared.frame_part, 9},
  },
  icon = shared.media_prefix.."graphics/icons/weapons/Laser-Blaster.png",
  icon_size = 64, icon_mipmaps = 3,
  animation = shared.mod_prefix.."Laser-Blaster",
})

wname = "gatling-blaster"  -- 6 huge bolters/autocannons
shared.weapon_gatling_blaster = wname
add_weapon({
  name = wname,
  grade = shared.gun_grade_2s,
  category = shared.wc_bolter,
  min_dst = 12, max_dst = (dst_m+dst_l)/2,
  barrel = 8,
  ammo = shared.cannon_shell,
  per_shot = 1, inventory = 6000,
  cd = 0.2, attack_size = 6, scatter = 5,
  pre_attack_sound = "wh40k-titans-bolter-big-pre",
  attack_sound = "wh40k-titans-bolter-huge",
  bolt_type = bolt_types.cannon_shell,
  ingredients = {
    {shared.bolter_engine, 6},
    {shared.barrel, 12},
    {shared.frame_part, 7},
  },
  icon = shared.media_prefix.."graphics/icons/weapons/Gatling-Blaster.png",
  icon_size = 64, icon_mipmaps = 3,
  animation = shared.mod_prefix.."Gatling-Blaster",
})

wname = "volcano-cannon"
shared.weapon_volcano_cannon = wname
add_weapon({
  name = wname,
  grade = shared.gun_grade_2s,
  category = shared.wc_laser,
  min_dst = 14, max_dst = dst_m,
  speed = {4, 6, 8, 10}, barrel = 10,
  ammo = shared.laser_ammo,
  cd = 1, attack_size = 1, scatter = 1,
  per_shot = 1, inventory = 1000,
  bolt_type = bolt_types.bolt_volcano,
  attack_sound = "wh40k-titans-laser",
  ammo = shared.hell_ammo,
  ingredients = {
    {shared.melta_pump, 3},
    {shared.ehe_emitter, 3},
    {shared.barrel, 4},
    {shared.frame_part, 5},
  },
  icon = shared.media_prefix.."graphics/icons/weapons/VolcanoCannon.png",
  icon_size = 64, icon_mipmaps = 4,
  animation = shared.mod_prefix.."VolcanoCannon",
})



--------- 3. Better: Reaver top, WarLord arms

wname = "plasma-sunfury"  -- Plasma 2: SunFury pattern Plasma Destructor/Annihilator
shared.weapon_plasma_sunfury = wname
add_weapon({
  name = wname,
  grade = shared.gun_grade_3f,
  category = shared.wc_plasma,
  min_dst = 12, max_dst = dst_m,
  ammo = shared.plasma_ammo,
  speed = 7, barrel = 12,
  per_shot = 4, inventory = 2000,
  cd = 2,
  bolt_type = bolt_types.bolt_plasma_2,
  attack_sound = "wh40k-titans-plasma-2",
  ingredients = {
    {shared.he_emitter, 6},
    {shared.emfc, 6},
    {shared.barrel, 6},
    {shared.frame_part, 5},
  },
  icon = shared.media_prefix.."graphics/icons/weapons/Plasma-SunFury.png",
  icon_size = 64, icon_mipmaps = 3,
  animation = shared.mod_prefix.."Plasma-SunFury",
})

wname = "volkite-destructor"  -- quick big melta, short-range
shared.weapon_volkite_destructor = wname
add_weapon({
  name = wname,
  grade = shared.gun_grade_3f,
  category = shared.wc_melta,
  min_dst = 12, max_dst = dst_m,
  ammo = shared.melta_ammo,
  speed = {2, 3, 4, 5}, scatter = 3, barrel = 12,
  per_shot = 1, inventory = 1000,
  cd = 1,
  bolt_type = bolt_types.bolt_volcano,  -- TODO: replace!
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

wname = "chainsword"
shared.weapon_chainsword = wname
add_weapon({
  name = wname,
  grade = shared.gun_grade_3f,
  category = shared.wc_melee,
  on_arm = true,
  no_top = true,
  bolt_type = bolt_types.bolt_melee,
  attack_size = 10,
  medium_length = 16,
  usage_time = 2 * UPS,
  half_angle = 0.15,
  pre_attack_sound = "wh40k-titans-chainsword",
  attack_sound = nil,
  ingredients = {
    {shared.antigraveng, 1},
    {shared.motor, 12},
    {shared.frame_part, 16},
  },
  icon = shared.media_prefix.."graphics/icons/weapons/ChainSword.png",
  icon_size = 64, icon_mipmaps = 3,
  animation = shared.mod_prefix.."ChainSword",
})



--------- 4. Big: WarBringer top, WarMaster arms

wname = "plasma-destructor"  -- Plasma 3: Suzerain class Plasma Destructor/Annihilator
shared.weapon_plasma_destructor = wname
add_weapon({
  name = wname,
  grade = shared.gun_grade_4m,
  category = shared.wc_plasma,
  min_dst = 12, max_dst = (dst_m + dst_l) / 2,
  ammo = shared.plasma_ammo,
  speed = 7, barrel = 12,
  per_shot = 6, inventory = 4000,
  cd = 1.5,
  bolt_type = bolt_types.bolt_plasma_3,
  pre_attack_sound = "wh40k-titans-plasma-pre",
  attack_sound = "wh40k-titans-plasma-2",
  ingredients = {
    {shared.he_emitter, 8},
    {shared.emfc, 8},
    {shared.barrel, 8},
    {shared.frame_part, 8},
  },
  icon = shared.media_prefix.."graphics/icons/weapons/Plasma-Suzerain.png",
  icon_size = 64, icon_mipmaps = 3,
  animation = shared.mod_prefix.."Plasma-Suzerain",
})

-- wname = "quake-cannon"
-- shared.weapon_quake_cannon = wname
-- add_weapon({
--   name = wname,
--   grade = shared.gun_grade_4m,
--   category = shared.wc_quake,
--   min_dst = 12, max_dst = dst_m, spd=0.5,
--   ammo = shared.quake_proj,
--   per_shot = 1, inventory = 500,
--   ingredients = {
--     {shared.quake_engine, 3},
--     {shared.barrel, 4},
--     {shared.frame_part, 5},
--   },
--   icon = "__base__/graphics/icons/grenade.png",
--   icon_size = 64, icon_mipmaps = 4,
--   animation = nil,  -- TODO: here!
-- })

-- wname = "graviton-ruinator"
-- shared.weapon_graviton_ruinator = wname
-- add_weapon({
--   name = wname,
--   grade = shared.gun_grade_4m,
--   category = shared.wc_quake,
--   min_dst = 12, max_dst = dst_m, spd=0.5,
--   ammo = shared.laser_ammo,
--   per_shot = 100, inventory = 5000,
--   ingredients = {
--     {shared.ehe_emitter, 8},
--     {shared.barrel, 12},
--     {shared.frame_part, 7},
--     {shared.antigraveng, 12},
--   },
--   icon = "__base__/graphics/icons/inserter.png",
--   icon_size = 64, icon_mipmaps = 4,
--   animation = nil,  -- TODO: here!
-- })

-- wname = "artillery-turret"
-- shared.weapon_artillery = wname
-- add_weapon({
--   name = wname,
--   grade = shared.gun_grade_4m,
--   top_only = true,
--   category = shared.wc_arty,

--   -- ammo = "mortar-cluster-bomb",
--   ammo = "artillery-shell",
--   -- ammo_category = "artillery-shell",

--   per_shot = 1, inventory = 200,
--   attack_sound = "wh40k-titans-rocket",
--   ingredients = {
--     {"artillery-turret", 1},
--     {shared.proj_engine, 3},
--     {shared.barrel, 3},
--     {shared.frame_part, 4},
--   },
--   icon = "__base__/graphics/icons/artillery-turret.png",
--   icon_size = 64, icon_mipmaps = 4,
--   animation = shared.mod_prefix.."ApocLauncher",
-- })



--------- 5. Huge: Emperor arms

wname = "plasma-annihilator"  -- Plasma 4 Grand Annihilator
shared.weapon_plasma_annihilator = wname
add_weapon({
  name = wname,
  grade = shared.gun_grade_5g,
  category = shared.wc_plasma,
  min_dst = 32, max_dst = dst_l,
  ammo = shared.plasma_ammo,
  per_shot = 10, inventory = 10000,
  cd = 5,
  bolt_type = bolt_types.bolt_plasma_4,
  pre_attack_sound = "wh40k-titans-plasma-pre",
  attack_sound = "wh40k-titans-plasma-2", -- TODO: replace
  ingredients = {
    {shared.he_emitter, 18},
    {shared.emfc, 18},
    {shared.barrel, 12},
    {shared.frame_part, 12},
  },
  icon = shared.media_prefix.."graphics/icons/weapons/Plasma-Annihilator.png",
  icon_size = 64, icon_mipmaps = 3,
  animation = shared.mod_prefix.."Plasma-Annihilator",
})

wname = "hellstorm-cannon"
shared.weapon_hellstorm_cannon = wname
add_weapon({
  name = wname,
  grade = shared.gun_grade_5g,
  category = shared.wc_hell,
  min_dst = 32, max_dst = dst_xl, spd=0.2,
  speed = {6, 7, 8, 9, 10, 11},
  ammo = shared.hell_ammo,
  per_shot = 12, inventory = 10000,
  cd = 6,
  bolt_type = bolt_types.bolt_volcano,
  -- TODO: add sounds
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
--   grade = shared.gun_grade_5g,
--   category = shared.wc_quake,
--   min_dst = 48, max_dst = dst_xl*3, spd=0.2,  -- TODO: don't draw such large circle!
--   ammo = shared.doom_missile_ammo,
--   per_shot = 1, inventory = 16,
--   ingredients = {
--     {shared.rocketer_engine, 16},
--     {shared.barrel, 16},
--     {shared.frame_part, 11},
--   },
--   icon = shared.media_prefix.."graphics/icons/weapons/MissileLauncher.png", -- TODO: replace
--   icon_size = 64, icon_mipmaps = 3,
--   animation = nil,  -- TODO: here!
-- })


shared.get_weapon_descr = function (weapon_type)
  local ammo = weapon_type.ammo or "unknown"
  local own_descr = {"item-description."..weapon_type.entity}
  local damage = weapon_type.bolt_type and (weapon_type.attack_size * weapon_type.bolt_type.single_damage) or nil
  if type(weapon_type.speed) == "table" then damage = #weapon_type.speed * damage end
  local stats_descr
  if weapon_type.category == shared.wc_melee then
    stats_descr = {"item-description.wh40k-titan-weapon-melee", weapon_type.grade, shorten_number(damage)}
  else
    stats_descr = {
      (weapon_type.attack_size == 1) and "item-description.wh40k-titan-weapon-1" or "item-description.wh40k-titan-weapon-n",
      -- Args:
      weapon_type.grade,
      weapon_type.ammo and {"item-name."..weapon_type.ammo} or {"ammo-category-name."..weapon_type.ammo_category}, -- "__ITEM__"..ammo.."__"
      weapon_type.per_shot,
      shorten_number(weapon_type.inventory),
      weapon_type.bolt_type and shorten_number(damage) or "terrible", -- TODO: replace/translate it!
      weapon_type.attack_size,
    }
  end
  local full_descr = {"?", {"", own_descr, " ", stats_descr}, stats_descr}
  return weapon_type.available and full_descr or {"item-description.wh40k-titans-not-yet"}
end
