local shared = require("shared")
local name = shared.tech_arty_lvl
local prereq = {shared.tech_arty1}

local levels = {
  -- Base is 1 2
  [1] = { -- 1 3
    count = 500,
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"military-science-pack", 1},
      {"chemical-science-pack", 1},
    }
  },
  [2] = { -- 2 4
    count = 1000,
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"military-science-pack", 1},
      {"chemical-science-pack", 1},
      {"production-science-pack", 1},
      {"utility-science-pack", 1},
    }
  },
  [3] = { -- 3 5
    count = 2000,
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"chemical-science-pack", 1},
      {"military-science-pack", 1},
      {"production-science-pack", 1},
      {"utility-science-pack", 1},
      {"space-science-pack", 1},
    }
  },
}

if settings.startup["af-tsl-support-recipes"].value then
  if mods[shared.SE] then
    levels = {
      -- Base is 1 2
      [1] = { -- 1 3
        count = 500,
        ingredients = {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"military-science-pack", 1},
          {"chemical-science-pack", 1},
        }
      },
      [2] = { -- 2 4
        count = 500,
        ingredients = {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"military-science-pack", 1},
          {"chemical-science-pack", 1},
          {"se-rocket-science-pack", 1},
        }
      },
      [3] = { -- 3 5
        count = 500,
        ingredients = {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"military-science-pack", 1},
          {"chemical-science-pack", 1},
          {"se-rocket-science-pack", 1},
          {"space-science-pack", 1},
          {"se-energy-science-pack-1", 1},
        }
      },
    }
  end
end


for k, info in pairs (levels) do

  local technology = {
    name = name.."-"..k,
    localised_name = {"technology-name."..name},
    type = "technology",
    icons = {
      {
        icon = "__Lightning__/graphics/tech/Arty-Extra.png",
        icon_size = 256, icon_mipmaps = 1,
      },
      {
        icon = "__core__/graphics/icons/technology/constants/constant-damage.png",
        icon_size = 128, icon_mipmaps = 3,
        shift = {100, 100},
      }
    },
    upgrade = true,
    effects = {
      {
        type = "nothing",
        effect_description = "Thunder artillery max lightning level +1",
        icons = {
          {
            icon = "__Lightning__/graphics/tech/Arty-Extra.png",
            icon_size = 256, icon_mipmaps = 1,
          },
          {
            icon = "__core__/graphics/icons/technology/constants/constant-damage.png",
            icon_size = 128, icon_mipmaps = 3,
            shift = {10, 10},
          }
        }
      },
    },
    prerequisites = k > 1 and {name.."-"..k - 1} or prereq,
    unit = {
      count = info.count,
      ingredients = info.ingredients,
      time = 60
    },
    order = name.."-"..k,
  }
  data:extend{technology}
end
