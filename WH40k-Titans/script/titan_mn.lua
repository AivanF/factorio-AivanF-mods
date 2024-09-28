local lib_ruins = require("script/ruins")
local lib_tech = require("script/tech")
local collision_mask_util_extended = require("cmue.collision-mask-util-control")

local shield_fill_time = 30 * 60 * UPS
local visual_ttl = 2

local wc_color = {}
wc_color[shared.wc_rocket] = color_ltgrey
wc_color[shared.wc_bolter] = color_dkgrey
wc_color[shared.wc_quake]  = color_dkgrey
wc_color[shared.wc_flamer] = color_orange
wc_color[shared.wc_plasma] = color_blue
wc_color[shared.wc_melta]  = color_cyan
wc_color[shared.wc_laser]  = color_gold
wc_color[shared.wc_hell]   = color_red
-- wc_color[shared.wc_gravy]  = color_purple
-- wc_color[shared.wc_warp]   = color_green
wc_color[shared.wc_melee]  = color_ared


local function try_remove_small_water(surface, position, radius)
  local only_water_layer = collision_mask_util_extended.get_named_collision_mask("only-water-layer")
  local total = surface.count_tiles_filtered{position=position, radius=radius}
  local water = surface.count_tiles_filtered{position=position, radius=radius, collision_mask={only_water_layer}}
  local shallow = surface.count_tiles_filtered{position=position, radius=radius, name="water-shallow"}
  -- game.print("Found water "..water.." and shallow "..shallow.." of total "..total)
  water = water + 0.5*shallow
  if water > 0 and water/total < 0.4 then
    local tiles = surface.find_tiles_filtered{position=position, radius=radius*0.75, collision_mask={only_water_layer}}
    local new_tiles = {}
    for _, tl in pairs(tiles) do
      table.insert(new_tiles, {position=tl.position, name="water-shallow"})
    end
    surface.set_tiles(new_tiles, true)
  end
end


local function far_seeing(titan_info)
  local dst = (titan_info.class + 10) * 5
  local size = (titan_info.class + 20) * 3

  titan_info.entity.force.chart(titan_info.entity.surface,
    math2d.bounding_box.create_from_centre(
      titan_info.entity.position,
      size, size)
  )

  titan_info.entity.force.chart(titan_info.entity.surface,
    math2d.bounding_box.create_from_centre(
      math2d.position.add(
        titan_info.entity.position,
        point_orientation_shift(titan_info.entity.orientation, dst)),
      size, size)
  )
  if titan_info.class >= shared.class_warlord then
  -- if dst >= 96 then
    for i = 0, 3 do
      titan_info.entity.force.chart(titan_info.entity.surface,
        math2d.bounding_box.create_from_centre(
          math2d.position.add(
            titan_info.entity.position,
            point_orientation_shift(titan_info.entity.orientation + i/4, dst/2)),
          size, size)
      )
    end
  end
end


local function get_shield_recharge_speed(force)
  return (2 + lib_tech.get_research_level(force.index, shared.void_shield_spd_research))
end


function lib_ttn.get_unit_shield_max_capacity(titan_info)
  if not titan_info.cached_max_shield then
    titan_info.cached_max_shield = 1
      * shared.titan_types[titan_info.class].max_shield
      * (2 + lib_tech.get_research_level(
              titan_info.entity.force.index,
              shared.void_shield_cap_research))
      * shared.void_shield_cap_base
  end
  return titan_info.cached_max_shield
end


local function process_single_titan(titan_info)
  local tick = game.tick
  local titan_type = shared.titan_types[titan_info.class]
  local class = titan_info.class
  local name = titan_type.name
  local entity = titan_info.entity
  local surface = entity.surface
  local spd = math.abs(entity.speed)
  if entity.speed < 0 then
    entity.speed = entity.speed * 0.99
  end
  local ori = entity.orientation
  local oris = 0
  if spd > 0.1 then
    oris = math.sin(tick/120 *2*math.pi) * 0.02 * spd/0.3 / (1+class/20)
  end
  local shadow_shift = {2 * (1+0.1*class), 1}
  titan_info.position = titan_info.entity.position

  far_seeing(titan_info) -- it's here to make it not so often


  ----- Body

  rendering.draw_animation{
    animation=name.."-shadow",
    x_scale=1, y_scale=1, render_layer=shared.rl_shadow,
    time_to_live=visual_ttl,
    surface=surface, target=entity, target_offset=shadow_shift,
    orientation=ori+oris,
  }
  rendering.draw_animation{
    animation=name,
    x_scale=1, y_scale=1, render_layer=shared.rl_body,
    time_to_live=visual_ttl,
    surface=surface, target=entity, target_offset={0, 0},
    orientation=ori+titan_info.oris,
  }
  rendering.draw_light{
    sprite=shared.mod_prefix.."light", scale=7+0.5*class,
    intensity=1.5+0.1*class, minimum_darkness=0,
    time_to_live=visual_ttl,
    surface=surface, target=math2d.position.add(entity.position, point_orientation_shift(ori, 6)),
  }

  if not titan_info.aux_laser then
    titan_info.aux_laser = {}
    init_aux_laser(titan_type, titan_info, entity)
  end
  for k, shift in ipairs(titan_type.aux_laser) do
    if titan_info.aux_laser[k] then
      -- titan_info.aux_laser[k].position = math2d.position.add(entity.position, point_orientation_shift(shift[2], shift[1]))
      titan_info.aux_laser[k].teleport(math2d.position.add(entity.position, point_orientation_shift(shift[2], shift[1])))
    end
  end
  -- Save after drawing, so that weapons can affect body's oris
  titan_info.oris = oris


  ----- Void Shield
  -- TODO: consider energy spent on guns?
  local max_shield = lib_ttn.get_unit_shield_max_capacity(titan_info)
  titan_info.shield = math.min((titan_info.shield or 0) + get_shield_recharge_speed(entity.force) * max_shield /shield_fill_time, max_shield)

  -- Shield's main visual
  local sc = 0.75 + 0.03*class
  if titan_info.shield > 100 then
    rendering.draw_sprite{
      sprite=shared.mod_prefix.."shield",
      x_scale=sc, y_scale=sc, render_layer=shared.rl_shield,
      time_to_live=visual_ttl,
      surface=surface, target=math2d.position.add(entity.position, point_orientation_shift(ori, 2)),
    }
  end

  -- Ratio bar
  local shield_cf = titan_info.shield/lib_ttn.get_unit_shield_max_capacity(titan_info)
    if shield_cf < 0.99 then
    local w2 = 1 + class/10
    local yy = 4 + class/10
    local hh = 0.5
    rendering.draw_rectangle{
      color={0,0,0,1}, filled=true,
      left_top=entity, left_top_offset={-w2-0.1,yy-0.1},
      right_bottom=entity, right_bottom_offset={w2+0.1,yy+hh+0.1},
      surface=surface, time_to_live=visual_ttl,
      forces={entity.force}, only_in_alt_mode=true
    }
    rendering.draw_rectangle{
      color={1,1,1,1}, filled=true,
      left_top=entity, left_top_offset={-w2,yy},
      right_bottom=entity, right_bottom_offset={-w2+2*w2*shield_cf,yy+hh},
      surface=surface, time_to_live=visual_ttl,
      forces={entity.force}, only_in_alt_mode=true
    }
  end


  ----- The Guns
  local weapon_type, armpos, gunpos, cannon
  local for_whom = list_players({entity.get_driver(), entity.get_passenger()})
  for wi, mounting in ipairs(titan_type.mounts) do
    cannon = titan_info.guns[wi]
    weapon_type = shared.weapons[cannon.name]
    if mounting.is_top then
      gunpos = math2d.position.add(entity.position, point_orientation_shift(ori+oris + mounting.oris, mounting.shift))
    else
      gunpos = math2d.position.add(entity.position, point_orientation_shift(ori      + mounting.oris, mounting.shift))
    end

    if weapon_type.on_arm then
      cannon.armpos = gunpos
      gunpos = math2d.position.add(cannon.armpos, point_orientation_shift(ori +cannon.oris/2 -(cannon.base_oris or 0), shared.titan_arm_length))
    end

    lib_ttn.wc_control[weapon_type.category](titan_info, titan_type, wi, cannon, gunpos, weapon_type, ori, tick)
    cannon.position = gunpos

    if cannon.entity == nil then
      rendering.draw_animation{
        animation=weapon_type.animation,
        x_scale=1, y_scale=1, render_layer=mounting.layer,
        time_to_live=visual_ttl,
        surface=surface,
        target=gunpos,
        orientation=ori-oris/2 + cannon.oris +(cannon.base_oris or 0)/2,
      }
      if weapon_type.on_arm then
        rendering.draw_animation{
          animation=shared.mod_prefix.."Arm",
          x_scale=1, y_scale=1, render_layer=mounting.layer, -- Hopefuly, arm should be upper
          time_to_live=visual_ttl,
          surface=surface,
          target=cannon.armpos,
          orientation=ori-oris/2 + cannon.oris/2 -(cannon.base_oris or 0),
        }
      end
    end

    if #for_whom > 0 and wc_color[weapon_type.category] then
      if weapon_type.max_dst then
        rendering.draw_circle{
          color=wc_color[weapon_type.category],
          radius=lib_ttn.calc_max_dst(cannon, entity.force, titan_type, wi, weapon_type) *0.95,
          filled=false, width=10+0.5*class, time_to_live=visual_ttl,
          surface=surface, target=gunpos, players=for_whom, --forces={entity.force},
          draw_on_ground=false, only_in_alt_mode=true,
        }
      elseif weapon_type.medium_length then
        rendering.draw_arc{
          color=wc_color[weapon_type.category],
          min_radius=weapon_type.medium_length-1,
          max_radius=weapon_type.medium_length+1,
          start_angle=orientation_to_radians(ori-oris/2+(cannon.base_oris or 0)/2) - weapon_type.arc_angle/2,
          angle=weapon_type.arc_angle,
          surface=surface, target=gunpos, time_to_live=visual_ttl, players=for_whom, --forces={entity.force},
          draw_on_ground=false, only_in_alt_mode=true,
        }
      end
    end
    -- TODO: add weapons shadow
  end

  -- TODO: remove foots if too far

  local img, sc, foot
  if spd > 0.03 then


    ----- Foots

    if titan_info.foot_cd < tick then
      titan_info.foot_cd = tick + 10 + 0.5 * class
      titan_info.foot_rot = not titan_info.foot_rot

      foot = titan_info.foots[titan_info.foot_rot and 1 or 2]
      if foot and foot.valid then foot.destroy() end

      local foot_oris, foot_shift
      if entity.speed < 0 then
        foot_oris = 0.4 * (titan_info.foot_rot and -1 or 1)
        foot_shift = 6 + class/8
      else
        foot_oris = 0.1 * (titan_info.foot_rot and -1 or 1)
        foot_shift = 8 + class/8
      end
      if class < 20 then
        img = shared.mod_prefix.."foot-small"
        sc = 1
      else
        img = shared.mod_prefix.."foot-big"
        sc = (class+5) /20
      end
      local foot_pos = math2d.position.add(entity.position, point_orientation_shift(ori + foot_oris, foot_shift))
      if not titan_type.over_water then
        local earty_radius = 5 + class*0.1
        try_remove_small_water(surface, foot_pos, earty_radius)
        try_remove_small_water(surface, math2d.position.add(entity.position, point_orientation_shift(ori, foot_shift)), earty_radius)
      end
      foot = surface.create_entity{
        name=titan_type.foot, force="neutral", position=foot_pos,
      }
      foot.destructible = false
      ctrl_data.foots[#ctrl_data.foots+1] = {
        owner = entity, entity=foot,
        animation=img, ori=ori, sc=sc,
      }
      surface.create_entity{
        name=titan_type.foot.."-damage", force="neutral", speed=1,
        position=foot.position, target=foot.position, source=math2d.position.add(foot.position, {x=0, y=-1})
      }
      titan_info.foots[titan_info.foot_rot and 1 or 2] = foot
      -- if titan_info.foots[titan_info.leg and 2 or 1] then
      --   game.print("Placed foot: "..serpent.line(foot.valid).." / "..serpent.line(titan_info.foots[titan_info.leg and 2 or 1].valid))
      -- end
    end


    ----- Tracks

    if titan_info.track_cd < tick then
      titan_info.track_cd = tick + 20 + class
      titan_info.track_rot = not titan_info.track_rot

      if class < 20 then
        img = shared.mod_prefix.."step-small"
        sc = 1
      else
        img = shared.mod_prefix.."step-big"
        sc = class / 20
      end

      rendering.draw_animation{
        animation=img, x_scale=sc, y_scale=sc,
        render_layer=shared.rl_track, time_to_live=5*UPS,
        surface=surface,
        target=math2d.position.add(entity.position, point_orientation_shift(ori + 0.25 * (titan_info.track_rot and 1 or -1), 4+0.1*titan_info.class)),
        target_offset={3, 0}, orientation=ori-oris/2,
      }
    end


    ----- Movement sounds

    local volume = math.min(1, spd/0.2) -- TODO: add class coef?
    if titan_info.body_cd < tick then
      surface.play_sound{
        path="wh40k-titans-walk-step",
        position=entity.position, volume_modifier=volume*0.8
      }
      titan_info.body_cd = tick + 30 + 1.5*class
    end
    if titan_info.voice_cd < tick then
      if settings.global["wh40k-titans-talk"].value and (math.random(100) < 20) then
        surface.play_sound{
          path="wh40k-titans-phrase-walk",
          position=entity.position, volume_modifier=1
        }
      end
      titan_info.voice_cd = tick + 450 + 15*class
    end
  end -- if spd

  -- Prevent slowing down
  if entity.stickers then
    for _, st in pairs(entity.stickers) do
      if st.valid then st.destroy() end
    end
  end
end -- process_single_titan





local function process_titans()
  -- TODO: optimise, get rid of table recreation
  local titans_old = ctrl_data.titans
  local titans_new = {}
  for unit_number, titan_info in pairs(titans_old) do
    if titan_info.entity and titan_info.entity.valid then
      titans_new[titan_info.entity.unit_number] = titan_info
      process_single_titan(titan_info)

      titan_info.ai_cd = ((titan_info.ai_cd or 0) + 1) % 20
      if titan_info.ai_cd == 0 then
        lib_ttn.handle_attack_ai(titan_info)
      end
    else
      game.print("Titan "..unit_number.." of class "..titan_info.class.." got invalid :(")
      lib_ttn.titan_removed(titan_info, true)
    end
  end
  ctrl_data.titans = titans_new

  for index, info in pairs(ctrl_data.foots) do
    if info.entity.valid then
      rendering.draw_animation{
        animation=info.animation,
        x_scale=info.sc or 1, y_scale=info.sc or 1, render_layer=shared.rl_foot,
        time_to_live=visual_ttl,
        surface=info.entity.surface,
        target=info.entity,
        orientation=info.ori,
      }
    else
      ctrl_data.foots[index] = nil
    end
  end
end


lib_ttn:on_event(defines.events.on_tick, process_titans)
