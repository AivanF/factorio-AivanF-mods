data:extend{
  {
    type = "double-setting",
    name = "af-reverse-lab-prob-mult",
    setting_type = "runtime-global",
    minimum_value = 0.1,
    default_value = 1,
    maximum_value = 10,
    order = "a-1",
  },
  {
    type = "int-setting",
    name = "af-reverse-lab-research-revprob",
    setting_type = "runtime-global",
    minimum_value = 0,
    default_value = 200,
    maximum_value = 100000,
    order = "a-2",
  },
}