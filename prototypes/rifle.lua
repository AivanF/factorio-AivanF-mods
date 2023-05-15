local Constants = require("constants")
local Recipe = require("__stdlib__/stdlib/data/recipe")

-- Item --
local container = {}
local item = {
    type = "gun",
    name = Constants.rifle,
    icon = "__" .. Constants.modName .. "__/graphics/" .. Constants.rifle ..
        ".png",
    icon_size = 64,
    subgroup = "gun",
    order = "a[basic-clips]-c[" .. Constants.rifle .. "]",
    attack_parameters = {
        type = "projectile",
        ammo_category = Constants.ammoCategory,
        cooldown = 60,
        sound = {
            { filename = "__" .. Constants.modName .. "__/SniperRifle.ogg", volume = 1.0 }
        },
        damage_modifer = 6,
        movement_slow_down_factor = 0.5,
        shell_particle = {
            name = "shell-particle",
            direction_deviation = 0.1,
            speed = 0.1,
            speed_deviation = 0.03,
            center = {0, 0.1},
            creation_distance = -0.5,
            starting_frame_speed = 0.4,
            starting_frame_speed_deviation = 0.1
        },
        projectile_creation_distance = 1.125,
        range = 60
    },
    stack_size = 1
}

table.insert(container, item)
data:extend(container)

-- Recipe --
data:extend({
    {
        enabled = false,
        energy_required = 15,
        ingredients = {
            {"copper-plate", 10}, {"iron-gear-wheel", 15}, {"steel-plate", 10}
        },
        name = Constants.rifle,
        result = Constants.rifle,
        type = "recipe"
    }
})
Recipe(Constants.rifle):add_unlock("military-2")
