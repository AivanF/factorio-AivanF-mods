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

local added = {}
local prerequisite, prereq

for short_name, item_info in pairs(bridge.item) do
  bridge.preprocess(item_info)
  if added[short_name] then return end
  -- Check item is materialised and handled by the Bridge
  if data.raw.item[item_info.name] and bridge.is_bridge_name(item_info.name) then
    prereq = get_pre(item_info.prereq)
    prerequisite = item_info.prerequisite
    if prerequisite and prereq and prereq ~= bridge.empty then
      -- log(bridge.log_prefix.."Finals_Item "..serpent.line(item_info))
      if data.raw["technology"][prerequisite] == nil then
        error("No tech named "..serpent.line(prereq))
      end
      data.raw["technology"][prerequisite].effects = data.raw["technology"][prerequisite].effects or {}
      table.insert(
        data.raw["technology"][prerequisite].effects,
        { type = "unlock-recipe", recipe = item_info.name })
      if prerequisite ~= prereq then
        table.insert(data.raw["technology"][prerequisite].prerequisites, prereq)
      end
    end
  end
  added[short_name] = true
end

for short_name, tech_info in pairs(bridge.tech) do
  if data.raw["technology"][tech_info.name] then
    bridge.preprocess(tech_info)
    -- log(bridge.log_prefix.."Finals_Tech "..serpent.line(tech_info))
    data.raw["technology"][tech_info.name].prerequisites = afci_bridge.clean_prerequisites(data.raw["technology"][tech_info.name].prerequisites)
    if added[short_name] then return end
    added[short_name] = true
  end
end


-- Allow prod modules. Code adopted from Krastorio2 by LGPL license.
local function hasLimitationRecipe(limitations, recipe_name)
  local has_it = false
  if limitations and #limitations > 0 then
    for i, name in pairs(limitations) do
      if name == recipe_name then
        has_it = true
        break
      end
    end
  end
  return has_it
end

local function hasPositiveProductivity(module)
  local has_it = false
  if module.effect then
    for effect_name, effect in pairs(module.effect) do
      if effect_name == "productivity" and effect.bonus > 0 then
        has_it = true
        break
      end
    end
  end
  return has_it
end

local function isLimited(module)
  return module and module.limitation and #module.limitation > 0
end

local has_it
for recipe_name, recipe in pairs(data.raw.recipe) do
  if recipe.afci_bridged and recipe.allow_productivity == true then
    for _, module in pairs(data.raw.module) do
      if hasPositiveProductivity(module) and isLimited(module) then
        has_it = false
        if module.limitation then
          has_it = hasLimitationRecipe(module.limitation, recipe_name)
        else
          module.limitation = {}
        end
        if not has_it then
          table.insert(module.limitation, recipe_name)
        end
      end
    end
  end
end
