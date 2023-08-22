local shared = require("shared")

-- TODO: create animations also??

for _, info in pairs(shared.weapons) do
  data:extend({
    {
      type = "recipe",
      name = info.name,
      localised_name = {"item-name."..shared.mod_prefix..info.name},
      enabled = false,
      energy_required = 60*60*24,
      icon = info.icon or "__base__/graphics/icons/pipe-to-ground.png",
      icon_size = info.icon_size or 64, icon_mipmaps = info.icon_mipmaps or 4,
      ingredients = info.ingredients,
      results = {},
      category = shared.craftcat_weapon,
      subgroup = shared.subg_weapons,
      order = "wh40k-tw-"..info.grade.."-"..info.order_index.."-"..info.name,
    },
  })
end
