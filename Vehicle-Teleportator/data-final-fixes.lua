local shared = require("shared")

if settings.startup["vehitel-improve-car"].value then
  data.raw["car"]["car"].allow_remote_driving = true
  if data.raw["car"]["car"].equipment_grid == nil then
    data.raw["car"]["car"].equipment_grid = data.raw["car"]["tank"].equipment_grid
  end
end
