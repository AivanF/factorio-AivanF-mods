local shared = require("shared")

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
    name = shared.rifle1,
    icon = "__" .. shared.modName .. "__/graphics/" .. shared.rifle1 ..
        ".png",
    icon_size = 64,
    subgroup = "gun",
    order = "a[basic-clips]-c-ra[" .. shared.rifle1 .. "]",
    attack_parameters = {
        type = "projectile",
        ammo_category = shared.ammoCategory,
        cooldown = cd1,
        sound = {
            { filename = "__" .. shared.modName .. "__/SniperRifle.ogg", volume = 1.0 }
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
    name = shared.rifle2,
    icon = "__" .. shared.modName .. "__/graphics/" .. shared.rifle2 ..
        ".png",
    icon_size = 64,
    subgroup = "gun",
    order = "a[basic-clips]-c-rb[" .. shared.rifle2 .. "]",
    attack_parameters = {
        type = "projectile",
        ammo_category = shared.ammoCategory,
        cooldown = cd2,
        sound = {
            { filename = "__" .. shared.modName .. "__/SniperRifle.ogg", volume = 1.0 }
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
            {type="item", name="wood", amount=10},
            {type="item", name="iron-gear-wheel", amount=15},
            {type="item", name="steel-plate", amount=10},
        },
        name = shared.rifle1,
        results = {{type="item", name=shared.rifle1, amount=1}},
        type = "recipe"
    }
})
table.insert(
  data.raw.technology["military-2"].effects,
  { type = "unlock-recipe", recipe = shared.rifle1 }
)

data:extend({
    {
        enabled = false,
        energy_required = 30,
        ingredients = {
            {type="item", name=shared.rifle1, amount=1},
            {type="item", name="small-lamp", amount=2},
            {type="item", name="pipe", amount=10},
            {type="item", name="steel-plate", amount=10},
        },
        name = shared.rifle2,
        results = {{type="item", name=shared.rifle2, amount=1}},
        type = "recipe"
    }
})
table.insert(
  data.raw.technology["military-4"].effects,
  { type = "unlock-recipe", recipe = shared.rifle2 }
)
