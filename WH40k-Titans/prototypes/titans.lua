local sounds = require("__base__.prototypes.entity.sounds")
local shared = require("shared")
local misc = require("prototypes.misc")

local titan_type = shared.titan_classes[shared.titan_1warhound]
local name = titan_type.entity
local icon = titan_type.icon
local icon_size = titan_type.icon_size
local icon_mipmaps = titan_type.icon_mipmaps

local cmu = require("collision-mask-util")
local only_water_layer = cmu.get_first_unused_layer()
-- Add new layer to the water, ignoring shallow
for name, proto in pairs(data.raw["tile"]) do
  if proto.draw_in_water_layer then
    log("Titans: only_water_layer for "..proto.name)
    proto.collision_mask[#proto.collision_mask+1] = only_water_layer
  end
end

local foot_size_1 = 2.5
local foot_size_2 = 5

data:extend({
  {
    type = "custom-input",
    name = shared.mod_prefix.."attack",
    key_sequence = "C",
    action = "lua",
  },
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
      -- {
      --   type = "direct",
      --   action_delivery = {
      --     type = "instant",
      --     target_effects = {
      --       {
      --         type = "create-entity",
      --         entity_name = "medium-explosion"
      --       },
      --     }
      --   }
      -- },
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
    resistances = {
      { type = "impact", decrease=1000, percent=100 },
    },
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
    resistances = {
      { type = "impact", decrease=1000, percent=100 },
    },
    picture = { layers = {misc.empty_sprite} }
  },
  {
    type = "item",
    name = name,
    icon = icon, icon_size = icon_size, icon_mipmaps = icon_mipmaps,
    subgroup = shared.subg_titans,
    order = "b[dummy-titan-item-1]",
    place_result = name,
    stack_size = 20,
  },
  {
    type = "recipe",
    name = name,
    enabled = false,
    category = shared.craftcat_titan,
    ingredients = {
      {"steel-plate", 100},
      {"copper-plate", 100},
    },
    result = name,
  },
  {
    -- For sandbox/god mod testing
    -- Other recipes aren't available due to the category
    type = "recipe",
    name = name.."-sandbox",
    enabled = true,
    ingredients = {
      {"steel-plate", 100},
      {"copper-plate", 100},
    },
    result = name,
    order = "a[test]",
  },
  {
    type = "car",
    name = name,
    icon = icon, icon_size = icon_size, icon_mipmaps = icon_mipmaps,
    flags = {"placeable-neutral", "player-creation", "placeable-off-grid"},
    minable = {mining_time = 1.5, result = name},  -- TODO: remove this
    energy_per_hit_point = 0.05,
    max_health = titan_type.health,
    healing_per_tick = math.ceil(titan_type.health / 600),  -- TODO: here?
    -- corpse = "medium-electric-pole-remnants",  -- TODO: here!
    -- minimap_representation = ,  -- TODO: here!
    dying_explosion = "medium-explosion",
    track_coverage_during_build_by_moving = true,
    resistances = {
      { type = "impact", decrease=1000, percent=100 },
      { type = "physical", decrease=500, percent=90 },
      { type = "fire", decrease=100, percent=90 },
      { type = "acid", decrease=100, percent=90 },
      { type = "poison", decrease=100, percent=99 },
      { type = "explosion", decrease=100, percent=90 },
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
    weight = titan_type.class * 50000,
    energy_source = { type = "void" },
    allow_passengers = true,
    has_belt_immunity = true,
    -- tank_driving = true,
    selection_priority = 70,

    effectivity = 1,
    consumption = "10MW",
    braking_power = "2MW",
    terrain_friction_modifier = 0.2,
    friction = 0.03,
    breaking_speed = 0.1,
    rotation_speed = 0.004,

    inventory_size = 50 * titan_type.class,
    equipment_grid = "wh40k-titan-c"..titan_type.class.."-egrid",
    chunk_exploration_radius = 1 + titan_type.class,
    render_layer = "air-object",
    final_render_layer = "air-object",
    animation = table.deepcopy(data.raw["car"]["car"].animation),
  },

  -- Dummy Reaver
  {
    type = "item",
    name = shared.titan_classes[shared.titan_2reaver].entity,
    icon = shared.titan_classes[shared.titan_2reaver].icon,
    icon_size = icon_size, icon_mipmaps = icon_mipmaps,
    subgroup = shared.subg_titans,
    order = "b[dummy-titan-item-2]",
    place_result = name,
    stack_size = 20,
  },
  {
    type = "recipe",
    name = shared.titan_classes[shared.titan_2reaver].entity,
    enabled = false,
    category = shared.craftcat_titan,
    ingredients = {
      {"steel-plate", 100},
      {"copper-plate", 100},
    },
    result = shared.titan_classes[shared.titan_2reaver].entity,
  },

  -- Dummy WarLord
  {
    type = "item",
    name = shared.titan_classes[shared.titan_3warlord].entity,
    icon = shared.titan_classes[shared.titan_3warlord].icon,
    icon_size = icon_size, icon_mipmaps = icon_mipmaps,
    subgroup = shared.subg_titans,
    order = "b[dummy-titan-item-3]",
    place_result = name,
    stack_size = 20,
  },
  {
    type = "recipe",
    name = shared.titan_classes[shared.titan_3warlord].entity,
    enabled = false,
    category = shared.craftcat_titan,
    ingredients = {
      {"steel-plate", 100},
      {"copper-plate", 100},
    },
    result = shared.titan_classes[shared.titan_3warlord].entity,
  },

  -- Dummy WarMaster
  {
    type = "item",
    name = shared.titan_classes[shared.titan_4warmaster].entity,
    icon = shared.titan_classes[shared.titan_4warmaster].icon,
    icon_size = icon_size, icon_mipmaps = icon_mipmaps,
    subgroup = shared.subg_titans,
    order = "b[dummy-titan-item-4]",
    place_result = name,
    stack_size = 20,
  },
  {
    type = "recipe",
    name = shared.titan_classes[shared.titan_4warmaster].entity,
    enabled = false,
    category = shared.craftcat_titan,
    ingredients = {
      {"steel-plate", 100},
      {"copper-plate", 100},
    },
    result = shared.titan_classes[shared.titan_4warmaster].entity,
  },

  -- Dummy Emperor
  {
    type = "item",
    name = shared.titan_classes[shared.titan_5emperor].entity,
    icon = shared.titan_classes[shared.titan_5emperor].icon,
    icon_size = icon_size, icon_mipmaps = icon_mipmaps,
    subgroup = shared.subg_titans,
    order = "b[dummy-titan-item-5]",
    place_result = name,
    stack_size = 20,
  },
  {
    type = "recipe",
    name = shared.titan_classes[shared.titan_5emperor].entity,
    enabled = false,
    category = shared.craftcat_titan,
    ingredients = {
      {"steel-plate", 100},
      {"copper-plate", 100},
    },
    result = shared.titan_classes[shared.titan_5emperor].entity,
  },
})

table.insert(
  data.raw.technology[shared.mod_prefix.."assembly"].effects,
  { type = "unlock-recipe", recipe = name }
)
