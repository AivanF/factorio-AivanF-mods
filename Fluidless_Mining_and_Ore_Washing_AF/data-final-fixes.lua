----------------------
-- data-final-fixes.lua --
----------------------
--
--
--
-- Build washing recipes, and replace mining result with gangue.
--
--
---

local defines = require("defines")
local functions = require("functions")

for ore_name,ore in pairs(data.raw.resource) do
	
	if ore.minable.fluid_amount ~= nil or ore.minable.required_fluid ~= nil then
		log( "Fluidless | pre  dump from final ****NAME" .. ore_name .. " ; ****AMOUNT" .. serpent.block( ore.minable.fluid_amount ) .. " ; ****FLUID" .. serpent.block( ore.minable.required_fluid ) .. " ; ****RESULT" .. serpent.dump( ore.minable.result) .. " ; ****RESULTS" .. serpent.dump( ore.minable.results ) )
		
		if ore.minable.fluid_amount ~= nil and ore.minable.required_fluid ~= nil then
			
			-- build gangue item and washing recipe
			if ore.minable.result ~= nil then
				-- single mining result
				
				local gangue_name = functions.build_gangue( data.raw.item[ ore.minable.result ] )
				functions.build_washing_recipe( data.raw.item[ ore.minable.result ], ore.minable.required_fluid, ore.minable.fluid_amount )
				
				ore.minable.result = gangue_name
				ore.minable.fluid_amount = nil
				ore.minable.required_fluid = nil
			
			elseif ore.minable.results ~= nil then
				-- multiple mining results
				
				local new_results_table = {}
				for _,result in pairs( ore.minable.results ) do
					local gangue_name = functions.build_gangue( data.raw.item[ result.name ] )
					local new_result = table.deepcopy( result )
					new_result.name = gangue_name
					table.insert( new_results_table, 1, new_result )
					functions.build_washing_recipe( data.raw.item[ result.name ], ore.minable.required_fluid, ore.minable.fluid_amount )
				end
				
				ore.minable.results = new_results_table
				ore.minable.fluid_amount = nil
				ore.minable.required_fluid = nil
			
			else
				log( "Stupid resource detected, unable to determine mining results: " .. ore_name .. " " .. serpent.dump( ore.minable.result or ore.minable.results ) )
			end
			
		else
		
			-- either only fluid amount or fluid type is set, check if gangue recipes exist, and if so, just reset those values to nil, to correct them
			
			if data.raw.item[ore.name .. "-gangue"] and data.raw.recipe[ore.name .. "-gangue" .. "-washing"] then
				ore.minable.fluid_amount = nil
				ore.minable.required_fluid = nil
			end
		
		end
		
		log( "Fluidless | pre  dump from final ****NAME" .. ore_name .. " ; ****AMOUNT" .. serpent.block( ore.minable.fluid_amount ) .. " ; ****FLUID" .. serpent.block( ore.minable.required_fluid ) .. " ; ****RESULT" .. serpent.dump( ore.minable.result) .. " ; ****RESULTS" .. serpent.dump( ore.minable.results ) )
	end
	
end

for ore_name,ore in pairs(data.raw.resource) do
	if ore.minable.fluid_amount ~= nil or ore.minable.required_fluid ~= nil then
		log( "Stubborn resource, stuck with 0 mining fluid " .. ore.name .. "; " .. serpent.block( ore.minable ) )
		
		ore.minable.fluid_amount = nil
		ore.minable.required_fluid = nil
	end
end

-- allow productivity

local washing_recipes = {};

for recipe_name, recipe in pairs(data.raw.recipe) do
	if recipe_name:find("%-gangue%-washing") then
		table.insert(washing_recipes, recipe_name)
	end
end

for k, v in pairs(data.raw.module) do
	if v.name:find("productivity%-module") and v.limitation then
		for _, washing_recipe in ipairs(washing_recipes) do
			if data.raw["recipe"][washing_recipe] then
				table.insert(v.limitation, washing_recipe)
			end
		end
	end
end


-- Deadlock's Stacking Beltboxes support, once every gangue item exists
functions.add_deadlock_stacking()
