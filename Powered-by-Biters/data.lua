--local sounds = require ("prototypes.entity.sounds")
require "afutils"

local floor,ceil,sqrt = math.floor,math.ceil,math.sqrt
local raw_stacksize = 0
local element, num

biter_bites_fish_capsules = {}


local function make_sticker(name, heal, ticks_duration, speed_bonus)
	local sticker = {
		type = "sticker", name = name,
		flags = {"not-on-map"},
		duration_in_ticks = ticks_duration,
	}
	if heal and heal ~=0 then
		sticker.damage_interval = 2
		sticker.damage_per_tick = { amount = heal * -2 / ticks_duration, type = (heal>0) and "physical" or "poison" }
	end
	if speed_bonus and speed_bonus~=0 then sticker.target_movement_modifier = 1+speed_bonus end
	return sticker
end

local function make_potion(name,icon,  										instaheal, heal, duration, speed, cooldown)
	duration = (duration or 1) * 60
	if cooldown then
		cooldown = cooldown * 60
	else
		cooldown = duration
	end
	
	local effects = {}

			--[[
                {
                  type = "play-sound",
                  sound = sounds.eat_fish
                }
				--]]

	
	if instaheal and instaheal ~=0 then 
		effects[#effects+1] = { type = "damage", damage = {type = "physical", amount = -instaheal}}
	end
	
	if heal and heal ~=0 or speed and speed~=0 then
		local stickername = name.."-sticker"
		local sticker = make_sticker(stickername, heal, duration, speed)
		sticker = make_sticker(stickername, heal, duration, speed)
		effects[#effects+1] = { type = "create-sticker", sticker = stickername, show_in_tooltip = true }
		data:extend{sticker}
	end

	
	local item =   {type = "capsule",name = name,
		icon = icon, icon_size = 32, icon_mipmaps = 1,
		subgroup = "raw-resource",order = "h[raw-fish]",
		stack_size = raw_stacksize,
		capsule_action =
		{
		  type = "use-on-self",
		  attack_parameters =
		  {
			type = "projectile",
			activation_type = "consume",
			ammo_category = "capsule",
			cooldown = cooldown,
			range = 0,
			ammo_type =
			{
			  category = "capsule",
			  target_type = "position",
			  action =
			  {
				type = "direct",
				action_delivery =
				{
				  type = "instant",
				  target_effects = effects
				}
			  }
			}
		  }
		}
	}

data:extend{item}
end

local fisheal,fishes = 0,0
--naively only checks the first tier of effects, but it works for vanilla and should work for any modded items that aren't super fancy, which we should probably leave alone anyway
local function fish_capsule(fish,cap,count)
	if not cap then return false end
	local proto,ele,cool = data.raw.capsule[cap]
	local heal,hot,effects,sticker = 0,0
	if proto and proto.capsule_action.type=="use-on-self" then
		ele=proto.capsule_action.attack_parameters
		if ele and ele.type=="projectile" then
			cool = ele.cooldown
			ele = ele.ammo_type
			if ele and ele.action and ele.action.type=="direct" then
				ele = ele.action.action_delivery
				effects=ele.target_effects
				if ele and ele.type=="instant" and effects then
					for _,ef in pairs(effects) do
						if ef.type=="damage" then
							ele = ef.damage.amount or 0
							heal = heal + ele
						elseif ef.type=="create-sticker" then
							ele = data.raw.sticker[ef.sticker]
							if ele and ele.damage_interval then
								hot = hot + ele.damage_per_tick.amount*ele.duration_in_ticks/ele.damage_interval
							end
						elseif ef.type=="" then
							--nuffin
						end
					end
					
					--finished iterating effects
					if heal+hot < 0 then
						biter_bites_fish_capsules[fish]=count
						fisheal = fisheal + heal + hot
						fishes = fishes+1
						
						if hot==0 then
							sticker=fish.."-sticker"
							while data.raw.sticker[sticker] do
								hot=hot+1
								sticker = fish.."-sticker"..(hot+1)
							end
							hot = 0
							for _,ef in pairs(effects) do
								if ef.type=="damage" then
									heal=ef.damage.amount
									if heal<=-2 then
										ele=ceil(heal/2)
										ef.damage.amount = heal - ele
										hot = hot + ele
									end
								end
							end
							data:extend{make_sticker(sticker,-hot,cool*2)}
							effects[#effects+1]={type="create-sticker",sticker=sticker,show_in_tooltip=true}
						end

						if proto.stack_size>raw_stacksize then raw_stacksize=proto.stack_size end

					end
				end
			end
		end
	end
end

for fish,proto in pairs(data.raw.fish) do
	element = proto.minable
	if element and proto.autoplace then
		if element.result then
			fish_capsule(fish,element.result, element.count)
		elseif element.results then
			for _,r in pairs(element.results) do
				fish_capsule(fish,r.name or r[1],r.count or r[1] or 1)
			end
		end
	end
end

fisheal=-fisheal/fishes/16	--normalize with vanilla; fish=16
function prettynum(num,inc)
	num=num*fisheal
	inc = inc or 5
	return num<inc and inc or floor(num/inc+.5)*inc
end

make_potion("raw-meat","__Powered-by-Biters__/graphics/raw.png",			prettynum(15),	prettynum(12),	2,	-0.15, 1.5)	--	-.15 move/use, (135 on use); 50//s+30/s=80/s		(-.3 = -2.7 tiles)
make_potion("roast-meat","__Powered-by-Biters__/graphics/roast.png",		prettynum(12),	prettynum(30),	1.5,0.10)		--	0.00 move/use, (210 on use); 40//s + 100/s= 140/s	(.15 = 1.2 tiles)	
make_potion("steamed-bun","__Powered-by-Biters__/graphics/steamed-bun.png",		prettynum(20),	prettynum(60),	3,	0.25, 2)	--	move/use, ( on use); 50//s + 100/s=  150/s			(.25 = (2 tiles/s) )


data.raw.capsule["steamed-bun"].icon_size=64


for _,c in pairs(data.raw.character) do
	c.ticks_to_stay_in_combat=c.ticks_to_stay_in_combat+600
end

data:extend{
  {
  	type = "recipe",
  	name = "cook-biter-meat",
    category = "smelting",
    energy_required = 3,
    ingredients = {{ "raw-meat", 6}},
    result = "roast-meat",
  },
  {
  	type = "recipe",
  	name = "steamed-bun",
    category = "chemistry",
    energy_required = 5,
    ingredients = {
			{ "raw-meat", 5},
			{ "raw-fish", 2},
			{ "wood", 1},
			{ type="fluid", name="steam", amount=20 },
		},
    result = "steamed-bun",
	result_count = 5,
	enabled=false,
	
  },
}

table.insert(data.raw.technology["oil-processing"].effects, {
   type = "unlock-recipe",
   recipe = "steamed-bun",
})

local to_oil = deepcopy(data.raw.recipe["coal-liquefaction"])
to_oil.name = "meet-to-oil"
to_oil.icon = "__Powered-by-Biters__/graphics/meet-to-oil.png"
to_oil.icon_size = 64
to_oil.category = "chemistry"
to_oil.order = to_oil.order
to_oil.ingredients = {{"raw-meat", 15}}
to_oil.energy_required = 3
to_oil.results = {{
	type = "fluid",
	name = "crude-oil",
	amount = 20,
}}
data.raw.recipe[to_oil.name] = to_oil

table.insert(data.raw.technology["advanced-oil-processing"].effects, {
	type = "unlock-recipe",
	recipe = to_oil.name,
})
