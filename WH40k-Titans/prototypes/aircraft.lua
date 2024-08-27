local shared = require("shared")

-- Adotped from the "Aircraft" mod by MIT license


local ICONPATH = shared.media_prefix.."graphics/icons/"
local ENTITYPATH = shared.media_prefix.."graphics/entity/"

local function addcommonanimlines(anim)
  for _,layer in pairs(anim.layers) do
    layer.width, layer.height = 448, 448
    layer.scale = 0.5
    layer.hr_version.width, layer.hr_version.height = 896, 896
    layer.hr_version.scale = 0.25
    layer.frame_count, layer.hr_version.frame_count = 1, 1
    layer.direction_count, layer.hr_version.direction_count = 36, 36
    layer.line_length, layer.hr_version.line_length = 6, 6
    layer.max_advance, layer.hr_version.max_advance = 1, 1
  end
  return anim
end

local function aircraftAnimation(nickname)
  local anim = {}
  anim.layers = {
    {
      filename = ENTITYPATH .. "/" .. nickname .. "-sheet.png",
      shift = util.by_pixel(9, -10),
      hr_version = {
        filename = ENTITYPATH .. "/" .. nickname .. "-sheet-HR.png",
        shift = util.by_pixel(9, -10),
      }
    },
    -- {
    --   filename = ENTITYPATH .. name .. "/" .. name .. "_spritesheet-shadow.png",
    --   shift = util.by_pixel(54, 35),
    --   draw_as_shadow = true,
    --   hr_version = {
    --     filename = ENTITYPATH .. name .. "/hr-" .. name .. "_spritesheet-shadow.png",
    --     shift = util.by_pixel(54, 35),
    --     draw_as_shadow = true,
    --   }
    -- }
  }
  addcommonanimlines(anim)
  return anim
end

local function aircraftLightAnimation(nickname)
  local anim = {}
  anim.layers = {
    {
      filename = ENTITYPATH .. "/" .. nickname .. "-sheet-light.png",
      shift = util.by_pixel(9, -10),
      draw_as_light = true,
      hr_version = {
        filename = ENTITYPATH .. "/" .. nickname .. "-sheet-light-HR.png",
        shift = util.by_pixel(9, -10),
        draw_as_light = true,
      }
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

  sound = { filename = shared.media_prefix.."sounds/aircraft-loop.ogg", volume = 0.3 },
  deactivate_sound = { filename = shared.media_prefix.."sounds/aircraft-stop.ogg", volume = 0.3 },
  match_speed_to_activity = true,
  fade_in_ticks = 30,
}

---add in one function all the common parameteres between aircrafts
local function add_recurrent_params(proto)
  proto.icon_size = 64
  proto.flags = {"placeable-neutral", "player-creation", "placeable-off-grid"}
  -- Overriding the "car" default disables acid puddle damage.
  proto.trigger_target_mask = { "common" }
  proto.has_belt_immunity = true
  proto.dying_explosion = "medium-explosion"
  proto.terrain_friction_modifier = 0
  proto.collision_box = {{-1.1, -1.5}, {1.1, 1.5}}
  proto.collision_mask = {}
  proto.selection_box = {{-1.1, -1.5}, {1.1, 1.5}}
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
    filename = ICONPATH .. "map-aircraft.png",
    flags = {"icon"},
    size = {48, 48},
    scale = 0.5
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

--------- Titan Ammo Supplier
local titan_supplier = {
  type = "car",
  name = shared.aircraft_supplier,
  icon = ICONPATH .. "aircraft-supplier.png",
  icon_size = 64, icon_mipmaps = 3,
  minable = {mining_time = 5, result = shared.aircraft_supplier},
  light = { lightdef(-40, -415, 7), lightdef(40, -415, 7) },
  animation = aircraftAnimation("aircraft-supplier"),
  light_animation = aircraftLightAnimation("aircraft-supplier"),
  corpse = "medium-remnants",
  -- SPECS
  max_health = 5000,
  energy_per_hit_point = 1,
  resistances = {
    resist("fire",      100,  50),
    resist("laser",     100,  50),
    resist("physical",   20,  75),
    resist("impact",      0, 100),
    resist("explosion", 100,  75),
    resist("acid",      100,  50),
  },
  inventory_size = 50,
  guns = {},
  equipment_grid = shared.mod_prefix.."aircraft",
  -- MOVEMENT
  effectivity = 0.9,
  braking_power = "3.5MW",
  burner = {
    fuel_categories = {"chemical"},
    fuel_inventory_size = 4,
    smoke = { smokedef(-16, 60, 38), smokedef(16, 60, 38) }
  },
  consumption = "4MW",
  friction = 0.002,
  stop_trigger_speed = 0.2,
  acceleration_per_energy = 0.3,
  breaking_speed = 0.05,
  rotation_speed = 0.01,
  weight = 2500,
}

add_recurrent_params(titan_supplier)

data:extend({
  {
    type = "equipment-grid",
    name = shared.mod_prefix.."aircraft",
    width = 12,
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

  titan_supplier,
  {
    type = "item-with-entity-data",
    name = shared.aircraft_supplier,
    icon = ICONPATH .. "aircraft-supplier.png",
    icon_size = 64, icon_mipmaps = 3,
    flags = {},
    subgroup = shared.subg_build,
    order = "y[aircraft-item-supplier]",
    place_result = shared.aircraft_supplier,
    stack_size = 1,
  },
  {
    type = "recipe",
    name = shared.aircraft_supplier,
    localised_name = {"entity-name."..shared.aircraft_supplier},
    icon = ICONPATH .. "aircraft-supplier.png",
    icon_size = 64, icon_mipmaps = 3,
    subgroup = shared.subg_build,
    order = "y[aircraft-item-supplier]",
    enabled = false,
    -- category = "advanced-crafting",
    ingredients = {
      {shared.servitor,    1},
      {shared.frame_part,  5},
      {shared.antigraveng, 1},
      {shared.motor,       3},
      -- {shared.rocket_engine, 3},
      {afci_bridge.get.rocket_engine().name, 5},
    },
    results = {{shared.aircraft_supplier, 1}},
    energy_required = 60,
  },
})
