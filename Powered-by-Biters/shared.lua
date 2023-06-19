mod_path = "__Powered-by-Biters__"

sounds_eat_fish = {
  {
    filename = "__base__/sound/eat.ogg",
    volume = 0.6
  },
  {
    filename = "__base__/sound/eat-1.ogg",
    volume = 0.6
  },
  {
    filename = "__base__/sound/eat-2.ogg",
    volume = 0.6
  },
  {
    filename = "__base__/sound/eat-3.ogg",
    volume = 0.6
  },
  {
    filename = "__base__/sound/eat-4.ogg",
    volume = 0.6
  }
}

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
