require("script/common")
local math2d = require("math2d")
local Lib = require("script/event_lib")
local lib = Lib.new()

local order_ttl = 60 * 5
local visual_ttl = 2

local max_oris = { -- titan cannon max orientation shift
  0.15, 0.15,
  0.4, 0.4,
  0.2, 0.2,
}


local function init_gun(name)
  return  {
    name = name,
    cd = 0,
    oris = 0, -- orientation shift of the cannon
    target = nil, -- LuaEntity or position
    ordered = 0, -- task creation tick for expiration
    gun_cd = 0,
  }
end


function lib.register_titan(entity)
  if ctrl_data.titans[entity.unit_number] then return end
  local class_info = shared.titan_classes[entity.name]
  local info = {
    entity = entity,
    class = class_info.class,
    shield = 0, -- void shield health amount
    voice_cd = 0, -- phrases muted till
    body_cd = 0, -- step and rotation sounds muted till
    track_cd = 0, -- footstep track drawing cooldown till
    foot_cd = 0,
    track_rot = false, -- R or L
    foot_rot = false, -- R or L
    foots = {}, -- 2 foot entities
    guns = {}, -- should be added by bunker script
  }

  if class_info.class == 1 then
    info.guns = {
      init_gun(shared.weapon_plasma_destructor),
      init_gun(shared.weapon_turbolaser),
    }
  else
    info.guns = {
      init_gun(shared.weapon_plasma_destructor),
      init_gun(shared.weapon_plasma_destructor),
      init_gun(shared.weapon_turbolaser),
      init_gun(shared.weapon_lascannon),
    }
  end

  ctrl_data.titans[entity.unit_number] = info
  entity.surface.play_sound{
    path="wh40k-titans-phrase-init",
    position=entity.position, volume_modifier=1
  }
end



----- MAIN -----

local function process_single_titan(info)
  local tick = game.tick
  local class_info = shared.titan_classes[info.class]
  local class = info.class
  local name = class_info.name
  local entity = info.entity
  local surface = entity.surface
  local spd = math.abs(entity.speed)
  if entity.speed < 0 then
    entity.speed = entity.speed * 0.99
  end
  local ori = entity.orientation
  local oris = math.sin(tick/120 *2*math.pi) * 0.02 * spd/0.3
  local shadow_shift = {2 * (1+class), 1}

  ----- Body

  rendering.draw_animation{
    animation=name.."-shadow",
    x_scale=1, y_scale=1, render_layer=shadow_render_layer,
    time_to_live=visual_ttl,
    surface=surface, target=entity, target_offset=shadow_shift,
    orientation=ori+oris,
  }
  rendering.draw_animation{
    animation=name,
    x_scale=1, y_scale=1, render_layer=body_render_layer,
    time_to_live=visual_ttl,
    surface=surface, target=entity, target_offset={0, 0},
    orientation=ori+oris,
  }
  rendering.draw_light{
    sprite=shared.mod_prefix.."light", scale=7+3*class,
    intensity=1+0.5*class, minimum_darkness=0, color=tint,
    time_to_live=visual_ttl,
    surface=surface, target=math2d.position.add(entity.position, point_orientation_shift(ori, 0, 6)),
  }


  ----- Void Shield
  -- TODO: consider energy spent on guns
  -- 3 minutes for the full recharge
  info.shield = math.min((info.shield or 0) + class_info.max_shield /60 /180, class_info.max_shield)
  local sc = 0.75 + 0.25*class

  -- Main visual
  if info.shield > 100 then
    rendering.draw_sprite{
      sprite=shared.mod_prefix.."shield",
      x_scale=sc, y_scale=sc, render_layer=shield_render_layer,
      time_to_live=visual_ttl,
      surface=surface, target=math2d.position.add(entity.position, point_orientation_shift(ori, 0, 2)),
    }
  end

  -- Ratio bar
  local shield_cf = info.shield/class_info.max_shield
    if shield_cf < 0.99 then
    local w2 = 1 + class
    local yy = 4 + class
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
  local weapon_class, tori, orid, gunpos, dst

  for k, cannon in ipairs(info.guns) do
    weapon_class = shared.weapons[info.guns[k].name]
    gunpos = math2d.position.add(entity.position, point_orientation_shift(ori, class_info.guns[k].oris, class_info.guns[k].shift))
    tori = ori  -- target orientation

    if cannon.target ~= nil and tick < cannon.ordered + order_ttl then
      -- TODO: check if target is a LuaEntity
      tori = points_to_orientation(gunpos, cannon.target)
      orid = orientation_diff(ori+cannon.oris, tori)
      cannon.oris = cannon.oris + 0.03*orid
      cannon.oris = math.clamp(cannon.oris, -max_oris[k], max_oris[k])
      dst = math2d.position.distance(gunpos, cannon.target)

      if math.abs(orid) < 0.015 and cannon.gun_cd < tick and dst > 4 and dst < weapon_class.max_dst then
        -- TODO: incapsulate attack
        -- TODO: add some time before attack
        -- TODO: calculate gun muzzle position
        surface.create_entity{
          name=shared.mod_prefix.."bolt-plasma", force="neutral", speed=5,
          position=gunpos, source=gunpos, target=cannon.target
        }

        cannon.target = nil
        cannon.gun_cd = tick + 180
      end
    else
      -- Smoothly remove oris
      -- TODO: add some time after attack
      cannon.target = nil
      if math.abs(cannon.oris) > 0.01 then
        cannon.oris = cannon.oris * 0.95
      else
        cannon.oris = 0
      end
    end

    rendering.draw_animation{
      animation=weapon_class.animation,
      x_scale=1, y_scale=1, render_layer=class_info.guns[k].layer,
      time_to_live=visual_ttl,
      surface=surface,
      target=gunpos,
      orientation=ori-oris/2 + cannon.oris,
    }
    -- TODO: add weapons shadow
  end

  -- TODO: remove foots if too far

  local img, sc, foot
  if spd > 0.03 then


    ----- Foots

    if info.foot_cd < tick then
      info.foot_cd = tick + 15 + 15 * class
      info.foot_rot = not info.foot_rot

      foot = info.foots[info.foot_rot and 1 or 2]
      if foot and foot.valid then foot.destroy() end

      local foot_oris, foot_shift
      if entity.speed < 0 then
        foot_oris = 0.4 * (info.foot_rot and -1 or 1)
        foot_shift = 6 + class
      else
        foot_oris = 0.1 * (info.foot_rot and -1 or 1)
        foot_shift = 8 + class
      end
      if class < 2 then
        img = shared.mod_prefix.."foot-small"
        sc = 1
      else
        img = shared.mod_prefix.."foot-big"
        sc = (class+0.5) / 2
      end
      foot = surface.create_entity{
        name=class_info.foot, force="neutral",
        position=math2d.position.add(entity.position, point_orientation_shift(ori, foot_oris, foot_shift)),
      }
      ctrl_data.foots[#ctrl_data.foots+1] = {  -- TODO: is this buggy?!?
        owner = entity, entity=foot,
        animation=img, ori=ori, sc=sc,
      }
      surface.create_entity{
        name=class_info.foot.."-damage", force="neutral", speed=1,
        position=foot.position, target=foot.position, source=math2d.position.add(foot.position, {x=0, y=-1})
      }
      info.foots[info.foot_rot and 1 or 2] = foot
      -- if info.foots[info.leg and 2 or 1] then
      --   game.print("Placed foot: "..serpent.line(foot.valid).." / "..serpent.line(info.foots[info.leg and 2 or 1].valid))
      -- end

      -- TODO: if not over_water, apply landfill/shallow-water if small (deep)water found
    end


    ----- Tracks

    if info.track_cd < tick then
      info.track_cd = tick + 45 + 15 * class
      info.track_rot = not info.track_rot

      if class < 2 then
        img = shared.mod_prefix.."step-small"
        sc = 1
      else
        img = shared.mod_prefix.."step-big"
        sc = class / 2
      end

      rendering.draw_animation{
        animation=img, x_scale=sc, y_scale=sc,
        render_layer=track_render_layer, time_to_live=60*5,
        surface=surface,
        target=math2d.position.add(entity.position, point_orientation_shift(ori, 0.25 * (info.track_rot and 1 or -1), 4+info.class)),
        target_offset={3, 0}, orientation=ori-oris/2,
      }
    end


    ----- Movement sounds

    local volume = math.min(1, spd/0.2) -- TODO: add class coef?
    if info.body_cd < tick then
      surface.play_sound{
        path="wh40k-titans-walk-step",
        position=entity.position, volume_modifier=volume*0.8
      }
      info.body_cd = tick + 30 + 15 * class
    end
    if info.voice_cd < tick then
      if math.random(100) < 30 then
        surface.play_sound{
          path="wh40k-titans-phrase-walk",
          position=entity.position, volume_modifier=1
        }
      end
      info.voice_cd = tick + 450 + 150 * class
    end
  end -- if spd

  -- Prevent slowing down
  if entity.stickers then
    for _, st in pairs(entity.stickers) do
      if st.valid then st.destroy() end
    end
  end
end


local function process_titans()
  for unit_number, info in pairs(ctrl_data.titans) do
    if info.entity.valid then
      process_single_titan(info)
    else
      ctrl_data.titans[unit_number] = nil
    end
  end
  for index, info in pairs(ctrl_data.foots) do
    if info.entity.valid then
      rendering.draw_animation{
        animation=info.animation,
        x_scale=info.sc or 1, y_scale=info.sc or 1, render_layer=foot_render_layer,
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


lib:on_event(defines.events.on_tick, process_titans)



----- Attack Order -----

local function handle_attack_order(event)
  -- https://lua-api.factorio.com/latest/events.html#CustomInputEvent
  local player = game.players[event.player_index]
  if not (player.character and player.character.vehicle) then return end
  local entity = player.character.vehicle
  local info = ctrl_data.titans[entity.unit_number]
  if not info then return end

  -- game.print("Titan attack by "..player.name.." at "..serpent.line(event.cursor_position))
  -- game.print(player.character.vehicle.name)

  -- local ori = points_to_orientation(player.character.vehicle.position, event.cursor_position)
  -- game.print("Ori: "..serpent.line(ori))
  -- return

  -- TODO: pick appropriate gun considering distance and player settings
  -- TODO: try to convert target position into the most dangeroues entity
  local tick = game.tick
  local target = event.cursor_position
  local todo
  local done = false
  local weapon_class, dst

  for k, cannon in pairs(info.guns) do
    weapon_class = shared.weapons[info.guns[k].name]
    todo = true
    todo = todo and cannon.gun_cd < tick 
    todo = todo and (target == nil or cannon.ordered+order_ttl < tick)

    if todo then
      dst = math2d.position.distance(entity.position, target)
      todo = dst > 3 and dst < weapon_class.max_dst
    end

    -- TODO: make priority choice: if there is gun_cd, save for secondary task order, trying to find a free cannon
    if todo then
      cannon.target = event.cursor_position
      cannon.ordered = tick
      done = true
      break
    end
  end
  -- game.print(serpent.block(info.guns))
  if done then
    if info.voice_cd < tick then
      if math.random(100) < 80 then
        entity.surface.play_sound{
          path="wh40k-titans-phrase-attack",
          position=entity.position, volume_modifier=1
        }
      end
      info.voice_cd = tick + 450 + 150 * info.class
    end
  else
    -- game.print("No ready titan cannon")
  end
end

lib:on_event(shared.mod_prefix.."attack", handle_attack_order)



----- Void Shields absorbing

lib:on_event(defines.events.on_entity_damaged, function(event)
  local entity = event.entity
  local unit_number = entity.valid and entity.unit_number
  if unit_number == nil then return end
  if ctrl_data.titans[unit_number] then
    local tctrl = ctrl_data.titans[unit_number]
    entity.health = event.final_health + event.final_damage_amount
    local damage = event.final_damage_amount
    local shielded = math.min(damage, tctrl.shield)
    tctrl.shield = tctrl.shield - shielded
    damage = damage - shielded
    entity.health = entity.health - damage
    -- game.print("damage: "..damage..", shielded: "..shielded)
  end
end)


return lib