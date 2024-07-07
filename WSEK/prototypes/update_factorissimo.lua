require("utils")

----- Tier 1
data.raw.technology["factory-architecture-t1"].prerequisites = {"basic-logistics", "stone-wall"}
data.raw.technology["factory-architecture-t1"].unit = {
	count = 50, time = 20, ingredients = {
		{"basic-tech-card",1},
	}}

data.raw.recipe["factory-1"].ingredients = {
	{"stone", 200}, {"iron-plate", 200}, {"copper-plate", 100},
}

----- Tier 2
data.raw.technology["factory-architecture-t2"].prerequisites = {"factory-architecture-t1", "warptorio-reactor-2"}
data.raw.technology["factory-architecture-t2"].unit = {
	count = 200, time = 30, ingredients = {
		{"basic-tech-card",1}, {"automation-science-pack",1},
	}}

data.raw.recipe["factory-2"].ingredients = {
	{"big-electric-pole", 10}, {"stone-brick", 250}, {"steel-plate", 150},
}

----- Recursion 1
data.raw.technology["factory-recursion-t1"].prerequisites = {"factory-architecture-t2", "logistics-2"}
data.raw.technology["factory-recursion-t1"].unit = {
	count = 500, time = 60, ingredients = {
		{"automation-science-pack",1}, {"logistic-science-pack",1},
	}}


----- Tier 3
data.raw.technology["factory-architecture-t3"].prerequisites = {"factory-architecture-t2", "warptorio-reactor-4"}
data.raw.technology["factory-architecture-t3"].unit = {
	count = 350, time = 30, ingredients = {
		{"automation-science-pack",1}, {"logistic-science-pack",1},
		{"military-science-pack",1},
	}}

data.raw.recipe["factory-3"].ingredients = {
	{"substation", 10}, {"concrete", 500}, {"steel-plate", 400},
}

----- Recursion 2
data.raw.technology["factory-recursion-t2"].prerequisites = {"factory-recursion-t1", "factory-architecture-t3", "warptorio-reactor-5"}
data.raw.technology["factory-recursion-t2"].unit = {
	count = 500, time = 60, ingredients = {
		{"automation-science-pack",1}, {"logistic-science-pack",1},
		{"military-science-pack",1}, {"chemical-science-pack",1},
	}}

----- Fluid connection
data.raw.technology["factory-connection-type-fluid"].prerequisites = {"factory-architecture-t1"}
data.raw.technology["factory-connection-type-fluid"].unit = {
	count = 50, time = 30, ingredients = {
		{"basic-tech-card",1}, {"automation-science-pack",1},
	}}

----- Chest connection
data.raw.technology["factory-connection-type-chest"].prerequisites = {"factory-architecture-t1", "logistics-2"}
data.raw.technology["factory-connection-type-chest"].unit = {
	count = 50, time = 30, ingredients = {
		{"automation-science-pack",1}, {"logistic-science-pack",1},
	}}

----- Overlay
data.raw.technology["factory-interior-upgrade-display"].prerequisites = {"factory-architecture-t1"}
data.raw.technology["factory-connection-type-fluid"].unit = {
	count = 50, time = 30, ingredients = {
		{"basic-tech-card",1}, {"automation-science-pack",1},
	}}
