data:extend{
  ----- Startup
  {
    name = "vehitel-improve-car",
    setting_type = "startup",
    type = "bool-setting",
    default_value = true,
    order = "a-1",
  },
  {
    name = "vehitel-energy-stored-cf",
    setting_type = "startup",
    type = "double-setting",
    minimum_value = 0.1,
    default_value = 2,
    maximum_value = 10,
    order = "a-2",
  },

  ----- Map/global
  {
    name = "vehitel-fuel-energy-required-cf",
    setting_type = "runtime-global",
    type = "double-setting",
    minimum_value = 0.1,
    default_value = 1,
    maximum_value = 10,
    order = "a-1",
  },
  {
    name = "vehitel-grid-energy-required-cf",
    setting_type = "runtime-global",
    type = "double-setting",
    minimum_value = 0.1,
    default_value = 1,
    maximum_value = 10,
    order = "a-2",
  },
}