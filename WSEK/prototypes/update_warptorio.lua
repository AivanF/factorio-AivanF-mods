require("utils")

-- Allow space building on the warp platform and floors
data.raw.tile["warp-tile-concrete"].collision_mask = {}
data.raw.tile["hazard-concrete-left"].collision_mask = {"ground-tile"}
-- TODO: prevent SE from replacing buildings with ground versions without space recipes


----- Reactor start -----

data.raw.technology["warptorio-reactor-1"].prerequisites = {"kr-automation-core"}
data.raw.technology["warptorio-reactor-1"].unit = {
	count = 50, time = 10, ingredients = { {"basic-tech-card",1} },}

data.raw.technology["warptorio-reactor-2"].prerequisites = {"warptorio-reactor-1", "automation-science-pack"}
data.raw.technology["warptorio-reactor-2"].unit = {
	count = 50, time = 10, ingredients = {
		{"basic-tech-card",1}, {"automation-science-pack",1},
	}}

data.raw.technology["warptorio-reactor-3"].prerequisites = {"warptorio-reactor-2", "logistic-science-pack"}
data.raw.technology["warptorio-reactor-3"].unit = {
	count = 50, time = 10, ingredients = {
		{"basic-tech-card",1}, {"automation-science-pack",1}, {"logistic-science-pack",1},
	}}

data.raw.technology["warptorio-reactor-4"].prerequisites = {"warptorio-reactor-3", "military-science-pack"}
data.raw.technology["warptorio-reactor-4"].unit = {
	count = 50, time = 10, ingredients = {
		{"automation-science-pack",1}, {"logistic-science-pack",1}, {"military-science-pack",1},
	}}

data.raw.technology["warptorio-reactor-5"].prerequisites = {"warptorio-reactor-4", "chemical-science-pack"}
data.raw.technology["warptorio-reactor-5"].unit = {
	count = 50, time = 10, ingredients = {
		{"automation-science-pack",1}, {"logistic-science-pack",1},
		{"military-science-pack",1}, {"chemical-science-pack",1},
	}}

data.raw.technology["warptorio-reactor-6"].prerequisites = {"warptorio-reactor-5"}
data.raw.technology["warptorio-reactor-6"].unit = {
	count = 100, time = 10, ingredients = {
		{"automation-science-pack",1}, {"logistic-science-pack",1},
		{"military-science-pack",1}, {"chemical-science-pack",1},
	}}

data.raw.technology["warptorio-reactor-7"].prerequisites = {"warptorio-reactor-6", "se-rocket-science-pack"}
data.raw.technology["warptorio-reactor-7"].unit = {
	count = 100, time = 10, ingredients = {
		{"automation-science-pack",1}, {"logistic-science-pack",1},
		{"military-science-pack",1}, {"chemical-science-pack",1},
		{"se-rocket-science-pack",1},
	}}

data.raw.technology["warptorio-reactor-8"].prerequisites = {"warptorio-reactor-7", "space-science-pack"}
data.raw.technology["warptorio-reactor-8"].unit = {
	count = 100, time = 10, ingredients = {
		{"automation-science-pack",1}, {"logistic-science-pack",1},
		{"military-science-pack",1}, {"chemical-science-pack",1},
		{"se-rocket-science-pack",1}, {"space-science-pack",1},
		-- {"production-science-pack",1}, {"utility-science-pack",1},
	}}

----- Reactor end -----



----- Planet Teleporter start -----

data.raw.technology["warptorio-teleporter-portal"].prerequisites = {"warptorio-reactor-1", "warptorio-factory-0"}
data.raw.technology["warptorio-teleporter-portal"].unit = {
	count = 30, time = 20, ingredients = data.raw.technology["warptorio-reactor-1"].unit.ingredients}

data.raw.technology["warptorio-teleporter-1"].prerequisites = {"warptorio-teleporter-portal", "warptorio-reactor-2"}
data.raw.technology["warptorio-teleporter-1"].unit = {
	count = 30, time = 20, ingredients = data.raw.technology["warptorio-reactor-2"].unit.ingredients}

data.raw.technology["warptorio-teleporter-2"].prerequisites = {"warptorio-teleporter-1", "warptorio-reactor-3", "electric-energy-distribution-1"}
data.raw.technology["warptorio-teleporter-2"].unit = {
	count = 30, time = 20, ingredients = data.raw.technology["warptorio-reactor-3"].unit.ingredients}

data.raw.technology["warptorio-teleporter-3"].prerequisites = {"warptorio-teleporter-2", "warptorio-reactor-4", "electric-energy-distribution-2"}
data.raw.technology["warptorio-teleporter-3"].unit = {
	count = 30, time = 20, ingredients = data.raw.technology["warptorio-reactor-4"].unit.ingredients}

data.raw.technology["warptorio-teleporter-4"].prerequisites = {"warptorio-teleporter-3", "warptorio-reactor-5"}
data.raw.technology["warptorio-teleporter-4"].unit = {
	count = 30, time = 20, ingredients = data.raw.technology["warptorio-reactor-5"].unit.ingredients}

data.raw.technology["warptorio-teleporter-5"].prerequisites = {"warptorio-teleporter-4", "warptorio-reactor-6"}
data.raw.technology["warptorio-teleporter-5"].unit = {
	count = 30, time = 20, ingredients = data.raw.technology["warptorio-reactor-6"].unit.ingredients}

----- Planet Teleporter end -----



----- Logistics start -----

data.raw.technology["warptorio-logistics-1"].prerequisites = {"warptorio-reactor-1", "warptorio-factory-0", "basic-logistics"}
data.raw.technology["warptorio-logistics-1"].unit = {
	count = 100, time = 20, ingredients = data.raw.technology["warptorio-reactor-1"].unit.ingredients}

data.raw.technology["warptorio-logistics-2"].prerequisites = {"warptorio-logistics-1", "warptorio-reactor-3", "logistics"}
data.raw.technology["warptorio-logistics-2"].unit = {
	count = 200, time = 20, ingredients = data.raw.technology["warptorio-reactor-3"].unit.ingredients}

data.raw.technology["warptorio-logistics-3"].prerequisites = {"warptorio-logistics-2", "warptorio-reactor-5", "logistics-2"}
data.raw.technology["warptorio-logistics-3"].unit = {
	count = 300, time = 20, ingredients = data.raw.technology["warptorio-reactor-5"].unit.ingredients}

data.raw.technology["warptorio-logistics-4"].prerequisites = {"warptorio-logistics-3", "warptorio-reactor-7", "logistics-3", "logistic-system"}
data.raw.technology["warptorio-logistics-4"].unit = {
	count = 400, time = 20, ingredients = data.raw.technology["warptorio-reactor-7"].unit.ingredients}

data.raw.technology["warptorio-dualloader-1"].prerequisites = {"warptorio-logistics-1"}
data.raw.technology["warptorio-dualloader-1"].unit = {
	count = 1000, time = 10, ingredients = data.raw.technology["warptorio-reactor-2"].unit.ingredients}

data.raw.technology["warptorio-triloader"].prerequisites = {"warptorio-dualloader-1", "warptorio-reactor-4"}
data.raw.technology["warptorio-triloader"].unit = {
	count = 3000, time = 10, ingredients = data.raw.technology["warptorio-reactor-4"].unit.ingredients}

----- Logistics end -----



----- Additions start -----

data.raw.technology["warptorio-homeworld"].prerequisites = {"warptorio-reactor-8"}
data.raw.technology["warptorio-homeworld"].unit = {
	count = 100, time = 30, ingredients = {
		{"space-science-pack",1}, {"production-science-pack",1}, {"utility-science-pack",1},
	}}

-- TODO: warptorio-alt-combinator

-- TODO: warptorio-beacon-
-- TODO: warptorio-bridgesize-

-- TODO: warptorio-accumulator

-- TODO: warptorio-rail-se/ne/sw/nw

-- TODO: warptorio-turret-ne/se/nw/sw
-- TODO: warptorio-factory-s/n/e/w Giga Floor
-- TODO: warptorio-boiler-s/n/e/w Giga Floor
-- TODO: warptorio-boiler-water-1/3  -- make it more expensive!!

-- TODO: warptorio-toolbar (spacetime)
-- TODO: warptorio-warpport (spacetime)
-- TODO: warptorio-warploader (spacetime)

----- Additions end -----



----- Character & General Skills start -----

-- ToolBelt
data.raw.technology["warptorio-toolbelt-1"].prerequisites = {"warptorio-reactor-1"}
data.raw.technology["warptorio-toolbelt-1"].unit = {
	count = 20, time = 30, ingredients = data.raw.technology["warptorio-reactor-1"].unit.ingredients}

data.raw.technology["warptorio-toolbelt-2"].prerequisites = {"warptorio-toolbelt-1", "warptorio-reactor-2"}
data.raw.technology["warptorio-toolbelt-2"].unit = {
	count = 50, time = 30, ingredients = data.raw.technology["warptorio-reactor-2"].unit.ingredients}

data.raw.technology["warptorio-toolbelt-3"].prerequisites = {"warptorio-toolbelt-2", "warptorio-reactor-3", "toolbelt"}
data.raw.technology["warptorio-toolbelt-3"].unit = {
	count = 75, time = 30, ingredients = data.raw.technology["warptorio-reactor-3"].unit.ingredients}

data.raw.technology["warptorio-toolbelt-4"].prerequisites = {"warptorio-toolbelt-3", "warptorio-reactor-4"}
data.raw.technology["warptorio-toolbelt-4"].unit = {
	count = 100, time = 30, ingredients = data.raw.technology["warptorio-reactor-4"].unit.ingredients}

data.raw.technology["warptorio-toolbelt-5"].prerequisites = {"warptorio-toolbelt-4", "warptorio-reactor-5"}
data.raw.technology["warptorio-toolbelt-5"].unit = {
	count = 150, time = 30, ingredients = data.raw.technology["warptorio-reactor-5"].unit.ingredients}

-- Reach distance
data.raw.technology["warptorio-reach-1"].prerequisites = {"warptorio-reactor-1"}
data.raw.technology["warptorio-reach-1"].unit = {
	count = 20, time = 30, ingredients = data.raw.technology["warptorio-reactor-1"].unit.ingredients}

data.raw.technology["warptorio-reach-2"].prerequisites = {"warptorio-reach-1", "warptorio-reactor-2"}
data.raw.technology["warptorio-reach-2"].unit = {
	count = 50, time = 30, ingredients = data.raw.technology["warptorio-reactor-2"].unit.ingredients}

data.raw.technology["warptorio-reach-3"].prerequisites = {"warptorio-reach-2", "warptorio-reactor-3"}
data.raw.technology["warptorio-reach-3"].unit = {
	count = 75, time = 30, ingredients = data.raw.technology["warptorio-reactor-3"].unit.ingredients}

data.raw.technology["warptorio-reach-4"].prerequisites = {"warptorio-reach-3", "warptorio-reactor-4"}
data.raw.technology["warptorio-reach-4"].unit = {
	count = 100, time = 30, ingredients = data.raw.technology["warptorio-reactor-4"].unit.ingredients}

data.raw.technology["warptorio-reach-5"].prerequisites = {"warptorio-reach-4", "warptorio-reactor-5"}
data.raw.technology["warptorio-reach-5"].unit = {
	count = 150, time = 30, ingredients = data.raw.technology["warptorio-reactor-5"].unit.ingredients}

-- Mining Prod
-- data.raw.technology["warptorio-mining-prod-1"].prerequisites = {"warptorio-reactor-2"}
-- data.raw.technology["warptorio-mining-prod-1"].max_level = 5
-- data.raw.technology["warptorio-mining-prod-1"].unit = {
--     count_formula="20*L", time = 30, ingredients = {
--         {"basic-tech-card",1},
--     }}

-- data.raw.technology["warptorio-mining-prod-6"].prerequisites = {"warptorio-mining-prod-1", "warptorio-reactor-3"}
-- data.raw.technology["warptorio-mining-prod-6"].max_level = 10
-- data.raw.technology["warptorio-mining-prod-6"].unit = {
--     count_formula="20*L", time = 30, ingredients = {
--         {"automation-science-pack",1},
--     }}

-- data.raw.technology["warptorio-mining-prod-11"].prerequisites = {"warptorio-mining-prod-6", "warptorio-reactor-4"}
-- data.raw.technology["warptorio-mining-prod-11"].max_level = 15
-- data.raw.technology["warptorio-mining-prod-11"].unit = {
--     count_formula="20*L", time = 30, ingredients = {
--         {"automation-science-pack",1}, {"logistic-science-pack",1}, {"military-science-pack",1},
--     }}

-- data.raw.technology["warptorio-mining-prod-16"].prerequisites = {"warptorio-mining-prod-11", "warptorio-reactor-6"}
-- data.raw.technology["warptorio-mining-prod-16"].max_level = 20
-- data.raw.technology["warptorio-mining-prod-16"].unit = {
--     count_formula="20*L", time = 30, ingredients = data.raw.technology["warptorio-reactor-6"].unit.ingredients}

-- data.raw.technology["warptorio-mining-prod-21"].prerequisites = {"warptorio-mining-prod-16", "warptorio-reactor-7"}
-- data.raw.technology["warptorio-mining-prod-21"].max_level = 25
-- data.raw.technology["warptorio-mining-prod-21"].unit = {
--     count_formula="20*L", time = 30, ingredients = data.raw.technology["warptorio-reactor-7"].unit.ingredients}

-- TODO: warptorio-axe-speed
-- TODO: warptorio-inserter-cap
-- TODO: warptorio-bot-speed
-- TODO: warptorio-bot-cap

-- Make Waptorio Armor stronger than K2 MK4 but harder to get
data.raw.technology["warptorio-armor"].prerequisites = {"warptorio-reactor-8", "kr-power-armor-mk4"}
data.raw.technology["warptorio-armor"].unit = data.raw.technology["kr-power-armor-mk4"].unit
data.raw.recipe["warptorio-armor"].ingredients = { {"power-armor-mk4", 4} }
data.raw.armor["warptorio-armor"].resistances = {
  { type = "physical", decrease = 40, percent = 60, },
  { type = "acid", decrease = 40, percent = 90, },
  { type = "explosion", decrease = 100, percent = 90, },
  { type = "fire", decrease = 50, percent = 90, },
  { type = "radioactive", decrease = 10, percent = 90, },
}

----- Character & General Skills end -----



----- Top Platform Size start -----

data.raw.technology["warptorio-platform-size-1"].prerequisites = {}
data.raw.technology["warptorio-platform-size-1"].unit = {
	count = 20, time = 30, ingredients = { {"basic-tech-card",1} }}

data.raw.technology["warptorio-platform-size-2"].prerequisites = {"warptorio-platform-size-1", "warptorio-reactor-2"}
data.raw.technology["warptorio-platform-size-2"].unit = {
	count = 50, time = 30, ingredients = { {"basic-tech-card",1}, {"automation-science-pack",1} }}

data.raw.technology["warptorio-platform-size-3"].prerequisites = {"warptorio-platform-size-2", "warptorio-reactor-3"}
data.raw.technology["warptorio-platform-size-3"].unit = {
	count = 75, time = 30, ingredients = {
		{"basic-tech-card",1}, {"automation-science-pack",1}, {"logistic-science-pack",1},
	}}

data.raw.technology["warptorio-platform-size-4"].prerequisites = {"warptorio-platform-size-3", "warptorio-reactor-4"}
data.raw.technology["warptorio-platform-size-4"].unit = {
	count = 100, time = 30, ingredients = {
		{"automation-science-pack",1}, {"logistic-science-pack",1}, {"military-science-pack",1},
	}}

data.raw.technology["warptorio-platform-size-5"].prerequisites = {"warptorio-platform-size-4", "warptorio-reactor-4"}
data.raw.technology["warptorio-platform-size-5"].unit = {
	count = 150, time = 30, ingredients = data.raw.technology["warptorio-reactor-4"].unit.ingredients}

data.raw.technology["warptorio-platform-size-6"].prerequisites = {"warptorio-platform-size-5", "warptorio-reactor-5"}
data.raw.technology["warptorio-platform-size-6"].unit = {
	count = 200, time = 30, ingredients = data.raw.technology["warptorio-reactor-5"].unit.ingredients}

data.raw.technology["warptorio-platform-size-7"].prerequisites = {"warptorio-platform-size-6", "warptorio-reactor-6", "solar-energy"}
data.raw.technology["warptorio-platform-size-7"].unit = {
	count = 300, time = 30, ingredients = data.raw.technology["warptorio-reactor-6"].unit.ingredients}

----- Top Platform Size end -----



----- Factory Floor start -----

data.raw.technology["warptorio-factory-0"].prerequisites = {"warptorio-platform-size-1", "automation"}
data.raw.technology["warptorio-factory-0"].unit = {
	count = 20, time = 30, ingredients = {
		{"basic-tech-card",1}
	}}

data.raw.technology["warptorio-factory-1"].prerequisites = {"warptorio-factory-0", "automation-science-pack"}
data.raw.technology["warptorio-factory-1"].unit = {
	count = 50, time = 30, ingredients = {
		{"basic-tech-card",1}, {"automation-science-pack",1},
	}}

data.raw.technology["warptorio-factory-2"].prerequisites = {"warptorio-factory-1", "logistic-science-pack", "steel-processing"}
data.raw.technology["warptorio-factory-2"].unit = {
	count = 100, time = 30, ingredients = data.raw.technology["warptorio-reactor-2"].unit.ingredients}

data.raw.technology["warptorio-factory-3"].prerequisites = {"warptorio-factory-2"}
data.raw.technology["warptorio-factory-3"].unit = {
	count = 150, time = 30, ingredients = data.raw.technology["warptorio-reactor-3"].unit.ingredients}

data.raw.technology["warptorio-factory-4"].prerequisites = {"warptorio-factory-3", "warptorio-reactor-4", "modules"}
data.raw.technology["warptorio-factory-4"].unit = {
	count = 200, time = 30, ingredients = data.raw.technology["warptorio-reactor-4"].unit.ingredients}

data.raw.technology["warptorio-factory-5"].prerequisites = {"warptorio-factory-4", "warptorio-reactor-5", "advanced-material-processing-2"}
data.raw.technology["warptorio-factory-5"].unit = {
	count = 200, time = 30, ingredients = data.raw.technology["warptorio-reactor-5"].unit.ingredients}

data.raw.technology["warptorio-factory-6"].prerequisites = {
	"warptorio-factory-5", "warptorio-reactor-6",
	-- "automation-3",  -- it requires space science pack
	-- "se-rocket-science-pack",
	"robotics",
}
data.raw.technology["warptorio-factory-6"].unit = {
	count = 250, time = 30, ingredients = data.raw.technology["warptorio-reactor-6"].unit.ingredients}

data.raw.technology["warptorio-factory-7"].prerequisites = {"warptorio-factory-6", "warptorio-reactor-7"}
data.raw.technology["warptorio-factory-7"].unit = {
	count = 300, time = 30, ingredients = data.raw.technology["warptorio-reactor-7"].unit.ingredients}

----- Factory Floor end -----



----- Harvester Floor start -----

data.raw.technology["warptorio-harvester-floor"].prerequisites = {"warptorio-factory-0"}
data.raw.technology["warptorio-harvester-floor"].unit = {
	count = 100, time = 30, ingredients = {
		{"basic-tech-card",1}
	}}

data.raw.technology["warptorio-harvester-size-1"].prerequisites = {"warptorio-harvester-floor", "automation-science-pack"}
data.raw.technology["warptorio-harvester-size-1"].unit = {
	count = 100, time = 30, ingredients = {
		{"basic-tech-card",1}, {"automation-science-pack",1},
	}}

data.raw.technology["warptorio-harvester-size-2"].prerequisites = {"warptorio-harvester-size-1", "logistic-science-pack"}
data.raw.technology["warptorio-harvester-size-2"].unit = {
	count = 150, time = 30, ingredients = data.raw.technology["warptorio-reactor-2"].unit.ingredients}

data.raw.technology["warptorio-harvester-size-3"].prerequisites = {"warptorio-harvester-size-2", "warptorio-reactor-3"}
data.raw.technology["warptorio-harvester-size-3"].unit = {
	count = 200, time = 30, ingredients = data.raw.technology["warptorio-reactor-3"].unit.ingredients}

data.raw.technology["warptorio-harvester-size-4"].prerequisites = {"warptorio-harvester-size-3", "warptorio-reactor-4", "stack-inserter"}
data.raw.technology["warptorio-harvester-size-4"].unit = {
	count = 200, time = 30, ingredients = data.raw.technology["warptorio-reactor-4"].unit.ingredients}

data.raw.technology["warptorio-harvester-size-5"].prerequisites = {
	"warptorio-harvester-size-4", "warptorio-reactor-5",
	-- "mining-productivity-3",  -- it requires space science pack
	-- "warp-mining-prod-4",
}
data.raw.technology["warptorio-harvester-size-5"].unit = {
	count = 200, time = 30, ingredients = data.raw.technology["warptorio-reactor-5"].unit.ingredients}

data.raw.technology["warptorio-harvester-size-6"].prerequisites = {"warptorio-harvester-size-5", "warptorio-reactor-6"}
data.raw.technology["warptorio-harvester-size-6"].unit = {
	count = 200, time = 30, ingredients = data.raw.technology["warptorio-reactor-6"].unit.ingredients}

data.raw.technology["warptorio-harvester-size-7"].prerequisites = {"warptorio-harvester-size-6", "warptorio-reactor-7"}
data.raw.technology["warptorio-harvester-size-7"].unit = {
	count = 200, time = 30, ingredients = data.raw.technology["warptorio-reactor-7"].unit.ingredients}

----- Harvester Floor end -----



----- Harvester West/East start -----

data.raw.technology["warptorio-harvester-west-1"].prerequisites = {"warptorio-harvester-floor"}
data.raw.technology["warptorio-harvester-west-1"].unit = {
	count = 50, time = 30, ingredients = {
		{"basic-tech-card",1},
	}}

data.raw.technology["warptorio-harvester-west-2"].prerequisites = {"warptorio-harvester-west-1", "automation-science-pack"}
data.raw.technology["warptorio-harvester-west-2"].unit = {
	count = 100, time = 30, ingredients = {
		{"basic-tech-card",1}, {"automation-science-pack",1},
	}}

data.raw.technology["warptorio-harvester-west-3"].prerequisites = {"warptorio-harvester-west-2", "mining-productivity-1", "logistic-science-pack"}
data.raw.technology["warptorio-harvester-west-3"].unit = {
	count = 150, time = 30, ingredients = {
		{"automation-science-pack",1}, {"logistic-science-pack",1},
	}}

data.raw.technology["warptorio-harvester-west-4"].prerequisites = {"warptorio-harvester-west-3", "mining-productivity-2", "warptorio-reactor-5"}
data.raw.technology["warptorio-harvester-west-4"].unit = {
	count = 200, time = 30, ingredients = {
		{"automation-science-pack",1}, {"logistic-science-pack",1},
		{"military-science-pack",1}, {"chemical-science-pack",1},
	}}

data.raw.technology["warptorio-harvester-west-5"].prerequisites = {"warptorio-harvester-west-4", "mining-productivity-3", "se-rocket-science-pack"}
data.raw.technology["warptorio-harvester-west-5"].unit = {
	count = 250, time = 30, ingredients = {
		{"automation-science-pack",1}, {"logistic-science-pack",1},
		{"military-science-pack",1}, {"chemical-science-pack",1},
		{"se-rocket-science-pack",1},
	}}

for i = 1, 5 do
	data.raw.technology["warptorio-harvester-east-"..i].prerequisites = data.raw.technology["warptorio-harvester-west-"..i].prerequisites
	data.raw.technology["warptorio-harvester-east-"..i].unit = data.raw.technology["warptorio-harvester-west-"..i].unit
end

----- Harvester West/East end -----



----- Boiler Room start -----

data.raw.technology["warptorio-boiler-0"].prerequisites = {"steel-processing", "warptorio-harvester-floor"}
data.raw.technology["warptorio-boiler-0"].unit = {
	count = 100, time = 30, ingredients = {
		{"basic-tech-card",1}, {"automation-science-pack",1},
	}}

data.raw.technology["warptorio-boiler-1"].prerequisites = {"warptorio-boiler-0", }
data.raw.technology["warptorio-boiler-1"].unit = {
	count = 100, time = 30, ingredients = {
		{"basic-tech-card",1}, {"automation-science-pack",1}, {"logistic-science-pack",1},
	}}

data.raw.technology["warptorio-boiler-2"].prerequisites = {"warptorio-boiler-1", "fluid-handling"}
data.raw.technology["warptorio-boiler-2"].unit = {
	count = 150, time = 30, ingredients = {
		{"basic-tech-card",1}, {"automation-science-pack",1}, {"logistic-science-pack",1},
	}}

data.raw.technology["warptorio-boiler-3"].prerequisites = {"warptorio-boiler-2", "chemical-science-pack"}
data.raw.technology["warptorio-boiler-3"].unit = {
	count = 150, time = 30, ingredients = {
		{"automation-science-pack",1}, {"logistic-science-pack",1},
		{"chemical-science-pack",1},
	}}

data.raw.technology["warptorio-boiler-4"].prerequisites = {"warptorio-boiler-3", "battery", "flammables"}
data.raw.technology["warptorio-boiler-4"].unit = {
	count = 200, time = 30, ingredients = {
		{"automation-science-pack",1}, {"logistic-science-pack",1},
		{"chemical-science-pack",1},
	}}

data.raw.technology["warptorio-boiler-5"].prerequisites = {"warptorio-boiler-4", "warptorio-reactor-5"}
data.raw.technology["warptorio-boiler-5"].unit = {
	count = 200, time = 30, ingredients = data.raw.technology["warptorio-reactor-5"].unit.ingredients}

data.raw.technology["warptorio-boiler-6"].prerequisites = {"warptorio-boiler-5", "warptorio-reactor-6"}
data.raw.technology["warptorio-boiler-6"].unit = {
	count = 200, time = 30, ingredients = data.raw.technology["warptorio-reactor-6"].unit.ingredients}

data.raw.technology["warptorio-boiler-7"].prerequisites = {"warptorio-boiler-6", "warptorio-reactor-7"}
data.raw.technology["warptorio-boiler-7"].unit = {
	count = 200, time = 30, ingredients = data.raw.technology["warptorio-reactor-7"].unit.ingredients}

data.raw.technology["warptorio-boiler-station"].prerequisites = {"warptorio-boiler-2"}
data.raw.technology["warptorio-boiler-station"].unit = {
	count = 100, time = 30, ingredients = {
		{"automation-science-pack",1}, {"logistic-science-pack",1},
		{"military-science-pack",1}, {"chemical-science-pack",1},
	}}

----- Boiler Room end -----



----- Update Tech Effects start -----
-- TODO: add Warptorio Energy Weapons Damage tech research

-- Add SE+K2 ammo into W2 tech research damage effects
local round_by = function(value, base)
  return math.floor(value/base + 0.5) * base
end

local missing_ammo_cats = {
  -- "bullet", "shotgun-shell",
  -- From SE
  -- "railgun-ammo",
  -- From K2
  "pistol-ammo", "anti-material-rifle-ammo",
  "rifle-ammo", "cannon-shell", "artillery-shell", "railgun-shell"
}

local function add_missing_damage_effects(technology)
  local effects = data.raw["technology"][technology].effects
  for i = 1, #missing_ammo_cats do
	table.append(effects, {
	  type = "ammo-damage", ammo_category = missing_ammo_cats[i],
	  modifier = round_by(effects[#effects - (#effects - 1)].modifier, 0.05)
	})
  end
end

add_missing_damage_effects("warptorio-physdmg-1")

----- Update Tech Effects end -----


--[[
----- For quick copy-paste:

basic-tech-card
automation-science-pack
logistic-science-pack
military-science-pack
chemical-science-pack
se-rocket-science-pack

space-science-pack
production-science-pack
utility-science-pack
kr-optimization-tech-card
advanced-tech-card

se-astronomic-science-pack-1
se-astronomic-science-pack-2
se-astronomic-science-pack-3
se-astronomic-science-pack-4
se-biological-science-pack-1
se-biological-science-pack-2
se-biological-science-pack-3
se-biological-science-pack-4
se-energy-science-pack-1
se-energy-science-pack-2
se-energy-science-pack-3
se-energy-science-pack-4
se-material-science-pack-1
se-material-science-pack-2
se-material-science-pack-3
se-material-science-pack-4

matter-tech-card
se-kr-matter-science-pack-2

se-deep-space-science-pack-1
se-deep-space-science-pack-2
se-deep-space-science-pack-3
se-deep-space-science-pack-4
]]--