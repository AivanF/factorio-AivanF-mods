local shared = require("shared")

require("prototypes/fixes-resist")

--[[
		Fix SE procedural updating
		Although `se_prodecural_tech_exclusions` works,
		there are other rude editions from prototypes/phase-3/technology.lua:
data_util.tech_add_ingredients_with_prerequisites("advanced-electronics-2", {data_util.mod_prefix .. "rocket-science-pack"})
data_util.tech_add_ingredients_with_prerequisites("industrial-furnace", {"space-science-pack"})

	So, let's clean up added science packs!
]]--
local dirty
for name, technology in pairs(data.raw.technology) do
	dirty = false
	for _, ingredient in pairs(technology.unit.ingredients) do
    if ingredient[1] == shared.sp or ingredient.name == shared.sp then
      dirty = true
    end
  end
  if dirty then
		technology.unit.ingredients = {{shared.sp, 1}}
	end
end


local function remove_recipe_effect(effects, name)
	for i = #effects, 1, -1 do
		if effects[i].type == "unlock-recipe" and effects[i].recipe == name then
			table.remove(effects, i)
		end
	end
end

-- Adjust AAI Programmable Vehicles
local obj
for _, titan_type in ipairs(shared.titan_type_list) do
	-- error(shared.mod_prefix..math.round(titan_type.class/10).."-class")
	local tech = data.raw.technology[shared.mod_prefix..math.floor(titan_type.class/10).."-class"]
	obj = data.raw[shared.titan_base_type][titan_type.entity.."-0"]
	if obj then
		obj.minable = nil
	end
	obj = data.raw[shared.titan_base_type][titan_type.entity.."-0-_-solid"]
	if obj then
		obj.minable = nil
	end
	obj = data.raw.recipe[titan_type.entity.."-0"]
	if obj then
		obj.hidden = true
		remove_recipe_effect(tech.effects, obj.name)
	end
	obj = data.raw.recipe[titan_type.entity.."-0-reverse"]
	if obj then
		obj.hidden = true
		remove_recipe_effect(tech.effects, obj.name)
	end
end


-- Allow turret equipment items be placed into Titans
for name, obj in pairs(data.raw["active-defense-equipment"]) do
  table.append(obj.categories, shared.equip_cat)
end


-- Updates after overhauls
-- Supplier equipment categories
local wanted_categories = {
  "aircraft", "aircraft-equipment", "armor-weapons",
  "universal-equipment", "vehicle-motor", "vehicle-robot-interaction-equipment",
}
local aircraft_grid = data.raw["equipment-grid"][shared.mod_prefix.."aircraft"]
aircraft_grid.equipment_categories = {}
for _, name in pairs(wanted_categories) do
	if data.raw["equipment-category"][name] then
		table.append(aircraft_grid.equipment_categories, name)
	end
end

if not mods[shared.K2] then
	table.append(aircraft_grid.equipment_categories, "armor")
end

-- Supplier can use any fuel you want
local titan_supplier = data.raw.car[shared.aircraft_supplier]
titan_supplier.burner.fuel_categories = {"chemical"}
if mods[shared.AIND] then
  table.append(titan_supplier.burner.fuel_categories, "processed-chemical")
end
if mods[shared.K2] then
  table.append(titan_supplier.burner.fuel_categories, "vehicle-fuel")
  table.append(titan_supplier.burner.fuel_categories, "nuclear-fuel")
  table.append(titan_supplier.burner.fuel_categories, "fusion-fuel")
  table.append(titan_supplier.burner.fuel_categories, "antimatter-fuel")
end
