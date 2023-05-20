data:extend{
    {
        type = "double-setting",
        name = "af-sniper-range-factor",
        setting_type = "startup",
        default_value = 2.5,
        allowed_values = {2.0, 2.5, 3.0},
        order = "a",
    },
    {
        type = "double-setting",
        name = "af-sniper-damage-gain",
        setting_type = "startup",
        default_value = 1.25,
        allowed_values = {1.0, 1.25, 1.5},
        order = "b",
    },
    {
        type = "bool-setting",
        name = "af-slower-sniper-than-carbine",
        setting_type = "startup",
        default_value = true,
        order = "c"
    },
}
