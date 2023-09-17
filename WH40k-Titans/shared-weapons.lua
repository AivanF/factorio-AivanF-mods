local shared = require("shared-base")

-- Aliases
shared.bolter_engine = shared.proj_engine
shared.rocket_engine = shared.proj_engine
shared.quake_engine  = shared.proj_engine
shared.las_engine    = shared.he_emitter
-- shared.melta_engine  = he_emitter + melta_pump
-- shared.plasma_engine = he_emitter + emfc
-- shared.hell_engine   = ehe_emitter + melta_pump

--------- Titan weapon ammo aliases
-- Custom
shared.big_bolt = shared.mod_prefix.."big-bolt"
shared.huge_bolt = shared.mod_prefix.."huge-bolt"
shared.quake_proj = shared.mod_prefix.."quake-projectile"
-- Builtin usage
shared.laser_ammo   = "battery"
shared.flamer_ammo  = "rocket-fuel"
shared.melta_ammo   = "rocket-fuel"
shared.hell_ammo    = "nuclear-fuel"
shared.missile_ammo = "explosive-rocket"
shared.plasma_ammo  = shared.bridge_prefix.."plasma-fuel"

--------- Titan weapon scaling
-- Specified size also allows to use 1 grade lower
shared.gun_grade_small  = 1
shared.gun_grade_medium = 2
shared.gun_grade_big    = 3

--------- Weapon categories
-- NOTE: number can be changed, shouldn't go to save files
-- This should be only used for faster runtime indices
shared.wc_rocket = 01
shared.wc_bolter = 02
shared.wc_quake  = 03
shared.wc_flamer = 11
shared.wc_laser  = 12
shared.wc_plasma = 13
shared.wc_melta  = 14
shared.wc_hell   = 15
shared.wc_melee  = 21

--------- Weapon types
shared.weapons = {}
local dst_s, dst_m, dst_l, dst_xl
dst_s, dst_m, dst_l, dst_xl = 64, 96, 128, 192
local wname = nil
local order_index = 1

local function add_weapon(weapon_type)
  weapon_type.entity = shared.mod_prefix..weapon_type.name
  weapon_type.cd = weapon_type.cd or 3
  weapon_type.attack_size = weapon_type.attack_size or 1

  shared.weapons[weapon_type.entity] = weapon_type
  shared.weapons[weapon_type.name] = weapon_type
end


--------- 1. Small

wname = "inferno"  -- 3 flamers
shared.weapon_inferno = wname
add_weapon({
  name = wname,
  grade = shared.gun_grade_small,
  category = shared.wc_flamer,
  min_dst = 6, max_dst = dst_s,
  speed = 18, barrel = 9,
  ammo = shared.flamer_ammo,
  per_shot = 1, inventory = 2000,
  cd = 0.05, attack_size = 5, scatter = 5,
  bolt_type = "flamethrower-fire-stream",
  ingredients = {
    {shared.melta_pump, 3},
    {shared.barrel, 6},
    {shared.frame_part, 2},
  },
  icon = "__base__/graphics/icons/flamethrower-turret.png",  -- TODO: replace
  icon_size = 64, icon_mipmaps = 4,
  animation = shared.mod_prefix.."Inferno",
  order_index = order_index,
})
order_index = order_index + 1

wname = "vulcan-mega-bolter"  -- 2 guns with 6 big bolters
shared.weapon_megabolter = wname
add_weapon({
  name = wname,
  grade = shared.gun_grade_small,
  category = shared.wc_bolter,
  min_dst = 6, max_dst = dst_s,
  ammo = shared.big_bolt,
  per_shot = 1, inventory = 2000,
  cd = 0.1, attack_size = 3,
  ingredients = {
    {shared.bolter_engine, 2},
    {shared.barrel, 12},
    {shared.frame_part, 2},
  },
  icon = "__base__/graphics/icons/gun-turret.png",
  icon_size = 64, icon_mipmaps = 4,
  animation = nil,  -- TODO: here!
  order_index = order_index,
})
order_index = order_index + 1

wname = "mauler-bolt-cannon"  -- 1 huge bolter
shared.weapon_boltcannon = wname
add_weapon({
  name = wname,
  grade = shared.gun_grade_small,
  category = shared.wc_bolter,
  min_dst = 6, max_dst = dst_s,
  ammo = shared.huge_bolt,
  per_shot = 1, inventory = 500,
  cd = 2,
  ingredients = {
    {shared.bolter_engine, 3},
    {shared.barrel, 4},
    {shared.frame_part, 3},
  },
  icon = "__base__/graphics/icons/gun-turret.png",
  icon_size = 64, icon_mipmaps = 4,
  animation = nil,  -- TODO: here!
  order_index = order_index,
})
order_index = order_index + 1

wname = "lascannon"
shared.weapon_lascannon = wname
add_weapon({
  name = wname,
  grade = shared.gun_grade_small,
  category = shared.wc_laser,
  min_dst = 6, max_dst = dst_m,
  speed = 15, barrel = 12,
  ammo = shared.laser_ammo,
  per_shot = 2, inventory = 2000,
  cd = 0.4,
  bolt_type = shared.mod_prefix.."bolt-laser",
  ingredients = {
    {shared.las_engine, 1},
    {shared.barrel, 2},
    {shared.frame_part, 2},
  },
  icon = shared.media_prefix.."graphics/icons/weapons/LasCannon.png",
  icon_size = 64, icon_mipmaps = 3,
  animation = shared.mod_prefix.."LasCannon",
  order_index = order_index,
})
order_index = order_index + 1

wname = "turbo-laser-destructor"  -- 2 lasers
shared.weapon_turbolaser = wname
add_weapon({
  name = wname,
  grade = shared.gun_grade_small,
  category = shared.wc_laser,
  min_dst = 8, max_dst = dst_m, spd=1.5,
  speed = 15, barrel = 12,
  ammo = shared.laser_ammo,
  per_shot = 3, inventory = 6000,
  cd = 0.15, attack_size = 3, scatter = 2,
  bolt_type = shared.mod_prefix.."bolt-laser",
  ingredients = {
    {shared.las_engine, 2},
    {shared.barrel, 4},
    {shared.frame_part, 5},
  },
  icon = shared.media_prefix.."graphics/icons/weapons/Turbo-Laser.png",
  icon_size = 64, icon_mipmaps = 3,
  animation = shared.mod_prefix.."Turbo-Laser",
  order_index = order_index,
})
order_index = order_index + 1

wname = "plasma-blastgun"
shared.weapon_plasma_blastgun = wname
add_weapon({
  name = wname,
  grade = shared.gun_grade_small,
  category = shared.wc_plasma,
  min_dst = 6, max_dst = dst_s,
  ammo = shared.plasma_ammo,
  per_shot = 2, inventory = 500,
  cd = 1,
  bolt_type = shared.mod_prefix.."bolt-plasma-1",
  ingredients = {
    -- {shared.melta_pump, 2},
    {shared.he_emitter, 2},
    {shared.emfc, 2},
    {shared.barrel, 4},
    {shared.frame_part, 2},
  },
  icon = shared.media_prefix.."graphics/icons/weapons/Plasma-BlastGun.png",
  icon_size = 64, icon_mipmaps = 3,
  animation = shared.mod_prefix.."Plasma-BlastGun",
  order_index = order_index,
})
order_index = order_index + 1

wname = "missile-launcher"
shared.weapon_missiles = wname
add_weapon({
  name = wname,
  grade = shared.gun_grade_small,
  category = shared.wc_rocket,
  min_dst = 8, max_dst = (dst_m+dst_l)/2,
  speed = 1, barrel = 0,
  ammo = shared.missile_ammo,
  per_shot = 1, inventory = 3000,
  attack_size = 3, scatter = 4,
  cd = 0.4, bolt_type = shared.mod_prefix.."explosive-rocket",
  ingredients = {
    {shared.rocket_engine, 4},
    {shared.barrel, 4},
    {shared.frame_part, 2},
  },
  icon = shared.media_prefix.."graphics/icons/weapons/MissileLauncher.png",
  icon_size = 64, icon_mipmaps = 3,
  animation = shared.mod_prefix.."MissileLauncher",
  order_index = order_index,
})
order_index = order_index + 1

wname = "apocalypse-missiles"
shared.weapon_apocalypse_missiles = wname  -- faster & farther rockets
add_weapon({
  name = wname,
  grade = shared.gun_grade_small,
  category = shared.wc_rocket,
  min_dst = 8, max_dst = dst_l,
  speed = 1, barrel = 0,
  ammo = shared.missile_ammo,
  per_shot = 1, inventory = 8000,
  cd = 0.15, attack_size = 7, scatter = 6,
  bolt_type = shared.mod_prefix.."explosive-rocket",
  ingredients = {
    {shared.rocket_engine, 10},
    {shared.barrel, 8},
    {shared.frame_part, 5},
  },
  icon = shared.media_prefix.."graphics/icons/weapons/ApocLauncher.png",
  icon_size = 64, icon_mipmaps = 3,
  animation = shared.mod_prefix.."ApocLauncher",
  order_index = order_index,
})
order_index = order_index + 1


--------- 2. Medium

wname = "plasma-destructor"
shared.weapon_plasma_destructor = wname
add_weapon({
  name = wname,
  grade = shared.gun_grade_medium,
  category = shared.wc_plasma,
  min_dst = 8, max_dst = dst_m,
  ammo = shared.plasma_ammo,
  per_shot = 3, inventory = 900,
  cd = 2,
  bolt_type = shared.mod_prefix.."bolt-plasma-2",
  ingredients = {
    -- {shared.melta_pump, 4},
    {shared.he_emitter, 6},
    {shared.emfc, 6},
    {shared.barrel, 6},
    {shared.frame_part, 3},
  },
  icon = shared.media_prefix.."graphics/icons/weapons/Plasma-BlastGun.png", -- TODO: replace
  icon_size = 64, icon_mipmaps = 3,
  animation = shared.mod_prefix.."Plasma-Destructor",
  order_index = order_index,
})
order_index = order_index + 1

wname = "gatling-blaster"  -- 3 huge bolters
shared.weapon_gatling_blaster = wname
add_weapon({
  name = wname,
  grade = shared.gun_grade_medium,
  category = shared.wc_bolter,
  min_dst = 8, max_dst = dst_m,
  ammo = shared.huge_bolt,
  per_shot = 1, inventory = 1000,
  attack_size = 3,
  ingredients = {
    {shared.bolter_engine, 9},
    {shared.barrel, 12},
    {shared.frame_part, 4},
  },
  icon = "__base__/graphics/icons/gun-turret.png",
  icon_size = 64, icon_mipmaps = 4,
  animation = nil,  -- TODO: here!
  order_index = order_index,
})
order_index = order_index + 1

-- wname = "quake-cannon"
-- shared.weapon_quake_cannon = wname
-- add_weapon({
--   name = wname,
--   grade = shared.gun_grade_medium,
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
--   order_index = order_index,
-- })
-- order_index = order_index + 1

wname = "volcano-cannon"
shared.weapon_volcano_cannon = wname
add_weapon({
  name = wname,
  grade = shared.gun_grade_medium,
  category = shared.wc_hell,
  min_dst = 8, max_dst = dst_l,
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
  order_index = order_index,
})
order_index = order_index + 1

-- wname = "graviton-ruinator"
-- shared.weapon_graviton_ruinator = wname
-- add_weapon({
--   name = wname,
--   grade = shared.gun_grade_medium,
--   category = shared.wc_quake,
--   min_dst = 10, max_dst = dst_l, spd=0.5,
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
--   order_index = order_index,
-- })
-- order_index = order_index + 1

wname = "volkite-destructor"  -- quick big melta, short-range
shared.weapon_volkite_destructor = wname
add_weapon({
  name = wname,
  grade = shared.gun_grade_medium,
  category = shared.wc_melta,
  min_dst = 8, max_dst = dst_m,
  ammo = shared.melta_ammo,
  per_shot = 1, inventory = 500,
  attack_size = 5,
  ingredients = {
    {shared.melta_pump, 6},
    {shared.he_emitter, 6},
    {shared.barrel, 8},
    {shared.frame_part, 10},
  },
  icon = "__base__/graphics/icons/flamethrower-turret.png",
  icon_size = 64, icon_mipmaps = 4,
  animation = nil,  -- TODO: here!
  order_index = order_index,
})
order_index = order_index + 1


--------- 3. Huge

wname = "plasma-annihilator"
shared.weapon_plasma_annihilator = wname
add_weapon({
  name = wname,
  grade = shared.gun_grade_big,
  category = shared.wc_plasma,
  min_dst = 12, max_dst = dst_l,
  ammo = shared.plasma_ammo,
  per_shot = 10, inventory = 5000,
  cd = 4,
  bolt_type = shared.mod_prefix.."bolt-plasma-3",
  ingredients = {
    -- {shared.melta_pump, 18},
    {shared.he_emitter, 18},
    {shared.emfc, 18},
    {shared.barrel, 10},
    {shared.frame_part, 6},
  },
  icon = shared.media_prefix.."graphics/icons/weapons/Plasma-BlastGun.png", -- TODO: replace
  icon_size = 64, icon_mipmaps = 3,
  animation = shared.mod_prefix.."Plasma-Destructor",  -- TODO: replace
  order_index = order_index,
})
order_index = order_index + 1

wname = "hellstorm-cannon"
shared.weapon_hellstorm_cannon = wname
add_weapon({
  name = wname,
  grade = shared.gun_grade_big,
  category = shared.wc_hell,
  min_dst = 16, max_dst = dst_xl, spd=0.2,
  ammo = shared.hell_ammo,
  per_shot = 12, inventory = 1000,
  cd = 6,
  ingredients = {
    {shared.melta_pump, 10},
    {shared.ehe_emitter, 20},
    {shared.barrel, 30},
    {shared.frame_part, 19},
  },
  icon = "__base__/graphics/icons/flamethrower-turret.png",
  icon_size = 64, icon_mipmaps = 4,
  animation = nil,  -- TODO: here!
  order_index = order_index,
})
order_index = order_index + 1

-- wname = "doomstrike-missiles"
-- shared.weapon_doomstrike_missiles = wname
-- add_weapon({
--   name = wname,
--   grade = shared.gun_grade_big,
--   category = shared.wc_quake,
--   min_dst = 32, max_dst = dst_xl*1.5, spd=0.2,
--   ammo = shared.doom_rocket,
--   per_shot = 1, inventory = 16,
--   ingredients = {
--     {shared.rocket_engine, 16},
--     {shared.barrel, 16},
--     {shared.frame_part, 11},
--   },
--   icon = shared.media_prefix.."graphics/icons/weapons/MissileLauncher.png", -- TODO: replace
--   icon_size = 64, icon_mipmaps = 3,
--   animation = shared.mod_prefix.."MissileLauncher", -- TODO: replace
--   order_index = order_index,
-- })
-- order_index = order_index + 1
