local bridge = require("bridge3-item")

if bridge.debug_all or settings.startup["afci-materialise-all"].value then
  log(bridge.log_prefix.."Tech: "..serpent.line(table.get_keys(data.raw.technology)))
end

-- Tie added researches
if data.raw.technology[bridge.early] and data.raw.technology[bridge.midgame] then
  table.insert(data.raw.technology[bridge.midgame].prerequisites, bridge.early)
end
if data.raw.technology[bridge.midgame] and data.raw.technology[bridge.lategame] then
  table.insert(data.raw.technology[bridge.lategame].prerequisites, bridge.midgame)
end
if data.raw.technology[bridge.lategame] and data.raw.technology[bridge.endgame] then
  table.insert(data.raw.technology[bridge.endgame].prerequisites, bridge.lategame)
end


-- Add research effects
-- Here because f*ing IR3 adds technologies in data-updates, not data as normal devs >(

local function get_pre(name_or_item)
  if name_or_item.name then
    -- It's an item_info
    return get_pre(name_or_item.prereq)
  else
    -- It's a string
    return name_or_item
  end
end

local function has_unlock(tech, recipe_name)
  for _, effect in pairs(tech.effects) do
    if effect.type == "unlock-recipe" and effect.recipe == recipe_name then return true end
  end
  return false
end

local function has_prerequisite(tech, name)
  for _, existing in pairs(tech.prerequisites or {}) do
    if existing == name then return true end
  end
  return false
end

-- Each item_info is stored twice in bridge.item: by short name and by prototype name
local added = {}
local prerequisite, prereq, tech

for _, item_info in pairs(bridge.item) do
  if not added[item_info] then
    added[item_info] = true
    bridge.preprocess(item_info)
    -- Check item is materialised and handled by the Bridge
    if data.raw.item[item_info.name] and bridge.is_bridge_name(item_info.name) then
      prereq = get_pre(item_info.prereq)
      prerequisite = item_info.prerequisite
      if prerequisite and prerequisite ~= bridge.empty then
        -- log(bridge.log_prefix.."Finals_Item "..serpent.line(item_info))
        tech = data.raw["technology"][prerequisite]
        if tech == nil then
          error("No tech named "..serpent.line(prereq))
        end
        tech.effects = tech.effects or {}
        if not has_unlock(tech, item_info.name) then
          table.insert(tech.effects, { type = "unlock-recipe", recipe = item_info.name })
        end
        if prerequisite ~= prereq and prereq ~= bridge.empty and not has_prerequisite(tech, prereq) then
          tech.prerequisites = tech.prerequisites or {}
          table.insert(tech.prerequisites, prereq)
        end
      end
    end
  end
end

for _, tech_info in pairs(bridge.tech) do
  if data.raw["technology"][tech_info.name] then
    bridge.preprocess(tech_info)
    -- log(bridge.log_prefix.."Finals_Tech "..serpent.line(tech_info))
    data.raw["technology"][tech_info.name].prerequisites = afci_bridge.clean_prerequisites(data.raw["technology"][tech_info.name].prerequisites)
  end
end
