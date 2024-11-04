local shared = require("shared")

-- Some code was adotped from the "Aircraft" mod under MIT license

local early_space_cruiser = settings.startup[shared.mod_prefix.."early"].value
-- To be overriden for overhaul mods
local technology_name = early_space_cruiser and "tank" or "spidertron"

local space_cruiser_ingredients
if early_space_cruiser then
  space_cruiser_ingredients = {
    {type="item", name="steel-plate", amount=200},
    {type="item", name="electric-engine-unit", amount=50},
    {type="item", name="advanced-circuit", amount=42},
    {type="item", name="accumulator", amount=10},
    {type="item", name="fission-reactor-equipment", amount=1},
    {type="item", name="efficiency-module", amount=10},
    {type="item", name="speed-module", amount=10},
    {type="item", name="modular-armor", amount=1},
  }
else
  -- TODO: add rocket/antimatter engine?
  -- TODO: maybe make more difficulty options or tiers for mid/late/end-game?
  space_cruiser_ingredients = {
    {type="item", name="low-density-structure", amount=200},
    {type="item", name="electric-engine-unit", amount=50},
    {type="item", name="processing-unit", amount=42},
    {type="item", name="accumulator", amount=10},
    {type="item", name="fission-reactor-equipment", amount=6},
    -- {type="item", name="fusion-reactor-equipment", amount=6}, -- It's Space Age only
    {type="item", name="efficiency-module-3", amount=10},
    {type="item", name="speed-module-3", amount=10},
    {type="item", name="power-armor-mk2", amount=1},
  }
end


local ICONPATH = shared.path_prefix.."media/"
local ENTITYPATH = shared.path_prefix.."media/"

local function addcommonanimlines(anim)
  for _,layer in pairs(anim.layers) do
    layer.width, layer.height = 896, 896
    layer.scale = 0.25
    layer.frame_count = 1
    layer.direction_count = 36
    layer.line_length = 6
    layer.max_advance = 1
  end
  return anim
end

local function aircraftAnimation(nickname)
  local anim = {}
  anim.layers = {
    {
      filename = ENTITYPATH .. nickname .. "-sheet-HR.png",
      shift = util.by_pixel(0, -10),
      scale = 0.25,
    },
    -- {
    --   filename = ENTITYPATH .. name .. "/" .. name .. "_spritesheet-shadow.png",
    --   shift = util.by_pixel(54, 35),
    --   draw_as_shadow = true,
    -- }
  }
  addcommonanimlines(anim)
  return anim
end

local function aircraftLightAnimation(nickname)
  local anim = {}
  anim.layers = {
    {
      filename = ENTITYPATH .. "/" .. nickname .. "-sheet-light-HR.png",
      shift = util.by_pixel(0, -10),
      scale = 0.25,
      draw_as_light = true,
    }
  }
  addcommonanimlines(anim)
  return anim
end

local function lightdef(shift, distance, intensity)
  return {
    type = "oriented",
    minimum_darkness = 0.3,
    picture = {
      filename = ENTITYPATH .. "aircraft-light-cone.png",
      scale = 0.5,
      width = 800,
      height = 800
    },
    shift = util.by_pixel(shift, distance),
    size = 2,
    intensity = intensity/10,
  }
end

local function smokedef(shift, radius, height)
  return {
    --name = "smoke",
    name = "aircraft-trail",
    --frequency = 200,
    frequency = 60,
    --deviation = util.by_pixel(2, 2), --position randomness
    deviation = util.by_pixel(0, 0), --position randomness
    position = util.by_pixel(shift, radius),
    height = height/32,
    starting_frame = 3,
    starting_frame_deviation = 5,
    starting_frame_speed = 5,
    starting_frame_speed_deviation = 5,
  }
end

local jetsounds = {

  sound = { filename = shared.path_prefix.."media/engine.ogg", volume = 0.7 },
  deactivate_sound = { filename = shared.path_prefix.."media/engine-stop.ogg", volume = 0.3 },
  match_speed_to_activity = true,
  fade_in_ticks = 30,
}

local bw, bh = 2, 2.5

---add in one function all the common parameteres between aircrafts
local function add_recurrent_params(proto)
  proto.icon_size = 64
  proto.flags = {
    "placeable-neutral", "player-creation", "placeable-off-grid",
    "no-automated-item-insertion", "no-automated-item-removal",
  }
  -- Overriding the "car" default disables acid puddle damage.
  proto.trigger_target_mask = { "common" }
  proto.has_belt_immunity = true
  proto.dying_explosion = "medium-explosion"
  proto.terrain_friction_modifier = 0
  proto.collision_box = {{-bw, -bh}, {bw, bh}}
  proto.collision_mask = {layers={}}
  proto.selection_box = {{-bw, -bh}, {bw, bh}}
  proto.selection_priority = 70
  proto.render_layer = "air-object"
  proto.final_render_layer = "air-object"
  proto.tank_driving = true
  proto.sound_no_fuel = { { filename = "__base__/sound/fight/tank-no-fuel-1.ogg", volume = 0.6 } }
  proto.vehicle_impact_sound = { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 }
  proto.working_sound = jetsounds
  proto.sound_minimum_speed = 0.19
  proto.sound_scaling_ratio = 0.06
  proto.open_sound = { filename = "__base__/sound/car-door-open.ogg", volume = 0.7 }
  proto.close_sound = { filename = "__base__/sound/car-door-close.ogg", volume = 0.7 }
  proto.mined_sound = {filename = "__core__/sound/deconstruct-large.ogg",volume = 0.8}
  proto.create_ghost_on_death = false
  --proto.alert_icon_shift = {0,-1}
  proto.minimap_representation = {
    filename = ICONPATH .. "space-cruiser-map.png",
    flags = {"icon"},
    size = {96, 96},
    scale = 0.5,
  }
  -- proto.selected_minimap_representation = {
  --   filename = ICONPATH .. "aircraft-minimap-representation-selected.png",
  --   flags = {"icon"},
  --   size = {40, 40},
  --   scale = 0.5
  -- }
  --proto.immune_to_tree_impacts = true --proto.immune_to_rock_impacts = true
  --proto.created_smoke = { smoke_name = "smoke" }
end

local function resist(type, decrease, percent)
  return {
    type = type,
    decrease = decrease,
    percent = percent
  }
end


local rcf = early_space_cruiser and 1 or 3

local space_cruiser = {
  type = "car",
  name = shared.space_cruiser,
  icon = ICONPATH .. "space-cruiser-icon.png",
  icon_size = 64, icon_mipmaps = 1,
  subgroup = "transport",
  minable = {mining_time = 2, result = shared.space_cruiser},
  light = { lightdef(-32, -440, 7), lightdef(32, -440, 7) },
  animation = aircraftAnimation("space-cruiser"),
  light_animation = aircraftLightAnimation("space-cruiser"),
  corpse = "medium-remnants",
  -- SPECS
  max_health = early_space_cruiser and 1000 or 3000,
  energy_per_hit_point = 1,
  resistances = {
    resist("fire",      10 *rcf, 30 *rcf),
    resist("laser",     10 *rcf, 20 *rcf),
    resist("physical",  10 *rcf, 20 *rcf),
    resist("impact",    10 *rcf, 30 *rcf),
    resist("explosion", 20 *rcf, 30 *rcf),
    resist("acid",      20 *rcf, 30 *rcf),
  },
  inventory_size = early_space_cruiser and 80 or 120,
  guns = {},
  equipment_grid = shared.space_cruiser,
  -- MOVEMENT
  allow_remote_driving = true,
  energy_source = {
    type = "burner",
    fuel_categories = {"chemical"},
    fuel_inventory_size = 1,
    burnt_inventory_size = 1,
    smoke = { smokedef(-72, 24, 8), smokedef(72, 24, 8) }
  },
  effectivity = 0.4,
  consumption = "4MW",
  braking_power = "3MW",
  friction = 0.003,
  stop_trigger_speed = 0.2,
  acceleration_per_energy = 0.3,
  breaking_speed = 0.15,
  rotation_speed = 0.02,
  weight = 2000,
}

add_recurrent_params(space_cruiser)

data:extend({
  {
    type = "equipment-grid",
    name = shared.space_cruiser,
    width = early_space_cruiser and 12 or 6,
    height = 8,
    equipment_categories = {} -- Added in the final fixes
  },
  {
    type = "trivial-smoke",
    name = "aircraft-trail",
    animation = {
      filename = ENTITYPATH.."aircraft-trail.png",
      priority = "high",
      width = 64,
      height = 64,
      frame_count = 1,
      repeat_count = 127,
      animation_speed = 1,
      scale = 0.5,
      tint = {r = 0.9, g = 0.6, b = 0.4, a = 1},
      draw_as_glow = true,
    },
    render_layer = "air-object",
    affected_by_wind = false,
    movement_slow_down_factor = 0,
    duration = 127,
    fade_away_duration = 127,
    show_when_smoke_off = true,
    start_scale = 0.5,
    end_scale = 6,
    --cyclic = true,
  },

  space_cruiser,
  {
    type = "item-with-entity-data",
    name = shared.space_cruiser,
    icon = ICONPATH .. "space-cruiser-icon.png",
    icon_size = 64, icon_mipmaps = 1,
    flags = {},
    subgroup = "transport",
    order = "x[space-cruiser]",
    place_result = shared.space_cruiser,
    stack_size = 1,
  },
  {
    type = "recipe",
    name = shared.space_cruiser,
    localised_name = {"entity-name."..shared.space_cruiser},
    icon = ICONPATH .. "space-cruiser-icon.png",
    icon_size = 64, icon_mipmaps = 1,
    subgroup = "transport",
    order = "x[space-cruiser]",
    enabled = false,
    ingredients = space_cruiser_ingredients,
    results = {{type="item", name=shared.space_cruiser, amount=1}},
    energy_required = 60,
  },
  {
    type = "equipment-grid",
    name = shared.space_cruiser,
    width = 12,
    height = 8,
    equipment_categories = {} -- Added in the final fixes
  },
})


table.insert(
  data.raw.technology[technology_name].effects,
  { type = "unlock-recipe", recipe = shared.space_cruiser }
)
