require "shared"

local floor, ceil, sqrt, min, max = math.floor, math.ceil, math.sqrt, math.min, math.max

local mss = settings.startup["af-meet-stack-size"].value


local function make_sticker(name, heal, ticks_duration, speed_bonus)
  local sticker = {
    type = "sticker",
    name = name,
    flags = {"not-on-map"},
    duration_in_ticks = ticks_duration,
  }
  if heal and heal ~=0 then
    sticker.damage_interval = 2
    sticker.damage_per_tick = { amount = heal * -2 / ticks_duration, type = (heal>0) and "physical" or "poison" }
    -- log('PBB_make_sticker: '..name..', duration: '..ticks_duration..', dmg: '..sticker.damage_per_tick.amount)
  end
  if speed_bonus and speed_bonus~=0 then sticker.target_movement_modifier = 1+speed_bonus end
  return sticker
end


function make_potion(name, stack_size, icon_size, icon_mipmaps, icon, instaheal, heal, duration, speed_bonus, cooldown)
  duration = max(1, duration) * 60
  if cooldown then
    cooldown = cooldown * 60
  else
    cooldown = duration
  end
  local effects = {
    {
      type = "play-sound",
      sound = sounds_eat_fish
    }
  }
  if instaheal and instaheal ~=0 then
    effects[#effects+1] = { type = "damage", damage = {type = (instaheal>0) and "physical" or "poison", amount = -instaheal}}
  end
  if heal and heal ~=0 or speed_bonus and speed_bonus~=0 then
    local stickername = name.."-sticker"
    local sticker = make_sticker(stickername, heal, duration, speed_bonus)
    effects[#effects+1] = { type = "create-sticker", sticker = stickername, show_in_tooltip = true }
    data:extend{sticker}
  end
  data:extend{{
    type = "capsule",
    name = name,
    icon = icon, icon_size = icon_size, icon_mipmaps = icon_mipmaps,
    subgroup = "raw-resource", order = "h[raw-fish]",
    stack_size = stack_size,
    capsule_action = {
      type = "use-on-self",
      attack_parameters = {
        type = "projectile",
        activation_type = "consume",
        ammo_category = "capsule",
        cooldown = cooldown,
        range = 0,
        ammo_type = {
          category = "capsule",
          target_type = "position",
          action = {
            type = "direct",
            action_delivery = {
              type = "instant",
              target_effects = effects
            }
          }
        }
      }
    }
  }}
end


if settings.startup["always-fry"].value then
  --           name           ss isz imm  icon                          insta-heal heal  dur  speed  cd
--make_potion("raw-fish",    100, 64, 4, "__base__/graphics/icons/fish.png",   -40,   0, 3.0, -0.2, 1.0)
  make_potion("raw-meat",    mss, 32, 1, mod_path.."/graphics/meat-raw.png",   -40,   0, 3.0, -0.2, 1.0)
else
--make_potion("raw-fish",    100, 64, 4, "__base__/graphics/icons/fish.png",    40,   0, 2.0, -0.2, 1.0)
  make_potion("raw-meat",    mss, 32, 1, mod_path.."/graphics/meat-raw.png",    40,   0, 2.0, -0.2, 1.0)
end

--           name           ss isz imm  icon                           insta-heal heal  dur  speed  cd
make_potion("fried-fish",  100, 64, 4, mod_path.."/graphics/fried-fish.png",   50,  50, 1.5,  0.1, 1.5)
make_potion("roast-meat",  100, 32, 1, mod_path.."/graphics/roast.png",        50,  50, 1.5,  0.1, 1.5)
make_potion("steamed-bun", 100, 32, 1, mod_path.."/graphics/steamed-bun.png", 100, 150, 3.0,  0.3, 2.0)


data.raw.capsule["steamed-bun"].icon_size = 64

for _, c in pairs(data.raw.character) do
  c.ticks_to_stay_in_combat = c.ticks_to_stay_in_combat + 60 * 5
end

data:extend{
  {
    type = "recipe",
    name = "cook-biter-meat",
    category = "smelting",
    energy_required = 2,
    ingredients = {{ "raw-meat", 5 }},
    result = "roast-meat",
  },
  {
    type = "recipe",
    name = "steamed-bun",
    category = "chemistry",
    energy_required = 5,
    ingredients = {
      { "roast-meat", 4 },
      -- { "raw-fish", 2 },
      { "wood", 4 },
      { type="fluid", name="steam", amount=50 },
    },
    result = "steamed-bun",
  result_count = 2,
  enabled=false,
  },
}

table.insert(data.raw.technology["oil-processing"].effects, {
   type = "unlock-recipe",
   recipe = "steamed-bun",
})
