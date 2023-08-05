if mods["space-exploration"] then
  -- For slightly better performance
  data.raw["double-setting"]["af-tsl-rate-cf"].default_value = 1/2
  data.raw["double-setting"]["af-tsl-energy-cf"].default_value = 2
else
  -- Hide SE-related settings
  data.raw["string-setting"]["af-tsl-planets---"].hidden = true
  for name, obj in pairs(data.raw["string-setting"]) do
    if name:find("af-tsl-preset-for-", 1, true) then
      obj.hidden = true
    end
  end
end