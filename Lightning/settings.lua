local shared = require("shared-pre")

data:extend{
    -- Startup
    {
        type = "double-setting",
        name = "af-tls-rod-catch-radius",
        setting_type = "startup",
        minimum_value = 16,
        default_value = 48,
        maximum_value = 96,
        order = "a",
    },

    -- Map/global
    {
        type = "string-setting",
        name = "af-tls-nauvis---",
        localised_name = "--------- Nauvis:",
        setting_type = "runtime-global",
        default_value = "",
        allowed_values = {""},
        allow_blank = true,
        order = "b-0",
    },
    {
        type = "int-setting",
        name = "af-tls-nauvis-base",
        setting_type = "runtime-global",
        minimum_value = 0,
        default_value = 0,
        maximum_value = 3,
        order = "b-home-1",
    },
    {
        type = "double-setting",
        name = "af-tls-nauvis-scale",
        setting_type = "runtime-global",
        minimum_value = 0,
        default_value = 1,
        maximum_value = 2,
        order = "b-home-2",
    },
    {
        type = "double-setting",
        name = "af-tls-nauvis-size",
        setting_type = "runtime-global",
        minimum_value = 0.1,
        default_value = 1,
        maximum_value = 50,
        order = "b-home-3",
    },
    {
        type = "double-setting",
        name = "af-tls-nauvis-zspeed",
        setting_type = "runtime-global",
        minimum_value = 0,
        default_value = 0,
        maximum_value = 10,
        order = "b-home-4",
    },

    {
        type = "string-setting",
        name = "af-tls-common-cf---",
        localised_name = "--------- Common:",
        setting_type = "runtime-global",
        default_value = "",
        allowed_values = {""},
        allow_blank = true,
        order = "c-0",
    },
    {
        type = "double-setting",
        name = "af-tls-capture-prob",
        setting_type = "runtime-global",
        minimum_value = 0.1,
        default_value = 0.95,
        maximum_value = 1,
        order = "c-common-0",
    },
    {
        type = "double-setting",
        name = "af-tls-rate-cf",
        setting_type = "runtime-global",
        minimum_value = 0.01,
        default_value = 1,
        maximum_value = 100,
        order = "c-common-1",
    },
    {
        type = "double-setting",
        name = "af-tls-energy-cf",
        setting_type = "runtime-global",
        minimum_value = 0.01,
        default_value = 1,
        maximum_value = 100,
        order = "c-common-2",
    },
    {
        type = "int-setting",
        name = "af-tls-extra-reduct",
        setting_type = "runtime-global",
        minimum_value = -1,
        default_value = 0,
        maximum_value = 2,
        order = "c-common-3",
    },

    {
        type = "string-setting",
        name = "af-tls-planets---",
        localised_name = "--------- Planets:",
        setting_type = "runtime-global",
        default_value = "",
        allowed_values = {""},
        allow_blank = true,
        order = "zzz-0",
    },
}

local resource, default
for index, info in ipairs(shared.default_presets) do
	resource, default = info[1], info[2]
	if default == nil then default = shared.PRESET_NIL end
	data:extend{{
		type = "string-setting",
        name = shared.preset_setting_name_for_resource(resource),
        localised_name = {"", {"resource-preset-setting"}, " ", {"item-name."..resource}},
        setting_type = "runtime-global",
        default_value = default,
        allowed_values = shared.allowed_presets,
        order = "zzz-"..string.format("%02d", index),
	}}
end
