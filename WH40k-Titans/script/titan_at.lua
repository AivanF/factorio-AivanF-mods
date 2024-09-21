local lib_ruins = require("script/ruins")
local lib_tech = require("script/tech")

lib_ttn.order_ttl = 5 * UPS

local max_oris = { -- titan cannon max orientation shift
  0.15, 0.15,
  0.4, 0.4,
  0.4, 0.4,
}


function lib_ttn.init_gun(name, weapon_type)
  weapon_type = weapon_type or shared.weapons[name]
  return  {
    name = weapon_type.name,
    cd = 0,
    oris = 0, -- orientation shift of the cannon
    target = nil, -- LuaEntity or position
    ordered = 0, -- task creation tick for expiration
    gun_cd = 0,
    attack_number = 0, -- from weapon_type.attack_size
    ammo_count = weapon_type.inventory,
    ai = false,
  }
end
lib_ttn.init_gun = lib_ttn.init_gun


function lib_ttn.calc_max_dst(cannon, force, titan_type, k, weapon_type)
  if not cannon.cached_dst then
    cannon.cached_dst = 1
      * weapon_type.max_dst
      * (1 + 0.01*titan_type.class)
      * (titan_type.guns[k].is_top and 1.1 or 1)
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
    source = math2d.position.add(source, point_orientation_shift(entity.orientation, cannon.oris, barrel))
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


local function gun_do_attack(entity, titan_type, k, cannon, gunpos, weapon_type, ori, tick, attacker)
  -- TODO: add some time before attack
  -- TODO: calculate gun muzzle position
  if (cannon.attack_number or 0) >= 1 then
    cannon.attack_number = cannon.attack_number - 1
  elseif weapon_type.attack_size > 1 then
    cannon.attack_number = (weapon_type.attack_size-1) or 0
    opt_play(entity, weapon_type.attack_start_sound)
  end
  if use_ammo_by_prob(entity.force) then
    cannon.ammo_count = math.max(0, cannon.ammo_count - weapon_type.per_shot)
  end
  local target = cannon.target
  if (weapon_type.scatter or 0) > 0 then
    target = math2d.position.add(target, {
      math.random(-weapon_type.scatter, weapon_type.scatter),
      math.random(-weapon_type.scatter, weapon_type.scatter)})
  end
  attacker(entity, titan_type, cannon, weapon_type, gunpos, target)
  cannon.gun_cd = tick + weapon_type.cd * UPS
  -- log("gun_do_attack name: "..cannon.name..", attack_number: "..cannon.attack_number)

  opt_play(entity, weapon_type.attack_sound)

  if (cannon.attack_number or 0) <= 0 then
    cannon.target = nil
    cannon.attack_number = 0
    cannon.when_can_rotate = tick + 90*weapon_type.grade
  else
    cannon.ordered = tick
  end
end


local function control_simple_gun(entity, titan_type, k, cannon, gunpos, weapon_type, ori, tick, attacker)
  if cannon.target ~= nil and tick < cannon.ordered + lib_ttn.order_ttl then
    local dst = math2d.position.distance(gunpos, cannon.target)
    if cannon.gun_cd < tick and dst > weapon_type.min_dst and dst < lib_ttn.calc_max_dst(cannon, entity.force, titan_type, k, weapon_type) then
      gun_do_attack(entity, titan_type, k, cannon, gunpos, weapon_type, ori, tick, attacker)
    end

  else
    cannon.target = nil
  end
end


local function control_rotate_gun(entity, titan_type, k, cannon, gunpos, weapon_type, ori, tick, attacker)
  if cannon.target ~= nil and tick < cannon.ordered + lib_ttn.order_ttl then
    -- TODO: check if target is a LuaEntity
    local tori = points_to_orientation(gunpos, cannon.target)
    local orid = orientation_diff(ori+cannon.oris, tori)
    cannon.oris = cannon.oris + (0.04-0.005*weapon_type.grade)*orid
    cannon.oris = math.clamp(cannon.oris, -max_oris[k], max_oris[k])
    local dst = math2d.position.distance(gunpos, cannon.target)

    if true
      and math.abs(orid) < (weapon_type.max_orid or 0.015)
      and cannon.gun_cd < tick
      and dst > weapon_type.min_dst and dst < lib_ttn.calc_max_dst(cannon, entity.force, titan_type, k, weapon_type)
    then
      gun_do_attack(entity, titan_type, k, cannon, gunpos, weapon_type, ori, tick, attacker)
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


local function control_beam_gun(entity, titan_type, k, cannon, gunpos, weapon_type, ori, tick)
  control_rotate_gun(entity, titan_type, k, cannon, gunpos, weapon_type, ori, tick, bolt_attacker)
end

local function control_bolt_gun(entity, titan_type, k, cannon, gunpos, weapon_type, ori, tick)
  control_rotate_gun(entity, titan_type, k, cannon, gunpos, weapon_type, ori, tick, bolt_attacker)
end

local function control_rocket_gun(entity, titan_type, k, cannon, gunpos, weapon_type, ori, tick)
  -- control_simple_gun(entity, titan_type, k, cannon, gunpos, weapon_type, ori, tick, bolt_attacker)
  control_rotate_gun(entity, titan_type, k, cannon, gunpos, weapon_type, ori, tick, bolt_attacker)
end

local function control_melta_gun(cannon, weapon_type, entity, ori, tick)
  control_rotate_gun(entity, titan_type, k, cannon, gunpos, weapon_type, ori, tick, bolt_attacker)
end

-- Called from process_single_titan
lib_ttn.wc_control = {}
lib_ttn.wc_control[shared.wc_rocket] = control_rocket_gun
lib_ttn.wc_control[shared.wc_bolter] = control_bolt_gun
lib_ttn.wc_control[shared.wc_quake]  = control_bolt_gun
lib_ttn.wc_control[shared.wc_flamer] = control_bolt_gun
lib_ttn.wc_control[shared.wc_plasma] = control_bolt_gun
lib_ttn.wc_control[shared.wc_melta]  = control_melta_gun
lib_ttn.wc_control[shared.wc_laser]  = control_beam_gun
lib_ttn.wc_control[shared.wc_hell]   = control_beam_gun


local enemies
local attack_ori_shifts = {0, 0.07, -0.07, 0.15, -0.15}
local ai_attack_radius = 6


local function find_ai_target(titan_info, entity, weapon_type, cannon)
  local enemy_number, target_option, new_oris
  local max_number = 0
  local result = nil
  if weapon_type.start_far then
    -- Going inside
    for _, oris in ipairs(attack_ori_shifts) do
      dst = weapon_type.max_dst
      while 0 < dst and weapon_type.min_dst*1.3 < dst do
        dst = dst * 0.75
        new_oris = 2/3*cannon.oris + oris
        if new_oris < 0.2 and new_oris > -0.2 then
          target_option = math2d.position.add(cannon.position, point_orientation_shift(entity.orientation -titan_info.oris/2, new_oris, dst))
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
          target_option = math2d.position.add(cannon.position, point_orientation_shift(entity.orientation -titan_info.oris/2, new_oris, dst))
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
    position=math2d.position.add(titan_info.entity.position, point_orientation_shift(entity.orientation, 0, titan_info.class)),
    radius=48 + titan_info.class, force=enemies, is_military_target=true
  }
  if enemy_number < 1 then return end

  local weapon_type, dst, target_option
  local done = false
  for k, cannon in pairs(table.shallow_copy(titan_info.guns)) do
    if cannon.ai and (cannon.target == nil or cannon.ordered+lib_ttn.order_ttl < tick) then
      weapon_type = shared.weapons[cannon.name]
      if cannon.ammo_count >= weapon_type.per_shot*weapon_type.attack_size then
        target_option = find_ai_target(titan_info, entity, weapon_type, cannon)
        if target_option then
          cannon.target = target_option
          cannon.ordered = tick
          opt_play(entity, weapon_type.pre_attack_sound)
          done = true
        end
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


local function check_cannon_ready(tick, titan_info, cn, cannon, target)
  local weapon_type = shared.weapons[cannon.name]
  local titan_type = shared.titan_types[titan_info.class]
  local todo = true
  todo = todo and cannon.gun_cd < tick
  todo = todo and (cannon.target == nil or cannon.ordered + lib_ttn.order_ttl < tick)
  todo = todo and cannon.ammo_count >= weapon_type.per_shot * weapon_type.attack_size
  if todo then
    dst = math2d.position.distance(titan_info.entity.position, target)
    todo = dst > weapon_type.min_dst and dst < lib_ttn.calc_max_dst(cannon, titan_info.force, titan_type, cn, weapon_type)
  end
  return todo
end


local function handle_attack_order(event, kind)
  -- https://lua-api.factorio.com/latest/events.html#CustomInputEvent
  local player = game.players[event.player_index]
  -- try_remove_small_water(player.character.surface, event.cursor_position, 8)
  if not (player.character and player.character.vehicle) then return end
  local entity = player.character.vehicle
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

  for cn, cannon in pairs(table.shallow_copy(titan_info.guns)) do
    if (player_settings.guns[cn] or {}).mode == kind and not titan_info.guns[cn].ai then
      -- weapon_type = shared.weapons[cannon.name]
      -- todo = true
      -- todo = todo and cannon.gun_cd < tick
      -- todo = todo and (cannon.target == nil or cannon.ordered+lib_ttn.order_ttl < tick)
      -- todo = todo and cannon.ammo_count >= weapon_type.per_shot*weapon_type.attack_size

      -- if todo then
      --   dst = math2d.position.distance(entity.position, target)
      --   todo = dst > weapon_type.min_dst and dst < lib_ttn.calc_max_dst(cannon, entity.force, titan_type, cn, weapon_type)
      -- end

      -- TODO: make priority choice: if there is gun_cd, save for secondary trying to find a free cannon
      if check_cannon_ready(tick, titan_info, cn, cannon, target) then
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
          for cn, cannon in pairs(titan_info.guns) do
            if check_cannon_ready(tick, titan_info, cn, cannon, target) then
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
