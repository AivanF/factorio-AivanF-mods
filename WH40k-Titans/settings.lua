data:extend{
  -- Startup
  {
    type = "double-setting",
    name = "wh40k-titans-ruin-prob",
    setting_type = "startup",
    minimum_value = 0.01,
    default_value = 0.06,
    maximum_value = 0.1,
    order = "a-1",
  },
  {
   type = "bool-setting",
    name = "wh40k-titans-aai-vehicle",
    setting_type = "startup",
    default_value = true,
    order = "a-2",
  },
  {
    type = "int-setting",
    name = "wh40k-titans-base-shield-cap-cf",
    setting_type = "startup",
    minimum_value = 1,
    default_value = 1,
    maximum_value = 10,
    order = "a-3",
  },

  -- Map/global
  {
    type = "bool-setting",
    name = "wh40k-titans-talk",
    setting_type = "runtime-global",
    default_value = true,
    order = "a-1",
  },
}