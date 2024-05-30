local shared = require("shared")

local function get_weapon_effects(grade)
  local result = {}
  local already = {}
  for _, info in pairs(shared.weapons) do
    if grade == info.grade and not already[info.name] then
      result[#result+1] = { type = "unlock-recipe", recipe = info.entity }
      already[info.name] = true
    end
  end
  return result
end

local function get_titan_effects(class)
  local result = {}
  for _, info in pairs(shared.titan_type_list) do
    if class == math.floor(info.class/10) then
      result[#result+1] = { type = "unlock-recipe", recipe = info.entity }
    end
  end
  return result
end

local tech_researches = {
  {
    name = shared.mod_prefix.."base",
    type = "technology",
    icons = {
      {
      icon = shared.media_prefix.."graphics/tech/datacard-titan.png",
      icon_size = 256,
      icon_mipmaps = 1,
      }
    },
    effects = {
      { type = "unlock-recipe", recipe = shared.excavator },
      { type = "unlock-recipe", recipe = "af-reverse-lab-2" },
      { type = "unlock-recipe", recipe = shared.sp },
      { type = "unlock-recipe", recipe = shared.lab },
    },
    prerequisites = {
      "military-science-pack",
      "chemical-science-pack",
    },
    unit = {
      count = 500,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"military-science-pack", 1},
        {"chemical-science-pack", 1},
        -- {"utility-science-pack", 1},
        -- {"production-science-pack", 1},
        -- {"space-science-pack", 1},
      },
      time = 60
    },
    order = name
  },
  {
    name = shared.mod_prefix.."assembly",
    type = "technology",
    icons = {
      {
      icon = shared.media_prefix.."graphics/tech/titan-assembly.png",
      icon_size = 256,
      icon_mipmaps = 1,
      }
    },
    effects = {
      { type = "unlock-recipe", recipe = shared.bunker_minable },
    },
    prerequisites = {shared.mod_prefix.."base"},
    unit = {
      count = 10,
      ingredients = {{shared.sp, 1}},
      time = 60
    },
    order = name
  },
  {
    name = shared.mod_prefix.."production",
    type = "technology",
    icons = {
      {
      icon = shared.media_prefix.."graphics/tech/titan-production.png",
      icon_size = 256,
      icon_mipmaps = 1,
      }
    },
    effects = {
      -- Body parts
      { type = "unlock-recipe", recipe = shared.servitor },
      { type = "unlock-recipe", recipe = shared.brain },
      { type = "unlock-recipe", recipe = shared.energy_core },
      { type = "unlock-recipe", recipe = shared.void_shield },
      { type = "unlock-recipe", recipe = shared.motor },
      { type = "unlock-recipe", recipe = shared.frame_part },
      -- Common details
      { type = "unlock-recipe", recipe = shared.antigraveng },
      { type = "unlock-recipe", recipe = shared.realityctrl },
      -- { type = "unlock-recipe", recipe = shared.emfc },
      -- Weapon parts
      { type = "unlock-recipe", recipe = shared.barrel },
      { type = "unlock-recipe", recipe = shared.proj_engine },
      { type = "unlock-recipe", recipe = shared.melta_pump },
      -- { type = "unlock-recipe", recipe = shared.he_emitter },
      -- { type = "unlock-recipe", recipe = shared.ehe_emitter },
    },
    prerequisites = afci_bridge.clean_prerequisites{
      shared.mod_prefix.."base",
      afci_bridge.get.emfc().prerequisite,
      afci_bridge.get.he_emitter().prerequisite,
      afci_bridge.get.ehe_emitter().prerequisite,
      afci_bridge.get.st_operator().prerequisite,
    },
    unit = {
      count = 500,
      ingredients = {{shared.sp, 1}},
      time = 60
    },
    order = name
  },


  ------- Titan classes
  {
    name = shared.mod_prefix.."1-class",
    type = "technology",
    icons = {
      {
      icon = shared.media_prefix.."graphics/tech/titan-1.png",
      icon_size = 256,
      icon_mipmaps = 1,
      }
    },
    effects = get_titan_effects(1),
    prerequisites = {shared.mod_prefix.."assembly"},
    unit = {
      count = 10,
      ingredients = {{shared.sp, 1}},
      time = 60
    },
    order = name
  },
  {
    name = shared.mod_prefix.."2-class",
    type = "technology",
    icons = {
      {
      icon = shared.media_prefix.."graphics/tech/titan-2.png",
      icon_size = 256,
      icon_mipmaps = 1,
      }
    },
    effects = get_titan_effects(2),
    prerequisites = {shared.mod_prefix.."1-class"},
    unit = {
      count = 50,
      ingredients = {{shared.sp, 1}},
      time = 60
    },
    order = name
  },
  {
    name = shared.mod_prefix.."3-class",
    type = "technology",
    icons = {
      {
      icon = shared.media_prefix.."graphics/tech/titan-3.png",
      icon_size = 256,
      icon_mipmaps = 1,
      }
    },
    effects = get_titan_effects(3),
    prerequisites = {shared.mod_prefix.."2-class"},
    unit = {
      count = 150,
      ingredients = {{shared.sp, 1}},
      time = 60
    },
    order = name
  },
  {
    name = shared.mod_prefix.."4-class",
    type = "technology",
    icons = {
      {
      icon = shared.media_prefix.."graphics/tech/titan-4.png",
      icon_size = 256,
      icon_mipmaps = 1,
      }
    },
    effects = get_titan_effects(4),
    prerequisites = {shared.mod_prefix.."3-class"},
    unit = {
      count = 350,
      ingredients = {{shared.sp, 1}},
      time = 60
    },
    order = name
  },
  {
    name = shared.mod_prefix.."5-class",
    type = "technology",
    icons = {
      {
      icon = shared.media_prefix.."graphics/tech/titan-5.png",
      icon_size = 256,
      icon_mipmaps = 1,
      }
    },
    effects = get_titan_effects(5),
    prerequisites = {shared.mod_prefix.."4-class"},
    unit = {
      count = 500,
      ingredients = {{shared.sp, 1}},
      time = 60
    },
    order = name
  },



  ------- Weapon grades
  {
    name = shared.mod_prefix.."0-grade",
    type = "technology",
    icons = {
      {
      icon = shared.media_prefix.."graphics/tech/grade-0.png",
      icon_size = 256,
      icon_mipmaps = 1,
      }
    },
    effects = get_weapon_effects(shared.gun_grade_small),
    prerequisites = {shared.mod_prefix.."1-class"},
    unit = {
      count = 1,
      ingredients = {{shared.sp, 1}},
      time = 60
    },
    order = name
  },
  {
    name = shared.mod_prefix.."1-grade",
    type = "technology",
    icons = {
      {
      icon = shared.media_prefix.."graphics/tech/grade-1.png",
      icon_size = 256,
      icon_mipmaps = 1,
      }
    },
    effects = get_weapon_effects(shared.gun_grade_medium),
    prerequisites = {shared.mod_prefix.."0-grade"},
    unit = {
      count = 10,
      ingredients = {{shared.sp, 1}},
      time = 60
    },
    order = name
  },
  {
    name = shared.mod_prefix.."2-grade",
    type = "technology",
    icons = {
      {
      icon = shared.media_prefix.."graphics/tech/grade-2.png",
      icon_size = 256,
      icon_mipmaps = 1,
      }
    },
    effects = get_weapon_effects(shared.gun_grade_big),
    prerequisites = {shared.mod_prefix.."1-grade", shared.mod_prefix.."3-class"},
    unit = {
      count = 200,
      ingredients = {{shared.sp, 1}},
      time = 60
    },
    order = name
  },
  {
    name = shared.mod_prefix.."3-grade",
    type = "technology",
    icons = {
      {
      icon = shared.media_prefix.."graphics/tech/grade-3.png",
      icon_size = 256,
      icon_mipmaps = 1,
      }
    },
    effects = get_weapon_effects(shared.gun_grade_huge),
    prerequisites = {shared.mod_prefix.."2-grade", shared.mod_prefix.."5-class"},
    unit = {
      count = 300,
      ingredients = {{shared.sp, 1}},
      time = 60
    },
    order = name
  },



  ------- Ammo
  {
    name = shared.mod_prefix.."ammo",
    type = "technology",
    icons = {
      {
      icon = shared.media_prefix.."graphics/tech/ammo.png",
      icon_size = 256,
      icon_mipmaps = 1,
      }
    },
    effects = {
      { type = "unlock-recipe", recipe = shared.big_bolt },
      { type = "unlock-recipe", recipe = shared.huge_bolt },
      { type = "unlock-recipe", recipe = shared.plasma_ammo },
    },
    prerequisites = {shared.mod_prefix.."0-grade"},
    unit = {
      count = 5,
      ingredients = {{shared.sp, 1}},
      time = 60
    },
    order = name
  },
}



------- Excavation improvements
local exc_speed_name = shared.exc_speed_research
local exc_speed_levels = {
  [1] = 2,
  [2] = 20,
  [3] = 100,
}
for k, price in pairs(exc_speed_levels) do
  local technology =
  {
    name = shared.exc_speed_research.."-"..k,
    localised_name = {"technology-name."..shared.exc_speed_research},
    type = "technology",
    icons =
    {
      {
        icon = shared.media_prefix.."graphics/tech/exc-impr-spd.png",
        icon_size = 256,
        icon_mipmaps = 1,
      },
      {
        icon = "__core__/graphics/icons/technology/constants/constant-movement-speed.png",
        icon_size = 128,
        icon_mipmaps = 3,
        shift = {100, 100},
      }
    },
    upgrade = true,
    effects = {
      {
        type = "nothing",
        effect_description = {"", {
          "modifier-description.titans-excavation-speed",
          math.floor(100*shared.exc_speed_by_level[k-1]),
          math.floor(100*shared.exc_speed_by_level[k]),
        }},
        icons = {
          {
            icon = shared.media_prefix.."graphics/tech/exc-impr-spd.png",
            icon_size = 256,
            icon_mipmaps = 1,
          },
          {
            icon = "__core__/graphics/icons/technology/constants/constant-speed.png",
            icon_size = 128,
            icon_mipmaps = 3,
            shift = {10, 10},
          }
        }
      },
    },
    prerequisites = k > 1 and {shared.exc_speed_research.."-"..k - 1} or {shared.mod_prefix.."base"},
    unit =
    {
      count = price,
      ingredients = {{shared.sp, 1}},
      time = 30
    },
    order = shared.exc_speed_research,
  }
  table.insert(tech_researches, technology)
end


local exc_efficiency_name = shared.exc_efficiency_research
local exc_efficiency_levels = {
  [1] = 3,
  [2] = 15,
  [3] = 100,
}
for k, price in pairs(exc_efficiency_levels) do
  local technology =
  {
    name = shared.exc_efficiency_research.."-"..k,
    localised_name = {"technology-name."..shared.exc_efficiency_research},
    type = "technology",
    icons =
    {
      {
        icon = shared.media_prefix.."graphics/tech/exc-impr-eff.png",
        icon_size = 256,
        icon_mipmaps = 1,
      },
      {
        icon = "__core__/graphics/icons/technology/constants/constant-mining-productivity.png",
        icon_size = 128,
        icon_mipmaps = 3,
        shift = {100, 100},
      }
    },
    upgrade = true,
    effects = {
      {
        type = "nothing",
        effect_description = {"", {
          "modifier-description.titans-excavation-efficiency",
          math.floor(100*shared.exc_efficiency_by_level[k-1]),
          math.floor(100*shared.exc_efficiency_by_level[k]),
        }},
        icons = {
          {
            icon = shared.media_prefix.."graphics/tech/exc-impr-eff.png",
            icon_size = 256,
            icon_mipmaps = 1,
          },
          {
            icon = "__core__/graphics/icons/technology/constants/constant-mining-productivity.png",
            icon_size = 128,
            icon_mipmaps = 3,
            shift = {10, 10},
          }
        }
      },
    },
    prerequisites = k > 1 and {shared.exc_efficiency_research.."-"..k - 1} or {shared.mod_prefix.."base"},
    unit =
    {
      count = price,
      ingredients = {{shared.sp, 1}},
      time = 30
    },
    order = shared.exc_efficiency_research,
  }
  table.insert(tech_researches, technology)
end



------- Outro
data:extend(tech_researches)

se_prodecural_tech_exclusions = se_prodecural_tech_exclusions or {}
for _, info in pairs(tech_researches) do
  table.insert(se_prodecural_tech_exclusions, info.name)
end
