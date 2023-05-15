local Constants = require("constants")
local Recipe = require("__stdlib__/stdlib/data/recipe")

-- Items --
local container = {}
local item1 = {
    type = "ammo",
    name = Constants.magazine1,
    icon = "__" .. Constants.modName .. "__/graphics/" .. Constants.magazine1 ..
        ".png",
    icon_size = 64,
    ammo_type = {
        category = Constants.ammoCategory,
        action = {
            type = "direct",
            action_delivery = {
                type = "instant",
                source_effects = {
                    type = "create-explosion",
                    entity_name = "explosion-gunshot"
                },
                target_effects = {
                    {
                        type = "create-entity",
                        entity_name = "explosion-hit",
                        offsets = {{0, 1}},
                        offset_deviation = {{-0.5, -0.5}, {0.5, 0.5}}
                    },
                    {
                        type = "damage",
                        damage = {amount = 80, type = "physical"}
                    }
                }
            }
        }
    },
    magazine_size = 5,
    subgroup = "ammo",
    order = "a[basic-clips]-d[" .. Constants.magazine1 .. "]",
    stack_size = 200
}
local item2 = {
    type = "ammo",
    name = Constants.magazine2,
    icon = "__" .. Constants.modName .. "__/graphics/" .. Constants.magazine2 ..
        ".png",
    icon_size = 64,
    ammo_type = {
        category = Constants.ammoCategory,
        action = {
            type = "direct",
            action_delivery = {
                type = "instant",
                source_effects = {
                    type = "create-explosion",
                    entity_name = "explosion-gunshot"
                },
                target_effects = {
                    {
                        type = "create-entity",
                        entity_name = "explosion-hit",
                        offsets = {{0, 1}},
                        offset_deviation = {{-0.5, -0.5}, {0.5, 0.5}}
                    },
                    {
                        type = "damage",
                        damage = {amount = 120, type = "physical"}
                    }
                }
            }
        }
    },
    magazine_size = 5,
    subgroup = "ammo",
    order = "a[basic-clips]-d[" .. Constants.magazine2 .. "]",
    stack_size = 200
}
local item3 = {
    type = "ammo",
    name = Constants.magazine3,
    icon = "__" .. Constants.modName .. "__/graphics/" .. Constants.magazine3 ..
        ".png",
    icon_size = 64,
    ammo_type = {
        category = Constants.ammoCategory,
        action = {
            type = "direct",
            action_delivery = {
                type = "instant",
                source_effects = {
                    type = "create-explosion",
                    entity_name = "explosion-gunshot"
                },
                target_effects = {
                    {
                        type = "create-entity",
                        entity_name = "explosion-hit",
                        offsets = {{0, 1}},
                        offset_deviation = {{-0.5, -0.5}, {0.5, 0.5}}
                    },
                    {
                        type = "damage",
                        damage = {amount = 160, type = "physical"}
                    }
                }
            }
        }
    },
    magazine_size = 5,
    subgroup = "ammo",
    order = "a[basic-clips]-d[" .. Constants.magazine2 .. "]",
    stack_size = 200
}

table.insert(container, item1)
table.insert(container, item2)
table.insert(container, item3)
data:extend(container)

-- Recipe --
data:extend({
    {
        enabled = false,
        energy_required = 3,
        ingredients = {
            {"copper-plate", 5}, {"steel-plate", 5}
        },
        name = Constants.magazine1,
        result = Constants.magazine1,
        type = "recipe"
    }
})
data:extend({
    {
        enabled = false,
        energy_required = 15,
        ingredients = {
            {Constants.magazine1, 5}, {"explosives", 1}
        },
        name = Constants.magazine2,
        results = {{
           name = Constants.magazine2,
           amount = 5,
        }},
        type = "recipe"
    }
})
data:extend({
    {
        enabled = false,
        energy_required = 3,
        ingredients = {
            {Constants.magazine2, 1}, {"uranium-238", 1}
        },
        name = Constants.magazine3,
        result = Constants.magazine3,
        type = "recipe"
    }
})
Recipe(Constants.magazine1):add_unlock("military-2")
Recipe(Constants.magazine2):add_unlock("military-3")
Recipe(Constants.magazine3):add_unlock("uranium-ammo")
