local shared = require("shared")
local sounds = require("__base__.prototypes.entity.sounds")

data:extend({
  {
    type = "projectile",
    name = shared.mod_prefix.."bolt-plasma",
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
              damage = {amount = 4000, type = "explosion"}
            },
            {
              type = "damage",
              vaporize = true,
              lower_distance_threshold = 8,
              upper_distance_threshold = 16,
              lower_damage_modifier = 1,
              upper_damage_modifier = 0.1,
              damage = {amount = 3000, type = "fire"}
            },
            {
              type = "damage",
              vaporize = true,
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
      shift = {0, 0},
      priority = "high"
    },
  },
})
