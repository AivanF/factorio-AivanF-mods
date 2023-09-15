local bridge = require("bridge1-base")

bridge.tech = {}
local function add_tech(tech_info)
  tech_info.updated = "none"
  bridge.tech[tech_info.short_name] = tech_info
  bridge.tech[tech_info.name] = tech_info
end


bridge.early = bridge.prefix.."early"
bridge.midgame = bridge.prefix.."midgame"
bridge.lategame = bridge.prefix.."lategame"
bridge.endgame = bridge.prefix.."endgame"

add_tech({
  short_name = "early",
  name = bridge.early,
  icon = bridge.media_path.."tech/t1-craft.png",
  icon_size = 256, icon_mipmaps = 1,
  prerequisites = {},
  count = 100,
  ingredients = {
    {"automation-science-pack", 1},
  },
})

add_tech({
  short_name = "midgame",
  name = bridge.midgame,
  icon = bridge.media_path.."tech/t2-industry.png",
  icon_size = 256, icon_mipmaps = 1,
  prerequisites = {
    -- bridge.tech.early.name,
    "chemical-science-pack",
  },
  count = 500,
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
  count = 1000,
  ingredients = {
    {"automation-science-pack", 1},
    {"logistic-science-pack", 1},
    {"chemical-science-pack", 1},
    {"production-science-pack", 1},
    {"utility-science-pack", 1},
  },
  modded = {
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

add_tech({
  short_name = "endgame",
  name = bridge.endgame,
  icon = bridge.media_path.."tech/t4-technomagic.png",
  icon_size = 256, icon_mipmaps = 1,
  prerequisites = {
    -- bridge.tech.lategame.name,
    "space-science-pack",
  },
  count = 5000,
  ingredients = {
    {"automation-science-pack", 1},
    {"logistic-science-pack", 1},
    {"chemical-science-pack", 1},
    {"production-science-pack", 1},
    {"utility-science-pack", 1},
    {"space-science-pack", 1},
  },
  modded = {
    -- {
    --   mod = bridge.mods.ir3,
    --   prerequisites = {
    --     "ir-research-2",
    --   },
    -- },
  },
})


-- Generate tech API, `bridge.setup[short_name]()` returns research name
for _, tech_info in pairs(bridge.tech) do
  bridge.setup[tech_info.short_name] = function()
    if tech_info.done then
      return tech_info.name
    end
    bridge.preprocess(tech_info)
    if bridge.is_new(tech_info.name) then
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
      tech_info.done = true
      for _, prereq in pairs(tech_info.prerequisites or {}) do
        if bridge.is_new(prereq) then
          bridge.setup[bridge.tech[prereq].short_name]()
        end
      end
    end
    return tech_info.name
  end
end

return bridge