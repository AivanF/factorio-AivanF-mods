local shared = require("shared")

local wanted_categories = {
  "aircraft", "aircraft-equipment", "armor-weapons",
  "universal-equipment", "vehicle-motor", "vehicle-robot-interaction-equipment",
}
local space_cruiser_grid = data.raw["equipment-grid"][shared.space_cruiser]
space_cruiser_grid.equipment_categories = {}
for _, name in pairs(wanted_categories) do
	if data.raw["equipment-category"][name] then
		table.insert(space_cruiser_grid.equipment_categories, name)
	end
end

if not mods[shared.K2] then
	table.insert(space_cruiser_grid.equipment_categories, "armor")
end

local titan_supplier = data.raw.car[shared.space_cruiser]
titan_supplier.burner.fuel_categories = {"nuclear"}
if mods[shared.K2] then
	titan_supplier.burner.fuel_categories = {"nuclear-fuel"}
	-- TODO: make only fusion for late-game mode/tier
  table.insert(titan_supplier.burner.fuel_categories, "fusion-fuel")
	-- TODO: make only antimatter for end-game mode/tier
  table.insert(titan_supplier.burner.fuel_categories, "antimatter-fuel")
end
