local shared = require("shared")
-- Fix SE procedural updating
data.raw.technology[shared.mod_prefix.."production"].unit.ingredients = {{shared.sp, 1}}

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
