local shared = require("shared")
local name = shared.tech_range

local levels = {
  [1] = {
    {"automation-science-pack", 1},
    {"logistic-science-pack", 1},
    {"military-science-pack", 1},
    {"chemical-science-pack", 1},
  },
  [2] = {
    {"automation-science-pack", 1},
    {"logistic-science-pack", 1},
    {"military-science-pack", 1},
    {"chemical-science-pack", 1},
    {"production-science-pack", 1},
  },
  [3] = {
    {"automation-science-pack", 1},
    {"logistic-science-pack", 1},
    {"chemical-science-pack", 1},
    {"military-science-pack", 1},
    {"production-science-pack", 1},
    {"utility-science-pack", 1},
  },
}
local inf_ingr = {
  {"automation-science-pack", 1},
  {"logistic-science-pack", 1},
  {"military-science-pack", 1},
  {"chemical-science-pack", 1},
  {"production-science-pack", 1},
  {"utility-science-pack", 1},
  {"space-science-pack", 1},
}

if settings.startup["af-tsl-support-recipes"].value then
  if mods[shared.SE] then
    levels = {
      [1] = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"military-science-pack", 1},
        {"chemical-science-pack", 1},
      },
      [2] = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"military-science-pack", 1},
        {"chemical-science-pack", 1},
      },
      [3] = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"military-science-pack", 1},
        {"chemical-science-pack", 1},
        {"se-rocket-science-pack", 1},
      },
      [4] = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
        {"se-rocket-science-pack", 1},
        {"space-science-pack", 1},
      },
      [5] = {
        {"space-science-pack", 1},
        {"utility-science-pack", 1},
        {"se-energy-science-pack-1", 1},
      },
      [6] = {
        {"space-science-pack", 1},
        {"utility-science-pack", 1},
        {"se-energy-science-pack-2", 1},
      },
      [7] = {
        {"space-science-pack", 1},
        {"utility-science-pack", 1},
        {"se-energy-science-pack-3", 1},
      },
    }
    inf_ingr = {
      {"space-science-pack", 1},
      {"utility-science-pack", 1},
      {"se-energy-science-pack-4", 1},
    }
  end
end

for k, ingredients in pairs (levels) do

  local technology = {
    name = name.."-"..k,
    localised_name = {"technology-name."..name},
    type = "technology",
    icons = {
      {
        icon = "__Lightning__/graphics/tech/Arty-Range.png",
        icon_size = 256, icon_mipmaps = 1,
      },
      {
        icon = "__core__/graphics/icons/technology/constants/constant-range.png",
        icon_size = 128, icon_mipmaps = 3,
        shift = {100, 100},
      }
    },
    upgrade = true,
    effects = {
      {
        type = "nothing",
        effect_description = "Lightning artillery range: +25%",
        icons = {
          {
            icon = "__Lightning__/graphics/tech/Arty-Range.png",
            icon_size = 256, icon_mipmaps = 1,
          },
          {
            icon = "__core__/graphics/icons/technology/constants/constant-range.png",
            icon_size = 128, icon_mipmaps = 3,
            shift = {10, 10},
          }
        }
      },
    },
    prerequisites = k > 1 and {name.."-"..k - 1} or {},
    unit = {
      count = k * 100,
      ingredients = ingredients,
      time = 30
    },
    order = name.."-"..k,
  }
  data:extend{technology}
end


local k = #levels + 1

local infinite = {
  name = name.."-"..k,
  localised_name = {"technology-name."..name},
  type = "technology",
  icons = {
    {
      icon = "__Lightning__/graphics/tech/Arty-Range.png",
        icon_size = 256, icon_mipmaps = 1,
    },
    {
      icon = "__core__/graphics/icons/technology/constants/constant-range.png",
      icon_size = 128, icon_mipmaps = 3,
      shift = {100, 100},
    }
  },
  upgrade = true,
  effects = {
    {
      type = "nothing",
      effect_description = "Lightning artillery range: +25%",
      icons = {
        {
          icon = "__Lightning__/graphics/tech/Arty-Range.png",
          icon_size = 256, icon_mipmaps = 1,
        },
        {
          icon = "__core__/graphics/icons/technology/constants/constant-range.png",
          icon_size = 128, icon_mipmaps = 3,
          shift = {10, 10},
        }
      }
    },
  },
  prerequisites = {name.."-"..(k - 1)},
  unit = {
    count_formula = "(2^(L-"..(#levels+1).."))*500",
    ingredients = inf_ingr,
    time = 30
  },
  order = name.."-"..k,
  max_level = "infinite"
}
data:extend{infinite}
