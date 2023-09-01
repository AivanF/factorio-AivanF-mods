require("__core__.lualib.util")
local Position = require('__stdlib__/stdlib/area/position')
local shared = require("shared")
local mod_name = shared.mod_name

----- Constants -----

-- TODO: move into shared
--[[
https://lua-api.factorio.com/latest/Concepts.html#RenderLayer
"air-object" = 145
"light-effect" = 148
"selection-box" = 187
]]--
local track_render_layer = 122
local foot_render_layer = 124 -- ="lower-object"
local shadow_render_layer = 144
local lower_render_layer = 168
local arm_render_layer = 169
local body_render_layer = 170
local shoulder_render_layer = 171
local shield_render_layer = 172

local building_update_rate = 60
local vehicle_update_rate = 1
local order_ttl = 60 * 5

local b1, b2 = 4, 2.5
local bunker_lamps = {
  {-b1, -b2}, {-b1, -b1}, {-b2, -b1},
  { b1, -b2}, { b1, -b1}, { b2, -b1},
  {-b1,  b2}, {-b1,  b1}, {-b2,  b1},
  { b1,  b2}, { b1,  b1}, { b2,  b1},
}
local max_oris = { -- titan cannon max orientation shift
  0.15, 0.15,
  0.4, 0.4,
  0.2, 0.2,
}

----- Script data -----

local blank_ctrl_data = {
  bunkers = {},
  titans = {},
  foots = {},
}
local ctrl_data = table.deepcopy(blank_ctrl_data)
local used_specials = {}


------- Logic -------

local function get_keys(tbl)
  if tbl == nil then return nil end
  local result = {}
  for k, v in pairs(tbl) do
    result[#result+1] = k
  end
  return result
end

local function merge(a, b, over)
  for k, v in pairs(b) do
    if a[k] == nil or over then
      a[k] = v
    end
  end
  return a
end

local function points_to_orientation(a, b)
  return 0.25 +math.atan2(b.y-a.y, b.x-a.x) /math.pi /2
end

local function orientation_diff(src, dst)
  if dst - src > 0.5 then src = src + 1 end
  if src - dst > 0.5 then dst = dst + 1 end
  return dst - src
end

local function point_orientation_shift(ori, oris, length)
  ori = -ori + 0.25 + oris
  ori = ori * 2 * math.pi
  return length*math.cos(ori), -length*math.sin(ori)
end

function math.clamp(v, mn, mx)
  return math.max(math.min(v, mx), mn)
end

local function is_titan(name)
  return name:find(shared.titan_prefix, 1, true)
end

local function die_all(list, global_storage)
  for _, special_entity in pairs(list) do
    special_entity.destroy()
    if global_storage ~= nil then
      global_storage[special_entity.unit_number] = nil
    end
  end
end

local function preprocess_entities(list)
  for _, entity in pairs(list) do
    used_specials[entity.unit_number] = true
    entity.active = false -- for crafting machines
  end
end

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


local function register_titan(entity)
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


local function register_bunker(entity)
  local unit_number = entity.unit_number
  local bucket = ctrl_data.bunkers[unit_number % building_update_rate]
  if not bucket then
    bucket = {}
    ctrl_data.bunkers[unit_number % building_update_rate] = bucket
  end
  local surface = entity.surface
  local bunker = bucket[unit_number] or {
    entity = entity,
    lamps = {},
    wstore = {},
    wrecipe = {},
    bstore = nil,
    brecipe = nil,
  }
  bucket[unit_number] = bunker

  for i, pos in ipairs(bunker_lamps) do
    bunker.lamps[i] = bunker.lamps[i] or surface.create_entity{
      name=shared.bunker_lamp, force="neutral",
      position={x=entity.position.x+pos[1], y=entity.position.y+pos[2]},
    }
  end
  preprocess_entities(bunker.lamps)

  bunker.wstore[1] = bunker.wstore[1] or surface.create_entity{
    name=shared.bunker_wstoreh, force="neutral",
    position={x=entity.position.x-1, y=entity.position.y-4},
  }
  bunker.wstore[2] = bunker.wstore[2] or surface.create_entity{
    name=shared.bunker_wstoreh, force="neutral",
    position={x=entity.position.x+1, y=entity.position.y-4},
  }
  bunker.wstore[3] = bunker.wstore[3] or surface.create_entity{
    name=shared.bunker_wstorev, force="neutral",
    position={x=entity.position.x-4, y=entity.position.y-1},
  }
  bunker.wstore[4] = bunker.wstore[4] or surface.create_entity{
    name=shared.bunker_wstorev, force="neutral",
    position={x=entity.position.x+4, y=entity.position.y-1},
  }
  bunker.wstore[5] = bunker.wstore[5] or surface.create_entity{
    name=shared.bunker_wstorev, force="neutral",
    position={x=entity.position.x-4, y=entity.position.y+1},
  }
  bunker.wstore[6] = bunker.wstore[6] or surface.create_entity{
    name=shared.bunker_wstorev, force="neutral",
    position={x=entity.position.x+4, y=entity.position.y+1},
  }
  preprocess_entities(bunker.wstore)

  bunker.wrecipe[1] = bunker.wrecipe[1] or surface.create_entity{
    name=shared.bunker_wrecipeh, force="neutral",
    position={x=entity.position.x-1, y=entity.position.y-3},
  }
  bunker.wrecipe[2] = bunker.wrecipe[2] or surface.create_entity{
    name=shared.bunker_wrecipeh, force="neutral",
    position={x=entity.position.x+1, y=entity.position.y-3},
  }
  bunker.wrecipe[3] = bunker.wrecipe[3] or surface.create_entity{
    name=shared.bunker_wrecipev, force="neutral",
    position={x=entity.position.x-3, y=entity.position.y-1},
  }
  bunker.wrecipe[4] = bunker.wrecipe[4] or surface.create_entity{
    name=shared.bunker_wrecipev, force="neutral",
    position={x=entity.position.x+3, y=entity.position.y-1},
  }
  bunker.wrecipe[5] = bunker.wrecipe[5] or surface.create_entity{
    name=shared.bunker_wrecipev, force="neutral",
    position={x=entity.position.x-3, y=entity.position.y+1},
  }
  bunker.wrecipe[6] = bunker.wrecipe[6] or surface.create_entity{
    name=shared.bunker_wrecipev, force="neutral",
    position={x=entity.position.x+3, y=entity.position.y+1},
  }
  preprocess_entities(bunker.wrecipe)

  bunker.brecipe = bunker.brecipe or surface.create_entity{
    name=shared.bunker_center, force="neutral",
    position={x=entity.position.x, y=entity.position.y},
  }
  bunker.bstore = bunker.bstore or surface.create_entity{
    name=shared.bunker_bstore, force="neutral",
    position={x=entity.position.x, y=entity.position.y+3.5},
  }
  preprocess_entities({bunker.brecipe, bunker.bstore})
end


local function on_any_built(event)
  local entity = event.created_entity or event.entity or event.destination
  if not (entity and entity.valid) then return end
  if is_titan(entity.name) then
    register_titan(entity)
  elseif entity.name == shared.bunker then
    register_bunker(entity)
  end
end


local function on_any_remove(event)
  local unit_number
  local entity = event.entity
  if entity and entity.valid then
    unit_number = entity.unit_number
  else
    entity = nil
  end
  unit_number = unit_number or event.unit_number
  if not unit_number then return end

  if ctrl_data.titans[unit_number] then
    local tctrl = ctrl_data.titans[unit_number]
    die_all(tctrl.foots)
    -- TODO: check event.name and make explo, corpse
    ctrl_data.titans[unit_number] = nil
  end

  local bucket = ctrl_data.bunkers[unit_number % building_update_rate]
  if bucket and bucket[unit_number] then
    local bunker = bucket[unit_number]
    -- TODO: replace non-empty storages with temp containers!
    die_all(bunker.lamps)
    die_all(bunker.wstore)
    die_all(bunker.wrecipe)
    die_all({bunker.brecipe, bunker.bstore})
    ctrl_data.bunkers[unit_number % building_update_rate] = nil
  end
end


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
    time_to_live=vehicle_update_rate+1,
    surface=surface, target=entity, target_offset=shadow_shift,
    orientation=ori+oris,
  }
  rendering.draw_animation{
    animation=name,
    x_scale=1, y_scale=1, render_layer=body_render_layer,
    time_to_live=vehicle_update_rate+1,
    surface=surface, target=entity, target_offset={0, 0},
    orientation=ori+oris,
  }
  rendering.draw_light{
    sprite=shared.mod_prefix.."light", scale=7+3*class,
    intensity=1+0.5*class, minimum_darkness=0, color=tint,
    time_to_live=vehicle_update_rate+1,
    surface=surface, target=Position.add(entity.position, point_orientation_shift(ori, 0, 6)),
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
      time_to_live=vehicle_update_rate+1,
      surface=surface, target=Position.add(entity.position, point_orientation_shift(ori, 0, 2)),
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
      surface=surface, time_to_live=vehicle_update_rate+1,
      forces={entity.force}, only_in_alt_mode=true
    }
    rendering.draw_rectangle{
      color={1,1,1,1}, filled=true,
      left_top=entity, left_top_offset={-w2,yy},
      right_bottom=entity, right_bottom_offset={-w2+2*w2*shield_cf,yy+hh},
      surface=surface, time_to_live=vehicle_update_rate+1,
      forces={entity.force}, only_in_alt_mode=true
    }
  end


  ----- The Guns
  local weapon_class, tori, orid, gunpos, dst

  for k, cannon in ipairs(info.guns) do
    weapon_class = shared.weapons[info.guns[k].name]
    gunpos = Position.add(entity.position, point_orientation_shift(ori, class_info.guns[k].oris, class_info.guns[k].shift))
    tori = ori  -- target orientation

    if cannon.target ~= nil and tick < cannon.ordered + order_ttl then
      -- TODO: check if target is a LuaEntity
      tori = points_to_orientation(gunpos, cannon.target)
      orid = orientation_diff(ori+cannon.oris, tori)
      cannon.oris = cannon.oris + 0.03*orid
      cannon.oris = math.clamp(cannon.oris, -max_oris[k], max_oris[k])
      dst = Position.distance(gunpos, cannon.target)

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
      time_to_live=vehicle_update_rate+1,
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
        position=Position.add(entity.position, point_orientation_shift(ori, foot_oris, foot_shift)),
      }
      ctrl_data.foots[#ctrl_data.foots+1] = {  -- TODO: is this buggy?!?
        owner = entity, entity=foot,
        animation=img, ori=ori, sc=sc,
      }
      surface.create_entity{
        name=class_info.foot.."-damage", force="neutral", speed=1,
        position=foot.position, target=foot.position, source=Position.add(foot.position, {x=0, y=-1})
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
        target=Position.add(entity.position, point_orientation_shift(ori, 0.25 * (info.track_rot and 1 or -1), 4+info.class)),
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
        time_to_live=vehicle_update_rate+1,
        surface=info.entity.surface,
        target=info.entity,
        orientation=info.ori,
      }
    else
      ctrl_data.foots[index] = nil
    end
  end
end


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
      dst = Position.distance(entity.position, target)
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


----- Void Shields absorbing
script.on_event(defines.events.on_entity_damaged, function(event)
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


local function process_bunkers()
  -- print(serpent.block(ctrl_data))
  -- TODO: check process status

  -- TODO: if is assembly process...

  -- TODO: if not in assembly process
  -- TODO: find class by recipe
  -- TODO: determine appropriate weapons recipes and storages content
  -- TODO: set lamp colors by prev values
end

script.on_nth_tick(building_update_rate, process_bunkers)
if vehicle_update_rate > 0 then
  script.on_nth_tick(vehicle_update_rate, process_titans)
else
  script.on_event(defines.events.on_tick, process_titans)
end


local function total_reload()
  local titan_count = 0
  local bunker_count = 0
  local special_removed = 0
  local special_saved = 0
  used_specials = {}

  for _, surface in pairs(game.surfaces) do
    for _, titan_class in pairs(shared.titan_classes) do
      for _, entity in pairs (surface.find_entities_filtered{name=titan_class.entity}) do
        register_titan(entity)
        titan_count = titan_count + 1
      end
    end

    for _, entity in pairs (surface.find_entities_filtered{name=shared.bunker}) do
      register_bunker(entity)
      bunker_count = bunker_count + 1
    end

    for _, name in pairs(shared.special_entities) do
      for _, entity in pairs (surface.find_entities_filtered{name=name}) do
        if used_specials[entity.unit_number] then
          special_saved = special_saved + 1
        else
          -- TODO: replace non-empty storages with temp containers!
          entity.destroy()
          special_removed = special_removed + 1
        end
      end
    end
  end
  used_specials = {}

  local txt = "WH40k-Titans reload: "..table.concat({
      "Ti="..titan_count,
      "Bn="..bunker_count,
      "SpRm="..special_removed,
      "SpSv="..special_saved,
    }, ", ")
  game.print(txt)
  log(txt)
end


local function on_init()
  global.ctrl_data = table.deepcopy(blank_ctrl_data)
end

local function on_load()
  ctrl_data = global.ctrl_data
end

local function clean_drawings()
  local ids = rendering.get_all_ids(mod_name)
  for _, id in pairs(ids) do
    if rendering.is_valid(id) then
      rendering.destroy(id)
    end
  end
end

local function update_configuration()
  global.ctrl_data = merge(global.ctrl_data or {}, blank_ctrl_data, false)
  ctrl_data = global.ctrl_data
  clean_drawings()
  total_reload()
end


script.on_event(shared.mod_prefix.."attack", handle_attack_order)

script.on_init(on_init)
script.on_load(on_load)
script.on_event(defines.events.on_runtime_mod_setting_changed, update_runtime_settings)
script.on_configuration_changed(update_configuration)

script.on_event({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}, on_any_built)

script.on_event({
  defines.events.on_player_mined_entity,
  defines.events.on_robot_mined_entity,
  defines.events.on_entity_died,
  defines.events.script_raised_destroy,
}, on_any_remove)

commands.add_command(
  "titans-clean-draw",
  "Remove all WH40k Titans drawings",
  clean_drawings
)
commands.add_command(
  "titans-reload",
  "Reload all WH40k Titans",
  update_configuration
)
