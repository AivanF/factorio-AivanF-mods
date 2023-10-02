local sounds = require("__base__.prototypes.entity.sounds")
local shared = require("shared")
local misc = require("prototypes.misc")

local minable_titans = false

-- local cmu = require("collision-mask-util")
-- local only_water_layer = cmu.get_first_unused_layer()
local collision_mask_util_extended = require("cmue.collision-mask-util-extended")
local only_water_layer = collision_mask_util_extended.get_make_named_collision_mask("only-water-layer")
-- Add new layer to the water, ignoring shallow
for name, proto in pairs(data.raw["tile"]) do
  if proto.draw_in_water_layer and not name:find("shallow", 1, true) then
    log("Titans: only_water_layer for "..proto.name)
    proto.collision_mask[#proto.collision_mask+1] = only_water_layer
  end
end

for _, titan_type in ipairs(shared.titan_type_list) do
  local name = titan_type.entity
  local class = titan_type.class
  local icon = titan_type.icon
  local icon_size = titan_type.icon_size
  local icon_mipmaps = titan_type.icon_mipmaps
  local place_result = titan_type.plane and name or shared.titan_prefix..shared.titan_warhound
  local about_guns = ""
  for k, gun in ipairs(titan_type.guns) do
    about_guns = about_guns.." "..(gun.is_top and "t" or "")..gun.grade
  end
  local description = {
    "",
    titan_type.available and {"entity-description."..name} or {"item-description.wh40k-titans-not-yet"},
    " ",
    {"entity-description.wh40k-titans-pattern", about_guns},
  }

  data:extend({
    {
      type = "item",
      name = name,
      icon = icon, icon_size = icon_size, icon_mipmaps = icon_mipmaps,
      subgroup = shared.subg_titans,
      order = "b[dummy-titan-item-"..class.."]",
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
      order = "b[dummy-titan-item-"..class.."]",
      enabled = false,
      category = shared.craftcat_titan..math.floor(titan_type.class/10),
      ingredients = shared.preprocess_recipe(titan_type.ingredients),
      -- results = minable_titans and {{name, 1}} or {},
      results = {{name, 1}},
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
      },
      minable = minable_titans and {mining_time = 1.5, result = name} or nil,
      energy_per_hit_point = 0.05,
      max_health = titan_type.health,
      minimap_representation = {
        filename = shared.media_prefix.."graphics/icons/titan-map.png",
        width = 64,
        height = 80,
      },
      dying_explosion = "medium-explosion",
      track_coverage_during_build_by_moving = true,
      resistances = {
        { type = "impact", decrease=1000, percent=100 },
        { type = "physical", decrease=300, percent=90 },
        { type = "explosion", decrease=300, percent=50 },
        { type = "fire", decrease=100, percent=90 },
        { type = "acid", decrease=100, percent=90 },
        { type = "poison", decrease=100, percent=99 },
        { type = "laser", decrease=100, percent=90 },
        { type = "electric", decrease=100, percent=90 },
      },
      collision_mask = titan_type.over_water and {} or {only_water_layer},
      collision_box = {{-4, -4}, {4, 4}},
      selection_box = {{-4, -4}, {4, 4}},
      drawing_box = {{-6, -6}, {6, 6}},
      vehicle_impact_sound = sounds.generic_impact,
      open_sound = sounds.electric_network_open,
      close_sound = sounds.electric_network_close,
      allow_passengers = true,
      has_belt_immunity = true,
      -- tank_driving = true,
      selection_priority = 70,

      energy_source = { type = "void" },
      effectivity = 1,
      weight = titan_type.class * 5000,
      consumption = math.floor(titan_type.spd * math.pow(titan_type.class, 0.5)).."MW",
      braking_power = "2MW",
      terrain_friction_modifier = 0.05,
      friction = 0.05,
      breaking_speed = 0.1,
      rotation_speed = (titan_type.class < shared.class_reaver) and 0.005 or 0.004,

      inventory_size = math.ceil(20 * titan_type.class/10),
      chunk_exploration_radius = math.ceil(1 + titan_type.class/10),
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
              damage = {amount = 500, type = "impact"}
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
              damage = {amount = 1000, type = "impact"}
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
    flags = {"placeable-neutral", "placeable-off-grid"},
    max_health = 10000,
    resistances = technomagic_resistances,
    selectable_in_game = false,
    collision_mask = {},
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
    call_for_help_radius = 2,
    attack_parameters = {
      type = "beam",
      cooldown = 40,
      range = 24,
      source_direction_count = 64,
      source_offset = {0, -3.423489 / 4},
      damage_modifier = 4,
      ammo_type = {
        category = "laser",
        energy_consumption = "800kJ",
        action = {
          type = "direct",
          action_delivery = {
            type = "beam",
            beam = "laser-beam",
            max_length = 24,
            duration = 40,
            source_offset = {0, -0.5 }
          }
        }
      },
    },
  },
})
