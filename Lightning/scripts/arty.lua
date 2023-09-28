require("common")

local pre_bomb_places = {
  {scale=0, x=0, y=0,},
}
local function precompute_bombarding_places(count, scale)
  for i = 1, count do
    pre_bomb_places[#pre_bomb_places+1] = {
      scale=scale,
      x=math.cos(2*math.pi *i /count),
      y=math.sin(2*math.pi *i /count),
      i=i,
    }
  end
end
precompute_bombarding_places(4, 1)
precompute_bombarding_places(6, 2)
local bomb_size_1 = #pre_bomb_places
precompute_bombarding_places(12, 3)
local bomb_size_2 = #pre_bomb_places
precompute_bombarding_places(18, 4)
local bomb_size_3 = #pre_bomb_places

local function calc_bombarding_place(i, scale, center, w2, h2)
  if scale < 1 then return center end
  if i > 0 and i < #pre_bomb_places then
    local sign = 1 - 2 * math.fmod(i, 2)
    local place = pre_bomb_places[i]
    return {
      x=center.x + place.x * place.scale/scale *w2 *sign,
      y=center.y + place.y * place.scale/scale *h2 *sign
    }
  else
    return {
      x=center+math.random(-w2, w2),
      y=center+math.random(-h2, h2)
    }
  end
end

local function level_to_energy_attack(power_level)
  return (50 + 50 * power_level * power_level) * MJ
end

function get_max_force_power_level(force_index, is_bombarding)
  -- Max research level is 3
  local max_arty_lvl = script_data.technologies[shared.tech_arty_lvl][force_index] or 0
  max_arty_lvl = max_arty_lvl + (is_bombarding and 1 or 2)
  return max_arty_lvl
end

function get_player_power_level(player, is_bombarding)
  local max_arty_lvl = get_max_force_power_level(player.force.index, is_bombarding)
  local power_level
  if is_bombarding then
    power_level = script_data.arty_lvl_bomb[player.index] or 2
  else
    power_level = script_data.arty_lvl_stri[player.index] or 5
  end
  power_level = math.clamp(power_level, 1, max_arty_lvl)
  return power_level
end

local function on_player_selected_area(event)
  local alt = event.name == defines.events.on_player_alt_selected_area
  if event.item ~= shared.remote_name then return end
  local player = game.players[event.player_index]
  local force = player.force
  local surface = event.surface
  local target = {
    x = (event.area.left_top.x + event.area.right_bottom.x) / 2,
    y = (event.area.left_top.y + event.area.right_bottom.y) / 2
  }
  local width  = event.area.right_bottom.x - event.area.left_top.x
  local height = event.area.right_bottom.y - event.area.left_top.y
  local bombarding_level = math.floor((width + height) / 35)
  local is_bombarding = bombarding_level > 0
  local bombarding_count = (bombarding_level > 3) and bomb_size_3 or (bombarding_level > 1) and bomb_size_2 or bomb_size_1
  local closest_arty = nil
  local closest_dst = math.huge
  local dst, todo

  -- local chunk = {x=math.floor(target.x/32), y=math.floor(target.y/32)}
  -- -- local chunk_is = surface.is_chunk_generated({chunk.x, chunk.y})
  -- local chunk_is = not shared.chunk_is_border(surface, chunk, 30)
  -- game.print("Chunk "..serpent.line(chunk).." is ready: "..serpent.line(chunk_is))

  local power_level = get_player_power_level(player, is_bombarding)
  local single_energy = level_to_energy_attack(power_level)
  local req_pc = 0.05
  local req_en = (is_bombarding and 10 or 1) * single_energy
  local act_en = req_en * 0.95
  local matched = 0
  local nearby = 0
  local max_dst
  local attacks = 0

  -- TODO: cache arty entities by surface?
  for _, info in ipairs(arty_protos_ordered) do
    for _, entity in pairs(surface.find_entities_filtered{name=info.name}) do
      todo = entity.force == force
      max_dst = info.max_dst * (1 + 0.25 * (script_data.technologies[shared.tech_arty_range][entity.force_index] or 0))
      if todo and alt then
        dst = math.sqrt( (entity.position.x-target.x)^2 + (entity.position.y-target.y)^2 )
        todo = dst > 8 and dst < info.max_dst and dst < closest_dst
      end if todo then nearby = nearby + 1 end
      if todo then todo = script_data.arty_tasks[entity.unit_number] == nil end
      if todo then todo = entity.energy > act_en end
      -- if todo then todo = entity.energy/entity.electric_buffer_size > req_pc end
      if todo and not alt then
        dst = math.sqrt( (entity.position.x-target.x)^2 + (entity.position.y-target.y)^2 )
        todo = dst > 8 and dst < info.max_dst and dst < closest_dst
      end
      if todo then
        closest_arty = entity
        closest_dst = dst
        matched = matched + 1
        attacks = attacks + math.floor(entity.energy / act_en)
      end
    end
  end

  if alt then
    local attack_type = "strike"
    if is_bombarding then
      attack_type = "bombarding"
      if bombarding_level > 1 then attack_type = attack_type.." x"..bombarding_level end
    end
    player.print(table.concat({
      "Lightning "..attack_type..":",
      nearby.." nearby,",
      matched.." ready",
      "for "..attacks,
      " of "..power_level.." lvl, ",
      shared.energy_to_str(req_en).."J",
    }, " "))
  else
    if closest_arty then
      script_data.arty_tasks[closest_arty.unit_number] = {
        -- Who
        player=player, force=force, entity=closest_arty,
        -- Where
        surface=surface, area=event.area, center=target, w2=width/2, h2=height/2,
        -- What
        count = 0, total = is_bombarding and bombarding_count or 1,
        bombarding_level = bombarding_level, power_level=power_level,
      }
      -- player.print("Lightning "..attack_type.." ordered: X"..math.floor(target.x).." Y"..math.floor(target.y))
      -- player.print(serpent.line(script_data.arty_tasks[closest_arty.unit_number]))
      surface.play_sound{path="tsl-lightning", position=player.position, volume_modifier=0.5}
    else
      player.print("No lightning tower with enough energy nearby")
    end
  end
end

function update_arty_tasks()
  for unit_number, task in pairs(script_data.arty_tasks) do
    if task.entity.valid and task.count < task.total then
      -- Random level for bombarding, specific for strike
      local power_level = (task.total > 1) and math.random(1, task.power_level) or task.power_level
      local single_energy = level_to_energy_attack(power_level)

      if task.entity.energy > single_energy then
        task.count = task.count + 1
        local cap_dst_limit = math.max(4, 30 / math.max(1, power_level))
        local place = calc_bombarding_place(task.count, task.bombarding_level, task.center, task.w2, task.h2)
        make_lightning(task.surface, place, task.power_level, cap_dst_limit, 0.25)
        task.entity.energy = math.max(0, task.entity.energy - single_energy)
        task.surface.play_sound{path="tsl-charging", position=task.entity.position, volume_modifier=math.max(1, 0.5+0.1*power_level)}
      end
    else
      script_data.arty_tasks[unit_number] = nil
    end
  end
end

function set_attack_level(player_index, value, is_bombarding, say)
  local player = game.get_player(player_index)
  local power_level = tonumber(value)
  if power_level == nil then
    player.print("Bad level "..serpent.line(value))
    return
  else
    local max_level = get_max_force_power_level(player.force_index, is_bombarding)
    power_level = math.clamp(power_level, 1, max_level)
    local attack_type = is_bombarding and "bombarding" or "strike"
    local changed = false
    if is_bombarding then
      changed = script_data.arty_lvl_bomb[player_index] ~= power_level
      script_data.arty_lvl_bomb[player_index] = power_level
    else
      changed = script_data.arty_lvl_stri[player_index] ~= power_level
      script_data.arty_lvl_stri[player_index] = power_level
    end
    if changed or say then
      player.print("Have set "..attack_type.." level "..power_level..", max is "..max_level)
    end
  end
end


local function set_attack_level_cmd(cmd, is_bombarding)
  set_attack_level(cmd.player_index, cmd.parameter, is_bombarding, true)
end

commands.add_command(
  "tsl-stri",
  "Set lightning level for your artillery strikes",
  function (cmd) set_attack_level_cmd(cmd, false) end
)
commands.add_command(
  "tsl-bomb",
  "Set lightning level for your artillery bombarding",
  function (cmd) set_attack_level_cmd(cmd, true) end
)

script.on_event(defines.events.on_player_selected_area, on_player_selected_area)
script.on_event(defines.events.on_player_alt_selected_area, on_player_selected_area)
