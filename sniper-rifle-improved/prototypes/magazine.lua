local shared = require("shared")

-- Items --
local container = {}
local item1 = {
    type = "ammo",
    name = shared.magazine1,
    icon = "__" .. shared.modName .. "__/graphics/" .. shared.magazine1 ..
        ".png",
    icon_size = 64,
    ammo_category = shared.ammoCategory,
    ammo_type = {
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
    order = "a[basic-clips]-d[" .. shared.magazine1 .. "]",
    stack_size = 200
}
local item2 = {
    type = "ammo",
    name = shared.magazine2,
    icon = "__" .. shared.modName .. "__/graphics/" .. shared.magazine2 ..
        ".png",
    icon_size = 64,
    ammo_category = shared.ammoCategory,
    ammo_type = {
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
    order = "a[basic-clips]-d[" .. shared.magazine2 .. "]",
    stack_size = 200
}
local item3 = {
    type = "ammo",
    name = shared.magazine3,
    icon = "__" .. shared.modName .. "__/graphics/" .. shared.magazine3 ..
        ".png",
    icon_size = 64,
    ammo_category = shared.ammoCategory,
    ammo_type = {
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
                        damage = {amount = 240, type = "physical"}
                    }
                }
            }
        }
    },
    magazine_size = 5,
    subgroup = "ammo",
    order = "a[basic-clips]-d[" .. shared.magazine2 .. "]",
    stack_size = 200
}

table.insert(container, item1)
table.insert(container, item2)
table.insert(container, item3)
data:extend(container)

-- Recipes --
data:extend({
    {
        enabled = false,
        energy_required = 3,
        ingredients = {
            {type="item", name="copper-plate", amount=5},
            {type="item", name="steel-plate", amount=5},
        },
        name = shared.magazine1,
        results = {{type="item", name=shared.magazine1, amount=1}},
        type = "recipe"
    }
})
data:extend({
    {
        enabled = false,
        energy_required = 15,
        ingredients = {
            {type="item", name=shared.magazine1, amount=5},
            {type="item", name="explosives", amount=1},
        },
        name = shared.magazine2,
        results = {{type="item", name=shared.magazine2, amount=5}},
        type = "recipe"
    }
})
data:extend({
    {
        enabled = false,
        energy_required = 3,
        ingredients = {
            {type="item", name=shared.magazine2, amount=1},
            {type="item", name="uranium-238", amount=1},
        },
        name = shared.magazine3,
        results = {{type="item", name=shared.magazine3, amount=1}},
        type = "recipe"
    }
})

table.insert(
  data.raw.technology["military-2"].effects,
  { type = "unlock-recipe", recipe = shared.magazine1 }
)
table.insert(
  data.raw.technology["military-3"].effects,
  { type = "unlock-recipe", recipe = shared.magazine2 }
)
table.insert(
  data.raw.technology["uranium-ammo"].effects,
  { type = "unlock-recipe", recipe = shared.magazine3 }
)
