local damage = 75
local duration = 15
local interval = 1
local per_tick = damage / (1 + interval)

data:extend({
  -- https://wiki.factorio.com/Prototype/Sticker
  {
    type = "sticker",
    name = "tsl-damage-1",
    flags = {"not-on-map"},
    duration_in_ticks = duration,
    damage_interval = interval,
    damage_per_tick = { amount = per_tick, type = "physical" }
  },
  {
    type = "sticker",
    name = "tsl-damage-2",
    flags = {"not-on-map"},
    duration_in_ticks = duration,
    damage_interval = interval,
    damage_per_tick = { amount = per_tick, type = "electric" }
  },

  -- https://wiki.factorio.com/Prototype/Sprite
  -- https://lua-api.factorio.com/latest/Concepts.html#SpritePath
  {
    type="sprite",
    name="tsl-lightning",
    filename="__Lightning__/graphics/fx/lightning.png",
    width=512,
    height=1024,
    shift=util.by_pixel(0, -512),
    blend_mode="additive",
  },
  {
    type="sprite",
    name="tsl-energy-1",
    filename="__Lightning__/graphics/icons/energy-1.png",
    width=64,
    height=64,
    scale=0.5,
    shift=util.by_pixel(0, -16),
  },
  {
    type="sprite",
    name="tsl-energy-2",
    filename="__Lightning__/graphics/icons/energy-2.png",
    width=64,
    height=64,
    scale=0.5,
    shift=util.by_pixel(0, -16),
  },
  {
    type="sprite",
    name="tsl-energy-3",
    filename="__Lightning__/graphics/icons/energy-3.png",
    width=64,
    height=64,
    scale=0.5,
    shift=util.by_pixel(0, -16),
  },
  {
    type="sprite",
    name="tsl-energy-4",
    filename="__Lightning__/graphics/icons/energy-4.png",
    width=64,
    height=64,
    scale=0.5,
    shift=util.by_pixel(0, -16),
  },
  {
    type="sprite",
    name="tsl-energy-5",
    filename="__Lightning__/graphics/icons/energy-5.png",
    width=64,
    height=64,
    scale=0.5,
    shift=util.by_pixel(0, -16),
  },

  -- https://wiki.factorio.com/Prototype/Sound
  -- https://lua-api.factorio.com/latest/Concepts.html#SoundPath
  {
    type="sound",
    name="tsl-lightning",
    category="game-effect",
    variations={
      {filename="__Lightning__/sounds/lightning-1.wav", min_speed=0.8, max_speed=1.2},
      {filename="__Lightning__/sounds/lightning-2.wav", min_speed=0.8, max_speed=1.2},
      {filename="__Lightning__/sounds/lightning-3.wav", min_speed=0.8, max_speed=1.2},
    },
    audible_distance_modifier=10,
  },
  {
    type="sound",
    name="tsl-charging",
    category="game-effect",
    variations={
      {filename="__Lightning__/sounds/charge-1.wav", min_speed=0.9, max_speed=1.1},
      {filename="__Lightning__/sounds/charge-2.wav", min_speed=0.9, max_speed=1.1},
      {filename="__Lightning__/sounds/charge-3.wav", min_speed=0.9, max_speed=1.1},
    },
    audible_distance_modifier=3,
  },
})
