local shared = require("shared")

-- TODO: upscale ingredients, so that modded ones are somehow equal to these one
-- TODO: add technologies for them?
local parts = {
  [shared.servitor] = {
    name = shared.servitor,
    icon = shared.media_prefix.."graphics/icons/details/bp-serv.png",
    icon_size = 64,
    icon_mipmaps = 4,
    ingredients = {
      {"wood", 50},
      -- {"low-density-structure", 20},
      {"processing-unit", 50},
      {"construction-robot", 1},
    },
    order = "a-1",
    place_result = nil,
  },
  [shared.brain] = {
    name = shared.brain,
    icon = shared.media_prefix.."graphics/icons/details/bp-brain.png",
    icon_size = 64,
    icon_mipmaps = 4,
    ingredients = {
      {"radar", 1},
      {"processing-unit", 200},
    },
    order = "a-2",
    place_result = nil,
  },
  [shared.motor] = {
    name = shared.motor,
    icon = shared.media_prefix.."graphics/icons/details/bp-motor.png",
    icon_size = 64,
    icon_mipmaps = 4,
    ingredients = {
      {"electric-engine-unit", 50},
    },
    order = "a-3",
    place_result = nil,
  },
  [shared.frame_part] = {
    name = shared.frame_part,
    icon = shared.media_prefix.."graphics/icons/details/bp-frame.png",
    icon_size = 64,
    icon_mipmaps = 4,
    ingredients = {
      {"low-density-structure", 50},
      {"iron-gear-wheel", 50},
      {"copper-cable", 100},
    },
    order = "a-4",
    place_result = nil,
  },
  [shared.energy_core] = {
    name = shared.energy_core,
    icon = shared.media_prefix.."graphics/icons/details/bp-ec.png",
    icon_size = 64,
    icon_mipmaps = 4,
    ingredients = {
      {"fusion-reactor-equipment", 50},
    },
    order = "a-5",
    place_result = nil,
  },
  [shared.void_shield] = {
    name = shared.void_shield,
    icon = shared.media_prefix.."graphics/icons/details/bp-void.png",
    icon_size = 64,
    icon_mipmaps = 4,
    ingredients = {
      {"energy-shield-mk2-equipment", 50},
    },
    order = "a-6",
    place_result = nil,
  },
}

-- TODO: customize recipes by enabled mods: SE, advanced power armor, meat of PBB

for _, info in pairs(parts) do
  data:extend({
    {
      type = "item",
      name = info.name,
      icon = info.icon,
      icon_size = info.icon_size, icon_mipmaps = info.icon_mipmaps,
      subgroup = shared.subg_parts,
      order = info.order,
      place_result = info.place_result,
      stack_size = 1,
    },
    {
      type = "recipe",
      name = info.name,
      enabled = false,
      ingredients = info.ingredients,
      result = info.name,
    },
  })
end
