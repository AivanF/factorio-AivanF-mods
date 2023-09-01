local shared = require("shared")

-- TODO: upscale ingredients, so that modded ones are somehow equal to these one
-- TODO: add technologies for them?
local parts = {
  [shared.barrel] = {
    name = shared.barrel,
    icon = shared.media_prefix.."graphics/icons/details/wp-barrel.png",
    icon_size = 64,
    icon_mipmaps = 4,
    ingredients = {
      {"sulfur", 100},
      {"low-density-structure", 50},
    },
    order = "b-1",
    place_result = nil,
  },
  [shared.proj_engine] = {
    name = shared.proj_engine,
    icon = shared.media_prefix.."graphics/icons/details/wp-engine.png",
    icon_size = 64,
    icon_mipmaps = 4,
    ingredients = {
      {"low-density-structure", 50},
      {"iron-gear-wheel", 50},
      {"electric-engine-unit", 50},
    },
    order = "b-2",
    place_result = nil,
  },
  [shared.he_emitter] = {
    name = shared.he_emitter,
    icon = shared.media_prefix.."graphics/icons/details/wp-he-em.png",
    icon_size = 64,
    icon_mipmaps = 4,
    ingredients = {
      {"electric-engine-unit", 50},
    },
    order = "b-3",
    place_result = nil,
  },
  [shared.ehe_emitter] = {
    name = shared.ehe_emitter,
    icon = shared.media_prefix.."graphics/icons/details/wp-ehe-em.png",
    icon_size = 64,
    icon_mipmaps = 4,
    ingredients = {
      {"low-density-structure", 50},
      {"iron-gear-wheel", 50},
      {"copper-cable", 100},
    },
    order = "b-4",
    place_result = nil,
  },
}

-- TODO: customize recipes by enabled mods: SE

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
