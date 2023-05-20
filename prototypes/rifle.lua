local Constants = require("constants")
local Recipe = require("__stdlib__/stdlib/data/recipe")

-- Items --

base_range = 18
range_factor = settings.startup["af-sniper-range-factor"].value
cd1 = 60
cd2 = cd1
if (settings.startup["af-slower-sniper-than-carbine"].value) then
    cd2 = cd2 * 1.25
end

local container = {}

local item1 = {
    type = "gun",
    name = Constants.rifle1,
    icon = "__" .. Constants.modName .. "__/graphics/" .. Constants.rifle1 ..
        ".png",
    icon_size = 64,
    subgroup = "gun",
    order = "a[basic-clips]-c-ra[" .. Constants.rifle1 .. "]",
    attack_parameters = {
        type = "projectile",
        ammo_category = Constants.ammoCategory,
        cooldown = cd1,
        sound = {
            { filename = "__" .. Constants.modName .. "__/SniperRifle.ogg", volume = 1.0 }
        },
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
        range = base_range * range_factor,
    },
    stack_size = 1
}
table.insert(container, item1)

local item2 = {
    type = "gun",
    name = Constants.rifle2,
    icon = "__" .. Constants.modName .. "__/graphics/" .. Constants.rifle2 ..
        ".png",
    icon_size = 64,
    subgroup = "gun",
    order = "a[basic-clips]-c-rb[" .. Constants.rifle2 .. "]",
    attack_parameters = {
        type = "projectile",
        ammo_category = Constants.ammoCategory,
        cooldown = cd2,
        sound = {
            { filename = "__" .. Constants.modName .. "__/SniperRifle.ogg", volume = 1.0 }
        },
        damage_modifier = 1.25,
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
        range = base_range * (range_factor + 1.0),
    },
    stack_size = 1
}
table.insert(container, item2)

data:extend(container)

-- Recipes --
data:extend({
    {
        enabled = false,
        energy_required = 15,
        ingredients = {
            {"wood", 10}, {"iron-gear-wheel", 15}, {"steel-plate", 10},
        },
        name = Constants.rifle1,
        result = Constants.rifle1,
        type = "recipe"
    }
})
Recipe(Constants.rifle1):add_unlock("military-2")
data:extend({
    {
        enabled = false,
        energy_required = 30,
        ingredients = {
            {Constants.rifle1, 1}, {"small-lamp", 2}, {"pipe", 10}, {"steel-plate", 10},
        },
        name = Constants.rifle2,
        result = Constants.rifle2,
        type = "recipe"
    }
})
Recipe(Constants.rifle2):add_unlock("military-4")
