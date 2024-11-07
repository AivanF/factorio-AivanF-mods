local bridge = require("bridge2-tech")

-- Items
bridge.item = {}
local ordered = 0

-- TODO: make recipe_anyway flag to add new recipe even if item and recipe already exist?


local function data_getter_inner(item_info)
  if item_info.done then
    if item_info.done == bridge.empty then
      error("Recursive add_item "..item_info.short_name)
    end
    return item_info
  end

  bridge.preprocess(item_info)
  -- True prototype name isn't available before preprocessing
  bridge.item[item_info.name] = item_info
  item_info.done = bridge.empty -- Aka false, just to prevent recursion

  -- Materialize required components if needed
  local ing_info
  if bridge.is_bridge_name(item_info.name) then
    for index, row in pairs(item_info.ingredients) do

    -- Array style, and 1st is an item_info
      if row[1] and row[1].is_bridge_item then
        ing_info = row[1]
        if bridge.is_bridge_name(ing_info.name) then
          ing_info.data_getter()
        end
        row[1] = ing_info.name
      end

      -- Factorio 2.0 doesn't support array style,
      -- let's transform to the dict
      if row[1] then
        item_info.ingredients[index] = { type = "item", name = row[1], amount = row[2] }
      end

      -- Dict style, and name is an item_info
      if row.name and row.name.is_bridge_item then
        ing_info = row.name
        if bridge.is_bridge_name(ing_info.name) then
          ing_info.data_getter()
        end
        row[1] = ing_info.name
      end

    end
  end

  -- Preprocess required tech research
  if item_info.prereq and item_info.prereq.is_bridge_item then
    -- Prerequisite can be a string or another item
    -- If so, let's recursively preprocess it and take its prerequisite
    ing_info = item_info.prereq
    if bridge.is_bridge_name(ing_info.name) then
      ing_info.data_getter()
    end
    item_info.prereq = ing_info.prereq
  end

  -- Materialize required tech research if needed
  if item_info.prerequisite and bridge.is_bridge_name(item_info.prerequisite) then
    bridge.setup_tech[bridge.tech[item_info.prerequisite].short_name]()
  end
  -- if bridge.is_bridge_name(item_info.prereq) then
  --   bridge.setup_tech[bridge.tech[item_info.prereq].short_name]()
  -- end

  -- Combine recipe results
  -- TODO: maybe always use {} and add other_results for byproducts?
  local results = item_info.results or {}
  table.insert(results, 1, {
    type="item",
    name=item_info.name,
    amount=item_info.result_count or 1
  })
  -- TODO: remove ores/scrap+sludge(SE)/slag(248k) if related startup setting is set

  -- Make actual item + recipe if the item was not replaced by some mod
  -- IS1: Maybe check item_info.updated!=repalced?
  if bridge.is_bridge_name(item_info.name) or item_info.afci_bridged then
    if data and data.raw and not data.raw.item[item_info.name] then
      log(bridge.log_prefix.."creating item "..item_info.short_name)
      local item_data = {
          type = item_info.item_prototype or "item",
          name = item_info.name,
          icon = item_info.icon,
          icon_size = item_info.icon_size,
          icon_mipmaps = item_info.icon_mipmaps,
          subgroup = item_info.subgroup,
          order = item_info.order,
          place_result = item_info.place_result,
          stack_size = item_info.stack_size or 20,
          afci_bridged = true,
      }
      local recipe_data = {
        type = "recipe",
        name = item_info.name,
        enabled = item_info.prerequisite == bridge.empty,
        energy_required = item_info.energy_required or 1,
        allow_productivity = item_info.allow_productivity,
        ingredients = item_info.ingredients,
        -- result_count = item_info.result_count,
        -- result = item_info.name,
        results = results,
        main_product = item_info.name,
        category = item_info.category or "crafting",
        afci_bridged = true,
      }
      if item_info.item_data then
        table.merge(item_data, item_info.item_data)
      end
      if item_info.recipe_data then
        table.merge(recipe_data, item_info.recipe_data)
      end
      data:extend({item_data, recipe_data})

      -- Note: tech research effects are added in data-final-fixes
      if item_info.builder and bridge.is_bridge_name(item_info.builder) then
        -- TODO: materialize builder entity; maybe it's better to consider crafting category
      end
    end
  end

  item_info.done = true
  bridge.item[item_info.name] = item_info
  return item_info
end


-- Generate items API, so that `bridge.get[short_name]()` returns item_info
function bridge.add_item(item_info)
  ordered = ordered + 1

  if bridge.item[item_info.short_name] then
    error("Item "..tostring(item_info.short_name).." already registered!")
  end
  item_info.is_bridge_item = true
  item_info.updated = bridge.not_updated
  item_info.order = item_info.order or "abc-"..ordered
  item_info.prerequisite = item_info.prereq -- original custom prereq
  bridge.item[item_info.short_name] = item_info

  item_info.data_getter = function()
    success, call_result = pcall(data_getter_inner, item_info)
    if not success then
      error(serpent.line({
        name = item_info.name,
        error = call_result,
      }))
    end
    return call_result
  end

  item_info.control_getter = function()
    if item_info.done then
      return item_info
    end
    bridge.preprocess(item_info)
    bridge.item[item_info.name] = item_info
    item_info.done = true
    return item_info
  end

  local union_getter = function()
    if data then
      return item_info.data_getter()
    elseif game or bridge.active_mods_cache then
      return item_info.control_getter()
    else
      error("Unknown game stage. Is it on_load?")
    end
  end
  item_info.getter = union_getter
  bridge.get[item_info.short_name] = union_getter
  return item_info
end

--[[

Ingredients names and prerequisite can be set as another
previously defined item_info via `bridge.item.NAME`

The modded sections should either:
1. Replace item specifying `name` + `prereq`
2. Adjust recipe specifying any fields except `name`

If ingredients of an item already replaced/adjusted for other mods,
there may be no need to replace item name or adjust ingredients,
however, changing of prerequisite name is recommended to prevent
creation of additional technology research.

Note that no-prerequisite is set by empty string,
this approach is chosen due to stupid `nil` behaviour of Lua.

]]

return bridge