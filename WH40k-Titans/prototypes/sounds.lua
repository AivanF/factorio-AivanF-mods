local shared = require("shared")

data:extend({
  -- https://wiki.factorio.com/Prototype/Sound
  -- https://lua-api.factorio.com/latest/Concepts.html#SoundPath
  {
    type="sound",
    name="wh40k-titans-phrase-init",
    category="game-effect",
    variations={
      {filename=shared.media_prefix.."sounds/voice/adeptus.wav"},
      {filename=shared.media_prefix.."sounds/voice/fear no darkness.wav"},
      {filename=shared.media_prefix.."sounds/voice/galaxy trembles.wav"},
      {filename=shared.media_prefix.."sounds/voice/void shields.wav"},
      {filename=shared.media_prefix.."sounds/voice/ashes.wav"},
      {filename=shared.media_prefix.."sounds/voice/behold.wav"},
      {filename=shared.media_prefix.."sounds/voice/serve.wav"},
      {filename=shared.media_prefix.."sounds/voice/fight for.wav"},
    },
    audible_distance_modifier=15,
  },
  {
    type="sound",
    name="wh40k-titans-phrase-walk",
    category="game-effect",
    variations={
      {filename=shared.media_prefix.."sounds/voice/fear no darkness.wav"},
      {filename=shared.media_prefix.."sounds/voice/my footsteps.wav"},
      {filename=shared.media_prefix.."sounds/voice/aliens.wav"},
      {filename=shared.media_prefix.."sounds/voice/haha.wav"},
    },
    audible_distance_modifier=10,
  },
  {
    type="sound",
    name="wh40k-titans-phrase-attack",
    category="game-effect",
    variations={
      {filename=shared.media_prefix.."sounds/voice/aliens.wav"},
      {filename=shared.media_prefix.."sounds/voice/haha.wav"},
      {filename=shared.media_prefix.."sounds/voice/clean.wav"},
      {filename=shared.media_prefix.."sounds/voice/die.wav"},
      {filename=shared.media_prefix.."sounds/voice/fight for.wav"},
    },
    audible_distance_modifier=10,
  },
  {
    -- TODO: split into for small 1-3 and huge 4-5 classes
    type="sound",
    name="wh40k-titans-walk-step",
    category="game-effect",
    variations={
      {filename=shared.media_prefix.."sounds/body/step-metal.wav", speed=2},
      {filename=shared.media_prefix.."sounds/body/step-thud-1.wav"},
      {filename=shared.media_prefix.."sounds/body/step-thud-2.wav"},
    },
    audible_distance_modifier=10,
  },
  {
    type="sound",
    name="wh40k-titans-assembly-main",
    category="environment",
    variations={
      {filename=shared.media_prefix.."sounds/assembly/main-1.wav"},
      {filename=shared.media_prefix.."sounds/assembly/main-2.wav"},
      {filename=shared.media_prefix.."sounds/assembly/main-3.wav"},
    },
    audible_distance_modifier=3,
  },
  {
    type="sound",
    name="wh40k-titans-assembly-add",
    category="environment",
    variations={
      {filename=shared.media_prefix.."sounds/assembly/add-1.wav"},
      {filename=shared.media_prefix.."sounds/assembly/add-2.wav"},
      {filename=shared.media_prefix.."sounds/assembly/add-3.wav"},
      {filename=shared.media_prefix.."sounds/assembly/add-4.wav"},
      {filename=shared.media_prefix.."sounds/assembly/add-5.wav"},
      {filename=shared.media_prefix.."sounds/assembly/add-6.wav"},
    },
    audible_distance_modifier=5,
  },
})
