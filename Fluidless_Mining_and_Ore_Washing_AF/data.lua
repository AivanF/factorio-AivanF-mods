--------------
-- data.lua --
--------------
--
-- "Gangue"
-- In mining, gangue (/ɡæŋ/) is the commercially worthless material that surrounds, or is closely mixed with, a wanted mineral in an ore deposit.
--
--
--
-- Scan for all possible ores and build prototypes for corresponding intermediate items for later washing.
--
--
---

local defines = require("defines")
local functions = require("functions")

for ore_name,ore in pairs(data.raw.resource) do
	
	if ore.minable.fluid_amount ~= nil or ore.minable.required_fluid ~= nil then
		log( "Fluidless | pre  dump from data ****NAME" .. ore_name .. " ; ****AMOUNT" .. serpent.block( ore.minable.fluid_amount ) .. " ; ****FLUID" .. serpent.block( ore.minable.required_fluid ) .. " ; ****RESULT" .. serpent.dump( ore.minable.result) .. " ; ****RESULTS" .. serpent.dump( ore.minable.results ) )
		
		if ore.minable.fluid_amount ~= nil and ore.minable.required_fluid ~= nil then
			
			-- build gangue item and washing recipe
			if ore.minable.result ~= nil then
				-- single mining result
				
				local gangue_name = functions.build_gangue( data.raw.item[ ore.minable.result ] )
				functions.build_washing_recipe( data.raw.item[ ore.minable.result ], ore.minable.required_fluid, ore.minable.fluid_amount )
				
				--ore.minable.result = gangue_name
				--ore.minable.fluid_amount = nil
				--ore.minable.required_fluid = nil
			
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
				
				--ore.minable.results = new_results_table
				--ore.minable.fluid_amount = nil
				--ore.minable.required_fluid = nil
			
			else
				log( "Stupid resource detected, unable to determine mining results: " .. ore_name .. " " .. serpent.dump( ore.minable.result or ore.minable.results ) )
			end
			
		end
		
		log( "Fluidless | post dump from data ****NAME" .. ore_name .. " ; ****AMOUNT" .. serpent.block( ore.minable.fluid_amount ) .. " ; ****FLUID" .. serpent.block( ore.minable.required_fluid ) .. " ; ****RESULT" .. serpent.dump( ore.minable.result) .. " ; ****RESULTS" .. serpent.dump( ore.minable.results ) )
	end
end