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
				-- 2.0 items may omit icon_size (defaults to 64), but Deadlock's stacking needs it
				icon_size = data.raw.item["stone"].icon_size or 64
			},
			{
				icon = gangue.icon,
				scale = 0.30,
				icon_size = ore.icon_size or 64
			},
		}
		gangue.icon = nil
		gangue.icon_size = ore.icon_size or 64
	elseif gangue.icons then
		-- for items with multiple icons already
		for i,icon in ipairs(gangue.icons) do
			icon.scale = (icon.scale or 1) * 0.30
			icon.icon_size = 32--ore.icon_size
		end
		table.insert(gangue.icons,1, { icon = data.raw.item["stone"].icon, icon_size = data.raw.item["stone"].icon_size or 64, scale = 0.50 })
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
	
	return gangue_name
end


-- Deadlock's Stacking Beltboxes: make every gangue item stackable.
-- Its API lives in the `deadlock` global, published by that mod's data.lua, and
-- is meant to be called from data-final-fixes so every gangue item exists first.
-- Old versions here called the deprecated `deadlock_stacking.create` straight from
-- data.lua, which crashed whenever we happened to load before Deadlock's own data.lua.
functions.add_deadlock_stacking = function()
	local api = rawget( _G, "deadlock" )
	local legacy = rawget( _G, "deadlock_stacking" )
	
	local add_stack
	if api and api.add_stack then
		add_stack = api.add_stack
	elseif legacy and legacy.create then
		-- forks that only kept the pre-0.16 interface
		add_stack = legacy.create
	else
		log( "Deadlock stacking | API not found, skipping gangue stacks" )
		return
	end
	
	-- "deadlock-stacking-2" is the tech Deadlock unlocks tier-2 stacking with;
	-- passing a tech that does not exist crashes inside their add_stacks_to_tech.
	local target_tech = data.raw.technology["deadlock-stacking-2"] and "deadlock-stacking-2" or nil
	
	-- collect first: add_stack extends data.raw.item, which we are iterating
	local gangue_names = {}
	for item_name, _ in pairs( data.raw.item ) do
		-- ours, and only ours: a gangue item with a matching washing recipe
		if item_name:find( "%-gangue$" ) and data.raw.recipe[ item_name .. "-washing" ]
				and not data.raw.item[ "deadlock-stack-" .. item_name ] then
			table.insert( gangue_names, item_name )
		end
	end
	
	for _, item_name in ipairs( gangue_names ) do
		log( "Deadlock stacking | " .. item_name )
		add_stack( item_name, nil, target_tech, 32 )
	end
	
	-- we run after Deadlock's own data-final-fixes, so redo the deferred pass
	-- that copies stack size / fuel values onto the items we just added
	if api and api.deferred_stacked_item_updates then
		api.deferred_stacked_item_updates()
	end
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
		
		-- Factorio 2.1 replaced recipe `category` with `categories`; one code base serves 2.0 and 2.1
		local base_major, base_minor = string.match(mods["base"], "^(%d+)%.(%d+)")
		if tonumber(base_major) * 100 + tonumber(base_minor) >= 201 then
			washing_recipe.categories = {"crafting-with-fluid"}
		else
			washing_recipe.category = "crafting-with-fluid"
		end
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
