local shared = require("shared")

if settings.startup["vehitel-improve-car"].value then
  data.raw["car"]["car"].allow_remote_driving = true
  if data.raw["car"]["car"].equipment_grid == nil then
    data.raw["car"]["car"].equipment_grid = data.raw["car"]["tank"].equipment_grid
  end
end

log(shared.mod_name.." adding recipes to: "..serpent.line{
  tech1=vehitel_data.tech1, tech2=vehitel_data.tech2, tech3=vehitel_data.tech3
})
table.insert(data.raw.technology[vehitel_data.tech1].effects, {type="unlock-recipe", recipe=shared.device1})
table.insert(data.raw.technology[vehitel_data.tech2].effects, {type="unlock-recipe", recipe=shared.device2})
if vehitel_data.enable_device3 then
  table.insert(data.raw.technology[vehitel_data.tech3].effects, {type="unlock-recipe", recipe=shared.device3})
end
