data:extend{
    -- Startup
    {
        type = "bool-setting",
        name = "af-meet-to-oil-early",
        setting_type = "startup",
        default_value = true,
        order = "a",
    },
    {
        type = "int-setting",
        name = "af-corpse-remove-time",
        setting_type = "startup",
        minimum_value = 1,
        maximum_value = 6000,
        default_value = 300,
        order = "b",
    },
    {
        type = "int-setting",
        name = "af-meet-to-oil-value",
        setting_type = "startup",
        minimum_value = 1,
        maximum_value = 50,
        default_value = 15,
        order = "c",
    },
    {
        type = "int-setting",
        name = "af-meet-stack-size",
        setting_type = "startup",
        minimum_value = 10,
        maximum_value = 10000,
        default_value = 100,
        order = "d",
    },
    {
        type = "bool-setting",
        name = "always-fry",
        setting_type = "startup",
        default_value = true,
        order = "z",
    },
}
