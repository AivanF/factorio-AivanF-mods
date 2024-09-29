data:extend{
  ----- Startup
  -- Misc
  {
    name = "wh40k-titans-ruin-prob",
    setting_type = "startup",
    type = "double-setting",
    minimum_value = 0.01,
    default_value = 0.06,
    maximum_value = 0.1,
    order = "a-1",
  },
  {
    name = "wh40k-titans-aai-vehicle",
    setting_type = "startup",
   type = "bool-setting",
    default_value = true,
    order = "a-2",
  },
  -- Combat balance
  {
    name = "wh40k-titans-resist-const",
    setting_type = "startup",
    type = "int-setting",
    minimum_value = 0,
    default_value = 500,
    maximum_value = 10 * 1000,
    order = "a-3",
  },
  {
    name = "wh40k-titans-resist-mult",
    setting_type = "startup",
    type = "int-setting",
    minimum_value = 0,
    default_value = 100,
    maximum_value = 10 * 1000,
    order = "a-4",
  },
  {
    name = "wh40k-titans-base-shield-cap-cf",
    setting_type = "startup",
    type = "int-setting",
    minimum_value = 1,
    default_value = 1,
    maximum_value = 10,
    order = "a-5",
  },
  {
    name = "wh40k-titans-friendly-fire-%",
    setting_type = "startup",
    type = "int-setting",
    minimum_value = 0,
    default_value = 35,
    maximum_value = 100,
    order = "a-6",
  },
  {
    name = "wh40k-titans-void-shield-melee-absorb-%",
    setting_type = "startup",
    type = "int-setting",
    minimum_value = 0,
    default_value = 20,
    maximum_value = 100,
    order = "a-7",
  },
  -- Style
  {
    name = "wh40k-titans-sounds-dst",
    setting_type = "startup",
    type = "double-setting",
    minimum_value = 0.1,
    default_value = 1.0,
    maximum_value = 2.0,
    order = "c-1",
  },
  {
    name = "wh40k-titans-sounds-vol",
    setting_type = "startup",
    type = "double-setting",
    minimum_value = 0.1,
    default_value = 1.0,
    maximum_value = 1.0,
    order = "c-2",
  },
  -- For debugging
  {
    name = "wh40k-titans-debug-border-startup",
    localised_name = {"mod-setting-name.wh40k-titans-debug-border--"},
    localised_description = {"mod-setting-description.wh40k-titans-debug-border--"},
    setting_type = "startup",
    type = "string-setting",
    default_value = "",
    allow_blank = true,
    order = "z-0",
  },
  {
    name = "wh40k-titans-show-damage-types",
    setting_type = "startup",
    type = "bool-setting",
    default_value = false,
    order = "z-1",
  },


  ----- Map/global
  -- Style
  {
    name = "wh40k-titans-talk",
    setting_type = "runtime-global",
    type = "bool-setting",
    default_value = true,
    order = "a-1",
  },
  -- For debugging
  {
    name = "wh40k-titans-debug-border-runtime",
    localised_name = {"mod-setting-name.wh40k-titans-debug-border--"},
    localised_description = {"mod-setting-description.wh40k-titans-debug-border--"},
    setting_type = "runtime-global",
    type = "string-setting",
    default_value = "",
    allow_blank = true,
    order = "z-0",
  },
  {
    name = "wh40k-titans-debug-info",
    setting_type = "runtime-global",
    type = "bool-setting",
    default_value = false,
    order = "z-1",
  },
  {
    name = "wh40k-titans-debug-quick",
    setting_type = "runtime-global",
    type = "bool-setting",
    default_value = false,
    order = "z-2",
  },
}