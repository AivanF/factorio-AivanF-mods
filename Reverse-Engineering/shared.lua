
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
    max_pcs = 1,
    usage = 100 * KW,
    prereq = nil,
    ingredients = {
      {type="item", name="iron-chest", amount=3},
      {type="item", name="inserter", amount=5},
      {type="item", name="assembling-machine-1", amount=1},
      {type="item", name="electronic-circuit", amount=10},
    }
  },
  {
    name = "af-reverse-lab-2",
    icon = "__Reverse-Engineering__/graphics/RLab-2-icon.png",
    icon_size = 64,
    icon_mipmaps = 1,
    sprite = "__Reverse-Engineering__/graphics/RLab-2.png",
    health = 750,
    max_pcs = 2,
    usage = 1 * MW,
    prereq = "automation-2",
    ingredients = {
      {type="item", name="af-reverse-lab-1", amount=1},
      -- {type="item", name="steel-chest", amount=3},
      {type="item", name="fast-inserter", amount=5},
      {type="item", name="assembling-machine-2", amount=1},
      {type="item", name="advanced-circuit", amount=10},
    },
  },
  {
    name = "af-reverse-lab-3",
    icon = "__Reverse-Engineering__/graphics/RLab-3-icon.png",
    icon_size = 64,
    icon_mipmaps = 1,
    sprite = "__Reverse-Engineering__/graphics/RLab-3.png",
    health = 1500,
    max_pcs = 5,
    usage = 5 * MW,
    prod_bonus = 1.5,
    prereq = "automation-3",
    ingredients = {
      {type="item", name="af-reverse-lab-2", amount=1},
      {type="item", name="bulk-inserter", amount=5},
      {type="item", name="assembling-machine-3", amount=1},
      -- {type="item", name="processing-unit", amount=10},
      {type="item", name="speed-module", amount=10},
      {type="item", name="productivity-module", amount=10},
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
    {type="item", name="iron-chest", amount=3},
    {type="item", name="fast-inserter", amount=5},
    {type="item", name="assembling-machine-2", amount=1},
    {type="item", name="advanced-circuit", amount=10},
  }
end
