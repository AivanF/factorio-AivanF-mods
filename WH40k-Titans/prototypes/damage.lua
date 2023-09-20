local shared = require("shared")
local sounds = require("__base__.prototypes.entity.sounds")
local fireutil = require("__base__.prototypes.fire-util")

data:extend({
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
    type = "projectile",
    name = shared.mod_prefix.."explosive-rocket",
    flags = {"not-on-map"},
    acceleration = 0.01,
    turn_speed = 0.005,
    turning_speed_increases_exponentially_with_projectile_speed = true,
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "create-entity",
            entity_name = "big-explosion"
          },
          {
            type = "damage",
            damage = {amount = 250, type = "explosion"}
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
            include_soft_decoratives = true, -- soft decoratives are decoratives with grows_through_rail_path = true
            include_decals = false,
            invoke_decorative_trigger = true,
            decoratives_with_trigger_only = false, -- if true, destroys only decoratives that have trigger_effect set
            radius = 3.5 -- large radius for demostrative purposes
          },
          {
            type = "nested-result",
            action =
            {
              type = "area",
              radius = 7,
              action_delivery =
              {
                type = "instant",
                target_effects =
                {
                  {
                    type = "damage",
                    damage = {amount = 300, type = "explosion"}
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
    animation =
    {
      filename = shared.media_prefix.."graphics/fx/rocket.png",
      draw_as_glow = true,
      frame_count = 8,
      line_length = 8,
      width = 18,
      height = 70,
      shift = {0, 0},
      priority = "high"
    },
    shadow =
    {
      filename = shared.media_prefix.."graphics/fx/rocket-shadow.png",
      frame_count = 1,
      width = 14,
      height = 28,
      priority = "high",
      shift = {0, 0}
    },
    smoke =
    {
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
    name = shared.mod_prefix.."bolt-laser",
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
            -- {
            --   type = "play-sound",
            --   sound = sounds.nuclear_explosion(0.9),
            --   play_on_target_position = false,
            --   max_distance = 800,
            --   -- volume_modifier = 1,
            --   audible_distance_modifier = 3
            -- },
          }
        }
      },
      {
        type = "area",
        radius = 8,
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
              damage = {amount = 1500, type = "explosion"}
            },
            {
              type = "damage",
              lower_distance_threshold = 4,
              upper_distance_threshold = 8,
              lower_damage_modifier = 1,
              upper_damage_modifier = 0.2,
              damage = {amount = 2000, type = "laser"}
            },
            {
              type = "damage",
              lower_distance_threshold = 4,
              upper_distance_threshold = 8,
              lower_damage_modifier = 1,
              upper_damage_modifier = 0.2,
              damage = {amount = 1500, type = "fire"}
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
              tile_collision_mask = { "water-tile" }
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
              sound = sounds.nuclear_explosion(0.9),
              play_on_target_position = false,
              max_distance = 600,
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
              vaporize = false,
              lower_distance_threshold = 10,
              upper_distance_threshold = 16,
              lower_damage_modifier = 1,
              upper_damage_modifier = 0.2,
              damage = {amount = 3000, type = "explosion"}
            },
            {
              type = "damage",
              vaporize = false,
              lower_distance_threshold = 8,
              upper_distance_threshold = 16,
              lower_damage_modifier = 1,
              upper_damage_modifier = 0.1,
              damage = {amount = 2000, type = "fire"}
            },
            {
              type = "damage",
              vaporize = false,
              lower_distance_threshold = 10,
              upper_distance_threshold = 16,
              lower_damage_modifier = 1,
              upper_damage_modifier = 0.2,
              damage = {amount = 2000, type = "electric"}
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
              type = "camera-effect",
              effect = "screen-burn",
              duration = 60,
              ease_in_duration = 5,
              ease_out_duration = 30,
              delay = 0,
              strength = 5,
              full_strength_max_distance = 100,
              max_distance = 400
            },
            {
              type = "set-tile",
              tile_name = "nuclear-ground",
              radius = 8,
              apply_projection = true,
              tile_collision_mask = { "water-tile" }
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
              entity_name = "nuke-explosion"
            },
            {
              type = "play-sound",
              sound = sounds.nuclear_explosion(0.9),
              play_on_target_position = false,
              max_distance = 800,
              -- volume_modifier = 1,
              audible_distance_modifier = 3
            },
          }
        }
      },
      {
        type = "area",
        radius = 16,
        ignore_collision_condition = true,
        action_delivery = {
          type = "instant",
          target_effects = {
            {
              type = "damage",
              vaporize = true,
              lower_distance_threshold = 10,
              upper_distance_threshold = 16,
              lower_damage_modifier = 1,
              upper_damage_modifier = 0.2,
              damage = {amount = 10000, type = "explosion"}
            },
            {
              type = "damage",
              vaporize = true,
              lower_distance_threshold = 8,
              upper_distance_threshold = 16,
              lower_damage_modifier = 1,
              upper_damage_modifier = 0.1,
              damage = {amount = 4000, type = "fire"}
            },
            {
              type = "damage",
              vaporize = true,
              lower_distance_threshold = 10,
              upper_distance_threshold = 16,
              lower_damage_modifier = 1,
              upper_damage_modifier = 0.2,
              damage = {amount = 6000, type = "electric"}
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
              duration = 150,
              ease_in_duration = 30,
              ease_out_duration = 60,
              delay = 0,
              strength = 7,
              full_strength_max_distance = 300,
              max_distance = 600
            },
            {
              type = "set-tile",
              tile_name = "nuclear-ground",
              radius = 14,
              apply_projection = true,
              -- tile_collision_mask = { "water-tile" }
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
              radius = 24
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
              sound = sounds.nuclear_explosion(0.9),
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
        radius = 24,
        ignore_collision_condition = true,
        action_delivery = {
          type = "instant",
          target_effects = {
            {
              type = "damage",
              vaporize = true,
              lower_distance_threshold = 16,
              upper_distance_threshold = 24,
              lower_damage_modifier = 1,
              upper_damage_modifier = 0.2,
              damage = {amount = 25000, type = "explosion"}
            },
            {
              type = "damage",
              vaporize = true,
              lower_distance_threshold = 16,
              upper_distance_threshold = 24,
              lower_damage_modifier = 1,
              upper_damage_modifier = 0.1,
              damage = {amount = 15000, type = "fire"}
            },
            {
              type = "damage",
              vaporize = true,
              -- lower_distance_threshold = 16,
              -- upper_distance_threshold = 24,
              -- lower_damage_modifier = 1,
              -- upper_damage_modifier = 0.2,
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
      scale = 2,
      shift = {0, 0},
      priority = "high"
    },
  },
})

local fire = table.deepcopy(data.raw["fire"]["fire-flame"])
fire.name = "titanic-fire-flame"
fire.damage_per_tick = {amount = 30 / 60, type = "fire"}
local stream = table.deepcopy(data.raw["stream"]["flamethrower-fire-stream"])
stream.name = "titanic-fire-stream"
stream.particle_horizontal_speed = stream.particle_horizontal_speed * 3
stream.action = {
  {
    type = "area",
    radius = 5,
    action_delivery =
    {
      type = "instant",
      target_effects =
      {
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
          damage = { amount = 25, type = "fire" },
          apply_damage_to_trees = true,
        },
        {
          type = "damage",
          damage = { amount = 25, type = "laser" },
          apply_damage_to_trees = true,
        },
      }
    }
  },
  {
    type = "direct",
    action_delivery =
    {
      type = "instant",
      target_effects =
      {
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
