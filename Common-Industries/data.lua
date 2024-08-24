local bridge = require("bridge3-item")

data:extend{
  -- {
  --   type = "recipe-category",
  --   name = cat_nano_crafting
  -- },
  -- {
  --   type = "recipe-category",
  --   name = cat_he_crafting
  -- },

  -- {
  --   type = "item-group",
  --   name = bridge.group_name,
  --   order = "ak",
  --   icon = bridge.media_path.."group.png",
  --   icon_size = 256, icon_mipmaps = 1,
  -- },
  {
    type = "item-subgroup",
    name = bridge.subg_early,
    group = bridge.group_name,
    order = "g-10",
  },
  {
    type = "item-subgroup",
    name = bridge.subg_mid,
    group = bridge.group_name,
    order = "g-20",
  },
  {
    type = "item-subgroup",
    name = bridge.subg_late,
    group = bridge.group_name,
    order = "g-30",
  },
  {
    type = "item-subgroup",
    name = bridge.subg_end,
    group = bridge.group_name,
    order = "g-40",
  },
}

-- Materialise everything for debug
if bridge.debug_all or settings.startup["afci-materialise-all"].value then
  log(bridge.log_prefix.."all_items: "..serpent.line(table.get_keys(data.raw.item)))
  for short_name, item_info in pairs(bridge.item) do
    if not item_info.minor then
      log("Doing "..short_name)
      item_info.getter()
      if not data.raw.item[item_info.name] then
        error("No item "..item_info.name.." for "..short_name)
      end
    end
  end
end

return bridge