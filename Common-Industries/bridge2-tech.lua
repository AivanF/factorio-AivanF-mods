local bridge = require("bridge1-base")

bridge.tech = {}
local function add_tech(tech_info)
  tech_info.status = bridge.status_draft
  bridge.tech[tech_info.short_name] = tech_info
  bridge.tech[tech_info.name] = tech_info
end


bridge.early = bridge.prefix.."early"
bridge.midgame = bridge.prefix.."midgame"
bridge.lategame = bridge.prefix.."lategame"
bridge.endgame = bridge.prefix.."endgame"

-- Age 1. Early-game, old technologies, hand crafting
add_tech({
  short_name = "early",
  name = bridge.early,
  icon = bridge.media_path.."tech/t1-craft.png",
  icon_size = 256, icon_mipmaps = 1,
  prerequisites = {},
  count = 20,
  ingredients = {
    {"automation-science-pack", 1},
  },
})

-- Age 2. Mid-game: more modern technologies, steam-punk, advanced metal alloys
-- Space Exploration analogue: Rocket Science packs
add_tech({
  short_name = "midgame",
  name = bridge.midgame,
  icon = bridge.media_path.."tech/t2-industry.png",
  icon_size = 256, icon_mipmaps = 1,
  prerequisites = {
    -- bridge.tech.early.name,
    "chemical-science-pack",
  },
  count = 100,
  ingredients = {
    {"automation-science-pack", 1},
    {"logistic-science-pack", 1},
    {"chemical-science-pack", 1},
  },
  modded = {
    {
      mod = bridge.mods.yit,
      prerequisites = {
        "chemical-science-pack",
        "yi-intermediates",
      }
    },
    {
      mod = bridge.mods.om_mat,
      prerequisites = {
        "chemical-science-pack",
        "omnitech-solvation-omniston-1",
      }
    },
  },
})

-- Age 3. Late-game: nano-technologies, high-energy, sci-fi
-- Space Exploration analogue: first other planets, Production + Utility Science packs
add_tech({
  short_name = "lategame",
  name = bridge.lategame,
  icon = bridge.media_path.."tech/t3-nanotech.png",
  icon_size = 256, icon_mipmaps = 1,
  prerequisites = {
    -- bridge.tech.midgame.name,
    "production-science-pack",
    "utility-science-pack",
  },
  count = 500,
  ingredients = {
    {"automation-science-pack", 1},
    {"logistic-science-pack", 1},
    {"chemical-science-pack", 1},
    {"production-science-pack", 1},
    {"utility-science-pack", 1},
  },
  modded = {
    {
      mod = bridge.mods.sa,
      prerequisites = {
        "production-science-pack",
        "utility-science-pack",
        "metallurgic-science-pack",
        "electromagnetic-science-pack",
        "agricultural-science-pack",
      },
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1},
        {"metallurgic-science-pack", 1},
        {"electromagnetic-science-pack", 1},
        {"agricultural-science-pack", 1},
      },
    },
    {
      mod = bridge.mods.bzcarbon,
      prerequisites = {"nanotubes"},
    },
    {
      mod = bridge.mods.yit,
      prerequisites = {
        "production-science-pack",
        "utility-science-pack",
        "yi-advanced-machines",
      },
    },
    {
      mod = bridge.mods.om_cry,
      prerequisites = {
        "chemical-science-pack",
        "omnitech-crystallonics-3",
      }
    },
  },
})

-- Age 4. End-game: extra-high-energy, space-time warping, pure sci-fi
-- Space Exploration analogue: advanced cosmic factory, Deep Space Science packs
add_tech({
  short_name = "endgame",
  name = bridge.endgame,
  icon = bridge.media_path.."tech/t4-technomagic.png",
  icon_size = 256, icon_mipmaps = 1,
  prerequisites = {
    -- bridge.tech.lategame.name,
    "space-science-pack",
  },
  count = 1000,
  ingredients = {
    {"automation-science-pack", 1},
    {"logistic-science-pack", 1},
    {"chemical-science-pack", 1},
    {"production-science-pack", 1},
    {"utility-science-pack", 1},
    {"space-science-pack", 1},
  },
  modded = {
    {
      mod = bridge.mods.sa,
      prerequisites = {
        "fusion-reactor",
        -- "promethium-science-pack",
      },
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1},
        {"metallurgic-science-pack", 1},
        {"electromagnetic-science-pack", 1},
        {"agricultural-science-pack", 1},
        {"cryogenic-science-pack", 1},
        -- {"promethium-science-pack", 1},
      },
    },
    -- {
    --   mod = bridge.mods.ir3,
    --   prerequisites = {
    --     "ir-research-2",
    --   },
    -- },
    {
      mod = {bridge.mods.se, bridge.mods.k2},
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"se-rocket-science-pack", 1},
        {"space-science-pack", 1},
        -- {"matter-tech-card", 1 }, -- aka Matter science 1
        {"se-kr-matter-science-pack-2", 1 }, -- aka Matter science 2
        -- {"advanced-tech-card", 1 }, -- aka Advanced science 1
        {"singularity-tech-card", 1 }, -- aka Advanced science 2

        {"se-energy-science-pack-2", 1},
        {"se-material-science-pack-2", 1},
        {"se-deep-space-science-pack-1", 1},
      },
    },
    {
      mod = bridge.mods.se,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"se-rocket-science-pack", 1},
        {"space-science-pack", 1},
        {"se-energy-science-pack-2", 1},
        {"se-material-science-pack-2", 1},
        {"se-deep-space-science-pack-1", 1},
      },
    },
    {
      mod = bridge.mods.k2,
      ingredients = {
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1},
        {"matter-tech-card", 1},
        {"advanced-tech-card", 1},
        {"singularity-tech-card", 1},
      },
    },
  },
})


-- Generate tech API, `bridge.setup_tech[short_name]()` returns research name
for _, tech_info in pairs(bridge.tech) do
  bridge.setup_tech[tech_info.short_name] = function()
    if tech_info.done then
      return tech_info.name
    end

    log(bridge.log_prefix.."creating tech "..tech_info.short_name)
    tech_info.done = true
    bridge.preprocess(tech_info)

    if not data.raw["technology"][tech_info.name] then
      data:extend({{
        name = tech_info.name,
        type = "technology",
        icons = {
          {
            icon = tech_info.icon,
            icon_size = tech_info.icon_size,
            icon_mipmaps = tech_info.icon_mipmaps,
          }
        },
        effects = {
          -- { type = "unlock-recipe", recipe = __XYZ__ },
        },
        prerequisites = tech_info.prerequisites or {},
        unit = {
          count = tech_info.count,
          ingredients = tech_info.ingredients,
          time = 30
        },
      }})
    end

    for _, prereq in pairs(tech_info.prerequisites or {}) do
      if bridge.is_bridge_name(prereq) then
        bridge.setup_tech[bridge.tech[prereq].short_name]()
      end
    end

    return tech_info.name
  end
end

return bridge