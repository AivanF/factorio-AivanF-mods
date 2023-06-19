require "shared"

function append(array, value)
    array[#array] = value
end

local basic_icon = mod_path .. "/graphics/basic-chest-icon.png"
local signals_icon = mod_path .. "/graphics/signals-chest-icon.png"
local logistic_icon = mod_path .. "/graphics/logistic-chest-icon.png"

local basic_entity_filename = mod_path .. "/graphics/basic-chest.png"
local basic_entity_filename_hr = mod_path .. "/graphics/basic-chest-hr.png"

local signals_entity_filename = mod_path .. "/graphics/signals-chest.png"
local signals_entity_filename_hr = mod_path .. "/graphics/signals-chest-hr.png"

local logistic_entity_filename = mod_path .. "/graphics/logistic-chest.png"
local logistic_entity_filename_hr = mod_path .. "/graphics/logistic-chest-hr.png"

local logistic_mode = "passive-provider"
if settings.startup["af-alc-active-chest"].value then
	logistic_mode = "active-provider"
end

data:extend({
  {
    type = "item",
    name = basic_chest_name,
    icon = basic_icon,
    icon_size = 64,
    subgroup = "logistic-network",
    order = "b[storage]-z-alc1["..basic_chest_name.."]",
    place_result = basic_chest_name,
    stack_size = 20
  },
  {
    type = "item",
    name = signals_chest_name,
    icon = signals_icon,
    icon_size = 64,
    subgroup = "logistic-network",
    order = "b[storage]-z-alc2["..signals_chest_name.."]",
    place_result = signals_chest_name,
    stack_size = 20
  },
  {
    type = "item",
    name = logistic_chest_name,
    icon = logistic_icon,
    icon_size = 64,
    subgroup = "logistic-network",
    order = "b[storage]-z-alc3["..logistic_chest_name.."]",
    place_result = logistic_chest_name,
    stack_size = 20
  },

  {
    type = "recipe",
    name = basic_chest_name,
    enabled = true,
    ingredients = {
      {"iron-plate", 10},
      {"electronic-circuit", 10},
      {"inserter", 2},
      {"radar", 1},
    },
    result = basic_chest_name
  },

  {
    type = "recipe",
    name = signals_chest_name,
    enabled = false,
    ingredients = {
      {"steel-plate", 10},
      {"electronic-circuit", 10},
      {"filter-inserter", 2},
      {"radar", 1},
    },
    result = signals_chest_name
  },
  {
    type = "recipe",
    name = logistic_chest_name,
    enabled = false,
    ingredients = {
      {"steel-plate", 20},
      {"advanced-circuit", 10},
      {"filter-inserter", 2},
      {"radar", 1},
    },
    result = logistic_chest_name
  },

-- }) data:extend({
  {
    type = "container",
    name = basic_chest_name,
    icon = basic_icon,
    icon_size = 64,
    flags = {"placeable-player", "player-creation"},
    minable = {mining_time = 0.5, result = basic_chest_name},
    max_health = 350,
    corpse = "small-remnants",
    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    resistances = {
      { type = "physical", decrease=5, percent=50 },
      { type = "impact", decrease=5, percent=50 },
      { type = "fire", decrease=5, percent=50 },
      { type = "acid", decrease=5, percent=10 },
      { type = "poison", decrease=50, percent=90 },
      { type = "explosion", decrease=50, percent=50 },
      { type = "laser", decrease=5, percent=50 },
      { type = "electric", decrease=5, percent=50 },
    },
    fast_replaceable_group = "container",
    inventory_size = 20,
    open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.75 },
    close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume=0.75 },
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume=0.65 },
    picture = {
      layers = {
        {
          filename = basic_entity_filename,
          width = 34,
          height = 38,
          shift = util.by_pixel(0, -0.5),
          hr_version = {
            filename = basic_entity_filename_hr,
            width = 66,
            height = 76,
            shift = util.by_pixel(-0.5, -0.5),
            scale = 0.5,
          }
        },
        {
          filename = "__base__/graphics/entity/iron-chest/iron-chest-shadow.png",
          width = 56,
          height = 26,
          shift = util.by_pixel(10, 6.5),
          draw_as_shadow = true,
          hr_version = {
            filename = "__base__/graphics/entity/iron-chest/hr-iron-chest-shadow.png",
            width = 110,
            height = 50,
            shift = util.by_pixel(10.5, 6),
            draw_as_shadow = true,
            scale = 0.5,
          }
        },
      },
    },
  },

-- }) data:extend({
  {
    type = "container",
    name = signals_chest_name,
    icon = signals_icon,
    icon_size = 64,
    flags = {"placeable-player", "player-creation"},
    minable = {mining_time = 0.5, result = signals_chest_name},
    max_health = 500,
    corpse = "small-remnants",
    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    resistances = {
      { type = "physical", decrease=10, percent=60 },
      { type = "impact", decrease=10, percent=60 },
      { type = "fire", decrease=10, percent=60 },
      { type = "acid", decrease=10, percent=30 },
      { type = "poison", decrease=50, percent=90 },
      { type = "explosion", decrease=50, percent=60 },
      { type = "laser", decrease=10, percent=60 },
      { type = "electric", decrease=10, percent=60 },
    },
    fast_replaceable_group = "container",
    inventory_size = 40,
    open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.75 },
    close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume=0.75 },
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume=0.65 },
    picture = {
      layers = {
        {
          filename = signals_entity_filename,
          width = 34,
          height = 38,
          shift = util.by_pixel(0, -0.5),
          hr_version = {
            filename = signals_entity_filename_hr,
            width = 66,
            height = 76,
            shift = util.by_pixel(-0.5, -0.5),
            scale = 0.5,
          }
        },
        {
          filename = "__base__/graphics/entity/steel-chest/steel-chest-shadow.png",
          width = 56,
          height = 22,
          shift = util.by_pixel(10, 6.5),
          draw_as_shadow = true,
          hr_version = {
            filename = "__base__/graphics/entity/steel-chest/hr-steel-chest-shadow.png",
            width = 110,
            height = 46,
            shift = util.by_pixel(10.5, 6),
            draw_as_shadow = true,
            scale = 0.5,
          }
        },
      },
    },
    circuit_wire_connection_point = circuit_connector_definitions["chest"].points,
    circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
    circuit_wire_max_distance = default_circuit_wire_max_distance,
  },

-- }) data:extend({
  {
    type = "logistic-container",
    name = logistic_chest_name,
    icon = logistic_icon,
    icon_size = 64,
    flags = {"placeable-player", "player-creation"},
    minable = {mining_time = 0.5, result = logistic_chest_name},
    max_health = 500,
    corpse = "small-remnants",
    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    resistances = {
      { type = "physical", decrease=20, percent=60 },
      { type = "impact", decrease=20, percent=60 },
      { type = "fire", decrease=20, percent=60 },
      { type = "acid", decrease=20, percent=30 },
      { type = "poison", decrease=50, percent=90 },
      { type = "explosion", decrease=50, percent=60 },
      { type = "laser", decrease=20, percent=60 },
      { type = "electric", decrease=20, percent=60 },
    },
    fast_replaceable_group = "container",
    inventory_size = 50,
    logistic_mode = logistic_mode,
    open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.75 },
    close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume=0.75 },
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume=0.65 },
    opened_duration = logistic_chest_opened_duration,
    animation =
    {
      layers =
      {
        {
          filename = logistic_entity_filename,
          priority = "extra-high",
          width = 34,
          height = 38,
          frame_count = 7,
          shift = util.by_pixel(0, -2),
          hr_version =
          {
            filename = logistic_entity_filename_hr,
            priority = "extra-high",
            width = 66,
            height = 74,
            frame_count = 7,
            shift = util.by_pixel(0, -2),
            scale = 0.5
          }
        },
        {
          filename = "__base__/graphics/entity/logistic-chest/logistic-chest-shadow.png",
          priority = "extra-high",
          width = 48,
          height = 24,
          repeat_count = 7,
          shift = util.by_pixel(8.5, 5.5),
          draw_as_shadow = true,
          hr_version =
          {
            filename = "__base__/graphics/entity/logistic-chest/hr-logistic-chest-shadow.png",
            priority = "extra-high",
            width = 96,
            height = 44,
            repeat_count = 7,
            shift = util.by_pixel(8.5, 5),
            draw_as_shadow = true,
            scale = 0.5
          }
        }
      }
    },
    circuit_wire_connection_point = circuit_connector_definitions["chest"].points,
    circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
    circuit_wire_max_distance = default_circuit_wire_max_distance,
  }
})

if settings.startup["af-alc-add-laser"].value then
  append(data.raw.recipe[ signals_chest_name].ingredients, {"laser-turret", 1})
  append(data.raw.recipe[logistic_chest_name].ingredients, {"laser-turret", 1})
end

table.insert(
  data.raw.technology["circuit-network"].effects,
  { type = "unlock-recipe", recipe = signals_chest_name }
)

-- logistic-robotics or logistic-system?
table.insert(
  data.raw.technology["logistic-robotics"].effects,
	{ type = "unlock-recipe", recipe = logistic_chest_name }
)
