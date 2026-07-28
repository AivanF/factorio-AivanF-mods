local defines = require("defines")

local functions ={}

functions.build_gangue = function( ore )
	
	local gangue_name = ore.name .. "-gangue"
	
	if data.raw.item[gangue_name] then
		log( "Gangue prep | gangue already exists ? " .. gangue_name )
		return gangue_name
	end
	
	-- else
	log( "Gangue prep | creating item " .. gangue_name )
	
	local gangue = table.deepcopy( ore )
	
	gangue.name = gangue_name
	
	-- make proper gangue icons by layering it with stone icon
	
	if gangue.icon then
		-- for item with single icon
		gangue.icons = {
			{
				icon = data.raw.item["stone"].icon,
				scale = 0.50,
				icon_size = data.raw.item["stone"].icon_size
			},
			{
				icon = gangue.icon,
				scale = 0.30,
				icon_size = ore.icon_size
			},
		}
		gangue.icon = nil
		gangue.icon_size = ore.icon_size
	elseif gangue.icons then
		-- for items with multiple icons already
		for i,icon in ipairs(gangue.icons) do
			icon.scale = (icon.scale or 1) * 0.30
			icon.icon_size = 32--ore.icon_size
		end
		table.insert(gangue.icons,1, { icon = data.raw.item["stone"].icon, icon_size = data.raw.item["stone"].icon_size, scale = 0.50 })
		gangue.icon_size = 32--ore.icon_size
	else
		error("Iconless item found, this is not normal.")
	end
	
	gangue.localised_name = {
	  "item-name.Fluidless_Mining_and_Ore_Washing-gangue",
	  {"item-name." .. ore.name}
	}
	
	if gangue.picture then
		gangue.picture = nil
	end
	
	if gangue.pictures then
		gangue.pictures = nil
	end
	
	data:extend({gangue})
	
	if mods["deadlock-beltboxes-loaders"] then
		-- add stackable
		deadlock_stacking.create( gangue_name, nil, "deadlock-stacking-2", 32)
	end
	
	return gangue_name
end
	
functions.build_washing_recipe = function( ore, fluid, fluid_amount )

	local fluid_amount_multiplier = settings.startup["FluidlessMiningAndOreWashing-fluidmultiplier"].value
	
	local washing_fluid = fluid or "water" -- bacause fuck you
	local washing_fluid_amount = fluid_amount
	local washing_result = ore.name
	local washing_recipe_name = ore.name .. "-gangue" .. "-washing"
	
	log( "Washing recipe " .. washing_recipe_name )
	
	if not data.raw.recipe[ washing_recipe_name ] then
		-- build recipe
		local washing_recipe = {
			type = "recipe",
			category = "crafting-with-fluid",
			enabled = true,
			name = washing_recipe_name,
			localised_name = {
				"recipe-name.Fluidless_Mining_and_Ore_Washing-washing",
				{"item-name." .. ore.name}
			},
			ingredients = {
				{
					type = "item",
					name = ore.name .. "-gangue",
					amount = 10
				},
				{
					type = "fluid",
					name = washing_fluid,
					amount = washing_fluid_amount * fluid_amount_multiplier
				}
			},
			results = {
				{
					type = "item",
					name = washing_result,
					amount = 10
				}
			}
		}
		
		data:extend({washing_recipe})
		
	else
		-- just update the recipe
		data.raw.recipe[ washing_recipe_name ].ingredients = {
			{
				type = "item",
				name = ore.name .. "-gangue",
				amount = 10
			},
			{
				type = "fluid",
				name = washing_fluid,
				amount = washing_fluid_amount * fluid_amount_multiplier
			}
		}
	end
	
end

return functions
