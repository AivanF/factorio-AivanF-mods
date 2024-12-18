local shared = require("shared")

local function add_weapon_recipe(info)
  local letter = "b"
  if info.no_top then
    letter = "m"
  elseif info.top_only then
    letter = "a"
  end
  data:extend({
    {
      type = "recipe",
      name = info.entity,
      localised_name = {"item-name."..info.entity},
      localised_description = shared.get_weapon_descr(info),
      enabled = false,
      energy_required = 60*60*24,
      icon = info.icon or "__base__/graphics/icons/pipe-to-ground.png",
      icon_size = info.icon_size or 64, icon_mipmaps = info.icon_mipmaps or 4,
      ingredients = shared.preprocess_recipe(info.ingredients),
      results = {},
      category = shared.craftcat_weapon..info.grade..letter,
      subgroup = shared.subg_weapons..info.grade,
      order = "wh40k-tw-"..info.grade.."-"..string.format("%02.0f", info.order_index).."-"..info.name,
    },
  })
end

for _, info in pairs(shared.weapons) do
  local success, err = pcall(add_weapon_recipe, info)
  if not success then
    error(serpent.line({
      weapon = info.entity,
      error = err,
    }))
  end
end
