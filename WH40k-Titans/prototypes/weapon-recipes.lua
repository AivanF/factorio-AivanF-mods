local shared = require("shared")

local ammo, stats_descr, own_descr, full_descr
for _, info in pairs(shared.weapons) do
  ammo = info.ammo or "unknown"
  own_descr = {"item-description."..info.entity}
  stats_descr = {
    (info.attack_size == 1) and "item-description.wh40k-titan-weapon-1" or "item-description.wh40k-titan-weapon-n",
    -- Args:
    {"item-name."..ammo}, -- "__ITEM__"..ammo.."__",
    info.per_shot,
    shorten_number(info.inventory),
    info.bolt_type and shorten_number(info.attack_size * info.bolt_type.single_damage) or "terrible",
    info.attack_size,
  }
  full_descr = {"?", {"", own_descr, " ", stats_descr}, stats_descr}
  data:extend({
    {
      type = "recipe",
      name = info.entity,
      localised_name = {"item-name."..info.entity},
      localised_description = info.available and full_descr or {"item-description.wh40k-titans-not-yet"},
      enabled = false,
      energy_required = 60*60*24,
      icon = info.icon or "__base__/graphics/icons/pipe-to-ground.png",
      icon_size = info.icon_size or 64, icon_mipmaps = info.icon_mipmaps or 4,
      ingredients = shared.preprocess_recipe(info.ingredients),
      results = {},
      category = shared.craftcat_weapon..info.grade,
      subgroup = shared.subg_weapons..info.grade,
      order = "wh40k-tw-"..info.grade.."-"..string.format("%02.0f", info.order_index).."-"..info.name,
    },
  })
end
