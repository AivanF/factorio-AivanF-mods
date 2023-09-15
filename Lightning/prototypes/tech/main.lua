local shared = require("shared")

local info = {
  c1 = {
    prereq = {"electric-energy-distribution-1"},
    count = 10,
    ingredients = {
      {"automation-science-pack", 1},
    }
  },
  c2 = {
    prereq = {shared.tech_catch1, "electric-energy-accumulators"},
    count = 500,
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"chemical-science-pack", 1},
    }
  },
  c3 = {
    prereq = {shared.tech_catch2, "production-science-pack", "utility-science-pack"},
    count = 1000,
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"chemical-science-pack", 1},
      {"production-science-pack", 1},
      {"utility-science-pack", 1},
      {"space-science-pack", 1},
    }
  },
  a1 = {
    prereq = {shared.tech_catch2, "military-science-pack"},
    count = 500,
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"military-science-pack", 1},
      {"chemical-science-pack", 1},
      {"production-science-pack", 1},
      {"utility-science-pack", 1},
    }
  },
  a2 = {
    prereq = {shared.tech_catch3, shared.tech_arty1},
    count = 1000,
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
  if mods[shared.IR] then
    info.c1.prereq = {"ir-bronze-milestone"}
  end
  if mods[shared.SE] then
    info = {
      c1 = {
        prereq = {},
        count = 10,
        ingredients = {
          {"automation-science-pack", 1},
        }
      },
      c2 = {
        prereq = {shared.tech_catch1, "electric-energy-accumulators"},
        count = 500,
        ingredients = {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
        }
      },
      c3 = {
        prereq = {shared.tech_catch2, "se-energy-science-pack-1"},
        count = 500,
        ingredients = {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
          {"se-rocket-science-pack", 1},
          {"space-science-pack", 1},
          {"se-energy-science-pack-1", 1},
        }
      },
      a1 = {
        prereq = {shared.tech_catch2, "military-science-pack"},
        count = 500,
        ingredients = {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"military-science-pack", 1},
          {"chemical-science-pack", 1},
          {"se-rocket-science-pack", 1},
        }
      },
      a2 = {
        prereq = {shared.tech_catch3, shared.tech_arty1},
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

data:extend{
  {
    name = shared.tech_catch1,
    localised_description = {"technology-description."..shared.tech_catch1},
    type = "technology",
    icons = {
      {
        icon = "__Lightning__/graphics/tech/Catch-Base.png",
        icon_size = 256, icon_mipmaps = 1,
      },
      {
        icon = "__Lightning__/graphics/icons/rod1.png",
        icon_size = 64, icon_mipmaps = 3,
        shift = {100, 100},
      }
    },
    upgrade = false,
    effects = {
      { type = "unlock-recipe", recipe = shared.rod1 },
    },
    prerequisites = info.c1.prereq,
    unit = {
      count = info.c1.count,
      ingredients = info.c1.ingredients,
      time = 30
    },
    order = "tsl-1[prot]-1",
  },
  {
    name = shared.tech_catch2,
    localised_description = {"technology-description."..shared.tech_catch2},
    type = "technology",
    icons = {
      {
        icon = "__Lightning__/graphics/tech/Catch-Base.png",
        icon_size = 256, icon_mipmaps = 1,
      },
      {
        icon = "__Lightning__/graphics/icons/han1.png",
        icon_size = 64, icon_mipmaps = 3,
        shift = {100, 100},
      }
    },
    upgrade = false,
    effects = {
      { type = "unlock-recipe", recipe = shared.han1 },
      { type = "unlock-recipe", recipe = shared.rod2 },
    },
    prerequisites = info.c2.prereq,
    unit = {
      count = info.c2.count,
      ingredients = info.c2.ingredients,
      time = 30
    },
    order = "tsl-1[prot]-2",
  },
  {
    name = shared.tech_catch3,
    localised_description = {"technology-description."..shared.tech_catch3},
    type = "technology",
    icons = {
      {
        icon = "__Lightning__/graphics/tech/Catch-Base.png",
        icon_size = 256, icon_mipmaps = 1,
      },
      {
        icon = "__Lightning__/graphics/icons/han2.png",
        icon_size = 64, icon_mipmaps = 3,
        shift = {100, 100},
      }
    },
    upgrade = false,
    effects = {
      { type = "unlock-recipe", recipe = shared.han2 },
    },
    prerequisites = info.c3.prereq,
    unit = {
      count = info.c3.count,
      ingredients = info.c3.ingredients,
      time = 30
    },
    order = "tsl-1[prot]-3",
  },
  {
    name = shared.tech_arty1,
    localised_description = {"technology-description."..shared.tech_arty1},
    type = "technology",
    icons = {
      {
        icon = "__Lightning__/graphics/tech/Arty-Base.png",
        icon_size = 256, icon_mipmaps = 1,
      },
      {
        icon = "__Lightning__/graphics/icons/arty1.png",
        icon_size = 64, icon_mipmaps = 3,
        shift = {100, 100},
      }
    },
    upgrade = false,
    effects = {
      { type = "unlock-recipe", recipe = shared.art1 },
    },
    prerequisites = info.a1.prereq,
    unit = {
      count = info.a1.count,
      ingredients = info.a1.ingredients,
      time = 30
    },
    order = "tsl-2[attack]-1",
  },
  {
    name = shared.tech_arty2,
    localised_description = {"technology-description."..shared.tech_arty2},
    type = "technology",
    icons = {
      {
        icon = "__Lightning__/graphics/tech/Arty-Base.png",
        icon_size = 256, icon_mipmaps = 1,
      },
      {
        icon = "__Lightning__/graphics/icons/arty2.png",
        icon_size = 64, icon_mipmaps = 3,
        shift = {100, 100},
      }
    },
    upgrade = false,
    effects = {
      { type = "unlock-recipe", recipe = shared.art2 },
    },
    prerequisites = info.a2.prereq,
    unit = {
      count = info.a2.count,
      ingredients = info.a2.ingredients,
      time = 30
    },
    order = "tsl-2[attack]-2",
  },
}

-- Enable arty-tool
table.insert(
  data.raw.technology[shared.tech_arty1].effects,
  { type = "unlock-recipe", recipe = shared.remote_name }
)
if settings.startup["af-tsl-early-arty"].value then
  table.insert(
    data.raw.technology[shared.tech_catch2].effects,
    { type = "unlock-recipe", recipe = shared.remote_name }
  )
end
