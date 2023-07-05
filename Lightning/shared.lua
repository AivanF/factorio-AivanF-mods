local shared = {}

function math.clamp(x, min, max)
    return math.max(math.min(x, max), min)
end

function shared.ShuffleInPlace(t)
    for i = #t, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
end

function shared.spairs(t, order)
    -- From here: https://stackoverflow.com/a/15706820/5308802

    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function shared.chunk_is_border(surface, chunk, dst)
  if dst == nil then dst = 3 end
  return (
    false
    or not surface.is_chunk_generated({chunk.x+dst, chunk.y})
    or not surface.is_chunk_generated({chunk.x, chunk.y+dst})
    or not surface.is_chunk_generated({chunk.x-dst, chunk.y})
    or not surface.is_chunk_generated({chunk.x, chunk.y-dst})
  )
end

function shared.Iter2Array(...)
  local arr = {}
  for v in ... do
    arr[#arr + 1] = v
  end
  return arr
end

shared.max_catch_radius = 48
shared.min_catch_radius = 8
return shared