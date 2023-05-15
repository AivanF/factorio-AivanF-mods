local Constants = require("constants")
local Recipe = require("__stdlib__/stdlib/data/recipe")

-- Item --
local container = {}
local item = {
    type = "ammo",
    name = Constants.magazine,
    icon = "__" .. Constants.modName .. "__/graphics/" .. Constants.magazine ..
        ".png",
    icon_size = 64,
    ammo_type = {
        category = Constants.category,
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
    order = "a[basic-clips]-d[" .. Constants.magazine .. "]",
    stack_size = 200
}

table.insert(container, item)
data:extend(container)

-- Recipe --
data:extend({
    {
        enabled = false,
        energy_required = 3,
        ingredients = {
            {"iron-plate", 5}, {"copper-plate", 5}, {"steel-plate", 2}
        },
        name = Constants.magazine,
        result = Constants.magazine,
        type = "recipe"
    }
})
Recipe(Constants.magazine):add_unlock("military-2")
