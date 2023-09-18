
KW = 1000
MW = 1000 * KW

rlab_list = {
  {
    name = "af-reverse-lab-1",
    icon = "__Reverse-Engineering__/graphics/RLab-1-icon.png",
    icon_size = 64,
    icon_mipmaps = 1,
    sprite = "__Reverse-Engineering__/graphics/RLab-1.png",
    health = 250,
    max_scale = 1,
    max_items = 1,
    usage = 100 * KW,
    prereq = nil,
    ingredients = {
      {"iron-chest", 3},
      {"inserter", 5},
      {"assembling-machine-2", 1},
      {"electronic-circuit", 10},
    }
  },
  {
    name = "af-reverse-lab-2",
    icon = "__Reverse-Engineering__/graphics/RLab-2-icon.png",
    icon_size = 64,
    icon_mipmaps = 1,
    sprite = "__Reverse-Engineering__/graphics/RLab-2.png",
    health = 750,
    max_scale = 4,
    max_items = 2,
    usage = 1 * MW,
    prereq = "automation-2",
    ingredients = {
      {"af-reverse-lab-1", 1},
      -- {"steel-chest", 3},
      {"filter-inserter", 5},
      {"assembling-machine-2", 1},
      {"advanced-circuit", 10},
    },
  },
  {
    name = "af-reverse-lab-3",
    icon = "__Reverse-Engineering__/graphics/RLab-3-icon.png",
    icon_size = 64,
    icon_mipmaps = 1,
    sprite = "__Reverse-Engineering__/graphics/RLab-3.png",
    health = 1500,
    max_scale = 10,
    max_items = 4,
    usage = 5 * MW,
    prod_bonus = 1.5,
    prereq = "automation-3",
    ingredients = {
      {"af-reverse-lab-2", 1},
      {"stack-filter-inserter", 5},
      {"assembling-machine-3", 1},
      -- {"processing-unit", 10},
      {"speed-module", 10},
      {"productivity-module", 10},
    },
  },
}

make_grades = true

rlabs = {}
for i, info in pairs(rlab_list) do
  info.grade = i
  rlabs[i] = info
  rlabs[info.name] = info
end

if not make_grades then
  rlabs[2].ingredients = {
    {"iron-chest", 3},
    {"filter-inserter", 5},
    {"assembling-machine-2", 1},
    {"advanced-circuit", 10},
  }
end
