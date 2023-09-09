local shared = require("shared")

if aai_vehicle_exclusions then
  for _, info in pairs(shared.titan_type_list) do
    table.insert(aai_vehicle_exclusions, info.entity)
  end
end
