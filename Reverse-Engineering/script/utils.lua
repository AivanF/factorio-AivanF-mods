require("__core__.lualib.util")

function istable(t) return type(t) == 'table' end

function islist(a)
  return not not a[1]
end

function deep_merge(a, b, over)
  for k, v in pairs(b) do
    if istable(v) and not islist(v) and istable(a[k]) then
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

function shuffle(t)
  for i = #t, 2, -1 do
    local j = math.random(i)
    t[i], t[j] = t[j], t[i]
  end
end
