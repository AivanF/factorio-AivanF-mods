have_SE = not not mods["space-exploration"]
subgroup = have_SE and "oil" or "fluid-recipes"
recipes = {}


if have_SE and settings.startup["af-revchem-petroleum-gas-cracking"].value then
  table.insert(recipes, "af-petroleum-gas-cracking")
  data:extend({
    {
      type = "recipe",
      name = "af-petroleum-gas-cracking",
      category = "chemistry",
      enabled = false,
      energy_required = 2,
      ingredients = {
        {type="fluid", name="petroleum-gas", amount=50}
      },
      results = {
        {type="fluid", name="se-methane-gas", amount=100}
      },
      main_product= "",
      icon = "__reverse-chemistry__/graphics/petroleum-gas-cracking.png",
      icon_size = 64, icon_mipmaps = 1,
      subgroup = subgroup,
      order = have_SE and "c-0" or "b[fluid-chemistry]-ac[petroleum-gas-cracking]",
      crafting_machine_tint =
      {
        primary = {r = 0.764, g = 0.596, b = 0.780, a = 1.000}, -- #c298c6ff
        secondary = {r = 0.762, g = 0.551, b = 0.844, a = 1.000}, -- #c28cd7ff
        tertiary = {r = 0.895, g = 0.773, b = 0.596, a = 1.000}, -- #e4c597ff
        quaternary = {r = 1.000, g = 0.734, b = 0.290, a = 1.000}, -- #ffbb49ff
      }
    },
  })
  table.insert(
    data.raw.technology["advanced-oil-processing"].effects,
    { type = "unlock-recipe", recipe = "af-petroleum-gas-cracking" }
  )
end


if have_SE and settings.startup["af-revchem-methane-gas-compression"].value then
  table.insert(recipes, "af-se-methane-gas-compression")
  data:extend({
    {
      type = "recipe",
      name = "af-se-methane-gas-compression",
      category = "chemistry",
      enabled = false,
      energy_required = 4,
      ingredients = {
        {type="fluid", name="se-methane-gas", amount=100}
      },
      results = {
        {type="fluid", name="petroleum-gas", amount=20}
      },
      main_product= "",
      icon = "__reverse-chemistry__/graphics/methane-gas-compression.png",
      icon_size = 64, icon_mipmaps = 1,
      subgroup = subgroup,
      order = have_SE and "d-a" or "b[fluid-chemistry]-ad1[methane-gas-compression]",
      crafting_machine_tint =
      {
        primary = {r = 0.700, g = 0.700, b = 0.600, a = 1.000},
        secondary = {r = 0.700, g = 0.700, b = 0.600, a = 1.000},
        tertiary = {r = 0.700, g = 0.700, b = 0.600, a = 1.000},
        quaternary = {r = 1.000, g = 0.900, b = 0.400, a = 1.000},
      }
    },
  })
  table.insert(
    data.raw.technology["advanced-oil-processing"].effects,
    { type = "unlock-recipe", recipe = "af-se-methane-gas-compression" }
  )
end


if settings.startup["af-revchem-petroleum-gas-compression"].value then
  table.insert(recipes, "af-petroleum-gas-compression")
  data:extend({
    {
      type = "recipe",
      name = "af-petroleum-gas-compression",
      category = "chemistry",
      enabled = false,
      energy_required = 4,
      ingredients = {
        {type="fluid", name="petroleum-gas", amount=40},
        {type="fluid", name="water", amount=20},
      },
      results = {
        {type="fluid", name="light-oil", amount=20}
      },
      main_product= "",
      icon = "__reverse-chemistry__/graphics/petroleum-gas-compression.png",
      icon_size = 64, icon_mipmaps = 1,
      subgroup = subgroup,
      order = have_SE and "d-b" or "b[fluid-chemistry]-ad2[petroleum-gas-compression]",
      crafting_machine_tint =
      {
        primary = {r = 0.764, g = 0.596, b = 0.780, a = 1.000}, -- #c298c6ff
        secondary = {r = 0.762, g = 0.551, b = 0.844, a = 1.000}, -- #c28cd7ff
        tertiary = {r = 0.895, g = 0.773, b = 0.596, a = 1.000}, -- #e4c597ff
        quaternary = {r = 1.000, g = 0.734, b = 0.290, a = 1.000}, -- #ffbb49ff
      }
    },
  })
  table.insert(
    data.raw.technology["advanced-oil-processing"].effects,
    { type = "unlock-recipe", recipe = "af-petroleum-gas-compression" }
  )
end


if settings.startup["af-revchem-light-oil-compression"].value then
  table.insert(recipes, "af-light-oil-compression")
  data:extend({
    {
      type = "recipe",
      name = "af-light-oil-compression",
      category = "chemistry",
      enabled = false,
      energy_required = 4,
      ingredients = {
        {type="fluid", name="light-oil", amount=40},
      },
      results = {
        {type="fluid", name="heavy-oil", amount=20}
      },
      main_product= "",
      icon = "__reverse-chemistry__/graphics/light-oil-compression.png",
      icon_size = 64, icon_mipmaps = 1,
      subgroup = subgroup,
      order = have_SE and "d-c" or "b[fluid-chemistry]-ad3[light-oil-compression]",
      crafting_machine_tint =
      {
        primary = {r = 1.000, g = 0.642, b = 0.261, a = 1.000}, -- #ffa342ff
        secondary = {r = 1.000, g = 0.722, b = 0.376, a = 1.000}, -- #ffb85fff
        tertiary = {r = 0.854, g = 0.659, b = 0.576, a = 1.000}, -- #d9a892ff
        quaternary = {r = 1.000, g = 0.494, b = 0.271, a = 1.000}, -- #ff7e45ff
      }
    },
  })
  table.insert(
    data.raw.technology["advanced-oil-processing"].effects,
    { type = "unlock-recipe", recipe = "af-light-oil-compression" }
  )
end


for _, name in pairs(recipes) do
  if data.raw.recipe[name] then
    for _, prototype in pairs(data.raw["module"]) do
      if string.find(prototype.name, "productivity", 1, true) and prototype.limitation then
        table.insert(prototype.limitation, name)
      end
    end
  end
end
