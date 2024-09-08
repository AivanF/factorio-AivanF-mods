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
      { type = "unlock-recipe", recipe = afci_bridge.get.bci().name },
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
      afci_bridge.get.bci().prerequisite,
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
      count = 20,
      ingredients = {{shared.sp, 1}},
      time = 60
    },
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
      count = 100,
      ingredients = {{shared.sp, 1}},
      time = 60
    },
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
      count = 250,
      ingredients = {{shared.sp, 1}},
      time = 60
    },
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
      count = 500,
      ingredients = {{shared.sp, 1}},
      time = 60
    },
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
      count = 1000,
      ingredients = {{shared.sp, 1}},
      time = 60
    },
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
      count = 5,
      ingredients = {{shared.sp, 1}},
      time = 60
    },
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
      count = 25,
      ingredients = {{shared.sp, 1}},
      time = 60
    },
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
      count = 150,
      ingredients = {{shared.sp, 1}},
      time = 60
    },
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
      count = 500,
      ingredients = {{shared.sp, 1}},
      time = 60
    },
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
      { type = "unlock-recipe", recipe = shared.laser_ammo },
      { type = "unlock-recipe", recipe = shared.melta_ammo },
      { type = "unlock-recipe", recipe = shared.plasma_ammo },
      { type = "unlock-recipe", recipe = shared.hell_ammo },
    },
    prerequisites = {shared.mod_prefix.."0-grade"},
    unit = {
      count = 5,
      ingredients = {{shared.sp, 1}},
      time = 60
    },
  },



  ------- AirCraft
  {
    name = shared.mod_prefix.."aircraft-supplier",
    type = "technology",
    icons = {
      {
      icon = shared.media_prefix.."graphics/tech/aircraft-supplier.png",
      icon_size = 256,
      icon_mipmaps = 1,
      }
    },
    effects = {
      { type = "unlock-recipe", recipe = shared.mod_prefix.."aircraft-supplier" },
    },
    prerequisites = {
      shared.mod_prefix.."1-class",
      afci_bridge.get.rocket_engine().prerequisite,
    },
    unit = {
      count = 50,
      ingredients = {{shared.sp, 1}},
      time = 60
    },
  },
}



------- Excavation improvements
local exc_speed_levels = {
  [1] = 2,
  [2] = 20,
  [3] = 50,
  [4] = 100,
  [5] = 250,
  [6] = 500,
  [7] = 1000,
}
for k, price in pairs(exc_speed_levels) do
  local technology =
  {
    name = shared.exc_speed_research.."-"..k,
    localised_name = {"technology-name."..shared.exc_speed_research},
    type = "technology",
    icons = {
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
          "modifier-description.wh40k-titans-excavation-speed",
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
    unit = {
      count = price,
      ingredients = {{shared.sp, 1}},
      time = 30
    },
  }
  table.insert(tech_researches, technology)
end


local exc_efficiency_levels = {
  [1] = 3,
  [2] = 30,
  [3] = 100,
  [4] = 150,
  [5] = 250,
}
for k, price in pairs(exc_efficiency_levels) do
  local technology =
  {
    name = shared.exc_efficiency_research.."-"..k,
    localised_name = {"technology-name."..shared.exc_efficiency_research},
    type = "technology",
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
        shift = {100, 100},
      }
    },
    upgrade = true,
    effects = {
      {
        type = "nothing",
        effect_description = {"", {
          "modifier-description.wh40k-titans-excavation-efficiency",
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
    unit = {
      count = price,
      ingredients = {{shared.sp, 1}},
      time = 30
    },
  }
  table.insert(tech_researches, technology)
end


local assembly_speed_research_prices = {
  [1] = 10,
  [2] = 25,
  [3] = 50,
  [4] = 100,
  [5] = 250,
}
for k, price in pairs(assembly_speed_research_prices) do
  local technology =
  {
    name = shared.assembly_speed_research.."-"..k,
    localised_name = {"technology-name."..shared.assembly_speed_research},
    type = "technology",
    icons = {
      {
        icon = shared.media_prefix.."graphics/tech/bunker-speed.png",
        icon_size = 256,
        icon_mipmaps = 1,
      },
    },
    upgrade = true,
    effects = {
      {
        type = "nothing",
        effect_description = {"", {
          "modifier-description.wh40k-titans-assembly-speed",
          math.floor(100*shared.assembly_speed_by_level[k-1]),
          math.floor(100*shared.assembly_speed_by_level[k]),
        }},
        icons = {
          {
            icon = shared.media_prefix.."graphics/tech/bunker-speed.png",
            icon_size = 256,
            icon_mipmaps = 1,
          },
        }
      },
    },
    prerequisites = k > 1 and {shared.assembly_speed_research.."-"..k - 1} or {shared.mod_prefix.."assembly"},
    unit = {
      count = price,
      ingredients = {{shared.sp, 1}},
      time = 30
    },
  }
  table.insert(tech_researches, technology)
end


local void_shield_cap_research_count = 8
for k = 1, void_shield_cap_research_count do
  local technology =
  {
    name = shared.void_shield_cap_research.."-"..k,
    localised_name = {"technology-name."..shared.void_shield_cap_research},
    type = "technology",
    icons = {
      {
        icon = shared.media_prefix.."graphics/tech/void-shield-capacity.png",
        icon_size = 256,
        icon_mipmaps = 1,
      },
    },
    upgrade = true,
    effects = {
      {
        type = "nothing",
        effect_description = {"", {
          "modifier-description.wh40k-titans-void-shield-capacity",
          math.floor(shared.void_shield_cap_base * (2+k-1) /1000),
          math.floor(shared.void_shield_cap_base * (2+k+0) /1000),
        }},
        icons = {
          {
            icon = shared.media_prefix.."graphics/tech/void-shield-capacity.png",
            icon_size = 256,
            icon_mipmaps = 1,
          },
        }
      },
    },
    prerequisites = k > 1 and {shared.void_shield_cap_research.."-"..k - 1} or {shared.mod_prefix.."1-class"},
    unit = {
      count = 10 * k * k,
      ingredients = {{shared.sp, 1}},
      time = 30
    },
  }
  table.insert(tech_researches, technology)
end


local void_shield_spd_research_count = 8
for k = 1, void_shield_spd_research_count do
  local technology =
  {
    name = shared.void_shield_spd_research.."-"..k,
    localised_name = {"technology-name."..shared.void_shield_spd_research},
    type = "technology",
    icons = {
      {
        icon = shared.media_prefix.."graphics/tech/void-shield-recharge.png",
        icon_size = 256,
        icon_mipmaps = 1,
      },
    },
    upgrade = true,
    effects = {
      {
        type = "nothing",
        effect_description = {"", {"technology-description."..shared.void_shield_spd_research}},
        icons = {
          {
            icon = shared.media_prefix.."graphics/tech/void-shield-recharge.png",
            icon_size = 256,
            icon_mipmaps = 1,
          },
        }
      },
    },
    prerequisites = k > 1 and {shared.void_shield_spd_research.."-"..k - 1} or {shared.mod_prefix.."1-class"},
    unit = {
      count = 10 * k * k,
      ingredients = {{shared.sp, 1}},
      time = 30
    },
  }
  table.insert(tech_researches, technology)
end


for k = 1, shared.attack_range_research_count do
  local technology =
  {
    name = shared.attack_range_research.."-"..k,
    localised_name = {"technology-name."..shared.attack_range_research},
    type = "technology",
    icons = {
      {
        icon = shared.media_prefix.."graphics/tech/titan-range.png",
        icon_size = 256,
        icon_mipmaps = 1,
      },
    },
    upgrade = true,
    effects = {
      {
        type = "nothing",
        effect_description = {"", {"technology-description."..shared.attack_range_research}},
        effect_description = {"", {
          "modifier-description.wh40k-titans-attack-cf",
          math.floor(shared.attack_range_cf_get(k-1)*100),
          math.floor(shared.attack_range_cf_get(k  )*100),
        }},
        icons = {
          {
            icon = shared.media_prefix.."graphics/tech/titan-range.png",
            icon_size = 256,
            icon_mipmaps = 1,
          },
        }
      },
    },
    prerequisites = k > 1 and {shared.attack_range_research.."-"..k - 1} or {shared.mod_prefix.."0-grade"},
    unit = {
      count = 10 * k * k,
      ingredients = {{shared.sp, 1}},
      time = 30
    },
  }
  table.insert(tech_researches, technology)
end


local ammo_usage_research_count = 10
for k = 1, ammo_usage_research_count do
  local technology =
  {
    name = shared.ammo_usage_research.."-"..k,
    localised_name = {"technology-name."..shared.ammo_usage_research},
    type = "technology",
    icons = {
      {
        icon = shared.media_prefix.."graphics/tech/titan-ammo-eff.png",
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
          "modifier-description.wh40k-titans-ammo-usage-eff", 5*k,
        }},
        icons = {
          {
            icon = shared.media_prefix.."graphics/tech/titan-ammo-eff.png",
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
    prerequisites = k > 1 and {shared.ammo_usage_research.."-"..k - 1} or {shared.mod_prefix.."0-grade"},
    unit = {
      count = 10 * k * k,
      ingredients = {{shared.sp, 1}},
      time = 30
    },
  }
  table.insert(tech_researches, technology)
end


local supplier_cap_research_prices = {
  [1] = 10,
  [2] = 50,
  [3] = 100,
}
for k, price in pairs(supplier_cap_research_prices) do
  local technology =
  {
    name = shared.supplier_cap_research.."-"..k,
    localised_name = {"technology-name."..shared.supplier_cap_research},
    type = "technology",
    icons = {
      {
        icon = shared.media_prefix.."graphics/tech/supplier+weight.png",
        icon_size = 256,
        icon_mipmaps = 1,
      },
    },
    upgrade = true,
    effects = {
      {
        type = "nothing",
        effect_description = {"", {
          "modifier-description.wh40k-titans-supplier-more-weight",
          5*(k), 5*(k+1),
        }},
        icons = {
          {
            icon = shared.media_prefix.."graphics/tech/supplier+weight.png",
            icon_size = 256,
            icon_mipmaps = 1,
          },
        }
      },
    },
    prerequisites = k > 1 and {shared.supplier_cap_research.."-"..k - 1} or {shared.mod_prefix.."aircraft-supplier"},
    unit = {
      count = price,
      ingredients = {{shared.sp, 1}},
      time = 30
    },
  }
  table.insert(tech_researches, technology)
end

local supplier_exch_research_prices = {
  [1] = 20,
  [2] = 50,
  [3] = 100,
  [4] = 200,
  [5] = 500,
  [6] = 1000,
  [7] = 2000,
}

for k, price in pairs(supplier_exch_research_prices) do
  local technology =
  {
    name = shared.supplier_exch_research.."-"..k,
    localised_name = {"technology-name."..shared.supplier_exch_research},
    type = "technology",
    icons = {
      {
        icon = shared.media_prefix.."graphics/tech/supplier+restock-speed.png",
        icon_size = 256,
        icon_mipmaps = 1,
      },
    },
    upgrade = true,
    effects = {
      {
        type = "nothing",
        effect_description = {"", {
          "modifier-description.wh40k-titans-supplier-faster-exchange",
          math.floor(shared.supplier_exch_by_level[k-1]),
          math.floor(shared.supplier_exch_by_level[k]),
        }},
        icons = {
          {
            icon = shared.media_prefix.."graphics/tech/supplier+restock-speed.png",
            icon_size = 256,
            icon_mipmaps = 1,
          },
        }
      },
    },
    prerequisites = k > 1 and {shared.supplier_exch_research.."-"..k - 1} or {shared.mod_prefix.."aircraft-supplier"},
    unit = {
      count = price,
      ingredients = {{shared.sp, 1}},
      time = 30
    },
  }
  table.insert(tech_researches, technology)
end



------- Outro
data:extend(tech_researches)
se_procedural_tech_exclusions = se_procedural_tech_exclusions or {}
table.insert(se_procedural_tech_exclusions, shared.mod_prefix)
-- for _, info in pairs(tech_researches) do
--   table.insert(se_procedural_tech_exclusions, info.name)
-- end
