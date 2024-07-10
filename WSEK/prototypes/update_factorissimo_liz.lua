require("utils")

----- Tier 1
-- data.raw.technology["space-factory-liz-architecture-t1"].prerequisites = {"basic-logistics", "stone-wall"}
data.raw.technology["space-factory-liz-architecture-t1"].unit = {
	count = 100, time = 30, ingredients = {
		{"automation-science-pack",1}, {"logistic-science-pack",1},
		{"chemical-science-pack",1}, {"se-rocket-science-pack",1},
		{"space-science-pack",1},
	}}

data.raw.recipe["space-factory-liz-1"].ingredients = {
	{"big-electric-pole", 50}, {"se-space-platform-scaffold", 500},
}

----- Tier 2
data.raw.technology["space-factory-liz-architecture-t2"].prerequisites = {
	"space-factory-liz-architecture-t1",
	"production-science-pack",
	"utility-science-pack",
}
data.raw.technology["space-factory-liz-architecture-t2"].unit = {
	count = 300, time = 45, ingredients = {
		{"automation-science-pack",1}, {"logistic-science-pack",1},
		{"chemical-science-pack",1}, {"se-rocket-science-pack",1},
		{"space-science-pack",1}, {"production-science-pack",1}, {"utility-science-pack",1},
	}}

data.raw.recipe["space-factory-liz-2"].ingredients = {
	{"substation", 50}, {"se-space-platform-scaffold", 2000},
}

----- Tier 3
data.raw.technology["space-factory-liz-architecture-t3"].prerequisites = {
	"space-factory-liz-architecture-t2",
	"factory-architecture-t3",
	"warptorio-reactor-8",
	"se-pylon",
	"se-space-platform-plating",
}
data.raw.technology["space-factory-liz-architecture-t3"].unit = {
	count = 500, time = 60, ingredients = {
		{"automation-science-pack",1}, {"logistic-science-pack",1},
		{"chemical-science-pack",1}, {"se-rocket-science-pack",1},
		{"space-science-pack",1}, {"production-science-pack",1}, {"utility-science-pack",1},
		{"se-energy-science-pack-1",1}, {"se-material-science-pack-1",1},
		{"se-astronomic-science-pack-1",1},
	}}

-- data.raw.recipe["space-factory-liz-3"].ingredients = {
-- 	{"substation", 10}, {"concrete", 500}, {"steel-plate", 400},
-- }
