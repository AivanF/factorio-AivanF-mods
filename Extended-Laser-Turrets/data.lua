local base_turret = data.raw["electric-turret"]["laser-turret"]
local fast_replaceable_group = base_turret.fast_replaceable_group or "laser-turret"


local function multEnergy(energy, mul)
  local e, u
  e, u = string.match(energy, "(%d+)(%a+)")
  return (tonumber(e) * mul) .. u
end


local function makeLaser(new_name, range_mult, damage_mult, energy_mult, health_mult, health_penalty, tint, ingredients)

  local newBeam = table.deepcopy(data.raw.beam["laser-beam"])
  newBeam.action.action_delivery.target_effects[1].damage.amount = data.raw.beam["laser-beam"].action.action_delivery.target_effects[1].damage.amount * damage_mult
  newBeam.damage_interval = math.max(5, newBeam.damage_interval / math.sqrt(damage_mult))
  newBeam.name = new_name .. "-beam"
  data:extend({ newBeam })

  local newEntity = table.deepcopy(base_turret)
  newEntity.rotation_speed = newEntity.rotation_speed * math.sqrt(math.max(damage_mult, range_mult))
  newEntity.max_health = newEntity.max_health * health_mult
  newEntity.map_color = tint
  newEntity.base_picture.layers[1].tint = tint
  newEntity.base_picture.layers[1].hr_version.tint = tint
  newEntity.folded_animation.layers[1].tint = tint
  newEntity.folded_animation.layers[1].hr_version.tint = tint
  newEntity.folding_animation.layers[1].tint = tint
  newEntity.folding_animation.layers[1].hr_version.tint = tint
  newEntity.prepared_animation.layers[1].tint = tint
  newEntity.prepared_animation.layers[1].hr_version.tint = tint
  newEntity.preparing_animation.layers[1].tint = tint
  newEntity.preparing_animation.layers[1].hr_version.tint = tint
  newEntity.name = new_name
  newEntity.minable.result = new_name
  newEntity.health_penalty = health_penalty
  newEntity.attack_parameters.ammo_type.action.action_delivery.beam = newBeam.name
  newEntity.attack_parameters.ammo_type.action.action_delivery.duration = newBeam.damage_interval
  newEntity.attack_parameters.cooldown = newBeam.damage_interval
  newEntity.attack_parameters.range = newEntity.attack_parameters.range * range_mult
  newEntity.attack_parameters.ammo_type.action.action_delivery.max_length = newEntity.attack_parameters.ammo_type.action.action_delivery.max_length * range_mult
  newEntity.attack_parameters.damage_modifier = newEntity.attack_parameters.damage_modifier * damage_mult
  newEntity.attack_parameters.ammo_type.energy_consumption = multEnergy(data.raw["electric-turret"]["laser-turret"].attack_parameters.ammo_type.energy_consumption, energy_mult)
  newEntity.energy_source.buffer_capacity = multEnergy(data.raw["electric-turret"]["laser-turret"].energy_source.buffer_capacity, energy_mult * 5)
  newEntity.energy_source.input_flow_limit = multEnergy(data.raw["electric-turret"]["laser-turret"].energy_source.input_flow_limit, energy_mult)
  data:extend({ newEntity })

  newEntity.fast_replaceable_group = fast_replaceable_group

  local newItem = table.deepcopy(data.raw["item"]["laser-turret"])
  newItem.icons = {
    {
      icon = "__base__/graphics/icons/laser-turret.png",
      tint = tint,
      icon_mipmaps = 4,
      icon_size = 64,
    }
  }
  newItem.name = new_name
  newItem.localised_description = {"item-description."..new_name}
  newItem.place_result = new_name
  data:extend({newItem})

  local newRecipe = {
    name = new_name,
    -- localised_name = {new_name},
    -- localised_description = {"item-description."..new_name},
    enabled = false,
    energy_required = 20,
    ingredients = ingredients,
    result = new_name,
    type = "recipe"
  }
  data:extend({ newRecipe })

  return newEntity
end


local mk2_long = "laser-turret-mk2-long"
local mk2_stro = "laser-turret-mk2-stro"
local mk3_long = "laser-turret-mk3-long"
local mk3_stro = "laser-turret-mk3-stro"

makeLaser(
  --       dst dmg  en  hp hp_pen
  mk2_long,  2,  1,  4,  4,     1,
  { r = .7, g = 1, b = .8, a = 1}, {
  {"laser-turret", 4}, {"stone-brick", 20}, {"effectivity-module", 1}
})
makeLaser(
  --       dst dmg  en  hp hp_pen
  mk2_stro,  1,  2,  4,  4,    -1,
  { r = .4, g = .7, b = .7, a = 1}, {
  {"laser-turret", 4}, {"stone-brick", 20}, {"speed-module", 1}
})
makeLaser(
  --       dst dmg  en  hp hp_pen
  mk3_long,  4,  2, 16, 10,     1,
  { r = 1, g = .8, b = .6, a = 1}, {
  {mk2_long, 4}, {"concrete", 50}, {"effectivity-module-2", 1}
})
makeLaser(
  --       dst dmg  en  hp hp_pen
  mk3_stro, 2,   4, 16, 10,    -1,
  { r = .8, g = .5, b = .2, a = 1}, {
  {mk2_stro, 4}, {"concrete", 50}, {"speed-module-2", 1}
})
-- mk2_long_ent.next_upgrade = mk3_long
-- mk2_stro_ent.next_upgrade = mk3_stro

local tech2 = "laser-turret-mk2"
local tech3 = "laser-turret-mk3"

data:extend{{
  name = tech2,
  localised_name = {"technology-name."..tech2},
  type = "technology",
  icons = {
    {
      icon = "__base__/graphics/technology/laser-turret.png",
      icon_size = 256, icon_mipmaps = 4,
    },
    {
      icon = "__core__/graphics/icons/technology/constants/constant-range.png",
      icon_size = 128, icon_mipmaps = 3,
      shift = {100, 100},
    }
  },
  effects = {
    { type = "unlock-recipe", recipe = mk2_long },
    { type = "unlock-recipe", recipe = mk2_stro },
  },
  prerequisites = {"laser-turret", "effectivity-module", "speed-module"},
  unit = {
    count = 300,
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"military-science-pack", 1},
      {"chemical-science-pack", 1},
      {"utility-science-pack", 1},
    },
    time = 30
  },
  order = "a-j-b-2"
}, {
  name = tech3,
  localised_name = {"technology-name."..tech3},
  type = "technology",
  icons = {
    {
      icon = "__base__/graphics/technology/laser-turret.png",
      icon_size = 256, icon_mipmaps = 4,
    },
    {
      icon = "__core__/graphics/icons/technology/constants/constant-damage.png",
      icon_size = 128, icon_mipmaps = 3,
      shift = {100, 100},
    }
  },
  effects = {
    { type = "unlock-recipe", recipe = mk3_long },
    { type = "unlock-recipe", recipe = mk3_stro },
  },
  prerequisites = {tech2, "effectivity-module-2", "speed-module-2"},
  unit = {
    count = 500,
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"military-science-pack", 1},
      {"chemical-science-pack", 1},
      {"utility-science-pack", 1},
      {"space-science-pack", 1},
    },
    time = 30
  },
  order = "a-j-b-3"
}}


if mods["space-exploration"] then
  data.raw.technology[tech2].unit.ingredients = {
   {"automation-science-pack", 1},
   {"logistic-science-pack", 1},
   {"military-science-pack", 1},
   {"chemical-science-pack", 1},
   {"se-rocket-science-pack", 1},
  }
  data.raw.technology[tech3].unit.ingredients = {
   {"automation-science-pack", 1},
   {"logistic-science-pack", 1},
   {"military-science-pack", 1},
   {"chemical-science-pack", 1},
   {"se-rocket-science-pack", 1},
   {"utility-science-pack", 1},
  }
end
