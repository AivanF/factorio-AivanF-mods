if mods["space-exploration"] then
else
  -- Hide SE-related settings
  data.raw["string-setting"]["af-tls-planets---"].hidden = true
  for name, obj in pairs(data.raw["string-setting"]) do
    if name:find("af-tls-preset-for-", 1, true) then
      obj.hidden = true
    end
  end
end