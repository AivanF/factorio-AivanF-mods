local lib_ruins = require("script/ruins")

local Lib = require("script/event_lib")
lib_ttn = Lib.new()

local titan_explo_bolt = shared.mod_prefix.."bolt-plasma-3"


----- Intro -----

local function init_aux_laser(titan_type, titan_info, entity)
  for k, shift in ipairs(titan_type.aux_laser) do
    titan_info.aux_laser[k] = entity.surface.create_entity{
      name=k>2 and shared.titan_aux_laser2 or shared.titan_aux_laser, position=entity.position,
      force=entity.force,
    }
    titan_info.aux_laser[k].destructible = false
  end
end


function lib_ttn.register_titan(entity)
  if ctrl_data.titans[entity.unit_number] then
    return ctrl_data.titans[entity.unit_number]
  end
  local titan_type, name = lib_ttn.titan_type_by_entity(entity)
  if not titan_type then
    game.print("Got bad titan "..entity.name)
    return
  end

  local titan_info = {
    name = name,
    unit_number = entity.unit_number,
    entity = entity,
    force = entity.force,
    surface = entity.surface,
    class = titan_type.class,
    shield = 0, -- void shield health amount
    voice_cd = 0, -- phrases muted till
    body_cd = 0, -- step and rotation sounds muted till
    track_cd = 0, -- footstep track drawing cooldown till
    foot_cd = 0,
    track_rot = false, -- R or L
    foot_rot = false, -- R or L
    foots = {}, -- 2 foot entities
    guns = {}, -- should be added by bunker script
    aux_laser = {},
    ai_cd = 0,
  }
  titan_info.shield = lib_ttn.get_unit_shield_max_capacity(titan_info) / 5

  -- entity.health = entity.health/100
  init_aux_laser(titan_type, titan_info, entity)

  -- Fill when placed in god/editor mode. Usually it's overriden by Assembly Bunker
  if titan_type.class == shared.class_warhound then
    titan_info.guns = {
      lib_ttn.init_gun(shared.weapon_inferno),
      -- lib_ttn.init_gun(shared.weapon_inferno),
      lib_ttn.init_gun(shared.weapon_plasma_blastgun),
      -- lib_ttn.init_gun(shared.weapon_turbolaser),
      -- lib_ttn.init_gun(shared.weapon_lascannon),
    }
  elseif titan_type.class == shared.class_direwolf then
    titan_info.guns = {
      lib_ttn.init_gun(shared.weapon_adrexbolter),
      lib_ttn.init_gun(shared.weapon_adrexbolter),
      lib_ttn.init_gun(shared.weapon_plasma_blastgun),
    }
  elseif titan_type.class == shared.class_reaver then
    titan_info.guns = {
      -- TODO: use weapon_gatling_blaster
      lib_ttn.init_gun(shared.weapon_plasma_destructor),
      lib_ttn.init_gun(shared.weapon_turbolaser),
      lib_ttn.init_gun(shared.weapon_apocalypse_missiles),
    }
  elseif titan_type.class >= shared.class_warmaster then
    titan_info.guns = {
      lib_ttn.init_gun(shared.weapon_plasma_annihilator),
      lib_ttn.init_gun(shared.weapon_plasma_destructor),
      lib_ttn.init_gun(shared.weapon_laserblaster),
      lib_ttn.init_gun(shared.weapon_laserblaster),
      lib_ttn.init_gun(shared.weapon_apocalypse_missiles),
      lib_ttn.init_gun(shared.weapon_apocalypse_missiles),
    }
  else
    titan_info.guns = {
      lib_ttn.init_gun(shared.weapon_laserblaster),
      lib_ttn.init_gun(shared.weapon_plasma_destructor),
      -- lib_ttn.init_gun(shared.weapon_plasma_annihilator),
      -- lib_ttn.init_gun(shared.weapon_lascannon),
      lib_ttn.init_gun(shared.weapon_missiles),
      lib_ttn.init_gun(shared.weapon_apocalypse_missiles),

      lib_ttn.init_gun(shared.weapon_turbolaser),
      lib_ttn.init_gun(shared.weapon_turbolaser),
    }
  end

  titan_info.guns = table.slice(titan_info.guns, 1, #titan_type.guns)

  ctrl_data.titans[entity.unit_number] = titan_info
  -- if settings.global["wh40k-titans-talk"].value
  entity.surface.play_sound{
    path="wh40k-titans-phrase-init",
    position=entity.position, volume_modifier=1
  }

  return titan_info
end



----- OUTRO -----

local function get_corpse_img(class)
  if class >= shared.class_warlord then
    return shared.mod_prefix.."corpse-3"
  end
  return shared.mod_prefix.."corpse-1"
end

local function titan_death(titan_info)
  -- For death only
  local source = titan_info.position
  local target
  local scatter = titan_info.class / 3
  local explo_count = titan_info.class/10
  for i = 0, explo_count do
    target = position_scatter(source, scatter)
    titan_info.surface.create_entity{
      name=titan_explo_bolt,
      position=source, source=source, target=target, speed=10,
    }
  end

  local titan_type = shared.titan_types[titan_info.class]
  local detailses = {}
  local ammo = {}
  table.insert(detailses, titan_type.ingredients)
  for k, cannon in pairs(titan_info.guns) do
    weapon_type = shared.weapons[cannon.name]
    table.insert(detailses, weapon_type.ingredients)
    table.insert(ammo, {name=weapon_type.ammo, count=cannon.ammo_count})
  end
  lib_ruins.spawn_ruin(titan_info.surface, {
    position = source,
    img = get_corpse_img(titan_info.class),
    details = merge_ingredients_doubles(iter_chain(detailses)),
    ammo = merge_ingredients_doubles(ammo),
  })

  titan_info.force.print(
    {"WH40k-Titans-gui.msg-titan-destroyed", {"entity-name."..titan_type.entity}},
    {1, 0.1, 0.1})
end

function lib_ttn.titan_removed_by_number(unit_number, is_death)
  local titan_info = unit_number and ctrl_data.titans[unit_number]
  if titan_info then
    lib_ttn.titan_removed(titan_info, is_death)
  end
end

function lib_ttn.titan_removed(titan_info, is_death)
  -- For any object remove
  local unit_number = titan_info.entity.unit_number

  if is_death then
    titan_death(titan_info)
  end

  lib_ttn.remove_titan_gui_by_titan(titan_info)
  die_all(titan_info.foots)
  die_all(titan_info.aux_laser)

  ctrl_data.titans[unit_number] = nil
end

lib_ttn:on_event(defines.events.script_raised_destroy, function(event)
  lib_ttn.titan_removed_by_number(event.entity.unit_number)
end)



----- MISC -----

function lib_ttn.titan_ammo_fulfill(titan_info)
  for _, gun_info in ipairs(titan_info.guns) do
    local weapon_type = shared.weapons[gun_info.name]
    gun_info.ammo_count = weapon_type.inventory
  end
end


function lib_ttn.titan_ammo_clear(titan_info)
  for _, gun_info in ipairs(titan_info.guns) do
    gun_info.ammo_count = 0
  end
end


function lib_ttn.titan_type_by_entity(entity)
  local name = entity.name
  local titan_type = shared.titan_types[name]
  if not titan_type and string.sub(entity.name, -2, -1) == "-0" then 
    name = string.sub(entity.name, 1, -3)
    titan_type = shared.titan_types[name]
  end
  return titan_type, name
end


function lib_ttn.get_crew(titan_info)
  local crew = {}
  crew[#crew+1] = titan_info.entity.get_driver()
  crew[#crew+1] = titan_info.entity.get_passenger()
  return crew
end


function lib_ttn.notify_crew(titan_info, message, color)
  color = color or {1,1,1}
  for _, player in pairs(list_players(lib_ttn.get_crew(titan_info))) do
    player.print(message, color)
  end
end


function lib_ttn.titan_entity_replaced(old_entity, new_entity)
  local titan_info = ctrl_data.titans[old_entity.unit_number]
  -- game.print("titan_entity_replaced "..old_entity.unit_number.." to "..new_entity.unit_number.." as "..serpent.line(titan_info))
  if titan_info == nil then return end

  titan_info.entity = new_entity
  titan_info.unit_number = new_entity.unit_number

  ctrl_data.titans[old_entity.unit_number] = nil
  ctrl_data.titans[new_entity.unit_number] = titan_info
end


local function titans_debug_cmd(cmd)
  local player = game.players[cmd.player_index]
  if not player.admin then
    player.print({"cant-run-command-not-admin", "Titans Debug"})
    return
  end
  local valid_titans = 0
  local bad_titans = 0
  for unit_number, titan_info in pairs(ctrl_data.titans) do
    if titan_info.entity.valid then
      valid_titans = valid_titans + 1
    else
      bad_titans = bad_titans + 1
    end
  end
  player.print("Found "..valid_titans.." good titans, "..bad_titans.." bad ones")
end


lib_ttn:on_event(defines.events.on_entity_damaged, function(event)
  -- Void Shields absorbing
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


commands.add_command(
  "titans-debug",
  "Prints some debug info",
  titans_debug_cmd
)


require("script/titan_ui")
require("script/titan_mn")
require("script/titan_at")
return lib_ttn