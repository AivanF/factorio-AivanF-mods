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