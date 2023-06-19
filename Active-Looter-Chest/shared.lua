
mod_name = "Active-Looter-Chest"
mod_path = "__"..mod_name.."__"
basic_chest_name = "af-alc-basic-chest"
signals_chest_name = "af-alc-signals-chest"
logistic_chest_name = "af-alc-logistic-chest"

function intify(bool)
  return bool and 1 or 0
end

function deepcopy(obj)
    if type(obj) ~= "table" then return obj end
    local res = setmetatable({}, getmetatable(obj))
    for k, v in pairs(obj) do res[deepcopy(k)] = deepcopy(v) end
    return res
end

function is_value_in_list(value, list)
  for i, v in pairs(list) do
    if v == value then
      return true
    end
  end
  return false
end
