local shared = require("shared")
local group_name = "wh40k-titans"

data:extend{
  {
    type = "recipe-category",
    name = shared.craftcat_titan
  },
  {
    type = "recipe-category",
    name = shared.craftcat_weapon
  },
  {
    type = "recipe-category",
    name = shared.craftcat_empty
  },

  {
    type = "item-group",
    name = group_name,
    order = "am",
    icon = shared.media_prefix.."graphics/tech/legio-titanicus.png",
    icon_size = 256, icon_mipmaps = 1,
  },
  {
    type = "item-subgroup",
    name = shared.subg_build,
    group = group_name,
    order = "a-10",
  },
  {
    type = "item-subgroup",
    name = shared.subg_parts,
    group = group_name,
    order = "a-20",
  },
  {
    type = "item-subgroup",
    name = shared.subg_titans,
    group = group_name,
    order = "a-30",
  },
  {
    type = "item-subgroup",
    name = shared.subg_weapons,
    group = group_name,
    order = "a-40",
  },
}