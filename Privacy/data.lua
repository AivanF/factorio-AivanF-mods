local S = require("shared")

local base_resistances = {
  { type = "physical", decrease=5, percent=50 },
  { type = "impact", decrease=50, percent=90 },
  { type = "fire", decrease=5, percent=50 },
  { type = "acid", decrease=5, percent=50 },
  { type = "poison", decrease=50, percent=90 },
  { type = "explosion", decrease=10, percent=50 },
  { type = "laser", decrease=5, percent=50 },
  { type = "electric", decrease=5, percent=50 },
}

local stub_recipe_category = "af-priv-empty"
local subgroup = "storage-private"


function make_private_storage(details, layers)
  local result = {
    type = S.storage_base_type,
    flags = {
      "placeable-neutral", "not-rotatable", "not-flammable",
      "placeable-player", "player-creation",
    },
    corpse = "small-remnants",
    collision_box = {{-1.35, -1.35}, {1.35, 1.35}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    resistances = base_resistances,
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume=0.75 },
    working_visualisations = {
      {
        always_draw = true,
        render_layer = "object",
        north_animation = {
          layers = layers
        },
        east_animation = {
          layers = layers
        },
        south_animation = {
          layers = layers
        },
        west_animation = {
          layers = layers
        }
      }
    },
    crafting_speed = 0.001,
    crafting_categories = {stub_recipe_category},
    energy_source = {type = "void"},
    energy_usage = "1W",
  }
  for k, v in pairs(details) do
    result[k] = v
  end
  return result
end


data:extend({
  {
    type = "recipe-category",
    name = stub_recipe_category,
  },
  {
    type = "item-subgroup",
    name = subgroup,
    group = "logistics",
    order = "a-2",
  },

  ----------- Lock detail
  {
    type = "item",
    name = S.lock_item,
    icon = S.mod_path.."/graphics/lock.png",
    icon_size = 64,
    subgroup = subgroup,
    order = "b-2-"..S.lock_item,
    stack_size = 20,
  },
  {
    type = "recipe",
    name = S.lock_item,
    enabled = true,
    ingredients = {
      {"iron-gear-wheel", 6},
      {"iron-stick", 8},
      {"copper-cable", 20},
    },
    result = S.lock_item,
  },


  ----------- Keys
  {
    type = "item-with-tags",
    name = S.iron_key_item,
    icon = S.mod_path.."/graphics/key-iron.png",
    icon_size = 64,
    subgroup = subgroup,
    order = "a-1-"..S.iron_key_item,
    stack_size = 20,
  },
  {
    type = "recipe",
    name = S.iron_key_item,
    enabled = true,
    ingredients = {
      {"iron-plate", 2},
    },
    result = S.iron_key_item,
  },

  {
    type = "item-with-tags",
    name = S.bronze_key_item,
    icon = S.mod_path.."/graphics/key-bronze.png",
    icon_size = 64,
    subgroup = subgroup,
    order = "a-2-"..S.bronze_key_item,
    stack_size = 20,
  },
  {
    type = "recipe",
    name = S.bronze_key_item,
    enabled = true,
    ingredients = {
      {"iron-plate", 1},
      {"copper-plate", 1},
    },
    result = S.bronze_key_item,
  },

  {
    type = "item-with-tags",
    name = S.car_key_item,
    icon = S.mod_path.."/graphics/key-car.png",
    icon_size = 64,
    subgroup = subgroup,
    order = "a-3-"..S.car_key_item,
    stack_size = 10,
  },
  {
    type = "recipe",
    name = S.car_key_item,
    enabled = false,
    ingredients = {
      {"steel-plate", 1},
      {"plastic-bar", 1},
    },
    result = S.car_key_item,
  },

  {
    type = "item-with-tags",
    name = S.noble_key_item,
    icon = S.mod_path.."/graphics/key-noble.png",
    icon_size = 64,
    subgroup = subgroup,
    order = "a-4-"..S.noble_key_item,
    stack_size = 10,
  },

  {
    type = "item-with-tags",
    name = S.nfc_key_item,
    icon = S.mod_path.."/graphics/key-nfc.png",
    icon_size = 64,
    subgroup = subgroup,
    order = "a-4-"..S.nfc_key_item,
    stack_size = 100,
  },
  {
    type = "recipe",
    name = S.nfc_key_item,
    enabled = false,
    ingredients = {
      {"steel-plate", 1},
      {"advanced-circuit", 1},
    },
    result = S.nfc_key_item,
  },


  ----------- Engraving Tables
  {
    type = "recipe",
    name = S.table_item,
    enabled = true,
    ingredients = {
      {"iron-gear-wheel", 10},
      {"copper-cable", 20},
      {"stone-brick", 20},
    },
    result = S.table_item,
  },
  {
    type = "item",
    name = S.table_item,
    icon = S.mod_path.."/graphics/engraving-table-HR.png",
    icon_size = 64,
    subgroup = subgroup,
    order = "b-1-"..S.table_item,
    place_result = S.table_item,
    stack_size = 10,
  },
  {
    type = "container",
    name = S.table_item,
    icon = S.mod_path.."/graphics/Chest-Locked-HR.png",
    icon_size = 64,
    flags = {"placeable-player", "player-creation"},
    minable = {mining_time = 0.5, result = S.table_item},
    max_health = 500,
    corpse = "small-remnants",
    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    inventory_size = 20,
    picture = {
      layers = {
        {
          filename = S.mod_path.."/graphics/engraving-table-HR.png",
          width = 76,
          height = 76,
          shift = util.by_pixel(0, -0.5),
          scale = 0.5,
          -- hr_version = {
          --   filename = S.mod_path.."/graphics/engraving-table-HR.png",
          --   width = 76,
          --   height = 76,
          --   shift = util.by_pixel(0, -0.5),
          --   scale = 0.5,
          -- }
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


  ----------- 1. Key Locked
  {
    type = "recipe",
    name = S.keylocked_chest_name,
    enabled = true,
    ingredients = {
      {"steel-chest", 1},
      {S.lock_item, 1},
    },
    result = S.keylocked_chest_name,
  },
  {
    type = "item",
    name = S.keylocked_chest_name,
    icon = S.mod_path.."/graphics/icon-lock.png",
    icon_size = 64,
    subgroup = subgroup,
    order = "c1-"..S.keylocked_chest_name,
    place_result = S.keylocked_chest_name,
    stack_size = 50,
  },
  make_private_storage({
      type = S.storage_base_type,
      name = S.keylocked_chest_name,
      icon = S.mod_path.."/graphics/icon-lock.png",
      icon_size = 64,
      minable = {mining_time = 0.5, result = S.keylocked_chest_name},
      max_health = 500,
      corpse = "small-remnants",
      collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
      selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    }, {
    {
      filename = S.mod_path.."/graphics/Chest-Locked-HR.png",
      width = 76,
      height = 76,
      shift = util.by_pixel(0, 0),
      scale = 0.5,
      -- hr_version = {
      --   filename = S.mod_path.."/graphics/Chest-Locked-HR.png",
      --   width = 66,
      --   height = 76,
      --   shift = util.by_pixel(-0.5, -0.5),
      --   scale = 0.5,
      -- }
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
  }),

  ----------- 2. Personal
  {
    type = "recipe",
    name = S.personal_chest_name,
    enabled = true,
    ingredients = {
      {"steel-chest", 1},
      {S.lock_item, 1},
      {"electronic-circuit", 10},
    },
    result = S.personal_chest_name,
  },
  {
    type = "item",
    name = S.personal_chest_name,
    icon = S.mod_path.."/graphics/icon-fingerprint.png",
    icon_size = 64,
    subgroup = subgroup,
    order = "c2-"..S.personal_chest_name,
    place_result = S.personal_chest_name,
    stack_size = 50,
  },
  make_private_storage({
      type = S.storage_base_type,
      name = S.personal_chest_name,
      icon = S.mod_path.."/graphics/icon-fingerprint.png",
      icon_size = 64,
      minable = {mining_time = 0.5, result = S.personal_chest_name},
      max_health = 500,
      corpse = "small-remnants",
      collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
      selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    }, {
    {
      filename = S.mod_path.."/graphics/Chest-Personal-HR.png",
      width = 76,
      height = 76,
      shift = util.by_pixel(0, 0),
      scale = 0.5,
      -- hr_version = {
      --   filename = S.mod_path.."/graphics/Chest-Personal-HR.png",
      --   width = 66,
      --   height = 76,
      --   shift = util.by_pixel(-0.5, -0.5),
      --   scale = 0.5,
      -- }
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
  }),

  ----------- 3. Team
  -- {
  --   type = "recipe",
  --   name = S.team_storage_name,
  --   enabled = true,
  --   ingredients = {
  --     {"steel-plate", 50},
  --     {"stone-brick", 50},
  --     {S.lock_item, 5},
  --     {"advanced-circuit", 10},
  --   },
  --   result = S.team_storage_name,
  -- },
  -- {
  --   type = "item",
  --   name = S.team_storage_name,
  --   icon = S.mod_path.."/graphics/Chest-Locked-HR.png",
  --   icon_size = 64,
  --   subgroup = subgroup,
  --   order = "c3-"..S.team_storage_name,
  --   place_result = S.team_storage_name,
  --   stack_size = 20,
  -- },
  -- make_private_storage({
  --     type = S.storage_base_type,
  --     name = S.team_storage_name,
  --     icon = S.mod_path.."/graphics/Chest-Locked-HR.png",
  --     icon_size = 64,
  --     minable = {mining_time = 1.5, result = S.team_storage_name},
  --     max_health = 1500,
  --     corpse = "small-remnants",
  --     collision_box = {{-1.35, -1.35}, {1.35, 1.35}},
  --     selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
  --   }, {
  --   {
  --     filename = S.mod_path.."/graphics/Chest-Locked-HR.png",
  --     width = 76,
  --     height = 76,
  --     shift = util.by_pixel(0, 0),
  --     scale = 0.5,
  --     -- hr_version = {
  --     --   filename = S.mod_path.."/graphics/Chest-Locked-HR.png",
  --     --   width = 66,
  --     --   height = 76,
  --     --   shift = util.by_pixel(-0.5, -0.5),
  --     --   scale = 0.5,
  --     -- }
  --   },
  --   {
  --     filename = "__base__/graphics/entity/iron-chest/iron-chest-shadow.png",
  --     width = 56,
  --     height = 26,
  --     shift = util.by_pixel(10, 6.5),
  --     draw_as_shadow = true,
  --     hr_version = {
  --       filename = "__base__/graphics/entity/iron-chest/hr-iron-chest-shadow.png",
  --       width = 110,
  --       height = 50,
  --       shift = util.by_pixel(10.5, 6),
  --       draw_as_shadow = true,
  --       scale = 0.5,
  --     }
  --   },
  -- }),

  ----------- 4. Bank
  {
    type = "recipe",
    name = S.bank_name,
    enabled = true,
    ingredients = {
      {"concrete", 200},
      {"steel-chest", 50},
      {S.lock_item, 50},
      {"processing-unit", 10},
    },
    result = S.bank_name,
  },
  {
    type = "item",
    name = S.bank_name,
    icon = S.mod_path.."/graphics/icon-bank.png",
    icon_size = 64,
    subgroup = subgroup,
    order = "c4-"..S.bank_name,
    place_result = S.bank_name,
    stack_size = 1,
  },
  make_private_storage({
      type = S.storage_base_type,
      name = S.bank_name,
      icon = S.mod_path.."/graphics/icon-bank.png",
      icon_size = 64,
      minable = {mining_time = 3, result = S.bank_name},
      max_health = 5000,
      corpse = "small-remnants",
      collision_box = {{-1.35, -1.35}, {1.35, 1.35}},
      selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
      energy_source = {type="electric", usage_priority="primary-input", buffer_capacity="200KW", input_flow_limit="150KW", drain="100KW"},
    }, {
    {
      filename = S.mod_path.."/graphics/Bank-HR.png",
      width = 288,
      height = 288,
      shift = {0, -0.6},
      scale = 0.5,
      -- hr_version = {
      --   filename = S.mod_path.."/graphics/Bank-HR.png",
      --   width = 228,
      --   height = 228,
      --   shift = util.by_pixel(-0.5, -0.5),
      --   scale = 0.5,
      -- }
    },
    -- TODO: make new shadow
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
  }),


  ----------- Sounds
  {
    type = "sound",
    name = "af-privacy-lock",
    category = "environment",
    variations = {
      {filename=S.mod_path.."/sounds/lock.wav"},
    },
    audible_distance_modifier = 1,
  },
  {
    type = "sound",
    name = "af-privacy-safe",
    category = "environment",
    variations = {
      {filename=S.mod_path.."/sounds/safe.wav"},
    },
    audible_distance_modifier = 1,
  },
  {
    type = "sound",
    name = "af-privacy-locked",
    category = "environment",
    variations = {
      {filename="__core__/sound/gui-red-button.ogg"},
    },
    audible_distance_modifier = 1,
  },
})

-- TODO: disable recipes by default, add required technologies
