local shared = require("shared.shared-base")

function shared.preprocess_recipe(ingredients)
  -- Materialize Bridge items
  result = {}
  for _, couple in pairs(ingredients) do
    if couple[1].short_name then
      afci_bridge.preprocess(couple[1])
      couple[1] = couple[1].name
    end
    result[#result+1] = couple
  end
  return result
end

function shared.shuffle(t)
  for i = #t, 2, -1 do
    local j = math.random(i)
    t[i], t[j] = t[j], t[i]
  end
end

function table.shallow_copy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

function table.slice(tbl, first, last, step)
  local sliced = {}
  for i = first or 1, last or #tbl, step or 1 do
    sliced[#sliced+1] = tbl[i]
  end
  return sliced
end

function get_keys(tbl)
  if tbl == nil then return nil end
  local result = {}
  for k, v in pairs(tbl) do
    result[#result+1] = k
  end
  return result
end

function merge(a, b, over)
  for k, v in pairs(b) do
    if a[k] == nil or over then
      a[k] = v
    end
  end
  return a
end



-- Long live the Functional programming!
function iter_len(list)
  return #list
end

function iter_chain(lists)
  -- Like Python's itertools.chain
  local result = {}
  for _, ar in pairs(lists) do
    for _, value in pairs(ar) do
      table.insert(result, value)
    end
  end
  return result
end

function iter_zip(lists)
  -- local common_len = math.min(table.unpack(func_map(iter_len, lists)))
  local result = {}
  local index = 1
  local row, nils
  while true do
    nils = 0
    row = {}
    for _, ar in pairs(lists) do
      table.insert(row, ar[index])
      nils = nils + ((ar[index] == nil) and 1 or 0)
    end
    if nils == #lists then
      break
    elseif nils > 0 then
      error("Different lengths")
    end
    table.insert(result, row)
    index = index + 1
  end
  return result
end

function partial(func, args_pre, args_post)
  args_pre = args_pre or {}
  args_post = args_post or {}
  return function(...)
    local new_args = iter_chain(args_pre, {{...}, args_post})
    func(table.unpack(new_args))
  end
end

function func_map(func, args)
  local results = {}
  for _, value in pairs(args) do
    results[#results+1] = func(value)
  end
  return results
end

function func_maps(func, args_arrays)
  local results = {}
  for _, args in pairs(args_arrays) do
    results[#results+1] = func(table.unpack(args))
  end
  return results
end



function shorten_number(value)
  if value > 1000000000 then
    value = value/1000000000
    if value < 10 and value - math.floor(value) > 0.1 then
      return string.format("%.1f", value).."B"
    else
      return string.format("%.0f", value).."B"
    end

  elseif value > 1000000 then
    value = value/1000000
    if value < 10 and value - math.floor(value) > 0.1 then
      return string.format("%.1f", value).."M"
    else
      return string.format("%.0f", value).."M"
    end

  elseif value > 1000 then
    value = value/1000
    if value < 10 and value - math.floor(value) > 0.1 then
      return string.format("%.1f", value).."k"
    else
      return string.format("%.0f", value).."k"
    end

  else
    return string.format("%.0f", value)
  end
end

color_default_dst = {1,1,1}
color_gold    = {255, 220,  50}
color_orange  = {255, 160,  50}
color_red     = {200,  20,  20}
color_blue    = { 70, 120, 230}
color_purple  = {200,  20, 200}
color_green   = {20,  120,  20}
color_cyan    = {20,  200, 200}
color_ltgrey  = {160, 160, 160}
color_dkgrey  = { 60,  60,  60}

technomagic_resistances = {
  { type = "impact", decrease=10000, percent=100 },
  { type = "physical", percent=100 },
  { type = "explosion", percent=100 },
  { type = "laser", percent = 100 },
  { type = "fire", percent = 100 },
  { type = "electric", percent=100 },
  { type = "acid", percent=100 },
  { type = "poison", percent=100 },
}
strong_resistances = {
  { type = "impact", decrease=1000, percent=100 },
  { type = "poison", decrease=1000, percent=100 },
  { type = "fire", decrease=1000, percent=100 },
  { type = "laser", decrease=50, percent=50 },
  { type = "electric", decrease=50, percent=50 },
  { type = "physical", decrease=50, percent=50 },
  { type = "explosion", decrease=50, percent=50 },
  { type = "acid", decrease=50, percent=50 },
}