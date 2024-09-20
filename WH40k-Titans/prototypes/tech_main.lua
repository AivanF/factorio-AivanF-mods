local shared = require("shared")

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
      -- { type = "unlock-recipe", recipe = shared.huge_bolt },
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
  -- {
  --   name = shared.mod_prefix.."worldbreaker",
  --   type = "technology",
  --   icons = {
  --     {
  --     icon = shared.media_prefix.."graphics/tech/WorldBreaker.png",
  --     icon_size = 256,
  --     icon_mipmaps = 1,
  --     }
  --   },
  --   effects = {
  --     { type = "unlock-recipe", recipe = shared.worldbreaker },
  --   },
  --   prerequisites = {shared.mod_prefix.."2-grade"},
  --   unit = {
  --     count = 5,
  --     ingredients = {{shared.sp, 3}},
  --     time = 60
  --   },
  -- },



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


------- Outro
data:extend(tech_researches)

se_procedural_tech_exclusions = se_procedural_tech_exclusions or {}
table.insert(se_procedural_tech_exclusions, shared.mod_prefix)
-- for _, info in pairs(tech_researches) do
--   table.insert(se_procedural_tech_exclusions, info.name)
-- end
