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
  return t
end

function math.round(v)
  return math.floor(v + 0.5)
end

function math.clamp(v, mn, mx)
  return math.max(math.min(v, mx), mn)
end

function math.lerp_map(v, min1, max1, min2, max2)
  -- Similar to LERP, linear interpolation
  return (v - min1) / (max1 - min1) * (max2 - min2) + min2
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

function table.extend(ar1, ar2)
  for _, v in pairs(ar2) do
    table.insert(ar1, v)
  end
end

function table.append(array, value)
    array[#array+1] = value
end

function table.contains(array, target)
    for index, value in ipairs(array) do
        if value == target then
            return true
        end
    end
    return false
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

function deep_get(obj, keys)
  for i, k in pairs(keys) do
    if obj[k] then
      obj = obj[k]
    else
      return nil
    end
  end
  return obj
end

function dict_from_keys_list(keys, value)
  local result = {}
  for _, name in ipairs(keys) do
    result[name] = value
  end
  return result
end



-- Long live the Functional programming!
function iter_len(list)
  return #list
end

function iter_chain(lists)
  -- Like Python's itertools.chain
  -- Example: iter_chain({ {3, 14}, {15, 92} }) = {3, 14, 15, 92}
  local result = {}
  for _, ar in pairs(lists) do
    for _, value in pairs(ar) do
      table.insert(result, value)
    end
  end
  return result
end

function iter_zip(lists)
  -- Example: iter_zip({ {3, 14, 15}, {2, 71, 82} }) = { {3, 2}, {14, 71}, {15, 82} }
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
  -- Example: partial(math.pow, {}, {2})(3) = 9
  -- Example: partial(math.pow, {2}, {})(3) = 8
  local _args_pre = args_pre or {}
  local _args_post = args_post or {}
  return function(...)
    local new_args = iter_chain({_args_pre, {...}, _args_post})
    return func(table.unpack(new_args))
  end
end

--[[
-- Complex example:
local forces = {{name="enemy"}}
local result = func_map(partial(deep_get, {}, {{"name"}}), forces)
serpent.line(result)  -- {"enemy"}
]] --

function func_map(func, args)
  -- Example: func_map(math.floor, {3.141592, 2.818281}) = {3, 2}
  local results = {}
  for _, value in pairs(args) do
    results[#results+1] = func(value)
  end
  return results
end

function func_maps(func, args_arrays)
  -- Example: func_maps(math.pow, {{3, 2}, {2, 3}}) = {9, 8}
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


function beautify_time(seconds)
  -- return util.formattime(seconds * UPS)
  if seconds <= 0 then
    return "0"
  else
    local days = math.floor(seconds /3600 /24)
    seconds = seconds - days *3600 *24
    local hours = math.floor(seconds /3600)
    seconds = seconds - hours *3600
    local mins = math.floor(seconds /60)
    seconds = seconds - mins *60
    local secs = math.floor(seconds)
    local h = string.format("%02.f",hours);
    local m = string.format("%02.f", mins);
    local s = string.format("%02.f", secs);
    if days > 0 then
      return days..":"..h..":"..m..":"..s
    elseif hours > 0 then
      return h..":"..m..":"..s
    elseif mins > 0 then
      return m..":"..s
    else
      return s
    end
  end
end


-- https://lua-api.factorio.com/latest/concepts.html#Color
color_default_dst = {1,1,1}
color_gold    = {255, 220,  50}
color_orange  = {255, 160,  50}
color_red     = {200,  20,  20}
color_ared    = {255,   0,   0, 64}
color_blue    = { 70, 120, 230}
color_purple  = {200,  20, 200}
color_green   = {20,  120,  20}
color_cyan    = {20,  200, 200}
color_ltgrey  = {160, 160, 160}
color_dkgrey  = { 60,  60,  60}

technomagic_resistances = {
  { type = "impact", percent=100 },
  { type = "physical", percent=100 },
  { type = "explosion", percent=100 },
  { type = "laser", percent = 100 },
  { type = "fire", percent = 100 },
  { type = "electric", percent=100 },
  { type = "acid", percent=100 },
  { type = "poison", percent=100 },
}
strong_resistances = {
  { type = "impact", percent=100 },
  { type = "poison", percent=100 },
  { type = "fire", percent=100 },
  { type = "laser", decrease=50, percent=50 },
  { type = "electric", decrease=50, percent=50 },
  { type = "physical", decrease=50, percent=50 },
  { type = "explosion", decrease=200, percent=50 },
  { type = "acid", decrease=50, percent=50 },
}