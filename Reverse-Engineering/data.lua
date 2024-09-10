local sounds = require("__base__.prototypes.entity.sounds")
require("shared")

local base_name = "af-reverse-lab"
local icon = "__Reverse-Engineering__/graphics/rlab-icon.png"
local icon_size = 64
local icon_mipmaps = 1

local special_flags = {
  "not-rotatable", "placeable-neutral", "placeable-off-grid",
  "not-blueprintable", "not-deconstructable", "not-flammable",
}

local resistances = {
  { type = "impact", decrease=10000, percent=100 },
  { type = "physical", percent=100 },
  { type = "explosion", percent=100 },
  { type = "laser", percent = 100 },
  { type = "fire", percent = 100 },
  { type = "electric", percent=100 },
  { type = "acid", percent=100 },
  { type = "poison", percent=100 },
}

local function box_mult(box, xs, ys)
  box[1][1] = box[1][1] * xs
  box[1][2] = box[1][2] * ys
  box[2][1] = box[2][1] * xs
  box[2][2] = box[2][2] * ys
  return box
end

local chest_base = table.deepcopy(data.raw["container"]["iron-chest"])
chest_base.max_health = 10000
chest_base.healing_per_tick = 10000
chest_base.flags = special_flags
chest_base.collision_mask = {}
chest_base.resistances = resistances
chest_base.next_upgrade = nil
chest_base.minable = nil
chest_base.inventory_size = 20

local chest_input = table.deepcopy(chest_base)
chest_input.name = base_name.."-chest-input"
-- chest_input.picture.layers[1].tint = {0.8, 1, 0.9}
-- chest_input.picture.layers[1].hr_version.tint = chest_input.picture.layers[1].tint
chest_input.selection_box = box_mult(chest_input.selection_box, 1, 3)
chest_input.collision_box = box_mult(chest_input.collision_box, 1, 3)
chest_input.picture = {
  layers = {
    {
      filename = "__Reverse-Engineering__/graphics/chest-input.png",
      priority = "extra-high",
      width = 34,
      height = 102,
      shift = util.by_pixel(0, 0),
      hr_version = {
        filename = "__Reverse-Engineering__/graphics/chest-input-hr.png",
        priority = "extra-high",
        width = 66,
        height = 192,
        shift = util.by_pixel(0, 0),
        scale = 0.5
      }
    },
    {
      filename = "__base__/graphics/entity/iron-chest/iron-chest-shadow.png",
      priority = "extra-high",
      width = 56,
      height = 26,
      shift = util.by_pixel(10, 6.5),
      draw_as_shadow = true,
      hr_version = {
        filename = "__base__/graphics/entity/iron-chest/hr-iron-chest-shadow.png",
        priority = "extra-high",
        width = 110,
        height = 50,
        shift = util.by_pixel(10.5, 6),
        draw_as_shadow = true,
        scale = 0.5
      }
    }
  }
}

local chest_packs = table.deepcopy(chest_base)
chest_packs.name = base_name.."-chest-packs"
-- chest_packs.picture.layers[1].tint = {0.9, 0.9, 1}
-- chest_packs.picture.layers[1].hr_version.tint = chest_packs.picture.layers[1].tint
chest_packs.picture = {
  layers = {
    {
      filename = "__Reverse-Engineering__/graphics/chest-science.png",
      priority = "extra-high",
      width = 34,
      height = 34,
      shift = util.by_pixel(0, 0),
      hr_version = {
        filename = "__Reverse-Engineering__/graphics/chest-science-hr.png",
        priority = "extra-high",
        width = 66,
        height = 66,
        shift = util.by_pixel(0, 0),
        scale = 0.5
      }
    },
    {
      filename = "__base__/graphics/entity/iron-chest/iron-chest-shadow.png",
      priority = "extra-high",
      width = 56,
      height = 26,
      shift = util.by_pixel(10, 6.5),
      draw_as_shadow = true,
      hr_version = {
        filename = "__base__/graphics/entity/iron-chest/hr-iron-chest-shadow.png",
        priority = "extra-high",
        width = 110,
        height = 50,
        shift = util.by_pixel(10.5, 6),
        draw_as_shadow = true,
        scale = 0.5
      }
    }
  }
}

local chest_other = table.deepcopy(chest_base)
chest_other.name = base_name.."-chest-other"
-- chest_other.picture.layers[1].tint = {1, 0.8, 0.8}
-- chest_other.picture.layers[1].hr_version.tint = chest_other.picture.layers[1].tint
chest_other.picture = {
  layers = {
    {
      filename = "__Reverse-Engineering__/graphics/chest-trash.png",
      priority = "extra-high",
      width = 34,
      height = 34,
      shift = util.by_pixel(0, 0),
      hr_version = {
        filename = "__Reverse-Engineering__/graphics/chest-trash-hr.png",
        priority = "extra-high",
        width = 66,
        height = 66,
        shift = util.by_pixel(0, 0),
        scale = 0.5
      }
    },
    {
      filename = "__base__/graphics/entity/iron-chest/iron-chest-shadow.png",
      priority = "extra-high",
      width = 56,
      height = 26,
      shift = util.by_pixel(10, 6.5),
      draw_as_shadow = true,
      hr_version = {
        filename = "__base__/graphics/entity/iron-chest/hr-iron-chest-shadow.png",
        priority = "extra-high",
        width = 110,
        height = 50,
        shift = util.by_pixel(10.5, 6),
        draw_as_shadow = true,
        scale = 0.5
      }
    }
  }
}

local chest_corpse = table.deepcopy(data.raw["container"]["iron-chest"])
chest_corpse.name = base_name.."-chest-corpse"
chest_corpse.next_upgrade = nil
chest_corpse.minable = {mining_time = 1}
chest_corpse.inventory_size = 20

data:extend({ chest_input, chest_packs, chest_other, chest_corpse })

for _, info in pairs(make_grades and rlab_list or {rlabs[2]}) do
  data:extend({
    {
      type = "simple-entity-with-force",
      name = info.name.."-center",
      localised_name = {"entity-name."..info.name},
      localised_description = {"entity-description.af-reverse-lab"},
      icon = info.icon, icon_size = info.icon_size, icon_mipmaps = info.icon_mipmaps,
      flags = special_flags,
      max_health = 10000,
      selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
      collision_box = {{-0.5, -0.5}, {0.5, 0.5}},
      -- collision_mask = {"floor-layer", "item-layer", "object-layer", "water-tile"},
      vehicle_impact_sound = sounds.generic_impact,
      animations = {
        filename = info.sprite,
        width = 240,
        height = 240,
        scale = 0.5,
      },
    },
    {
      type = "electric-energy-interface",
      name = info.name,
      minable = {mining_time = 1.0, result = info.name},
      se_allow_in_space = true,
      icon = info.icon, icon_size = info.icon_size, icon_mipmaps = info.icon_mipmaps,
      flags = {
        "not-rotatable", "placeable-neutral", "player-creation",
      },
      max_health = info.health,
      -- corpse = "medium-electric-pole-remnants",
      corpse = "lab-remnants",
      dying_explosion = "massive-explosion",
      selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
      collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
      collision_mask = {"floor-layer", "item-layer", "object-layer", "water-tile"},
      selection_priority = 40,
      vehicle_impact_sound = sounds.generic_impact,
      open_sound = sounds.electric_network_open,
      close_sound = sounds.electric_network_close,
      energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        buffer_capacity = (100*info.usage/KW).."KJ",
        input_flow_limit = (20*info.usage/KW).."KW",
        drain = (info.usage/KW).."KW",
      },
      render_layer = "floor",
      animations = {
        -- filename = info.sprite,
        filename = "__Reverse-Engineering__/graphics/RLab-floor.png",
        width = 240,
        height = 240,
        scale = 0.5,
        shift = { 0.2, 0 },
      },
    },
    {
      type = "item",
      name = info.name,
      icon = info.icon, icon_size = info.icon_size, icon_mipmaps = info.icon_mipmaps,
      subgroup = "production-machine",
      order = "g[lab-reversed-"..info.grade.."]",
      place_result = info.name,
      stack_size = 10,
    },
    {
      type = "recipe",
      name = info.name,
      enabled = not info.prereq,
      ingredients = info.ingredients,
      result = info.name,
    },
  })
  if info.prereq then
    table.insert(
      data.raw.technology[info.prereq].effects,
      { type = "unlock-recipe", recipe = info.name }
    )
  end
end


data:extend{
  {
    type = "sprite",
    name = "af-reverse-lab-worth",
    filename = "__Reverse-Engineering__/graphics/shortcut-worth.png",
    width = 64, height = 64,
  },
  {
    -- https://wiki.factorio.com/Prototype/Shortcut#small_icon
    type = "shortcut",
    name = "af-reverse-lab-worth",
    localised_name = { "shortcut-name.af-reverse-lab-see-worth"},
    localised_description = { "shortcut-description.af-reverse-lab-see-worth"},
    -- associated_control_input = "__xyz__", TODO: add this?
    order = "def",
    action = "lua",
    style = "blue",
    icon = {
      filename = "__Reverse-Engineering__/graphics/shortcut-worth.png",
      size = 64,
      scale = 1,
      priority = "extra-high-no-scale",
    },
  },
}

informatron_make_image("reveng-info", "__Reverse-Engineering__/graphics/info-expl.jpg", 900, 600)
