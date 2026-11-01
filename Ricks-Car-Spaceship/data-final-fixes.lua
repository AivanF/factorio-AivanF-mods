local shared = require("shared")

local wanted_categories = {
  "aircraft", "aircraft-equipment", "armor-weapons",
  "universal-equipment", "vehicle-motor", "vehicle-robot-interaction-equipment",
  "kr-vehicle", "kr-vehicle-motor", "kr-vehicle-roboport",
}
local space_cruiser_grid = data.raw["equipment-grid"][shared.space_cruiser]
space_cruiser_grid.equipment_categories = {}
for _, name in pairs(wanted_categories) do
	if data.raw["equipment-category"][name] then
		table.insert(space_cruiser_grid.equipment_categories, name)
	end
end

-- An equipment grid must have at least one category
if not mods[shared.K2] or #space_cruiser_grid.equipment_categories == 0 then
	table.insert(space_cruiser_grid.equipment_categories, "armor")
end

local titan_supplier = data.raw.car[shared.space_cruiser]
titan_supplier.energy_source.fuel_categories = {"nuclear"}
if mods[shared.K2] then
	-- TODO: make only fusion for late-game mode/tier
  table.insert(titan_supplier.energy_source.fuel_categories, "kr-fusion-fuel")
	-- TODO: make only antimatter for end-game mode/tier
  table.insert(titan_supplier.energy_source.fuel_categories, "kr-antimatter-fuel")
end
