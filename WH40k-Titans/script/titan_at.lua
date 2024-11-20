local lib_ruins = require("script/ruins")
local lib_tech = require("script/tech")

lib_ttn.order_ttl = 5 * UPS

local max_oris = { -- titan cannon max orientation shift
  0.15, 0.15,
  0.4, 0.4,
  0.4, 0.4,
}

-- Called from register_titan
function lib_ttn.init_gun(name, weapon_type)
  weapon_type = weapon_type or shared.weapons[name]
  local cannon = {
    name = weapon_type.name,
    cd = 0,
    oris = 0, -- orientation shift of the cannon
    target = nil, -- LuaEntity or position
    ordered = 0, -- task creation tick for expiration
    gun_cd = 0,
    attack_number = 0, -- from weapon_type.attack_size
    ammo_count = weapon_type.inventory,
    ammo_name = weapon_type.ammo,
    ai = false,
  }
  return cannon
end


function lib_ttn.calc_max_dst(cannon, force, titan_type, wi, weapon_type)
  if not cannon.cached_dst then
    cannon.cached_dst = 1
      * weapon_type.max_dst
      * (1 + 0.01*titan_type.class)
      * (titan_type.mounts[wi].is_top and 1.1 or 1)
      * (force and shared.attack_range_cf_get(lib_tech.get_research_level(force.index, shared.attack_range_research)) or 1)
  end
  return cannon.cached_dst
end


local function bolt_attacker(entity, titan_type, cannon, weapon_type, source, target)
  if weapon_type.bolt_type == nil then
    error("Weapon "..weapon_type.name.." has no bolt type!")
  end
  local speed = weapon_type.speed or 10
  if type(speed) ~= "table" then speed = {speed,} end
  local barrel = weapon_type.barrel or 12
  if weapon_type.category == shared.wc_flamer then
    source = math2d.position.add(source, {math.random(-1, 1), math.random(-1, 1)})
  end
  if barrel > 0 then
    source = math2d.position.add(source, point_orientation_shift(entity.orientation + cannon.oris, barrel))
  end
  for _, value in ipairs(speed) do
    entity.surface.create_entity{
      name=weapon_type.bolt_type.entity, force=entity.force,
      position=source, source=entity, target=target, speed=value,
    }
  end
end


local function opt_play(entity, sound)
  if not sound then return end
  entity.surface.play_sound{
    path=sound,
    position=entity.position, volume_modifier=1
  }
end


local function use_ammo_by_prob(force)
  local lvl = lib_tech.get_research_level(force.index, shared.ammo_usage_research)
  if lvl > 0 then
    return math.random(0, 100) <= 100 - 5 * lvl
  else
    return true
  end
end


local function gun_do_attack(titan_info, titan_type, wi, cannon, gunpos, weapon_type, ori, tick, attacker)
  -- TODO: add some time before attack
  -- TODO: calculate gun muzzle position
  if (cannon.attack_number or 0) >= 1 then
    cannon.attack_number = cannon.attack_number - 1
  elseif weapon_type.attack_size > 1 then
    cannon.attack_number = (weapon_type.attack_size-1) or 0
    opt_play(titan_info.entity, weapon_type.attack_start_sound)
  end
  if use_ammo_by_prob(titan_info.entity.force) then
    cannon.ammo_count = math.max(0, cannon.ammo_count - weapon_type.per_shot)
  end
  local target = cannon.target
  if (weapon_type.scatter or 0) > 0 then
    target = math2d.position.add(target, {
      math.random(-weapon_type.scatter, weapon_type.scatter),
      math.random(-weapon_type.scatter, weapon_type.scatter)})
  end
  attacker(titan_info.entity, titan_type, cannon, weapon_type, gunpos, target)
  cannon.gun_cd = tick + weapon_type.cd * UPS
  -- log("gun_do_attack name: "..cannon.name..", attack_number: "..cannon.attack_number)

  opt_play(titan_info.entity, weapon_type.attack_sound)

  if (cannon.attack_number or 0) <= 0 then
    cannon.target = nil
    cannon.attack_number = 0
    cannon.when_can_rotate = tick + 90*weapon_type.grade
  else
    cannon.ordered = tick
  end
end


local function control_simple_gun(titan_info, titan_type, wi, cannon, gunpos, weapon_type, ori, tick)
  if cannon.target ~= nil and tick < cannon.ordered + lib_ttn.order_ttl then
    local dst = math2d.position.distance(gunpos, cannon.target)
    if cannon.gun_cd < tick and dst > weapon_type.min_dst and dst < lib_ttn.calc_max_dst(cannon, titan_info.entity.force, titan_type, wi, weapon_type) then
      gun_do_attack(titan_info.entity, titan_type, wi, cannon, gunpos, weapon_type, ori, tick, bolt_attacker)
    end

  else
    cannon.target = nil
  end
end


local function control_rotate_gun(titan_info, titan_type, wi, cannon, gunpos, weapon_type, ori, tick)
  if cannon.target ~= nil and tick < cannon.ordered + lib_ttn.order_ttl then
    -- TODO: check if target is a LuaEntity
    local tori = points_to_orientation(gunpos, cannon.target)
    local orid = orientation_diff(ori+cannon.oris, tori)
    cannon.oris = cannon.oris + (0.04-0.005*weapon_type.grade)*orid
    cannon.oris = math.clamp(cannon.oris, -max_oris[wi], max_oris[wi])
    local dst = math2d.position.distance(gunpos, cannon.target)

    if true
      and math.abs(orid) < (weapon_type.max_orid or 0.015)
      and cannon.gun_cd < tick
      and dst > weapon_type.min_dst and dst < lib_ttn.calc_max_dst(cannon, titan_info.entity.force, titan_type, wi, weapon_type)
    then
      gun_do_attack(titan_info, titan_type, wi, cannon, gunpos, weapon_type, ori, tick, bolt_attacker)
    end

  else
    cannon.target = nil
    if (cannon.when_can_rotate or 0) < tick then
      -- Smoothly remove oris
      if math.abs(cannon.oris) > 0.005 then
        cannon.oris = cannon.oris * 0.95
      else
        cannon.oris = 0
      end
    end
  end
end


local function control_arty_gun(titan_info, titan_type, wi, cannon, gunpos, weapon_type, ori, tick)
  local created = false
  if cannon.entity == nil or not cannon.entity.valid then
    cannon.entity = titan_info.entity.surface.create_entity{
      name=shared.arty, position=gunpos, force=titan_info.entity.force,
    }
    cannon.entity.destructible = false
    created = true
  else
    if math.fmod(tick, 2) == 0 then
      cannon.entity.teleport(gunpos)
    end
  end

  -- cannon.entity.orientation = 0
  -- cannon.entity.relative_turret_orientation = entity.orientation

  -- if math.abs(cannon.entity.orientation - entity.orientation) > 0.2 then
  --   cannon.entity.orientation = entity.orientation
  -- end

  local ent_inv = cannon.entity.get_inventory(defines.inventory.turret_ammo)
  local to_add = 0

  if created then
    to_add = math.min(cannon.ammo_count, shared.arty_invsz)

  else
    local ent_has = ent_inv.get_item_count(cannon.ammo_name)

    -- It's easy to put some ammo into entity, and take back upon Titan outro,
    -- But I don't wanna bother with summing cannon.ammo_count and entity.inventory, and events order,
    -- so, trying to maintain correct value at runtime.

    -- But maybe I simply can set its ammo_stack_limit to a high value, and then copy back into cannon.ammo_count?

    if cannon.ammo_count >= shared.arty_invsz then
      local gun_dif = shared.arty_invsz - ent_has
      cannon.ammo_count = cannon.ammo_count - gun_dif
    else
      cannon.ammo_count = ent_has
    end

    if cannon.ammo_count >= shared.arty_invsz then
      to_add = shared.arty_invsz - ent_has
    end
  end

  if to_add > 0 then
    ent_inv.insert({name=cannon.ammo_name, count=to_add})
  end
end


local function start_melee()
  -- TODO: here!
end


local function control_melee(titan_info, titan_type, wi, cannon, gunpos, weapon_type, ori, tick)
  if cannon.base_oris == nil then
    cannon.base_oris = ((math.fmod(wi, 2) == 0) and 1 or -1) * 0.15
  end
  if cannon.target ~= nil then
    if cannon.tick == nil then
      cannon.tick = 0
      cannon.attack_number = 1
    else
      cannon.tick = cannon.tick + 1
      if cannon.tick > weapon_type.usage_time then
        cannon.target = nil
        cannon.tick = nil
        return
      end

      cannon.oris = (1
        * ((math.fmod(wi, 2) == 1) and 1 or -1)
        * math.sin(cannon.tick/weapon_type.usage_time *2*math.pi) * weapon_type.half_angle
      )
      titan_info.oris = titan_info.oris + cannon.oris/5

      if true
        and cannon.attack_number <= #weapon_type.attack_ticks
        and cannon.tick == weapon_type.attack_ticks[cannon.attack_number]
      then
        local bolt_ori = titan_info.entity.orientation + cannon.oris + cannon.base_oris/2
        local position = math2d.position.add(cannon.position, point_orientation_shift(bolt_ori, weapon_type.medium_length))
        titan_info.entity.surface.create_entity{
          name=weapon_type.bolt_type.entity, force=titan_info.entity.force,
          position=position, target=position, source=titan_info.entity, speed=1,
        }
        cannon.attack_number = cannon.attack_number + 1
      end
    end
  end
end


-- Called from process_single_titan
lib_ttn.wc_control = {}
lib_ttn.wc_control[shared.wc_rocket] = control_rotate_gun
lib_ttn.wc_control[shared.wc_bolter] = control_rotate_gun
lib_ttn.wc_control[shared.wc_quake]  = control_rotate_gun
lib_ttn.wc_control[shared.wc_flamer] = control_rotate_gun
lib_ttn.wc_control[shared.wc_plasma] = control_rotate_gun
lib_ttn.wc_control[shared.wc_melta]  = control_rotate_gun
lib_ttn.wc_control[shared.wc_laser]  = control_rotate_gun
lib_ttn.wc_control[shared.wc_hell]   = control_rotate_gun
lib_ttn.wc_control[shared.wc_arty]   = control_arty_gun
lib_ttn.wc_control[shared.wc_melee]  = control_melee


local enemies -- storages are dangerous, but here the value is set & used inside each tick only
local attack_ori_shifts = {0, 0.07, -0.07, 0.15, -0.15}
local ai_attack_radius = 6


local function find_gun_target(titan_info, entity, weapon_type, cannon, wi)
  local enemy_number, target_option, new_oris
  local max_number = 0
  local result = nil
  -- TODO: get rid of attack_ori_shifts, calc it dynamically by 0,±1/3,±2/3 of allowed by wi
  if weapon_type.start_far then
    -- Going inside
    for _, oris in ipairs(attack_ori_shifts) do
      dst = weapon_type.max_dst
      while 0 < dst and weapon_type.min_dst*1.3 < dst do
        dst = dst * 0.75
        new_oris = 2/3*cannon.oris + oris
        if new_oris < 0.2 and new_oris > -0.2 then
          target_option = math2d.position.add(cannon.position, point_orientation_shift(entity.orientation -titan_info.oris/2 + new_oris, dst))
          enemy_number = entity.surface.count_entities_filtered{position=target_option, radius=ai_attack_radius, force=enemies, is_military_target=true}
          if enemy_number > max_number then
            max_number = enemy_number
            result = target_option
          end
        end
      end
    end
  else
    -- Going outside
    for _, oris in ipairs(attack_ori_shifts) do
      dst = weapon_type.min_dst*1.3
      while 0 < dst and dst < weapon_type.max_dst do
        dst = dst * 1.25
        new_oris = 2/3*cannon.oris + oris
        if new_oris < 0.2 and new_oris > -0.2 then
          target_option = math2d.position.add(cannon.position, point_orientation_shift(entity.orientation -titan_info.oris/2 + new_oris, dst))
          enemy_number = entity.surface.count_entities_filtered{position=target_option, radius=ai_attack_radius, force=enemies, is_military_target=true}
          if enemy_number > max_number then
            max_number = enemy_number
            result = target_option
          end
        end
      end
    end
  end
  return result
end

local function handler_ai_gun(entity, titan_info, weapon_type, cannon, wi)
  if cannon.ammo_count >= weapon_type.per_shot*weapon_type.attack_size
  then
    return find_gun_target(titan_info, entity, weapon_type, cannon, wi)
  end
  return nil
end

local function handler_ai_melee(entity, titan_info, weapon_type, cannon, wi)
  local target_option = math2d.position.add(titan_info.entity.position, point_orientation_shift(
    entity.orientation -cannon.base_oris/2,
    shared.titan_arm_length + weapon_type.medium_length))
  local enemy_number = entity.surface.count_entities_filtered{
    position=target_option,
    radius=weapon_type.medium_length, force=enemies, is_military_target=true
  }
  if enemy_number > 1 then
    return target_option
  else
    return nil
  end
end

local wc_ai_handler = {}
wc_ai_handler[shared.wc_rocket] = handler_ai_gun
wc_ai_handler[shared.wc_bolter] = handler_ai_gun
wc_ai_handler[shared.wc_quake]  = handler_ai_gun
wc_ai_handler[shared.wc_flamer] = handler_ai_gun
wc_ai_handler[shared.wc_plasma] = handler_ai_gun
wc_ai_handler[shared.wc_melta]  = handler_ai_gun
wc_ai_handler[shared.wc_laser]  = handler_ai_gun
wc_ai_handler[shared.wc_hell]   = handler_ai_gun
wc_ai_handler[shared.wc_arty]   = niller
wc_ai_handler[shared.wc_melee]  = handler_ai_melee

function lib_ttn.handle_attack_ai(titan_info)
  local tick = game.tick
  local entity = titan_info.entity
  local titan_type = shared.titan_types[titan_info.class]
  enemies = {}
  for _, f in pairs(game.forces) do
    if f.is_enemy(titan_info.force) then
      table.insert(enemies, f)
    end
  end
  -- game.print("enemies: "..serpent.line(func_map(partial(deep_get, {}, {{"name"}}), enemies)))

  local enemy_number = entity.surface.count_entities_filtered{
    position=math2d.position.add(titan_info.entity.position, point_orientation_shift(entity.orientation, titan_info.class)),
    radius=48 + titan_info.class, force=enemies, is_military_target=true
  }
  if enemy_number < 1 then return end

  local weapon_type, target_option
  local done = false
  for wi, cannon in pairs(titan_info.guns) do
    if cannon.ai and (cannon.target == nil or cannon.ordered+lib_ttn.order_ttl < tick) then
      weapon_type = shared.weapons[cannon.name]
      target_option = wc_ai_handler[weapon_type.category](entity, titan_info, weapon_type, cannon, wi);
      if target_option then
        cannon.target = target_option
        cannon.ordered = game.tick
        opt_play(entity, weapon_type.pre_attack_sound)
        return true
      end
    end
  end

  if done then
    if titan_info.voice_cd < tick then
      if settings.global["wh40k-titans-talk"].value and math.random(100) < 80 then
        entity.surface.play_sound{
          path="wh40k-titans-phrase-attack",
          position=entity.position, volume_modifier=1
        }
      end
      titan_info.voice_cd = tick + 450 + 15*titan_info.class
    end
  end
end


local function check_cannon_ready(tick, titan_info, wi, cannon, weapon_type, target)
  if weapon_type.max_dst == nil then
    return false
  end
  local titan_type = shared.titan_types[titan_info.class]
  local todo = true
  todo = todo and cannon.gun_cd < tick
  todo = todo and (cannon.target == nil or cannon.ordered + lib_ttn.order_ttl < tick)
  todo = todo and cannon.ammo_count >= weapon_type.per_shot * weapon_type.attack_size
  if todo then
    dst = math2d.position.distance(titan_info.entity.position, target)
    todo = dst > weapon_type.min_dst and dst < lib_ttn.calc_max_dst(cannon, titan_info.force, titan_type, wi, weapon_type)
  end
  return todo
end


local function check_melee_ready(tick, titan_info, wi, cannon, weapon_type, target)
  local titan_type = shared.titan_types[titan_info.class]
  local todo = true
  todo = todo and cannon.gun_cd < tick
  todo = todo and (cannon.target == nil or cannon.ordered + lib_ttn.order_ttl < tick)
  return todo
end

local wc_readiness_checker = {}
wc_readiness_checker[shared.wc_melee] = check_melee_ready


local function check_weapon_ready(tick, titan_info, wi, cannon, target)
  local weapon_type = shared.weapons[cannon.name];
  return (wc_readiness_checker[weapon_type.category] or check_cannon_ready)(tick, titan_info, wi, cannon, weapon_type, target);
end


local function handle_attack_order(event, kind)
  -- https://lua-api.factorio.com/latest/events.html#CustomInputEvent
  local player = game.players[event.player_index]
  -- try_remove_small_water(player.character.surface, event.cursor_position, 8)
  -- game.print("Attacking: "..serpent.line({
  --   character=player.character,
  --   character_vehicle=player.character and player.character.vehicle,
  --   physical_vehicle=player.physical_vehicle,
  --   vehicle=player.vehicle,
  -- }))
  local entity = player.vehicle or player.physical_vehicle
  if not entity then return end
  local titan_info = ctrl_data.titans[entity.unit_number]
  if not titan_info then return end
  local titan_type = shared.titan_types[titan_info.class]

  local tick = game.tick
  local target = event.cursor_position
  local todo
  local done = false
  local weapon_type, dst

  local player_settings = ctrl_data.by_player[event.player_index] or {}
  player_settings.guns = player_settings.guns or {}

  for wi, cannon in pairs(titan_info.guns) do
    if (player_settings.guns[wi] or {}).mode == kind and not titan_info.guns[wi].ai then
      -- TODO: make priority choice: if there is gun_cd, save for secondary trying to find a free cannon
      if check_weapon_ready(tick, titan_info, wi, cannon, target) then
        cannon.target = target
        cannon.ordered = tick
        -- cannon.attack_number = 0
        done = true
        opt_play(entity, shared.weapons[cannon.name].pre_attack_sound)
        break
      end
    end
  end

  if done then
    if titan_info.voice_cd < tick then
      if settings.global["wh40k-titans-talk"].value and math.random(100) < 40 then
        entity.surface.play_sound{
          path="wh40k-titans-phrase-attack",
          position=entity.position, volume_modifier=1
        }
      end
      titan_info.voice_cd = tick + 450 + 15*titan_info.class
    end
  else
    -- game.print("No ready titan cannon")
  end
end


local function on_player_selected_area(event)
  if event.item ~= shared.worldbreaker then return end
  local alt = event.name == defines.events.on_player_alt_selected_area
  local player = game.players[event.player_index]
  local force = player.force
  local surface = event.surface
  local source = player.position
  local target = {
    x = (event.area.left_top.x + event.area.right_bottom.x) / 2,
    y = (event.area.left_top.y + event.area.right_bottom.y) / 2
  }

  local dst = math2d.position.distance(source, target)
  if dst > 40 then
    -- Try to call Titans attacks
    local tick = game.tick
    local done = false
    for unit_number, titan_info in pairs(ctrl_data.titans) do
      if titan_info.surface == surface and titan_info.force == force then
        dst = math2d.position.distance(source, titan_info.entity.position)
        if dst < 192 then
          for wi, cannon in pairs(titan_info.guns) do
            if check_weapon_ready(tick, titan_info, wi, cannon, target) then
              cannon.target = target
              cannon.ordered = tick
              break
            end
          end
        end
      end
      if done then break end
    end

  elseif dst > 9 then
    -- Use local laser gun
    player.surface.create_entity{
      name=shared.bolt_types.bolt_laser.entity, force=player.force,
      position=source, source=source, target=target, speed=8,
    }
    opt_play(player, attack_sound)
  end
end


lib_ttn:on_event(shared.mod_prefix.."attack-1", function(event) handle_attack_order(event, 1) end)
lib_ttn:on_event(shared.mod_prefix.."attack-2", function(event) handle_attack_order(event, 2) end)
lib_ttn:on_event(shared.mod_prefix.."attack-3", function(event) handle_attack_order(event, 3) end)
lib_ttn:on_event(shared.mod_prefix.."attack-4", function(event) handle_attack_order(event, 4) end)

lib_ttn:on_event(defines.events.on_player_selected_area, on_player_selected_area)
lib_ttn:on_event(defines.events.on_player_alt_selected_area, on_player_selected_area)
