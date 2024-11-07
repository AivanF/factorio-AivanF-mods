local shared = require("shared")
local misc = require("prototypes.misc")
local sounds = require("__base__.prototypes.entity.sounds")
local fireutil = require("__base__.prototypes.fire-util")

local function find_sound(name)
return data.raw.sound[name]
end

data:extend({
{
  type = "damage-type",
  name = shared.step_damage,
  hidden = not settings.startup["wh40k-titans-show-damage-types"].value,
},
{
  type = "damage-type",
  name = shared.melee_damage,
  hidden = not settings.startup["wh40k-titans-show-damage-types"].value,
},
{
  type = "damage-type",
  name = shared.mepow_damage,
  hidden = not settings.startup["wh40k-titans-show-damage-types"].value,
},
{
  type = "custom-input",
  name = shared.mod_prefix.."attack-1",
  key_sequence = "Z",
  action = "lua",
},
{
  type = "custom-input",
  name = shared.mod_prefix.."attack-2",
  key_sequence = "X",
  action = "lua",
},
{
  type = "custom-input",
  name = shared.mod_prefix.."attack-3",
  key_sequence = "C",
  action = "lua",
},
{
  type = "custom-input",
  name = shared.mod_prefix.."attack-4",
  key_sequence = "V",
  action = "lua",
},

{
  type = "projectile",
  name = shared.mod_prefix.."bolt-melee",
  flags = {"not-on-map"},
  acceleration = 0.01,
  turn_speed = 0.1,
  action = {
    {
      type = "direct",
      action_delivery = {
        type = "instant",
        target_effects = {
          {
            type = "destroy-decoratives",
            include_soft_decoratives = true,
            include_decals = true,
            invoke_decorative_trigger = true,
            decoratives_with_trigger_only = false,
            radius = 1
          },
          -- {
          --   type = "create-entity",
          --   entity_name = "medium-scorchmark",
          --   offsets = {{ 0, 0 }},
          --   check_buildability = true
          -- },
          {
            type = "create-entity",
            -- entity_name = "medium-explosion"
            entity_name = "explosion"
          },
        }
      }
    },
    {
      type = "area",
      radius = 6,
      ignore_collision_condition = true,
      action_delivery = {
        type = "instant",
        target_effects = {
          {
            type = "damage",
            lower_distance_threshold = 6,
            upper_distance_threshold = 3,
            lower_damage_modifier = 1,
            upper_damage_modifier = 0.2,
            damage = {amount = 10000, type = "impact"}
          },
          {
            type = "damage",
            lower_distance_threshold = 6,
            upper_distance_threshold = 3,
            lower_damage_modifier = 1,
            upper_damage_modifier = 0.2,
            damage = {amount = 10000, type = shared.melee_damage}
          },
        }
      }
    },
  },
  animation = misc.empty_sprite,
},

{
  type = "projectile",
  name = shared.mod_prefix.."bolt-melee-energy",
  flags = {"not-on-map"},
  acceleration = 0.01,
  turn_speed = 0.1,
  action = {
    {
      type = "direct",
      action_delivery = {
        type = "instant",
        target_effects = {
          {
            type = "destroy-decoratives",
            include_soft_decoratives = true,
            include_decals = true,
            invoke_decorative_trigger = true,
            decoratives_with_trigger_only = false,
            radius = 2
          },
          -- {
          --   type = "create-entity",
          --   entity_name = "medium-scorchmark",
          --   offsets = {{ 0, 0 }},
          --   check_buildability = true
          -- },
          {
            type = "create-entity",
            -- entity_name = "medium-explosion"
            entity_name = "explosion"
          },
        }
      }
    },
    {
      type = "area",
      radius = 7,
      ignore_collision_condition = true,
      action_delivery = {
        type = "instant",
        target_effects = {
          {
            type = "damage",
            lower_distance_threshold = 7,
            upper_distance_threshold = 3,
            lower_damage_modifier = 1,
            upper_damage_modifier = 0.2,
            damage = {amount = 10000, type = "impact"}
          },
          {
            type = "damage",
            lower_distance_threshold = 7,
            upper_distance_threshold = 3,
            lower_damage_modifier = 1,
            upper_damage_modifier = 0.2,
            damage = {amount = 5000, type = shared.melee_damage}
          },
          {
            type = "damage",
            lower_distance_threshold = 7,
            upper_distance_threshold = 4,
            lower_damage_modifier = 1,
            upper_damage_modifier = 0.2,
            damage = {amount = 15000, type = shared.mepow_damage}
          },
          {
            type = "damage",
            lower_distance_threshold = 7,
            upper_distance_threshold = 4,
            lower_damage_modifier = 1,
            upper_damage_modifier = 0.2,
            damage = {amount = 5000, type = "explosion"}
          },
        }
      }
    },
  },
  animation = {
    filename=shared.media_prefix.."graphics/fx/Plasma.png",
    draw_as_glow = true,
    frame_count = 1,
    line_length = 1,
    width = 320,
    height = 320,
    scale = 0.5,
    shift = {0, 0},
    priority = "high"
  },
},

{
  type = "projectile",
  name = shared.mod_prefix.."bolt-big",
  flags = {"not-on-map"},
  collision_box = {{-0.5, -1.5}, {0.5, 1.5}},
  acceleration = 0,
  piercing_damage = 500,
  -- action = {
  --   type = "direct",
  --   action_delivery = {
  --     type = "instant",
  --     target_effects = {
  --       -- TODO: add some cannon explo?
  --       {
  --         type = "create-entity",
  --         entity_name = "uranium-cannon-explosion"
  --       }
  --     }
  --   }
  -- },
  final_action = {
    type = "direct",
    action_delivery = {
      type = "instant",
      target_effects = {
        {
          type = "create-entity",
          entity_name = "medium-explosion"
        },
        {
          type = "nested-result",
          action = {
            type = "area",
            radius = 5,
            action_delivery = {
              type = "instant",
              target_effects = {
                {
                  type = "damage",
                  damage = {amount = 500, type = "physical"}
                },
                {
                  type = "damage",
                  damage = {amount = 1000, type = "explosion"}
                },
                {
                  type = "create-entity",
                  entity_name = "explosion"
                }
              }
            }
          }
        },
        {
          type = "create-entity",
          entity_name = "medium-scorchmark-tintable",
          check_buildability = true
        },
        {
          type = "invoke-tile-trigger",
          repeat_count = 1
        },
        {
          type = "destroy-decoratives",
          from_render_layer = "decorative",
          to_render_layer = "object",
          include_soft_decoratives = true,
          include_decals = false,
          invoke_decorative_trigger = true,
          decoratives_with_trigger_only = false, -- if true, destroys only decoratives that have trigger_effect set
          radius = 3
        }
      }
    }
  },
  animation = {
    filename = shared.media_prefix.."graphics/fx/rocket.png",
    draw_as_glow = true,
    frame_count = 8,
    line_length = 8,
    width = 18,
    height = 70,
    shift = {0, 0},
    priority = "high"
  },
  shadow = {
    filename = shared.media_prefix.."graphics/fx/rocket-shadow.png",
    frame_count = 1,
    width = 14,
    height = 28,
    priority = "high",
    shift = {0, 0}
  },
  smoke = {
    {
      name = "smoke-fast",
      deviation = {0.15, 0.15},
      frequency = 2,
      position = {0, 1},
      slow_down_factor = 1,
      starting_frame = 3,
      starting_frame_deviation = 5,
      starting_frame_speed = 0,
      starting_frame_speed_deviation = 5
    }
  }
},

{
  type = "projectile",
  name = shared.mod_prefix.."bolt-huge",
  flags = {"not-on-map"},
  collision_box = {{-0.5, -1.5}, {0.5, 1.5}},
  acceleration = 0,
  piercing_damage = 750,
  action = {
    type = "direct",
    action_delivery = {
      type = "instant",
      target_effects = {
        {
          type = "damage",
          damage = {amount = 1000 , type = "physical"}
        },
        -- TODO: add some cannon explo?
        -- {
        --   type = "create-entity",
        --   entity_name = "uranium-cannon-explosion"
        -- }
      }
    }
  },
  final_action = {
    type = "direct",
    action_delivery = {
      type = "instant",
      target_effects = {
        {
          type = "create-entity",
          entity_name = "big-explosion"
        },
        {
          type = "nested-result",
          action = {
            type = "area",
            radius = 7,
            action_delivery = {
              type = "instant",
              target_effects = {
                {
                  type = "damage",
                  damage = {amount = 2000, type = "explosion"}
                },
                {
                  type = "create-entity",
                  entity_name = "big-explosion"
                }
              }
            }
          }
        },
        {
          type = "create-entity",
          entity_name = "medium-scorchmark-tintable",
          check_buildability = true
        },
        {
          type = "invoke-tile-trigger",
          repeat_count = 1
        },
        {
          type = "destroy-decoratives",
          from_render_layer = "decorative",
          to_render_layer = "object",
          include_soft_decoratives = true,
          include_decals = false,
          invoke_decorative_trigger = true,
          decoratives_with_trigger_only = false, -- if true, destroys only decoratives that have trigger_effect set
          radius = 3.25 -- large radius for demostrative purposes
        }
      }
    }
  },
  animation = {
    filename = shared.media_prefix.."graphics/fx/rocket.png",
    draw_as_glow = true,
    frame_count = 8,
    line_length = 8,
    width = 18,
    height = 70,
    shift = {0, 0},
    priority = "high"
  },
  shadow = {
    filename = shared.media_prefix.."graphics/fx/rocket-shadow.png",
    frame_count = 1,
    width = 14,
    height = 28,
    priority = "high",
    shift = {0, 0}
  },
  smoke = {
    {
      name = "smoke-fast",
      deviation = {0.15, 0.15},
      frequency = 2,
      position = {0, 1},
      slow_down_factor = 1,
      starting_frame = 3,
      starting_frame_deviation = 5,
      starting_frame_speed = 0,
      starting_frame_speed_deviation = 5
    }
  }
},

{
  type = "projectile",
  name = shared.mod_prefix.."cannon-shell",
  flags = {"not-on-map"},
  collision_box = {{-0.5, -1.5}, {0.5, 1.5}},
  acceleration = 0,
  piercing_damage = 750,
  action = {
    type = "direct",
    action_delivery = {
      type = "instant",
      target_effects = {
        {
          type = "damage",
          damage = {amount = 1000 , type = "physical"}
        },
        -- TODO: add some cannon explo?
        -- {
        --   type = "create-entity",
        --   entity_name = "uranium-cannon-explosion"
        -- }
      }
    }
  },
  final_action = {
    type = "direct",
    action_delivery = {
      type = "instant",
      target_effects = {
        {
          type = "create-entity",
          entity_name = "big-explosion"
        },
        {
          type = "nested-result",
          action = {
            type = "area",
            radius = 5,
            action_delivery = {
              type = "instant",
              target_effects = {
                {
                  type = "damage",
                  damage = {amount = 2000, type = "explosion"}
                },
                {
                  type = "damage",
                  damage = {amount = 2000, type = "physical"}
                },
                {
                  type = "create-entity",
                  entity_name = "medium-explosion"
                }
              }
            }
          }
        },
        {
          type = "create-entity",
          entity_name = "medium-scorchmark-tintable",
          check_buildability = true
        },
        {
          type = "invoke-tile-trigger",
          repeat_count = 1
        },
        {
          type = "destroy-decoratives",
          from_render_layer = "decorative",
          to_render_layer = "object",
          include_soft_decoratives = true,
          include_decals = false,
          invoke_decorative_trigger = true,
          decoratives_with_trigger_only = false, -- if true, destroys only decoratives that have trigger_effect set
          radius = 3.25 -- large radius for demostrative purposes
        }
      }
    }
  },
  animation = {
    filename = shared.media_prefix.."graphics/fx/rocket.png",
    draw_as_glow = true,
    frame_count = 8,
    line_length = 8,
    width = 18,
    height = 70,
    shift = {0, 0},
    priority = "high"
  },
  shadow = {
    filename = shared.media_prefix.."graphics/fx/rocket-shadow.png",
    frame_count = 1,
    width = 14,
    height = 28,
    priority = "high",
    shift = {0, 0}
  },
  smoke = {
    {
      name = "smoke-fast",
      deviation = {0.15, 0.15},
      frequency = 2,
      position = {0, 1},
      slow_down_factor = 1,
      starting_frame = 3,
      starting_frame_deviation = 5,
      starting_frame_speed = 0,
      starting_frame_speed_deviation = 5
    }
  }
},

{
  type = "projectile",
  name = shared.mod_prefix.."explosive-rocket",
  flags = {"not-on-map"},
  acceleration = 0.01,
  turn_speed = 0.005,
  turning_speed_increases_exponentially_with_projectile_speed = true,
  action = {
    type = "direct",
    action_delivery = {
      type = "instant",
      target_effects = {
        {
          type = "create-entity",
          entity_name = "big-explosion"
        },
        {
          type = "damage",
          damage = {amount = 300, type = "physical"}
        },
        {
          type = "create-entity",
          entity_name = "medium-scorchmark-tintable",
          check_buildability = true
        },
        {
          type = "invoke-tile-trigger",
          repeat_count = 1
        },
        {
          type = "destroy-decoratives",
          from_render_layer = "decorative",
          to_render_layer = "object",
          include_soft_decoratives = true,
          include_decals = false,
          invoke_decorative_trigger = true,
          decoratives_with_trigger_only = false,
          radius = 3.5 -- large radius for demostrative purposes
        },
        {
          type = "nested-result",
          action = {
            type = "area",
            radius = 9,
            action_delivery = {
              type = "instant",
              target_effects = {
                {
                  type = "damage",
                  damage = {amount = 700, type = "explosion"}
                },
                {
                  type = "create-entity",
                  entity_name = "explosion"
                }
              }
            }
          }
        }
      }
    }
  },
  light = {intensity = 0.5, size = 4},
  animation = {
    filename = shared.media_prefix.."graphics/fx/rocket.png",
    draw_as_glow = true,
    frame_count = 8,
    line_length = 8,
    width = 18,
    height = 70,
    shift = {0, 0},
    priority = "high"
  },
  shadow = {
    filename = shared.media_prefix.."graphics/fx/rocket-shadow.png",
    frame_count = 1,
    width = 14,
    height = 28,
    priority = "high",
    shift = {0, 0}
  },
  smoke = {
    {
      name = "smoke-fast",
      deviation = {0.15, 0.15},
      frequency = 2,
      position = {0, 1},
      slow_down_factor = 1,
      starting_frame = 3,
      starting_frame_deviation = 5,
      starting_frame_speed = 0,
      starting_frame_speed_deviation = 5
    }
  }
},

{
  type = "projectile",
  name = shared.mod_prefix.."bolt-volcano",
  flags = {"not-on-map"},
  acceleration = 0.002,
  turn_speed = 0.01,
  action = {
    {
      type = "direct",
      action_delivery = {
        type = "instant",
        target_effects = {
          {
            type = "destroy-decoratives",
            include_soft_decoratives = true,
            include_decals = true,
            invoke_decorative_trigger = true,
            decoratives_with_trigger_only = false,
            radius = 6
          },
          {
            type = "create-entity",
            entity_name = "huge-scorchmark",
            offsets = {{ 0, -0.5 }},
            check_buildability = true
          },
          {
            type = "create-entity",
            entity_name = "medium-explosion"
          },
          {
            type = "play-sound",
            sound = find_sound("wh40k-titans-explo-2"),
            play_on_target_position = false,
            max_distance = 1000,
            -- volume_modifier = 1,
            audible_distance_modifier = 3
          },
        }
      }
    },
    {
      type = "area",
      radius = 12,
      ignore_collision_condition = true,
      action_delivery = {
        type = "instant",
        target_effects = {
          {
            type = "damage",
            lower_distance_threshold = 6,
            upper_distance_threshold = 12,
            lower_damage_modifier = 1,
            upper_damage_modifier = 0.2,
            damage = {amount = 10000, type = "explosion"}
          },
          {
            type = "damage",
            lower_distance_threshold = 6,
            upper_distance_threshold = 12,
            lower_damage_modifier = 1,
            upper_damage_modifier = 0.2,
            damage = {amount = 5000, type = "laser"}
          },
          {
            type = "damage",
            lower_distance_threshold = 6,
            upper_distance_threshold = 12,
            lower_damage_modifier = 1,
            upper_damage_modifier = 0.2,
            damage = {amount = 5000, type = "fire"}
          },
          {
            type = "damage",
            lower_distance_threshold = 6,
            upper_distance_threshold = 12,
            lower_damage_modifier = 1,
            upper_damage_modifier = 0.2,
            damage = {amount = 5000, type = "electric"}
          },
        }
      }
    },
  },
  animation = {
    filename=shared.media_prefix.."graphics/fx/Volcano.png",
    draw_as_glow = true,
    frame_count = 1,
    line_length = 1,
    width = 300,
    height = 612,
    shift = {0, 0},
    priority = "high"
  },
},

{
  type = "projectile",
  name = shared.mod_prefix.."bolt-laser",
  flags = {"not-on-map"},
  acceleration = 0.002,
  turn_speed = 0.01,
  action = {
    {
      type = "direct",
      action_delivery = {
        type = "instant",
        target_effects = {
          {
            type = "destroy-decoratives",
            include_soft_decoratives = true,
            include_decals = true,
            invoke_decorative_trigger = true,
            decoratives_with_trigger_only = false,
            radius = 4
          },
          {
            type = "create-entity",
            entity_name = "huge-scorchmark",
            offsets = {{ 0, -0.5 }},
            check_buildability = true
          },
          {
            type = "create-entity",
            entity_name = "medium-explosion"
          },
          {
            type = "play-sound",
            sound = find_sound("wh40k-titans-explo-1"),
            play_on_target_position = false,
            max_distance = 500,
            -- volume_modifier = 1,
            audible_distance_modifier = 3
          },
        }
      }
    },
    {
      type = "area",
      radius = 9,
      ignore_collision_condition = true,
      action_delivery = {
        type = "instant",
        target_effects = {
          {
            type = "damage",
            lower_distance_threshold = 4,
            upper_distance_threshold = 8,
            lower_damage_modifier = 1,
            upper_damage_modifier = 0.2,
            damage = {amount = 2000, type = "explosion"}
          },
          {
            type = "damage",
            lower_distance_threshold = 4,
            upper_distance_threshold = 8,
            lower_damage_modifier = 1,
            upper_damage_modifier = 0.2,
            damage = {amount = 3000, type = "laser"}
          },
          {
            type = "damage",
            lower_distance_threshold = 4,
            upper_distance_threshold = 8,
            lower_damage_modifier = 1,
            upper_damage_modifier = 0.2,
            damage = {amount = 2000, type = "fire"}
          },
        }
      }
    },
  },
  animation = {
    filename=shared.media_prefix.."graphics/fx/Laser.png",
    draw_as_glow = true,
    frame_count = 1,
    line_length = 1,
    width = 300,
    height = 612,
    shift = {0, 0},
    priority = "high"
  },
},

{
  type = "projectile",
  name = shared.mod_prefix.."bolt-plasma-1",
  flags = {"not-on-map"},
  acceleration = 0.001,
  turn_speed = 0.01,
  action = {
    {
      type = "direct",
      action_delivery = {
        type = "instant",
        target_effects = {
          {
            type = "set-tile",
            tile_name = "nuclear-ground",
            radius = 6,
            apply_projection = true,
            tile_collision_mask = { layers = {["water_tile"]=true} }
          },
          {
            type = "invoke-tile-trigger",
            repeat_count = 1
          },
          {
            type = "destroy-decoratives",
            include_soft_decoratives = true,
            include_decals = true,
            invoke_decorative_trigger = true,
            decoratives_with_trigger_only = false,
            radius = 12
          },
          {
            type = "create-entity",
            entity_name = "huge-scorchmark",
            offsets = {{ 0, -0.5 }},
            check_buildability = true
          },
          {
            type = "create-entity",
            entity_name = "massive-explosion"
          },
          {
            type = "play-sound",
            sound = find_sound("wh40k-titans-explo-2"),
            play_on_target_position = true,
            max_distance = 600,
            -- volume_modifier = 1,
            audible_distance_modifier = 3
          },
        }
      }
    },
    {
      type = "area",
      radius = 15,
      ignore_collision_condition = true,
      action_delivery = {
        type = "instant",
        target_effects = {
          {
            type = "damage",
            vaporize = false,
            lower_distance_threshold = 10,
            upper_distance_threshold = 16,
            lower_damage_modifier = 1,
            upper_damage_modifier = 0.2,
            damage = {amount = 5000, type = "explosion"}
          },
          {
            type = "damage",
            vaporize = false,
            lower_distance_threshold = 8,
            upper_distance_threshold = 16,
            lower_damage_modifier = 1,
            upper_damage_modifier = 0.1,
            damage = {amount = 3000, type = "fire"}
          },
          {
            type = "damage",
            vaporize = false,
            lower_distance_threshold = 10,
            upper_distance_threshold = 16,
            lower_damage_modifier = 1,
            upper_damage_modifier = 0.2,
            damage = {amount = 3000, type = "electric"}
          },
        }
      }
    },
  },
  animation = {
    filename=shared.media_prefix.."graphics/fx/Plasma.png",
    draw_as_glow = true,
    frame_count = 1,
    line_length = 1,
    width = 320,
    height = 320,
    scale = 0.5,
    shift = {0, 0},
    priority = "high"
  },
},

{
  type = "projectile",
  name = shared.mod_prefix.."bolt-plasma-2",
  flags = {"not-on-map"},
  acceleration = 0.001,
  turn_speed = 0.01,
  action = {
    {
      type = "direct",
      action_delivery = {
        type = "instant",
        target_effects = {
          {
            type = "set-tile",
            tile_name = "nuclear-ground",
            radius = 8,
            apply_projection = true,
            tile_collision_mask = { layers = {["water_tile"]=true} }
          },
          {
            type = "invoke-tile-trigger",
            repeat_count = 1
          },
          {
            type = "destroy-decoratives",
            include_soft_decoratives = true,
            include_decals = true,
            invoke_decorative_trigger = true,
            decoratives_with_trigger_only = false,
            radius = 15
          },
          {
            type = "create-entity",
            entity_name = "huge-scorchmark",
            offsets = {{ 0, -0.5 }},
            check_buildability = true
          },
          {
            type = "create-entity",
            entity_name = "nuke-explosion"
          },
          {
            type = "play-sound",
            sound = find_sound("wh40k-titans-explo-2"),
            play_on_target_position = true,
            max_distance = 800,
            -- volume_modifier = 1,
            audible_distance_modifier = 3
          },
        }
      }
    },
    {
      type = "area",
      radius = 20,
      ignore_collision_condition = true,
      action_delivery = {
        type = "instant",
        target_effects = {
          {
            type = "damage",
            vaporize = false,
            lower_distance_threshold = 12,
            upper_distance_threshold = 24,
            lower_damage_modifier = 1,
            upper_damage_modifier = 0.2,
            damage = {amount = 11000, type = "explosion"}
          },
          {
            type = "damage",
            vaporize = false,
            lower_distance_threshold = 12,
            upper_distance_threshold = 24,
            lower_damage_modifier = 1,
            upper_damage_modifier = 0.1,
            damage = {amount = 6000, type = "fire"}
          },
          {
            type = "damage",
            vaporize = false,
            lower_distance_threshold = 12,
            upper_distance_threshold = 24,
            lower_damage_modifier = 1,
            upper_damage_modifier = 0.2,
            damage = {amount = 8000, type = "electric"}
          },
        }
      }
    },
  },
  animation = {
    filename=shared.media_prefix.."graphics/fx/Plasma.png",
    draw_as_glow = true,
    frame_count = 1,
    line_length = 1,
    width = 320,
    height = 320,
    shift = {0, 0},
    priority = "high"
  },
},

{
  type = "projectile",
  name = shared.mod_prefix.."bolt-plasma-3",
  flags = {"not-on-map"},
  acceleration = 0.001,
  turn_speed = 0.01,
  action = {
    {
      type = "direct",
      action_delivery = {
        type = "instant",
        target_effects = {
          {
            type = "camera-effect",
            effect = "screen-burn",
            duration = 40,
            ease_in_duration = 5,
            ease_out_duration = 20,
            delay = 0,
            strength = 5,
            full_strength_max_distance = 100,
            max_distance = 400
          },
          {
            type = "set-tile",
            tile_name = "nuclear-ground",
            radius = 10,
            apply_projection = true,
            tile_collision_mask = { layers = {["water_tile"]=true} }
          },
          {
            type = "invoke-tile-trigger",
            repeat_count = 1
          },
          {
            type = "destroy-decoratives",
            include_soft_decoratives = true,
            include_decals = true,
            invoke_decorative_trigger = true,
            decoratives_with_trigger_only = false,
            radius = 15
          },
          {
            type = "create-entity",
            entity_name = "huge-scorchmark",
            offsets = {{ 0, -0.5 }},
            check_buildability = true
          },
          {
            type = "create-entity",
            entity_name = "nuke-explosion"
          },
          {
            type = "play-sound",
            sound = find_sound("wh40k-titans-explo-2"),
            play_on_target_position = true,
            max_distance = 800,
            -- volume_modifier = 1,
            audible_distance_modifier = 3
          },
        }
      }
    },
    {
      type = "area",
      radius = 24,
      ignore_collision_condition = true,
      action_delivery = {
        type = "instant",
        target_effects = {
          {
            type = "damage",
            vaporize = true,
            lower_distance_threshold = 14,
            upper_distance_threshold = 26,
            lower_damage_modifier = 1,
            upper_damage_modifier = 0.2,
            damage = {amount = 20000, type = "explosion"}
          },
          {
            type = "damage",
            vaporize = true,
            lower_distance_threshold = 14,
            upper_distance_threshold = 26,
            lower_damage_modifier = 1,
            upper_damage_modifier = 0.1,
            damage = {amount = 10000, type = "fire"}
          },
          {
            type = "damage",
            vaporize = true,
            lower_distance_threshold = 14,
            upper_distance_threshold = 26,
            lower_damage_modifier = 1,
            upper_damage_modifier = 0.2,
            damage = {amount = 20000, type = "electric"}
          },
        }
      }
    },
  },
  animation = {
    filename=shared.media_prefix.."graphics/fx/Plasma.png",
    draw_as_glow = true,
    frame_count = 1,
    line_length = 1,
    width = 320,
    height = 320,
    shift = {0, 0},
    priority = "high"
  },
},

{
  type = "projectile",
  name = shared.mod_prefix.."bolt-plasma-4",
  flags = {"not-on-map"},
  acceleration = 0.001,
  turn_speed = 0.01,
  action = {
    {
      type = "cluster",
      cluster_count = 6,
      distance = 18,
      distance_deviation = 6,
      action_delivery =
      {
        type = "projectile",
        projectile = shared.mod_prefix.."bolt-plasma-2",
        direction_deviation = 0.6,
        starting_speed = 2,
        starting_speed_deviation = 0.3
      }
    },
    {
      type = "direct",
      action_delivery = {
        type = "instant",
        target_effects = {
          {
            type = "camera-effect",
            effect = "screen-burn",
            duration = 90,
            ease_in_duration = 10,
            ease_out_duration = 40,
            delay = 0,
            strength = 7,
            full_strength_max_distance = 200,
            max_distance = 600
          },
          {
            type = "set-tile",
            tile_name = "nuclear-ground",
            radius = 14,
            apply_projection = true,
            tile_collision_mask = { layers = {["water_tile"]=true} }
          },
          {
            type = "invoke-tile-trigger",
            repeat_count = 1
          },
          {
            type = "destroy-decoratives",
            include_soft_decoratives = true,
            include_decals = true,
            invoke_decorative_trigger = true,
            decoratives_with_trigger_only = false,
            radius = 27
          },
          {
            type = "create-entity",
            entity_name = "huge-scorchmark",
            offsets = {{ 0, -0.5 }},
            check_buildability = true
          },
          {
            type = "create-entity",
            entity_name = "nuke-explosion"
          },
          {
            type = "play-sound",
            sound = find_sound("wh40k-titans-explo-3"),
            play_on_target_position = true,
            max_distance = 1000,
            -- volume_modifier = 1,
            audible_distance_modifier = 3
          },
        }
      }
    },
    {
      type = "area",
      radius = 28,
      ignore_collision_condition = true,
      action_delivery = {
        type = "instant",
        target_effects = {
          {
            type = "damage",
            vaporize = true,
            lower_distance_threshold = 18,
            upper_distance_threshold = 30,
            lower_damage_modifier = 1,
            upper_damage_modifier = 0.2,
            damage = {amount = 50000, type = "explosion"}
          },
          {
            type = "damage",
            vaporize = true,
            lower_distance_threshold = 18,
            upper_distance_threshold = 30,
            lower_damage_modifier = 1,
            upper_damage_modifier = 0.1,
            damage = {amount = 40000, type = "fire"}
          },
          {
            type = "damage",
            vaporize = true,
            -- lower_distance_threshold = 16,
            -- upper_distance_threshold = 24,
            -- lower_damage_modifier = 1,
            -- upper_damage_modifier = 0.2,
            damage = {amount = 40000, type = "electric"}
          },
        }
      }
    },
  },
  animation = {
    filename=shared.media_prefix.."graphics/fx/Plasma.png",
    draw_as_glow = true,
    frame_count = 1,
    line_length = 1,
    width = 320,
    height = 320,
    scale = 2,
    shift = {0, 0},
    priority = "high"
  },
},

{
  type = "artillery-projectile",
  name = shared.doom_missile_ammo,
  flags = {"not-on-map"},
  map_color = {r=1, g=0.5, b=0},
  reveal_map = true,
  acceleration = 0.01,
  turn_speed = 0.005,
  turning_speed_increases_exponentially_with_projectile_speed = true,
  height_from_ground = 320 / 64,
  chart_picture =
  {
    filename = "__base__/graphics/entity/artillery-projectile/artillery-shoot-map-visualization.png",
    flags = { "icon" },
    frame_count = 1,
    width = 64,
    height = 64,
    priority = "high",
    scale = 0.5
  },
  action = {
    type = "direct",
    action_delivery = {
      type = "instant",
      target_effects = {
        {
          type = "nested-result",
          action =
          {
            type = "area",
            target_entities = false,
            trigger_from_target = true,
            repeat_count = 1,
            radius = 1,
            action_delivery =
            {
              type = "projectile",
              projectile = "atomic-rocket",
              starting_speed = 7,
              starting_speed_deviation = 0,
            }
          }
        },
        -- {
        --   type = "create-entity",
        --   entity_name = "huge-scorchmark",
        --   offsets = {{ 0, 0 }},
        --   check_buildability = true
        -- },
        -- {
        --   type = "create-entity",
        --   entity_name = "nuke-explosion"
        -- },
        -- {
        --   type = "damage",
        --   damage = {amount = 10000, type = "physical"}
        -- },
        -- {
        --   type = "invoke-tile-trigger",
        --   repeat_count = 1
        -- },
        -- {
        --   type = "destroy-decoratives",
        --   from_render_layer = "decorative",
        --   to_render_layer = "object",
        --   include_soft_decoratives = true,
        --   include_decals = false,
        --   invoke_decorative_trigger = true,
        --   decoratives_with_trigger_only = false,
        --   radius = 5, -- large radius for demostrative purposes
        -- },
        {
          type = "nested-result",
          action = {
            type = "area",
            radius = 20,
            action_delivery = {
              type = "instant",
              target_effects = {
                {
                  type = "damage",
                  vaporize = false,
                  lower_distance_threshold = 10,
                  upper_distance_threshold = 20,
                  lower_damage_modifier = 1,
                  upper_damage_modifier = 0.2,
                  damage = {amount = 20000, type = "explosion"}
                },
                {
                  type = "create-entity",
                  entity_name = "big-explosion"
                }
              }
            }
          }
        },
      }
    }
  },
  light = {intensity = 0.7, size = 5},
  animation = {
    filename = shared.media_prefix.."graphics/fx/DeathStrike-Missile.png",
    draw_as_glow = true,
    frame_count = 1,
    width = 32, height = 107,
    shift = {0, 0},
    priority = "high"
  },
  shadow = {
    filename = shared.media_prefix.."graphics/fx/DeathStrike-Shadow.png",
    frame_count = 1,
    width = 32, height = 107,
    priority = "high",
    shift = {0, 0}
  },
  smoke = {
    {
      name = "smoke-fast",
      deviation = {0.3, 0.3},
      frequency = 2,
      position = {0, 2},
      slow_down_factor = 1,
      starting_frame = 3,
      starting_frame_deviation = 5,
      starting_frame_speed = 0,
      starting_frame_speed_deviation = 5
    }
  }
},

{
  type = "artillery-projectile",
  name = shared.plasma_missile_ammo,
  flags = {"not-on-map"},
  map_color = {r=0.1, g=0.2, b=1},
  reveal_map = true,
  acceleration = 0.01,
  turn_speed = 0.005,
  turning_speed_increases_exponentially_with_projectile_speed = true,
  height_from_ground = 320 / 64,
  chart_picture =
  {
    filename = "__base__/graphics/entity/artillery-projectile/artillery-shoot-map-visualization.png",
    flags = { "icon" },
    frame_count = 1,
    width = 64,
    height = 64,
    priority = "high",
    scale = 0.5
  },
  action = {
    {
      type = "direct",
      action_delivery =
        {
          type = "projectile",
          projectile = shared.mod_prefix.."bolt-plasma-4",
          starting_speed = 7,
          max_range = 1,
        },
    },
    -- {
    --   type = "cluster",
    --   cluster_count = 6,
    --   distance = 10,
    --   distance_deviation = 4,
    --   action_delivery =
    --   {
    --     type = "projectile",
    --     projectile = shared.mod_prefix.."bolt-plasma-3",
    --     direction_deviation = 0.6,
    --     starting_speed = 0.25,
    --     starting_speed_deviation = 0.3
    --   }
    -- },
    -- {
    --   type = "direct",
    --   action_delivery = {
    --     type = "instant",
    --     target_effects = {
    --     {
    --         type = "create-entity",
    --         entity_name = "huge-scorchmark",
    --         offsets = {{ 0, 0 }},
    --         check_buildability = true
    --       },
    --       {
    --         type = "create-entity",
    --         entity_name = "nuke-explosion"
    --       },
    --       {
    --         type = "damage",
    --         damage = {amount = 10000, type = "physical"}
    --       },
    --       {
    --         type = "invoke-tile-trigger",
    --         repeat_count = 1
    --       },
    --       {
    --         type = "destroy-decoratives",
    --         from_render_layer = "decorative",
    --         to_render_layer = "object",
    --         include_soft_decoratives = true,
    --         include_decals = false,
    --         invoke_decorative_trigger = true,
    --         decoratives_with_trigger_only = false,
    --         radius = 5, -- large radius for demostrative purposes
    --       },
    --       {
    --         type = "nested-result",
    --         action = {
    --           type = "area",
    --           radius = 16,
    --           action_delivery = {
    --             type = "instant",
    --             target_effects = {
    --               {
    --                 type = "damage",
    --                 vaporize = true,
    --                 lower_distance_threshold = 10,
    --                 upper_distance_threshold = 16,
    --                 lower_damage_modifier = 1,
    --                 upper_damage_modifier = 0.2,
    --                 damage = {amount = 50000, type = "explosion"}
    --               },
    --               {
    --                 type = "damage",
    --                 vaporize = true,
    --                 lower_distance_threshold = 10,
    --                 upper_distance_threshold = 16,
    --                 lower_damage_modifier = 1,
    --                 upper_damage_modifier = 0.2,
    --                 damage = {amount = 50000, type = "electric"}
    --               },
    --               {
    --                 type = "damage",
    --                 vaporize = true,
    --                 lower_distance_threshold = 10,
    --                 upper_distance_threshold = 16,
    --                 lower_damage_modifier = 1,
    --                 upper_damage_modifier = 0.2,
    --                 damage = {amount = 50000, type = "physical"}
    --               },
    --               {
    --                 type = "create-entity",
    --                 entity_name = "big-explosion"
    --               }
    --             }
    --           }
    --         }
    --       }
    --     }
    --   },
    -- },
  },
  light = {intensity = 0.8, size = 6},
  animation = {
    filename = shared.media_prefix.."graphics/fx/DeathStrike-Missile.png",
    draw_as_glow = true,
    frame_count = 1,
    width = 32, height = 107,
    shift = {0, 0},
    priority = "high"
  },
  shadow = {
    filename = shared.media_prefix.."graphics/fx/DeathStrike-Shadow.png",
    frame_count = 1,
    width = 32, height = 107,
    priority = "high",
    shift = {0, 0}
  },
  smoke = {
    {
      name = "smoke-fast",
      deviation = {0.3, 0.3},
      frequency = 2,
      position = {0, 2},
      slow_down_factor = 1,
      starting_frame = 3,
      starting_frame_deviation = 5,
      starting_frame_speed = 0,
      starting_frame_speed_deviation = 5
    }
  }
},

{
  type = "artillery-projectile",
  name = shared.warp_missile_ammo,
  flags = {"not-on-map"},
  map_color = {r=0.5, g=0.1, b=1},
  reveal_map = true,
  acceleration = 0.01,
  turn_speed = 0.005,
  turning_speed_increases_exponentially_with_projectile_speed = true,
  height_from_ground = 320 / 64,
  chart_picture =
  {
    filename = "__base__/graphics/entity/artillery-projectile/artillery-shoot-map-visualization.png",
    flags = { "icon" },
    frame_count = 1,
    width = 64,
    height = 64,
    priority = "high",
    scale = 0.5
  },
  action = {
    {
      type = "cluster",
      cluster_count = 24,
      distance = 12,
      distance_deviation = 5,
      action_delivery =
      {
        type = "projectile",
        projectile = shared.mod_prefix.."bolt-laser",
        direction_deviation = 0.6,
        starting_speed = 0.25,
        starting_speed_deviation = 0.3
      }
    },
    {
      type = "direct",
      action_delivery = {
        type = "instant",
        target_effects = {
        {
            type = "create-entity",
            entity_name = "huge-scorchmark",
            offsets = {{ 0, 0 }},
            check_buildability = true
          },
          {
            type = "create-entity",
            entity_name = "massive-explosion"
          },
          {
            type = "invoke-tile-trigger",
            repeat_count = 1
          },
          {
            type = "destroy-decoratives",
            from_render_layer = "decorative",
            to_render_layer = "object",
            include_soft_decoratives = true,
            include_decals = false,
            invoke_decorative_trigger = true,
            decoratives_with_trigger_only = false,
            radius = 5, -- large radius for demostrative purposes
          },
          {
            type = "nested-result",
            action = {
              type = "area",
              radius = 20,
              action_delivery = {
                type = "instant",
                target_effects = {
                  {
                    type = "damage",
                    vaporize = true,
                    lower_distance_threshold = 10,
                    upper_distance_threshold = 20,
                    lower_damage_modifier = 1,
                    upper_damage_modifier = 0.2,
                    damage = {amount = 100*1000, type = "explosion"}
                  },
                  {
                    type = "damage",
                    vaporize = true,
                    lower_distance_threshold = 10,
                    upper_distance_threshold = 20,
                    lower_damage_modifier = 1,
                    upper_damage_modifier = 0.1,
                    damage = {amount = 100*1000, type = shared.mepow_damage}
                  },
                  {
                    type = "damage",
                    vaporize = true,
                    lower_distance_threshold = 10,
                    upper_distance_threshold = 20,
                    lower_damage_modifier = 1,
                    upper_damage_modifier = 0.1,
                    damage = {amount = 100*1000, type = shared.melee_damage}
                  },
                  {
                    type = "create-entity",
                    entity_name = "big-explosion"
                  }
                }
              }
            }
          }
        }
      },
    },
  },
  light = {intensity = 0.9, size = 7},
  animation = {
    filename = shared.media_prefix.."graphics/fx/DeathStrike-Missile.png",
    draw_as_glow = true,
    frame_count = 1,
    width = 32, height = 107,
    shift = {0, 0},
    priority = "high"
  },
  shadow = {
    filename = shared.media_prefix.."graphics/fx/DeathStrike-Shadow.png",
    frame_count = 1,
    width = 32, height = 107,
    priority = "high",
    shift = {0, 0}
  },
  smoke = {
    {
      name = "smoke-fast",
      deviation = {0.3, 0.3},
      frequency = 2,
      position = {0, 2},
      slow_down_factor = 1,
      starting_frame = 3,
      starting_frame_deviation = 5,
      starting_frame_speed = 0,
      starting_frame_speed_deviation = 5
    }
  }
},
})


local fire = table.deepcopy(data.raw["fire"]["fire-flame"])
fire.name = "titanic-fire-flame"
fire.damage_per_tick = {amount = 50 / 60, type = "fire"}
local stream = table.deepcopy(data.raw["stream"]["flamethrower-fire-stream"])
stream.name = "titanic-fire-stream"
stream.particle_horizontal_speed = stream.particle_horizontal_speed * 5
stream.action = {
{
  type = "area",
  radius = 5,
  action_delivery = {
    type = "instant",
    target_effects = {
      {
        type = "create-sticker",
        sticker = "fire-sticker",
        show_in_tooltip = true,
      },
      {
        type = "create-sticker",
        sticker = "slowdown-sticker",
      },
      {
        type = "damage",
        damage = { amount = 50, type = "fire" },
        apply_damage_to_trees = true,
      },
      {
        type = "damage",
        damage = { amount = 50, type = "laser" },
        apply_damage_to_trees = true,
      },
    }
  }
},
{
  type = "direct",
  action_delivery = {
    type = "instant",
    target_effects = {
      {
        type = "create-fire",
        entity_name = "titanic-fire-flame",
        show_in_tooltip = true
      },
      {
        type = "create-sticker",
        sticker = "slowdown-sticker",
      },
    }
  }
}
}
data:extend({ stream, fire })
