local shared = require("shared")

local dst_cf = settings.startup["wh40k-titans-sounds-dst"].value
local vol_cf = settings.startup["wh40k-titans-sounds-vol"].value

local to_add = {
  -- https://wiki.factorio.com/Prototype/Sound
  -- https://lua-api.factorio.com/latest/Concepts.html#SoundPath
  -- audible_distance_modifier = 1 means 40 tiles



  ----- Buildings -----
  {
    type = "sound",
    name = "wh40k-titans-assembly-main",
    category = "environment",
    variations = {
      {filename=shared.media_prefix.."sounds/assembly/main-1.wav"},
      {filename=shared.media_prefix.."sounds/assembly/main-2.wav"},
      {filename=shared.media_prefix.."sounds/assembly/main-3.wav"},
    },
    audible_distance_modifier = 3,
  },
  {
    type = "sound",
    name = "wh40k-titans-random-work",
    category = "environment",
    variations = {
      {filename=shared.media_prefix.."sounds/random-work/add-1.wav"},
      {filename=shared.media_prefix.."sounds/random-work/add-2.wav"},
      {filename=shared.media_prefix.."sounds/random-work/add-3.wav"},
      {filename=shared.media_prefix.."sounds/random-work/add-4.wav"},
      {filename=shared.media_prefix.."sounds/random-work/add-5.wav"},
      {filename=shared.media_prefix.."sounds/random-work/add-6.wav"},
    },
    audible_distance_modifier = 3,
  },



  ----- Titan SFXs -----
  {
    type = "sound",
    name = "wh40k-titans-phrase-init",
    category = "game-effect",
    variations = {
      {filename=shared.media_prefix.."sounds/voice/adeptus.wav"},
      {filename=shared.media_prefix.."sounds/voice/fear no darkness.wav"},
      {filename=shared.media_prefix.."sounds/voice/galaxy trembles.wav"},
      {filename=shared.media_prefix.."sounds/voice/void shields.wav"},
      {filename=shared.media_prefix.."sounds/voice/ashes.wav"},
      {filename=shared.media_prefix.."sounds/voice/behold.wav"},
      {filename=shared.media_prefix.."sounds/voice/serve.wav"},
      {filename=shared.media_prefix.."sounds/voice/fight for.wav"},
    },
    allow_random_repeat = true,
    audible_distance_modifier = 15,
  },
  {
    type = "sound",
    name = "wh40k-titans-phrase-walk",
    category = "game-effect",
    variations = {
      {filename=shared.media_prefix.."sounds/voice/fear no darkness.wav"},
      {filename=shared.media_prefix.."sounds/voice/my footsteps.wav"},
      {filename=shared.media_prefix.."sounds/voice/aliens.wav"},
      {filename=shared.media_prefix.."sounds/voice/haha.wav"},
    },
    allow_random_repeat = true,
    audible_distance_modifier = 10,
  },
  {
    type = "sound",
    name = "wh40k-titans-phrase-attack",
    category = "game-effect",
    variations = {
      {filename=shared.media_prefix.."sounds/voice/aliens.wav"},
      {filename=shared.media_prefix.."sounds/voice/haha.wav"},
      {filename=shared.media_prefix.."sounds/voice/clean.wav"},
      {filename=shared.media_prefix.."sounds/voice/die.wav"},
      {filename=shared.media_prefix.."sounds/voice/fight for.wav"},
    },
    allow_random_repeat = true,
    audible_distance_modifier = 10,
  },
  {
    -- TODO: split into for small 1-3 and huge 4-5 classes
    type = "sound",
    name = "wh40k-titans-walk-step",
    category = "game-effect",
    variations = {
      {filename=shared.media_prefix.."sounds/body/step-metal.wav", speed=2},
      {filename=shared.media_prefix.."sounds/body/step-thud-1.wav"},
      {filename=shared.media_prefix.."sounds/body/step-thud-2.wav"},
    },
    allow_random_repeat = true,
    audible_distance_modifier = 10,
  },



  ----- Explosions -----
  {
    type = "sound",
    name = "wh40k-titans-explo-1",
    category = "environment",
    variations = {
      {filename=shared.media_prefix.."sounds/explosions/explo-small-1.wav"},
      {filename=shared.media_prefix.."sounds/explosions/explo-small-2.wav"},
      {filename=shared.media_prefix.."sounds/explosions/explo-small-3.wav"},
    },
    audible_distance_modifier = 2,
  },
  {
    type = "sound",
    name = "wh40k-titans-explo-2",
    category = "environment",
    variations = {
      {filename=shared.media_prefix.."sounds/explosions/explo-medium-1.wav"},
      {filename=shared.media_prefix.."sounds/explosions/explo-medium-2.wav"},
      {filename=shared.media_prefix.."sounds/explosions/explo-medium-3.wav"},
    },
    audible_distance_modifier = 4,
  },
  {
    type = "sound",
    name = "wh40k-titans-explo-3",
    category = "environment",
    variations = {
      {filename=shared.media_prefix.."sounds/explosions/explo-huge.wav"},
    },
    audible_distance_modifier = 8,
  },
  {
    type = "sound",
    name = "wh40k-titans-explo-en",
    category = "environment",
    variations = {
      {filename=shared.media_prefix.."sounds/explosions/explo-energetic.wav"},
    },
    audible_distance_modifier = 10,
  },



  ----- Weapons -----
  {
    type = "sound",
    name = "wh40k-titans-bolter-big",
    category = "environment",
    variations = {
      {filename=shared.media_prefix.."sounds/weapons/bolt-big-x5.wav"},
    },
    audible_distance_modifier = 3,
  },
  {
    type = "sound",
    name = "wh40k-titans-bolter-big-pre",
    category = "environment",
    variations = {
      {filename=shared.media_prefix.."sounds/weapons/bolt-big-x5-pre.wav"},
    },
    audible_distance_modifier = 3,
  },
  {
    type = "sound",
    name = "wh40k-titans-bolter-huge",
    category = "environment",
    variations = {
      {filename=shared.media_prefix.."sounds/weapons/bolt-huge-1.wav"},
      {filename=shared.media_prefix.."sounds/weapons/bolt-huge-2.wav"},
      {filename=shared.media_prefix.."sounds/weapons/bolt-huge-3.wav"},
    },
    audible_distance_modifier = 5,
  },
  {
    type = "sound",
    name = "wh40k-titans-rocket",
    category = "environment",
    variations = {
      {filename=shared.media_prefix.."sounds/weapons/rocket-1.wav"},
      {filename=shared.media_prefix.."sounds/weapons/rocket-2.wav"},
      {filename=shared.media_prefix.."sounds/weapons/rocket-3.wav"},
    },
    audible_distance_modifier = 1,
  },
  {
    type = "sound",
    name = "wh40k-titans-laser",
    category = "environment",
    variations = {
      {filename=shared.media_prefix.."sounds/weapons/laser-1.wav"},
      {filename=shared.media_prefix.."sounds/weapons/laser-2.wav"},
      {filename=shared.media_prefix.."sounds/weapons/laser-3.wav"},
      {filename=shared.media_prefix.."sounds/weapons/laser-4.wav"},
    },
    audible_distance_modifier = 3,
  },
  {
    type = "sound",
    name = "wh40k-titans-plasma-1",
    category = "environment",
    variations = {
      {filename=shared.media_prefix.."sounds/weapons/plasma-1-1.wav"},
      {filename=shared.media_prefix.."sounds/weapons/plasma-1-2.wav"},
      {filename=shared.media_prefix.."sounds/weapons/plasma-1-3.wav"},
    },
    audible_distance_modifier = 4,
  },
  {
    type = "sound",
    name = "wh40k-titans-plasma-2",
    category = "environment",
    variations = {
      {filename=shared.media_prefix.."sounds/weapons/plasma-2.wav"},
    },
    audible_distance_modifier = 6,
  },
  {
    type = "sound",
    name = "wh40k-titans-plasma-pre",
    category = "environment",
    variations = {
      {filename=shared.media_prefix.."sounds/weapons/plasma-pre.wav"},
    },
    audible_distance_modifier = 4,
  },
  {
    type = "sound",
    name = "wh40k-titans-chainsword",
    category = "environment",
    variations = {
      {filename=shared.media_prefix.."sounds/weapons/chainsword-1.wav"},
      {filename=shared.media_prefix.."sounds/weapons/chainsword-2.wav"},
    },
    audible_distance_modifier = 2,
  },
}

for _, obj in pairs(to_add) do
  for _, row in pairs(obj.variations or {}) do
    row.volume = (obj.volume or 1) * (row.volume or 1) * vol_cf
  end
end

data:extend(to_add)
