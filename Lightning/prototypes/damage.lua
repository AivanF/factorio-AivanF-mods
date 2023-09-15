local sounds = require("__base__.prototypes.entity.sounds")
local shared = require("shared")

local projectiles = {
  -- https://wiki.factorio.com/Types/TriggerEffect
  -- https://wiki.factorio.com/Data.raw#explosion

  {
    type = "projectile",
    name = "tsl-explo-0",
    flags = {"not-on-map"},
    acceleration = 0.001,
    turn_speed = 0.01,
    action = {
      {
        type = "area",
        radius = 2,
        ignore_collision_condition = true,
        action_delivery = {
          type = "instant",
          target_effects = {
            {
              type = "damage",
              vaporize = false,
              damage = {amount = 10, type = "explosion"}
            },
            {
              type = "damage",
              vaporize = false,
              damage = {amount = 10, type = "fire"}
            },
          }
        }
      },
    },
  },

  {
    type = "projectile",
    name = "tsl-explo-1",
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
              type = "create-entity",
              entity_name = "explosion"
            },
          }
        }
      },
      {
        type = "area",
        radius = 2,
        ignore_collision_condition = true,
        action_delivery = {
          type = "instant",
          target_effects = {
            {
              type = "damage",
              vaporize = false,
              lower_distance_threshold = 0,
              upper_distance_threshold = 16,
              lower_damage_modifier = 1,
              upper_damage_modifier = 0.1,
              damage = {amount = 50, type = "explosion"}
            },
            {
              type = "damage",
              vaporize = false,
              lower_distance_threshold = 0,
              upper_distance_threshold = 16,
              lower_damage_modifier = 1,
              upper_damage_modifier = 0.1,
              damage = {amount = 50, type = "fire"}
            },
            {
              type = "damage",
              vaporize = false,
              lower_distance_threshold = 0,
              upper_distance_threshold = 16,
              lower_damage_modifier = 1,
              upper_damage_modifier = 0.1,
              damage = {amount = 50, type = "electric"}
            },
          }
        }
      },
    },
  },

  {
    type = "projectile",
    name = "tsl-explo-2",
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
              type = "create-entity",
              entity_name = "medium-explosion"
            },
          }
        }
      },
      {
        type = "area",
        radius = 4,
        ignore_collision_condition = true,
        action_delivery = {
          type = "instant",
          target_effects = {
            {
              type = "damage",
              vaporize = false,
              lower_distance_threshold = 0,
              upper_distance_threshold = 16,
              lower_damage_modifier = 1,
              upper_damage_modifier = 0.1,
              damage = {amount = 100, type = "explosion"}
            },
            {
              type = "damage",
              vaporize = false,
              lower_distance_threshold = 0,
              upper_distance_threshold = 16,
              lower_damage_modifier = 1,
              upper_damage_modifier = 0.1,
              damage = {amount = 100, type = "fire"}
            },
            {
              type = "damage",
              vaporize = false,
              lower_distance_threshold = 0,
              upper_distance_threshold = 16,
              lower_damage_modifier = 1,
              upper_damage_modifier = 0.1,
              damage = {amount = 100, type = "electric"}
            },
          }
        }
      },
    },
  },

  {
    type = "projectile",
    name = "tsl-explo-3",
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
              duration = 45,
              ease_in_duration = 5,
              ease_out_duration = 30,
              delay = 0,
              strength = 3,
              full_strength_max_distance = 20,
              max_distance = 60
            },
            {
              type = "create-entity",
              entity_name = "massive-explosion"
            },
          }
        }
      },
      {
        type = "area",
        radius = 5,
        ignore_collision_condition = true,
        action_delivery = {
          type = "instant",
          target_effects = {
            {
              type = "damage",
              vaporize = false,
              lower_distance_threshold = 0,
              upper_distance_threshold = 16,
              lower_damage_modifier = 1,
              upper_damage_modifier = 0.1,
              damage = {amount = 200, type = "explosion"}
            },
            {
              type = "damage",
              vaporize = false,
              lower_distance_threshold = 0,
              upper_distance_threshold = 16,
              lower_damage_modifier = 1,
              upper_damage_modifier = 0.1,
              damage = {amount = 100, type = "fire"}
            },
            {
              type = "damage",
              vaporize = false,
              lower_distance_threshold = 0,
              upper_distance_threshold = 16,
              lower_damage_modifier = 1,
              upper_damage_modifier = 0.1,
              damage = {amount = 200, type = "electric"}
            },
          }
        }
      },
    },
  },

  {
    type = "projectile",
    name = "tsl-explo-4",
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
              ease_out_duration = 45,
              delay = 0,
              strength = 5,
              full_strength_max_distance = 30,
              max_distance = 200
            },
            {
              type = "set-tile",
              tile_name = "nuclear-ground",
              radius = 4,
              apply_projection = true,
              tile_collision_mask = { "water-tile" }
            },
            {
              type = "create-entity",
              entity_name = "massive-explosion"
            },
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
              vaporize = true,
              lower_distance_threshold = 8,
              upper_distance_threshold = 16,
              lower_damage_modifier = 1,
              upper_damage_modifier = 0.1,
              damage = {amount = 1000, type = "explosion"}
            },
            {
              type = "damage",
              vaporize = true,
              lower_distance_threshold = 8,
              upper_distance_threshold = 16,
              lower_damage_modifier = 1,
              upper_damage_modifier = 0.1,
              damage = {amount = 500, type = "fire"}
            },
            {
              type = "damage",
              vaporize = true,
              lower_distance_threshold = 8,
              upper_distance_threshold = 16,
              lower_damage_modifier = 1,
              upper_damage_modifier = 0.1,
              damage = {amount = 500, type = "electric"}
            },
            {
              type = "create-entity",
              entity_name = "medium-explosion"
            },
          }
        }
      },
    },
  },

  {
    type = "projectile",
    name = "tsl-explo-5",
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
              duration = 90,
              ease_in_duration = 5,
              ease_out_duration = 45,
              delay = 0,
              strength = 7,
              full_strength_max_distance = 160,
              max_distance = 600
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
        radius = 12,
        ignore_collision_condition = true,
        action_delivery = {
          type = "instant",
          target_effects = {
            {
              type = "damage",
              vaporize = true,
              lower_distance_threshold = 8,
              upper_distance_threshold = 16,
              lower_damage_modifier = 1,
              upper_damage_modifier = 0.2,
              damage = {amount = 1000, type = "impact"}
            },
            {
              type = "damage",
              vaporize = true,
              lower_distance_threshold = 8,
              upper_distance_threshold = 16,
              lower_damage_modifier = 1,
              upper_damage_modifier = 0.2,
              damage = {amount = 3000, type = "explosion"}
            },
            {
              type = "damage",
              vaporize = true,
              lower_distance_threshold = 8,
              upper_distance_threshold = 16,
              lower_damage_modifier = 1,
              upper_damage_modifier = 0.2,
              damage = {amount = 3000, type = "fire"}
            },
            {
              type = "damage",
              vaporize = true,
              lower_distance_threshold = 8,
              upper_distance_threshold = 16,
              lower_damage_modifier = 1,
              upper_damage_modifier = 0.2,
              damage = {amount = 3000, type = "electric"}
            },
          }
        }
      },
    },
  },
}

--- For debugging
-- for _, proto in pairs(projectiles) do
--   proto.animation = {
--     filename = "__base__/graphics/entity/rocket/rocket.png",
--     draw_as_glow = true,
--     frame_count = 8,
--     line_length = 8,
--     width = 9,
--     height = 35,
--     shift = {0, 0},
--     priority = "high"
--   }
-- end

data:extend(projectiles)
