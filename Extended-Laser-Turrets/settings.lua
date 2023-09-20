local def_damage = 2
local def_range  = 2
local def_energy = 4
local def_health = 3

local dangerous_mods = {
  "bobenemies",
  "RampantFixed",
  "Rampant",
  "Big-Monsters",
  "SchallEndgameEvolution",
  "Natural_Evolution_Enemies",
  "Nova-Natural_Evolution_Enemies",
  -- "Cold_biters",
  -- "Explosive_biters",
}
for _, name in pairs(dangerous_mods) do
  if mods[name] then
    def_damage = 3
    def_range  = 3
    def_energy = 3
    def_health = 4
    break
  end
end


data:extend{
  {
    type = "int-setting",
    name = "af-elt-dmg-cf",
    setting_type = "startup",
    minimum_value = 2,
    default_value = def_damage,
    maximum_value = 50,
    order = "a-1",
  },
  {
    type = "int-setting",
    name = "af-elt-dst-cf",
    setting_type = "startup",
    minimum_value = 2,
    default_value = def_range,
    maximum_value = 5,
    order = "a-2",
  },
  {
    type = "int-setting",
    name = "af-elt-pwr-cf",
    setting_type = "startup",
    minimum_value = 2,
    default_value = def_energy,
    maximum_value = 50,
    order = "a-3",
  },
  {
    type = "int-setting",
    name = "af-elt-hp-cf",
    setting_type = "startup",
    minimum_value = 1,
    default_value = def_health,
    maximum_value = 20,
    order = "a-4",
  },
}
