local shared = require("shared")
vehitel_data = {}

local rocket_lift_weight = data.raw["utility-constants"]["default"].rocket_lift_weight
-- local rocket_lift_weight = 1000000

local have_SA = mods["space-age"]

local tech1 = "chemistry-science-pack"
local ingredients1 = {
  {type="item", name="steel-plate", amount=60},
  {type="item", name="advanced-circuit", amount=42},
  {type="item", name="electric-engine-unit", amount=12},
  {type="item", name="copper-cable", amount=200},
}

local tech2 = "space-science-pack"
local ingredients2 = {
  {type="item", name=shared.device1, amount=1},
  {type="item", name="low-density-structure", amount=60},
  {type="item", name="processing-unit", amount=42},
  {type="item", name="fission-reactor-equipment", amount=1},
}

local enable_device3 = false
local tech3 = "space-science-pack"
local ingredients3 = {
  {type="item", name=shared.device2, amount=12},
}

local equipment_type = "battery-equipment"
-- local equipment_type = "movement-bonus-equipment"

local eqcats = {"armor"}
if mods["WH40k-Titans"] then
  table.insert(eqcats, "wh40k-titans-")
end


if mods["Common-Industries"] then
  tech1 = afci_bridge.get.dense_cable().prerequisite
  ingredients1 = {
    {type="item", name="steel-plate", amount=60},
    {type="item", name=have_SA and "processing-unit" or "advanced-circuit", amount=42},
    {type="item", name="electric-engine-unit", amount=12},
    {type="item", name=afci_bridge.get.dense_cable().name, amount=12},
  }

  tech2 = afci_bridge.get.emfc().prerequisite
  ingredients2 = {
    {type="item", name=shared.device1, amount=1},
    {type="item", name="low-density-structure", amount=60},
    {type="item", name=afci_bridge.get.emfc().name, amount=12},
    {type="item", name="fission-reactor-equipment", amount=1},
  }

  enable_device3 = true
  tech3 = afci_bridge.get.st_operator().prerequisite
  ingredients3 = {
    {type="item", name=shared.device2, amount=1},
    {type="item", name=afci_bridge.get.nano_mat().name, amount=60},
    {type="item", name=afci_bridge.get.st_operator().name, amount=1},
    {type="item", name=afci_bridge.get.best_energy_provider().name, amount=1},
  }


elseif have_SA then
  tech1 = "space-science-pack"
  ingredients1 = {
    {type="item", name="steel-plate", amount=60},
    {type="item", name="processing-unit", amount=42},
    {type="item", name="electric-engine-unit", amount=12},
    {type="item", name="copper-cable", amount=200},
  }

  tech2 = "electromagnetic-science-pack"
  ingredients2 = {
    {type="item", name=shared.device1, amount=1},
    {type="item", name="low-density-structure", amount=60},
    {type="item", name="supercapacitor", amount=42},
    {type="item", name="fission-reactor-equipment", amount=1},
  }

  enable_device3 = true
  tech3 = "quantum-processor"
  ingredients3 = {
    {type="item", name=shared.device2, amount=1},
    {type="item", name="tungsten-plate", amount=60},
    {type="item", name="quantum-processor", amount=42},
    {type="item", name="fusion-reactor-equipment", amount=1},
  }
else
end



data:extend({
  {
    type = "item",
    name = shared.device1,
    icon = shared.path_prefix.."graphics/quantum-carburetor-g1-icon.png",
    icon_size = 64, icon_mipmaps = 3,
    subgroup = "utility-equipment",
    order = "z-"..shared.device1,
    stack_size = 20,
    weight = rocket_lift_weight / 400,
    place_as_equipment_result = shared.device1,
  },
  {
    type = "recipe",
    name = shared.device1,
    enabled = false,
    energy_required = 60,
    ingredients = ingredients1,
    results = {{type="item", name=shared.device1, amount=1}},
    category = "advanced-crafting",
  },
  {
    name = shared.device1,
    type = equipment_type,
    sprite = {
      flags = {"no-crop", "no-scale"},
      filename = shared.path_prefix.."graphics/quantum-carburetor-g1-eq.png",
      -- shift = {4, 0},
      -- scale = 0.5,
      width = 64, height = 96,
    },
    shape = {
      type = "full",
      width = 2,
      height = 3,
    },
    energy_source = {
      type = "electric",
      buffer_capacity = "20MJ",
      drain = "40kW",
      input_flow_limit = "200kW",
      output_flow_limit = "20kW",
      usage_priority = "secondary-input",
    },
    energy_consumption = "500kW",
    movement_bonus = 0.1,
    categories = eqcats,
  },

  {
    type = "item",
    name = shared.device2,
    icon = shared.path_prefix.."graphics/quantum-carburetor-g2-icon.png",
    icon_size = 64, icon_mipmaps = 3,
    subgroup = "utility-equipment",
    order = "z-"..shared.device2,
    stack_size = 10,
    weight = rocket_lift_weight / 200,
    place_as_equipment_result = shared.device2,
  },
  {
    type = "recipe",
    name = shared.device2,
    enabled = false,
    energy_required = 60,
    ingredients = ingredients2,
    results = {{type="item", name=shared.device2, amount=1}},
    category = "advanced-crafting",
  },
  {
    name = shared.device2,
    type = equipment_type,
    sprite = {
      flags = {"no-crop", "no-scale"},
      filename = shared.path_prefix.."graphics/quantum-carburetor-g2-eq.png",
      -- shift = {4, 0},
      -- scale = 0.5,
      width = 64, height = 96,
    },
    shape = {
      type = "full",
      width = 2,
      height = 3,
    },
    energy_source = {
      type = "electric",
      buffer_capacity = "100MJ",
      drain = "100kW",
      input_flow_limit = "500kW",
      output_flow_limit = "50kW",
      usage_priority = "secondary-input",
    },
    energy_consumption = "1MW",
    movement_bonus = 0.2,
    categories = eqcats,
  },

  {
    type = "item",
    name = shared.device3,
    icon = shared.path_prefix.."graphics/quantum-carburetor-g3-icon.png",
    icon_size = 64, icon_mipmaps = 3,
    subgroup = "utility-equipment",
    order = "z-"..shared.device3,
    stack_size = 5,
    weight = rocket_lift_weight / 100,
    place_as_equipment_result = shared.device3,
  },
  {
    type = "recipe",
    name = shared.device3,
    enabled = false,
    energy_required = 60,
    ingredients = ingredients3,
    results = {{type="item", name=shared.device3, amount=1}},
    category = "advanced-crafting",
  },
  {
    name = shared.device3,
    type = equipment_type,
    sprite = {
      flags = {"no-crop", "no-scale"},
      filename = shared.path_prefix.."graphics/quantum-carburetor-g3-eq.png",
      -- shift = {4, 0},
      -- scale = 0.5,
      width = 64, height = 96,
    },
    shape = {
      type = "full",
      width = 2,
      height = 3,
    },
    energy_source = {
      type = "electric",
      buffer_capacity = "500MJ",
      drain = "200kW",
      input_flow_limit = "2MW",
      output_flow_limit = "200kW",
      usage_priority = "secondary-input",
    },
    energy_consumption = "2MW",
    movement_bonus = 0.5,
    categories = eqcats,
  },
})

log(shared.mod_name.." adding recipes to: "..serpent.line{tech1=tech1, tech2=tech2, tech3=tech3})
vehitel_data.tech1 = tech1
vehitel_data.tech2 = tech2
vehitel_data.tech3 = tech3
vehitel_data.enable_device3 = enable_device3
-- Technology effects are added in the data-final-fixes


data:extend({
  {
    type = "sprite",
    name = shared.mod_prefix.."gui-btn-main",
    filename = shared.path_prefix.."graphics/ui-teleporter-icon-main.png",
    width = 128, height = 128, mipmap_count = 4,
  },
  {
    type = "sprite",
    name = shared.mod_prefix.."gui-btn-idle",
    filename = shared.path_prefix.."graphics/ui-teleporter-icon-idle.png",
    width = 128, height = 128, mipmap_count = 4,
  },
  {
    type = "sprite",
    name = shared.mod_prefix.."gui-btn-active",
    filename = shared.path_prefix.."graphics/ui-teleporter-icon-active.png",
    width = 128, height = 128, mipmap_count = 4,
  },
  {
    type = "sprite",
    name = shared.mod_prefix.."gui-btn-error",
    filename = shared.path_prefix.."graphics/ui-teleporter-icon-error.png",
    width = 128, height = 128, mipmap_count = 4,
  },
  {
    type = "selection-tool",
    name = shared.dst_selector,
    icon = "__base__/graphics/icons/spidertron-remote.png",
    -- icon = shared.path_prefix.."graphics/icons/WorldBreaker.png",
    -- icon_size = 64, icon_mipmaps = 3,
    flags = {"only-in-cursor", "not-stackable", "spawnable"},
    subgroup = "spawnables",
    stack_size = 1,
    select = {
      border_color = {r = 0.6, g = 0.5, b = 1.0},
      mode = {"not-same-force"},
      cursor_box_type = "entity",
    },
    alt_select = {
      border_color = {r = 0.5, g = 0.1, b = 0.2},
      mode = {"not-same-force"},
      cursor_box_type = "entity",
    },
  },


  {
    type = "sound",
    name = shared.mod_prefix.."teleport-shutdown",
    category = "environment",
    variations = {
      {filename=shared.path_prefix.."sounds/teleport-shutdown.wav"},
    },
    audible_distance_modifier = 2,
  },
  {
    type = "sound",
    name = shared.mod_prefix.."teleport-finish",
    category = "environment",
    variations = {
      {filename=shared.path_prefix.."sounds/teleport-finish.wav"},
    },
    audible_distance_modifier = 3,
  },
  {
    type = "sound",
    name = shared.mod_prefix.."teleport-progress",
    category = "environment",
    variations = {
      {filename=shared.path_prefix.."sounds/teleport-progress.wav"},
    },
    audible_distance_modifier = 2,
  },
  {
    type = "sound",
    name = shared.mod_prefix.."teleport-start",
    category = "environment",
    variations = {
      {filename=shared.path_prefix.."sounds/teleport-start.wav"},
    },
    audible_distance_modifier = 2,
  },
})
