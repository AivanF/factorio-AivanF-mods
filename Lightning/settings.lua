data:extend{
    -- Startup
    -- Map/global
    {
        type = "int-setting",
        name = "af-tls-nauvis-base",
        setting_type = "runtime-global",
        minimum_value = 0,
        default_value = 0,
        maximum_value = 3,
        order = "a",
    },
    {
        type = "double-setting",
        name = "af-tls-nauvis-scale",
        setting_type = "runtime-global",
        minimum_value = 0,
        default_value = 1,
        maximum_value = 2,
        order = "b",
    },
    {
        type = "double-setting",
        name = "af-tls-rate-cf",
        setting_type = "runtime-global",
        minimum_value = 0.01,
        default_value = 1,
        maximum_value = 100,
        order = "c",
    },
    {
        type = "double-setting",
        name = "af-tls-energy-cf",
        setting_type = "runtime-global",
        minimum_value = 0.01,
        default_value = 1,
        maximum_value = 100,
        order = "d",
    },
}
