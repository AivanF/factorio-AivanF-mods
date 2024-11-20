local sounds = require("__base__.prototypes.entity.sounds")
local shared = require("shared")
local misc = require("prototypes.misc")

local minable_titans = false

local only_water_layer_name = shared.titan_prefix.."-only-water-layer"
data:extend({
  {
    type = "collision-layer",
    name = only_water_layer_name,
    collision_mask = {layers = {}},
  },
})

-- Add new layer to the water, ignoring shallow
-- Seems like they use the same objects, deep copy them firstly
for name, proto in pairs(data.raw["tile"]) do
  if name:find("shallow", 1, true) then
    log("Titans: deepcopy for tile "..proto.name)
    proto.collision_mask = table.deepcopy(proto.collision_mask)
  end
end
for name, proto in pairs(data.raw["tile"]) do
  if true
    and proto.fluid
    -- and (name:find("water", 1, true) or name:find("ocean", 1, true) or name:find("lava", 1, true))
    and not name:find("shallow", 1, true)
  then
    log("Titans: only_water_layer for tile "..proto.name)
    proto.collision_mask.layers[only_water_layer_name] = true
  end
end

for _, titan_type in ipairs(shared.titan_type_list) do
  local name = titan_type.entity
  local class = titan_type.class
  local class_precise = math.round(titan_type.class/10)
  local icon = titan_type.icon
  local icon_size = titan_type.icon_size
  local icon_mipmaps = titan_type.icon_mipmaps
  local place_result = titan_type.plane and name or shared.titan_prefix..shared.titan_warhound
  local about_guns = ""
  for wi, mounting in ipairs(titan_type.mounts) do
    about_guns = about_guns.." "..(mounting.is_arm and "H" or mounting.top_only and "A" or mounting.is_top and "T" or "C")..mounting.grade
  end
  local description = {
    "",
    titan_type.available and {"entity-description."..name} or {"item-description.wh40k-titans-not-yet"},
    " ",
    {"entity-description.wh40k-titans-time", beautify_time(shared.get_titan_assembly_time(name))},
    " ",
    {"entity-description.wh40k-titans-pattern", about_guns},
  }

  local main_resist = settings.startup["wh40k-titans-resist-const"].value + settings.startup["wh40k-titans-resist-mult"].value * class_precise

  local rotation_speed
  if titan_type.class < shared.class_reaver then
    rotation_speed = 0.005
  elseif titan_type.class < shared.class_reaver then
    rotation_speed = 0.004
  else
    rotation_speed = 0.003
  end

  data:extend({
    {
      type = "item",
      name = name,
      icon = icon, icon_size = icon_size, icon_mipmaps = icon_mipmaps,
      subgroup = shared.subg_titans,
      order = "c[dummy-titan-item-"..class.."]",
      place_result = place_result,
      stack_size = 1,
    },
    {
      type = "recipe",
      name = name,
      localised_name = {"entity-name."..name},
      localised_description = description,
      icon = icon, icon_size = icon_size, icon_mipmaps = icon_mipmaps,
      subgroup = shared.subg_titans,
      order = "c[dummy-titan-item-"..class.."]",
      enabled = false,
      category = shared.craftcat_titan..class_precise,
      ingredients = shared.preprocess_recipe(titan_type.ingredients),
      -- results = minable_titans and {{name, 1}} or {},
      results = {{type="item", name=name, amount=1}},
      energy_required = 60*60*24,
    },
    {
      type = shared.titan_base_type,
      name = name,
      localised_description = description,
      icon = icon, icon_size = icon_size, icon_mipmaps = icon_mipmaps,
      flags = {
        "placeable-neutral", "player-creation", "placeable-off-grid",
        "no-automated-item-removal", "no-automated-item-insertion",
        "not-flammable", "not-repairable",
      },
      minable = minable_titans and {mining_time = 1.5, result = name} or nil,
      energy_per_hit_point = 0.05,
      max_health = titan_type.health,
      minimap_representation = {
        filename = shared.media_prefix.."graphics/icons/map-titan.png",
        width = 64,
        height = 80,
      },
      dying_explosion = "medium-explosion",
      track_coverage_during_build_by_moving = true,
      resistances = {
        { type = "impact", decrease=0, percent=100 },
        { type = "fire", decrease=0, percent=100 },
        { type = "poison", decrease=0, percent=100 },

        { type = "acid", decrease=main_resist, percent=80 },
        { type = "laser", decrease=main_resist, percent=80 },
        { type = "electric", decrease=main_resist, percent=80 },

        { type = "explosion", decrease=main_resist, percent=80 },
        { type = "physical", decrease=main_resist, percent=80 },
      },
      collision_mask = {layers=dict_from_keys_list(titan_type.over_water and {} or {only_water_layer_name}, true)},
      collision_box = {{-4, -4}, {4, 4}},
      selection_box = {{-4, -4}, {4, 4}},
      drawing_box = {{-6, -6}, {6, 6}},
      vehicle_impact_sound = sounds.generic_impact,
      open_sound = sounds.electric_network_open,
      close_sound = sounds.electric_network_close,
      allow_passengers = true,
      has_belt_immunity = true,
      trigger_target_mask = { "common" }, -- Override car's default to disable acid puddle damage
      -- tank_driving = true,
      selection_priority = 70,
      is_military_target = true,
      allow_remote_driving = true,

      energy_source = { type = "void" },
      effectivity = 1,
      weight = titan_type.class * 5000,
      consumption = math.floor(titan_type.spd * math.pow(titan_type.class, 0.5)).."MW",
      braking_power = "2MW",
      terrain_friction_modifier = 0,
      friction = 0.05,
      breaking_speed = 0.1,
      rotation_speed = rotation_speed,
      repair_speed_modifier = 0.5,

      equipment_grid = shared.mod_prefix.."t"..class_precise,
      inventory_size = 20 * class_precise,
      chunk_exploration_radius = 1 + class_precise,
      -- render_layer = "air-object",
      -- final_render_layer = "air-object",
      animation = table.deepcopy(data.raw["car"]["car"].animation),
    },
  })
end


local foot_size_1 = 2.5
local foot_size_2 = 5
-- Dummy icon for foots
local titan_type = shared.titan_types[shared.class_warhound]
local icon = titan_type.icon
local icon_size = titan_type.icon_size
local icon_mipmaps = titan_type.icon_mipmaps


data:extend({
  {
    type = "projectile",
    name = shared.titan_foot_small.."-damage",
    flags = {"not-on-map"},
    acceleration = 0.001,
    turn_speed = 0.01,
    action = {
      {
        type = "area",
        radius = foot_size_1+2,
        ignore_collision_condition = true,
        action_delivery = {
          type = "instant",
          target_effects = {
            {
              type = "damage",
              vaporize = false,
              damage = {amount = 500, type = shared.step_damage}
            },
          }
        }
      },
    },
  },
  {
    type = "projectile",
    name = shared.titan_foot_big.."-damage",
    flags = {"not-on-map"},
    acceleration = 0.001,
    turn_speed = 0.01,
    action = {
      {
        type = "area",
        radius = foot_size_2+2,
        ignore_collision_condition = true,
        action_delivery = {
          type = "instant",
          target_effects = {
            {
              type = "damage",
              vaporize = false,
              damage = {amount = 1000, type = shared.step_damage}
            },
          }
        }
      },
    },
  },
  {
    type = "simple-entity",
    name = shared.titan_foot_small,
    icon = icon, icon_size = icon_size, icon_mipmaps = icon_mipmaps,
    flags = {"placeable-neutral", "placeable-off-grid"},
    selectable_in_game = false, --shared.debug_mod,
    collision_box = {{-foot_size_1, -foot_size_1}, {foot_size_1, foot_size_1}},
    selection_box = {{-foot_size_1, -foot_size_1}, {foot_size_1, foot_size_1}},
    selection_priority = 60,
    max_health = 5000,
    resistances = technomagic_resistances,
    picture = { layers = {misc.empty_sprite} },
  },
  {
    type = "simple-entity",
    name = shared.titan_foot_big,
    icon = icon, icon_size = icon_size, icon_mipmaps = icon_mipmaps,
    flags = {"placeable-neutral", "placeable-off-grid"},
    selectable_in_game = false, --shared.debug_mod,
    collision_box = {{-foot_size_2, -foot_size_2}, {foot_size_2, foot_size_2}},
    selection_box = {{-foot_size_2, -foot_size_2}, {foot_size_2, foot_size_2}},
    selection_priority = 60,
    max_health = 5000,
    resistances = technomagic_resistances,
    picture = { layers = {misc.empty_sprite} }
  },
  {
    type = "electric-turret",
    name = shared.titan_aux_laser,
    icon = "__base__/graphics/icons/laser-turret.png",
    icon_size = 64, icon_mipmaps = 4,
    flags = {"placeable-neutral", "placeable-off-grid",},
    hidden = true,
    max_health = 10000,
    resistances = technomagic_resistances,
    selectable_in_game = false,
    collision_mask = {layers={}},
    collision_box = {{-0.7, -0.7 }, {0.7, 0.7}},
    selection_box = {{ -1, -1}, {1, 1}},
    map_color = {0,0,0,0},
    rotation_speed = 0.03,
    preparing_speed = 0.1,
    folding_speed = 0.1,
    energy_source = { type = "void" },
    glow_light_intensity = 1,
    folded_animation = { layers = {misc.empty_sprite} },
    preparing_animation = { layers = {misc.empty_sprite} },
    prepared_animation = { layers = {misc.empty_sprite} },
    folding_animation = { layers = {misc.empty_sprite} },
    base_picture = { layers = {misc.empty_sprite} },
    graphics_set = {},
    call_for_help_radius = 2,
    attack_parameters = {
      type = "beam",
      cooldown = 40,
      range = 28,
      source_direction_count = 64,
      source_offset = {0, -3.423489 / 4},
      damage_modifier = 5,
      ammo_category = "laser",
      ammo_type = {
        category = "laser",
        energy_consumption = "800kJ",
        action = {
          type = "direct",
          action_delivery = {
            type = "beam",
            beam = "laser-beam",
            max_length = 28,
            duration = 40,
            source_offset = {0, -1 }
          }
        }
      },
    },
  },
  {
    type = "electric-turret",
    name = shared.titan_aux_laser2,
    icon = "__base__/graphics/icons/laser-turret.png",
    icon_size = 64, icon_mipmaps = 4,
    flags = {"placeable-neutral", "placeable-off-grid"},
    hidden = true,
    max_health = 10000,
    resistances = technomagic_resistances,
    selectable_in_game = false,
    collision_mask = {layers={}},
    collision_box = {{-0.7, -0.7 }, {0.7, 0.7}},
    selection_box = {{ -1, -1}, {1, 1}},
    map_color = {0,0,0,0},
    rotation_speed = 0.03,
    preparing_speed = 0.1,
    folding_speed = 0.1,
    energy_source = { type = "void" },
    glow_light_intensity = 2,
    folded_animation = { layers = {misc.empty_sprite} },
    preparing_animation = { layers = {misc.empty_sprite} },
    prepared_animation = { layers = {misc.empty_sprite} },
    folding_animation = { layers = {misc.empty_sprite} },
    base_picture = { layers = {misc.empty_sprite} },
    graphics_set = {},
    call_for_help_radius = 2,
    attack_parameters = {
      type = "beam",
      cooldown = 40,
      range = 44,
      source_direction_count = 64,
      source_offset = {0, -3.423489 / 4},
      damage_modifier = 15,
      ammo_category = "laser",
      ammo_type = {
        category = "laser",
        energy_consumption = "800kJ",
        action = {
          type = "direct",
          action_delivery = {
            type = "beam",
            beam = "laser-beam",
            max_length = 44,
            duration = 20,
            source_offset = {0, -2 }
          }
        }
      },
    },
  },
})


-- -- local arty = table.deepcopy(data.raw["artillery-turret"]["artillery-turret"])
-- local arty = table.deepcopy(data.raw["ammo-turret"]["mortar-turret"])

-- arty.name = shared.arty
-- arty.ammo_stack_limit = shared.arty_invsz
-- arty.flags = {
--   "placeable-neutral", "placeable-off-grid",
--   "no-automated-item-removal",
--   "no-automated-item-insertion",
-- }
-- arty.collision_mask = {layers={}},
-- -- arty.manual_range_modifier = 1.5 * arty.manual_range_modifier
-- -- arty.turret_rotation_speed = 2 * arty.turret_rotation_speed
-- arty.minable = nil
-- arty.fast_replaceable_group = nil
-- arty.selectable_in_game = shared.debug_mod

-- arty.integration_patch = nil
-- -- arty.base_picture = nil
-- arty.folded_animation = table.deepcopy(data.raw["artillery-turret"]["artillery-turret"].cannon_barrel_pictures)
-- table.extend(arty.folded_animation.layers, table.deepcopy(data.raw["artillery-turret"]["artillery-turret"].cannon_base_pictures.layers))
-- arty.folded_animation.layers[1].slice = 4
-- arty.folded_animation.layers[1].hr_version.slice = 4
-- arty.folded_animation.layers[2].slice = 4
-- arty.folded_animation.layers[2].hr_version.slice = 4
-- arty.folded_animation.layers[3].slice = 4
-- arty.folded_animation.layers[3].hr_version.slice = 4
-- arty.folded_animation.layers[4].slice = 4
-- arty.folded_animation.layers[4].hr_version.slice = 4
-- arty.base_picture_render_layer = shared.rl_shoulder2_name
-- arty.gun_animation_render_layer = shared.rl_shoulder3_name

-- arty.alert_when_attacking = false
-- arty.rotation_speed = 0.01
-- arty.attack_parameters.turn_range = 1
-- arty.attack_parameters.cooldown = 60 * 3
-- arty.attack_parameters.range = 7 * 32
-- arty.attack_parameters.min_range = 2 * 32
-- arty.attack_parameters.projectile_creation_distance = 2.5
-- arty.attack_parameters.ammo_category = "artillery-shell"

-- data:extend({ arty })

