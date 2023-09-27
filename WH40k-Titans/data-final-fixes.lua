local shared = require("shared")
-- Fix SE procedural updating
data.raw.technology[shared.mod_prefix.."production"].unit.ingredients = {{shared.sp, 1}}

-- Adjust AAI Programmable Vehicles
local obj
for _, titan_type in ipairs(shared.titan_type_list) do
	obj = data.raw[shared.titan_base_type][titan_type.entity.."-0"]
	if obj then
		obj.minable = nil
	end
	obj = data.raw[shared.titan_base_type][titan_type.entity.."-0-_-solid"]
	if obj then
		obj.minable = nil
	end
end
