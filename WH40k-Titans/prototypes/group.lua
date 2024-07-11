local shared = require("shared")
local group_name = "wh40k-titans"

for i = 1, 5 do
  data:extend{{
    type = "recipe-category",
    name = shared.craftcat_titan..i
  }}
end
for i = 0, 3 do
  data:extend{
    {
      type = "recipe-category",
      name = shared.craftcat_weapon..i
    },
    {
      type = "item-subgroup",
      name = shared.subg_weapons..i,
      group = group_name,
      order = "a-42-"..i,
    },
  }
end

data:extend{
  {
    type = "recipe-category",
    name = shared.craftcat_empty
  },

  {
    type = "item-group",
    name = group_name,
    order = "d-d",
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
    name = shared.subg_ammo,
    group = group_name,
    order = "a-40",
  },
}