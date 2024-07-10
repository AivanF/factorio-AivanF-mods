
-- Update Vanilla, to make it some easier
data.raw.technology["electricity"].unit = {
	count = 20, time = 10, ingredients = {
		{"basic-tech-card",1}, {"automation-science-pack",1},
	}}

data.raw.technology["landfill"].prerequisites = {"basic-logistics"}
data.raw.technology["landfill"].unit = {
	count = 50, time = 15, ingredients = {
		{"basic-tech-card",1}, {"automation-science-pack",1},
	}}

data.raw.technology["logistic-system"].prerequisites = {"logistic-robotics"}
data.raw.technology["logistic-system"].unit = {
	count = 200, time = 30, ingredients = {
		{"automation-science-pack",1}, {"logistic-science-pack",1},
		{"chemical-science-pack",1}, {"se-rocket-science-pack",1},
	}}

-- Update Warptorio, to make it robust with SE+K2
require("prototypes/update_warptorio")

-- Update Krastorio, to make the start faster
data.raw.technology["kr-crusher"].unit = {count = 10, time = 30, ingredients = { {"basic-tech-card",1} }}
data.raw.technology["kr-stone-processing"].unit = {count = 10, time = 30, ingredients = { {"basic-tech-card",1} }}
data.raw.technology["kr-greenhouse"].unit = {count = 20, time = 30, ingredients = { {"automation-science-pack",1}, {"logistic-science-pack",1} }}

data.raw["electric-energy-interface"]["kr-crash-site-generator"].energy_production = "900kW"
data.raw["electric-energy-interface"]["kr-crash-site-generator"].energy_source = {
	type = "electric",
	buffer_capacity = "900kJ",
	usage_priority = "primary-output",
	input_flow_limit = "0kW",
	output_flow_limit = "900kW",
}

-- Allow manual tech cards crafting
data.raw.recipe["blank-tech-card"].category = "crafting"
data.raw.recipe["automation-science-pack"].category = "crafting"
data.raw.recipe["logistic-science-pack"].category = "crafting"
data.raw.recipe["military-science-pack"].category = "crafting"


-- Update Factorissimo, to make the buildings earlier & cheaper, so that you have more space to build
if data.raw.technology["factory-architecture-t1"] then
	require("prototypes/update_factorissimo")
end
if data.raw.technology["space-factory-liz-architecture-t1"] then
	require("prototypes/update_factorissimo_liz")
end
