local shared = require("shared")
local name = shared.tech_catch_energy

local levels = {
  -- 0 is 50%
  [1] = {  -- 60%
    count = 50,
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"chemical-science-pack", 1},
    }
  },
  [2] = {  -- 70%
    count = 100,
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"chemical-science-pack", 1},
    }
  },
  [3] = {  -- 80%
    count = 200,
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"chemical-science-pack", 1},
      {"production-science-pack", 1},
    }
  },
  [4] = {  -- 90%
    count = 500,
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"chemical-science-pack", 1},
      {"production-science-pack", 1},
      {"utility-science-pack", 1},
    }
  },
  [5] = {  -- 100%
    count = 1000,
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"chemical-science-pack", 1},
      {"production-science-pack", 1},
      {"utility-science-pack", 1},
    }
  },
}

if settings.startup["af-tsl-support-recipes"].value then
  if mods[shared.SE] then
    levels = {
      -- 0 is 50%
      [1] = {  -- 60%
        count = 50,
        ingredients = {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
        }
      },
      [2] = {  -- 70%
        count = 100,
        ingredients = {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
        }
      },
      [3] = {  -- 80%
        count = 150,
        ingredients = {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
          {"se-rocket-science-pack", 1},
        }
      },
      [4] = {  -- 90%
        count = 200,
        ingredients = {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
          {"se-rocket-science-pack", 1},
          {"space-science-pack", 1},
        }
      },
      [5] = {  -- 100%
        count = 500,
        ingredients = {
          {"space-science-pack", 1},
          {"utility-science-pack", 1},
          {"se-energy-science-pack-1", 1},
        }
      },
    }
  end
end

for k, info in pairs (levels) do

  local technology =
  {
    name = name.."-"..k,
    localised_name = {"technology-name."..name},
    type = "technology",
    icons = {
      {
        icon = "__Lightning__/graphics/tech/Lightning-Catch.png",
        icon_size = 256, icon_mipmaps = 1,
      },
      {
        icon = "__core__/graphics/icons/technology/constants/constant-battery.png",
        icon_size = 64, icon_mipmaps = 2,
        shift = {100, 100},
      }
    },
    upgrade = true,
    effects = {
      {
        type = "nothing",
        effect_description = "Higher lightning energy catch, +10%",
        icons = {
          {
            icon = "__Lightning__/graphics/tech/Lightning-Catch.png",
            icon_size = 256, icon_mipmaps = 1,
          },
          {
            icon = "__core__/graphics/icons/technology/effect-constant/effect-constant-battery.png",
            icon_size = 64, icon_mipmaps = 2,
            shift = {10, 10},
          }
        }
      },
    },
    prerequisites = k > 1 and {name.."-"..(k - 1)} or {},
    unit = {
      count = info.count,
      ingredients = info.ingredients,
      time = 30
    },
    order = name.."-"..k,
  }
  data:extend{technology}
end
