data:extend{
    -- Startup
    {
        type = "int-setting",
        name = "af-alc-scan-update-rate",
        setting_type = "startup",
        minimum_value = 2,
        maximum_value = 120,
        default_value = 10,
        order = "a",
    },
    {
        type = "bool-setting",
        name = "af-alc-add-laser",
        setting_type = "startup",
        default_value = false,
        order = "b",
    },
    {
        type = "bool-setting",
        name = "af-alc-active-chest",
        setting_type = "startup",
        default_value = false,
        order = "c",
    },
    {
        type = "bool-setting",
        name = "af-alc-loot-corpses",
        setting_type = "startup",
        default_value = true,
        order = "d",
    },

    -- Map/global
    {
        type = "bool-setting",
        name = "af-alc-chest-show",
        setting_type = "runtime-global",
        default_value = false,
        order = "a",
    },
    {
        type = "int-setting",
        name = "af-alc-chest-radius",
        setting_type = "runtime-global",
        minimum_value = 4,
        maximum_value = 32,
        default_value = 10,
        order = "b",
    },
    {
        type = "int-setting",
        name = "af-alc-max-shift",
        setting_type = "runtime-global",
        minimum_value = 4,
        maximum_value = 2048,
        default_value = 96,
        order = "c",
    },
    {
        type = "int-setting",
        name = "af-alc-items-per-tick",
        setting_type = "runtime-global",
        minimum_value = 1,
        maximum_value = 50,
        default_value = 5,
        order = "d",
    },
}
