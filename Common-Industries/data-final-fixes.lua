local bridge = require("bridge3-item")

log(bridge.log_prefix.."Tech: "..serpent.line(table.get_keys(data.raw.technology)))

local function get_pre(name_or_item)
  if name_or_item.name then
    -- It's an item_info
    return get_pre(name_or_item.prerequisite)
  else
    -- It's a string
    return name_or_item
  end
end

-- Add research effects
-- Because f*ing IR3 adds technologies in data-updates, not data as normal devs >(
local added = {}
local prerequisite

for short_name, item_info in pairs(bridge.item) do
  bridge.preprocess(item_info)
  if added[short_name] then return end
  -- Check item is materialised and handled by the Bridge
  if data.raw.item[item_info.name] and bridge.is_new(item_info.name) then
    prerequisite = get_pre(item_info.prerequisite)
    if prerequisite and prerequisite ~= bridge.empty then
      -- log(bridge.log_prefix.."finals "..serpent.line(item_info))
      if data.raw["technology"][prerequisite] == nil then
        error("No tech named "..serpent.line(prerequisite))
      end
      table.insert(
        data.raw["technology"][prerequisite].effects,
        { type = "unlock-recipe", recipe = item_info.name })
    end
  end
  added[short_name] = true
end