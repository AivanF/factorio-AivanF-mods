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
    if class == math.round(info.class/10) then
      result[#result+1] = { type = "unlock-recipe", recipe = info.entity }
    end
  end
  return result
end


local tech_researches = {
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
    prerequisites = {
      -- shared.mod_prefix.."assembly",
      shared.mod_prefix.."0-grade",
    },
    unit = {
      count = 25,
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
    prerequisites = {
      shared.mod_prefix.."1-class",
      shared.mod_prefix.."1-grade",
    },
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
    prerequisites = {
      shared.mod_prefix.."2-class",
      shared.mod_prefix.."2-grade",
    },
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
    prerequisites = {
      shared.mod_prefix.."3-class",
      shared.mod_prefix.."3-grade",
    },
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
    prerequisites = {
      shared.mod_prefix.."4-class",
      shared.mod_prefix.."4-grade",
    },
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
    effects = get_weapon_effects(shared.gun_grade_0m),
    prerequisites = {
      shared.mod_prefix.."assembly",
    },
    unit = {
      count = 10,
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
    effects = get_weapon_effects(shared.gun_grade_1v),
    prerequisites = {
      shared.mod_prefix.."0-grade",
      -- shared.mod_prefix.."1-class",
    },
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
    effects = get_weapon_effects(shared.gun_grade_2s),
    prerequisites = {
      shared.mod_prefix.."1-grade",
      shared.mod_prefix.."1-class",
    },
    unit = {
      count = 100,
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
    effects = get_weapon_effects(shared.gun_grade_3f),
    prerequisites = {
      shared.mod_prefix.."2-grade",
      shared.mod_prefix.."2-class",
    },
    unit = {
      count = 200,
      ingredients = {{shared.sp, 1}},
      time = 60
    },
  },
  {
    name = shared.mod_prefix.."4-grade",
    type = "technology",
    icons = {
      {
      icon = shared.media_prefix.."graphics/tech/grade-4.png",
      icon_size = 256,
      icon_mipmaps = 1,
      }
    },
    effects = get_weapon_effects(shared.gun_grade_4m),
    prerequisites = {
      shared.mod_prefix.."3-grade",
      shared.mod_prefix.."3-class",
    },
    unit = {
      count = 300,
      ingredients = {{shared.sp, 1}},
      time = 60
    },
  },
  {
    name = shared.mod_prefix.."5-grade",
    type = "technology",
    icons = {
      {
      icon = shared.media_prefix.."graphics/tech/grade-5.png",
      icon_size = 256,
      icon_mipmaps = 1,
      }
    },
    effects = get_weapon_effects(shared.gun_grade_5g),
    prerequisites = {
      shared.mod_prefix.."4-grade",
      shared.mod_prefix.."4-class",
    },
    unit = {
      count = 500,
      ingredients = {{shared.sp, 1}},
      time = 60
    },
  },
}

------- Outro
data:extend(tech_researches)
