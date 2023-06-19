require "shared"

local to_oil = deepcopy(data.raw.recipe["coal-liquefaction"])
to_oil.name = "meet-to-oil"
to_oil.icon = mod_path .. "/graphics/meet-to-oil.png"
to_oil.icon_size = 64
to_oil.category = "chemistry"
to_oil.order = to_oil.order
to_oil.ingredients = {{"raw-meat", 10}}
to_oil.energy_required = 3
to_oil.results = {{
  type = "fluid",
  name = "crude-oil",
  amount = settings.startup["af-meet-to-oil-value"].value,
}}
data.raw.recipe[to_oil.name] = to_oil

local prereq = "advanced-oil-processing"
if settings.startup["af-meet-to-oil-early"].value then
  prereq = "oil-processing"
end

table.insert(data.raw.technology[prereq].effects, {
  type = "unlock-recipe",
  recipe = to_oil.name,
})
