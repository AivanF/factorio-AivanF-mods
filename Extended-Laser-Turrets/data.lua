local base_turret = data.raw["electric-turret"]["laser-turret"]
local fast_replaceable_group = base_turret.fast_replaceable_group or "laser-turret"


local function multEnergy(energy, mul)
  local e, u
  e, u = string.match(energy, "(%d+)(%a+)")
  return (tonumber(e) * mul) .. u
end

local damage_set = settings.startup["af-elt-dmg-cf"].value
local range_set  = settings.startup["af-elt-dst-cf"].value
local energy_set = settings.startup["af-elt-pwr-cf"].value
local health_set = settings.startup["af-elt-hp-cf"].value

local function make_resistances(resist)
  return {
    {
      type = "physical",
      decrease = 5 ^ resist,
      percent = 20
    }, {
      type = "impact",
      decrease = 5 ^ resist,
      percent = 50
    }, {
      type = "explosion",
      decrease = 10 ^ resist,
      percent = 30
    }, {
      type = "fire",
      percent = 100
    }, {
      type = "acid",
      decrease = 5 ^ resist,
      percent = 80
    }, {
      type = "laser",
      decrease = 5 ^ resist,
      percent = 70
    }
  }
end


local function makeLaser(new_name, range_cf, damage_cf, energy_cf, health_cf, health_penalty, tint, ingredients)
  local range_mult = range_set ^ range_cf
  local damage_mult = damage_set ^ damage_cf
  local energy_mult = energy_set ^ energy_cf
  local health_mult = health_set ^ health_cf

  local descr
  if health_cf >= 2 then
    if damage_cf > range_cf then
      descr = {"item-description.laser-turret-mk3-stro", ""..damage_mult, ""..range_mult}
    else
      descr = {"item-description.laser-turret-mk3-long", ""..math.floor(range_mult), ""..damage_mult}
    end
  else
    if damage_cf > range_cf then
      descr = {"item-description.laser-turret-mk2-stro", ""..damage_mult}
    else
      descr = {"item-description.laser-turret-mk2-long", ""..range_mult}
    end
  end

  local newBeam = table.deepcopy(data.raw.beam["laser-beam"])
  newBeam.action.action_delivery.target_effects[1].damage.amount = data.raw.beam["laser-beam"].action.action_delivery.target_effects[1].damage.amount * damage_mult
  newBeam.damage_interval = math.max(5, newBeam.damage_interval / math.sqrt(damage_mult))
  newBeam.name = new_name .. "-beam"
  data:extend({ newBeam })

  local newEntity = table.deepcopy(base_turret)
  newEntity.localised_description = descr
  newEntity.rotation_speed = newEntity.rotation_speed * math.sqrt(math.max(damage_mult, range_mult))
  newEntity.max_health = newEntity.max_health * health_mult
  newEntity.resistances = make_resistances(health_cf)
  newEntity.map_color = tint
  -- newEntity.base_picture.layers[1].tint = tint
  newEntity.folded_animation.layers[1].tint = tint
  newEntity.folding_animation.layers[1].tint = tint
  newEntity.prepared_animation.layers[1].tint = tint
  newEntity.preparing_animation.layers[1].tint = tint
  newEntity.name = new_name
  newEntity.minable.result = new_name
  newEntity.health_penalty = health_penalty
  newEntity.attack_parameters.ammo_type.action.action_delivery.beam = newBeam.name
  newEntity.attack_parameters.ammo_type.action.action_delivery.duration = newBeam.damage_interval
  newEntity.attack_parameters.cooldown = newBeam.damage_interval
  newEntity.attack_parameters.range = newEntity.attack_parameters.range * range_mult
  newEntity.attack_parameters.ammo_type.action.action_delivery.max_length = newEntity.attack_parameters.ammo_type.action.action_delivery.max_length * range_mult
  newEntity.attack_parameters.damage_modifier = newEntity.attack_parameters.damage_modifier * math.sqrt(damage_mult)
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
    },
    (damage_cf > range_cf) and {
      icon = "__core__/graphics/icons/technology/effect-constant/effect-constant-range.png",
      icon_mipmaps = 2,
      icon_size = 64,
      scale = 0.3 + health_cf/4,
      shift = {8, 16},
    } or {
      icon = "__core__/graphics/icons/technology/effect-constant/effect-constant-damage.png",
      icon_mipmaps = 2,
      icon_size = 64,
      scale = 0.3 + health_cf/4,
      shift = {8, 16},
    },
  }
  newItem.name = new_name
  newItem.place_result = new_name
  data:extend({newItem})

  local newRecipe = {
    type = "recipe",
    name = new_name,
    enabled = false,
    energy_required = 20,
    ingredients = ingredients,
    results = {{type="item", name=new_name, amount=1}},
  }
  data:extend({ newRecipe })

  return newEntity
end


local mk2_long = "laser-turret-mk2-long"
local mk2_stro = "laser-turret-mk2-stro"
local mk3_long = "laser-turret-mk3-long"
local mk3_stro = "laser-turret-mk3-stro"

local mk2_long_tint = { r = .7, g = 0.8, b = 1, a = 1}
local mk2_long_ent = makeLaser(
  --       dst dmg  en  hp hp_pen
  mk2_long,  1,  0,  1,  1,     2,
  mk2_long_tint, {
  {type="item", name="laser-turret", amount=4},
  {type="item", name="stone-brick", amount=20},
  {type="item", name="efficiency-module", amount=1},
})

local mk2_stro_tint = { r = .4, g = .7, b = .7, a = 1}
local mk2_stro_ent = makeLaser(
  --       dst dmg  en  hp hp_pen
  mk2_stro,  0,  1,  1,  1,    -2,
  mk2_stro_tint, {
    {type="item", name="laser-turret", amount=4},
    {type="item", name="stone-brick", amount=20},
    {type="item", name="speed-module", amount=1},
})

local mk3_long_tint = { r = 1, g = .8, b = .6, a = 1}
makeLaser(
  --       dst dmg  en  hp hp_pen
  mk3_long,1.5,  1,  2,  2,    1,
  mk3_long_tint, {
    {type="item", name=mk2_long, amount=4},
    {type="item", name="concrete", amount=50},
    {type="item", name="efficiency-module-2", amount=1},
})

local mk3_stro_tint = { r = .8, g = .4, b = .2, a = 1}
makeLaser(
  --       dst dmg  en  hp hp_pen
  mk3_stro,  1,  2,  2,  2,    -3,
  mk3_stro_tint, {
    {type="item", name=mk2_stro, amount=4},
    {type="item", name="concrete", amount=50},
    {type="item", name="speed-module-2", amount=1},
})
mk2_long_ent.next_upgrade = mk3_long
mk2_stro_ent.next_upgrade = mk3_stro

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
      tint = mk2_stro_tint,
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
  prerequisites = {"laser-turret", "efficiency-module", "speed-module"},
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
      tint = mk3_stro_tint,
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
  prerequisites = {tech2, "efficiency-module-2", "speed-module-2"},
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
   {"space-science-pack", 1},
   {"utility-science-pack", 1},
  }
end
