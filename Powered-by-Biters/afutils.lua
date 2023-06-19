
function getKey(obj)
    local keys = {}
    local n = 0

    for k, v in pairs(obj) do
      n = n + 1
      keys[n] = k
    end
    return keys
end

function deepcopy(obj)
    if type(obj) ~= 'table' then return obj end
    local res = setmetatable({}, getmetatable(obj))
    for k, v in pairs(obj) do res[deepcopy(k)] = deepcopy(v) end
    return res
end
