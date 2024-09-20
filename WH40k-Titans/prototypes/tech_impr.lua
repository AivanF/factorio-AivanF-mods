local shared = require("shared")

local tech_researches = {}

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
