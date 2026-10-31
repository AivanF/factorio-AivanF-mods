-- Recipes created by this mod, see the end of the file
local recipes_before = {}
for name, _ in pairs(data.raw.recipe) do recipes_before[name] = true end

require("prototypes.sounds")
require("prototypes.sprites")
require("prototypes.group")
require("prototypes.science")
require("prototypes.bunker")
require("prototypes.details")
require("prototypes.equip")
require("prototypes.weapon-recipes")
require("prototypes.ammo")
require("prototypes.tech_main")
require("prototypes.tech_lvls")
require("prototypes.tech_impr")
require("prototypes.titans")
require("prototypes.damage")
require("prototypes.corpses")
require("prototypes.excavation")
require("prototypes.aircraft")

-- Factorio 2.1 replaced recipe `category` with `categories`; one code base serves 2.0 and 2.1
local base_major, base_minor = string.match(mods["base"], "^(%d+)%.(%d+)")
if tonumber(base_major) * 100 + tonumber(base_minor) >= 201 then
  for name, recipe in pairs(data.raw.recipe) do
    if not recipes_before[name] and recipe.category then
      recipe.categories = {recipe.category}
      recipe.category = nil
    end
  end
end
