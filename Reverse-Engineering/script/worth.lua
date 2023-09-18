local ext, delimiter = ".tsv", "\t"
-- local ext, delimiter = ".csv", ", "

function istable(t) return type(t) == 'table' end

function deep_merge(a, b, over)
  for k, v in pairs(b) do
    if istable(v) and istable(a[k]) then
      deep_merge(a[k], v, over)
    elseif a[k] == nil or over then
      a[k] = v
    end
  end
  return a
end

function merge(a, b, over)
  for k, v in pairs(b) do
    if a[k] == nil or over then
      a[k] = v
    end
  end
  return a
end

function from_key_list(ar, value)
  local result = {}
  for _, key in pairs(ar) do
    result[key] = value
  end
  return result
end

-- Like Python's itertools.chain
function chain_arrays(lists)
  local result = {}
  for _, ar in pairs(lists) do
    for _, value in pairs(ar) do
      table.insert(result, value)
    end
  end
  return result
end

local red = "automation-science-pack"
local green = "logistic-science-pack"
local grey = "military-science-pack"
local blue = "chemical-science-pack"
local yellow = "utility-science-pack"
local purple = "production-science-pack"
local white = "space-science-pack"

ignore_tech = {
  ["fluid-handling"] = true,
}
ignore_item = from_key_list({
  "green-wire",
  "red-wire",
  "spidertron-remote",
  "artillery-targeting-remote",
  -- "discharge-defense-remote",
  -- "lightning-arty-remote",
}, true)
scipacks = {}

local override_items = {
  ["gun-turret"] = { ingredients = {red, grey}, need=10, price=1, prob=0.1 },
  ["solid-fuel"] = { ingredients = {red, green, blue}, need=50 },
}

local function get_tech_worth(source_tech_values)
  source_tech_values = source_tech_values or {}
  local tech_values = table.deepcopy(source_tech_values)
  for tech_name, tech_data in pairs(game.technology_prototypes) do
    tech_values[tech_name] = 1
    for tech2_name, tech2_data in pairs(tech_data.prerequisites) do
      tech_values[tech_name] = tech_values[tech_name] + (source_tech_values[tech2_name] or 1)
    end
  end
  return tech_values
end

local function try_stack(item_info, need, min_stack)
  if item_info.done then return end
  need = math.max(math.floor(need), 1)
  local price = math.max(math.floor(item_info.price *need /2), 1)
  if true
    and item_info.stack_size >= min_stack
    and need <= item_info.stack_size
    and price > 1
  then
    item_info.price = price
    item_info.need = need
    item_info.done = true
  end
end

local function finalise(item_info)
  local result = 1
  for _, value in pairs(item_info.prices) do
    value = math.min(5.5, math.max(0.2, value))
    -- result = math.max(result, value)
    result = result * value
  end
  item_info.price = result
  item_info.need = 1
  item_info.done = result > 1
  -- item_info.need = math.max(1, math.floor(game.item_prototypes[item_info.item_name].stack_size / 5))
  try_stack(item_info,  5, 10)
  try_stack(item_info, 10, 20)
  try_stack(item_info, 20, 50)
  try_stack(item_info, 50,100)
  -- item_info.price = math.floor(item_info.price)
  item_info.prob = item_info.price / 15
end

function cache_data()
  local tech_values = get_tech_worth()
  tech_values = get_tech_worth(tech_values)
  tech_values = get_tech_worth(tech_values)

  local total = 0
  local item_opts, prices, total_price, ingredients, item_name, stack_size
  local reverse_items = {} -- item_name => tech_name => {price=, ingredients=}
  local texts = {
    table.concat({"Tech", "Item", "stack_size",
      "by count", "by stack", "by tech cost", "by ingredients", "Final Price", "Need"}, delimiter),
  }
  local recipes_of = {} -- item_name => recipe

  for tech_name, tech_data in pairs(game.technology_prototypes) do
    for _, modifier in pairs(ignore_tech[tech_name] and {} or tech_data.effects) do
      if modifier.type == "unlock-recipe" then
        for _, prod in pairs(game.recipe_prototypes[modifier.recipe].products) do
          if true or prod.type == "item" then
            item_name = prod.name
            recipes_of[item_name] = game.recipe_prototypes[modifier.recipe]
            total = total + 1
            item_opts = reverse_items[item_name] or {}
            reverse_items[item_name] = item_opts
            total_price = 0
            ingredients = {}
            for _, ingr in pairs(tech_data.research_unit_ingredients) do
              if true or ingr.type == "item" then
                table.insert(ingredients, ingr.name)
                total_price = total_price + ingr.amount * tech_data.research_unit_count
              end
            end
            stack_size = game.item_prototypes[item_name] and game.item_prototypes[item_name].stack_size or 100 -- fluids
            prices = {
              1 /(prod.probability or 1) /(prod.amount or prod.amount_max or 1),
              1 /(math.log10(stack_size)+1),
              math.log10(total_price / 3),
            }
            deep_merge(scipacks, from_key_list(ingredients, true))
            item_opts[tech_name] = {
              item_name = item_name,
              tech_name = tech_name,
              prices = prices,
              simple_price = tech_values[tech_name],
              stack_size = stack_size,
              ingredients = ingredients,
            }
          end
        end
      end
    end
  end

  -- Pick earlier research for each item
  global.reverse_items = {} -- item_name => {tech_name=, price=, ingredients=}
  for item_name, item_opts in pairs(reverse_items) do
    local min_price = math.huge
    local result = nil
    for tech_name, item_info in pairs(item_opts) do
      if item_info.simple_price < min_price then
        min_price = item_info.simple_price
        result = item_info
      end
    end
    global.reverse_items[item_name] = result
  end

  -- Calc prices considering ingredients
  for item_name, item_info in pairs(global.reverse_items) do
    local ingr_price = 0
    for _, ingr in pairs(recipes_of[item_name].ingredients) do
      local item_info2 = global.reverse_items[ingr.name]
      if item_info2 then
        ingr_price = ingr_price + tech_values[item_info2.tech_name]
      else
        ingr_price = ingr_price + 0.2
      end
    end
    table.insert(item_info.prices, ingr_price/2)
    finalise(item_info)
    table.insert(texts, table.concat(
      chain_arrays({
        {item_info.tech_name, item_name, item_info.stack_size},
        item_info.prices, {item_info.price, item_info.need}}),
      delimiter))
    if ignore_item[item_name] or item_info.price < 1 then
      global.reverse_items[item_name] = nil
    end
  end

  game.write_file("af-revlab-prices"..ext, table.concat(texts, "\n"))
  deep_merge(global.reverse_items, override_items, true)
  -- game.print("Cached "..total.." items")
end
