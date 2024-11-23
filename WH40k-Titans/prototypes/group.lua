local shared = require("shared")
local group_name = "wh40k-titans"

for i = 1, 5 do
  data:extend{{
    type = "recipe-category",
    name = shared.craftcat_titan..i
  }}
end
for i = 0, 5 do
  data:extend{
    {
      type = "recipe-category",
      name = shared.craftcat_weapon..i.."m",
    },
    {
      type = "recipe-category",
      name = shared.craftcat_weapon..i.."b",
    },
    {
      type = "recipe-category",
      name = shared.craftcat_weapon..i.."a"
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
    type = "recipe-category",
    name = shared.craftcat_nomount
  },
  {
    type = "recipe",
    name = shared.craftcat_nomount,
    hide_from_player_crafting = true,
    enabled = true,
    energy_required = 60*60*24,
    icon = "__core__/graphics/cancel.png",
    icon_size = 64, icon_mipmaps = 4,
    ingredients = {},
    results = {},
    category = shared.craftcat_nomount,
    subgroup = shared.subg_weapons.."0",
    order = "wh40k-tw-0",
  },
  {
    type = "recipe-category",
    name = shared.craftcat_noknownweapon
  },
  {
    type = "recipe",
    name = shared.craftcat_noknownweapon,
    hide_from_player_crafting = true,
    enabled = true,
    energy_required = 60*60*24,
    icon = shared.media_prefix.."graphics/icons/btns/ic-question.png",
    icon_size = 64, icon_mipmaps = 1,
    ingredients = {},
    results = {},
    category = shared.craftcat_noknownweapon,
    subgroup = shared.subg_weapons.."0",
    order = "wh40k-tw-0",
  },

  {
    type = "item-subgroup",
    name = shared.mod_prefix.."signals",
    group = "signals",
    order = "zz"
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