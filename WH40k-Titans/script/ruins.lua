require("script/common")
local Lib = require("script/event_lib")
local lib = Lib.new()

local debug_many = false
debug_many = true
local base_ruin_prob = heavy_debugging and 0.8 or 0.04
local sector_size = (heavy_debugging and debug_many and 2 or 20) * 32
local blank_world = {
  surface = nil,
  mod = nil, -- name
  zone = nil, -- mod's zone index
  ruins = {},  -- array of ruin_info
  sectors = {}, -- contains: ghosts = {}, -- array of ruin_info
  sector_size = nil,
  ruin_prob_cf = 1,
  deaths = 0,
  created_ruins = 0,
  finished_ruins = 0,
}
local blank_ruin_info = {
  -- world = nil,
  -- sector = nil,
  died = nil,
  class = nil,
  entity = nil,
  details = {}, -- [{name=, count=}]
  ammo = {}, -- [{name=, count=}]
  exc_info = nil,
}
local blank_sector = {
  ruins = {}, -- 
  ruin_ghosts = {},
}

lib.ammo_unit = 100

function lib.initial_index()
  ctrl_data.by_surface = {}
  ctrl_data.by_zones = {}
  if game.surfaces["nauvis"] then
    lib.opt_new_world({surface = game.surfaces["nauvis"]})
  end
end

-- Tries to find existing world for new surface
function lib.opt_new_world(data)
  if not data.surface then
    error("Missing surface")
  end
  if heavy_debugging then
    game.print("WH40k_Titans-opt_new_world: "..serpent.line(data.surface.name))
  end

  local world

  -- Update settings if it already exists
  if ctrl_data.by_surface[data.surface.index] then
    world = merge(ctrl_data.by_surface[data.surface.index], data, true)
  end

  -- Try to restore persistent world from integrated mods
  if data.mod and data.zone then
    if ctrl_data.by_zones[data.mod] and ctrl_data.by_zones[data.mod][data.zone] then
      world = ctrl_data.by_zones[data.mod][data.zone]
    end
  end

  if not world then
    world = merge(data or {}, table.deepcopy(blank_world), false)
    -- TODO: consider world.surface.map_gen_settings.width&height?
  end
  ctrl_data.by_surface[world.surface.index] = world

  -- Save persistent world
  if data.mod and data.zone then
    ctrl_data.by_zones[data.mod] = ctrl_data.by_zones[data.mod] or {}
    ctrl_data.by_zones[data.mod][data.zone] = world
  end

  return world
end

function lib.materialise_ruin(world, ruin_info)
  if ruin_info.entity then return end
  local position = ruin_info.position
  -- TODO: try adjust position, check there are no player buildings
  -- TODO: add enemies if a new chunk
  ruin_info.entity = world.surface.create_entity{
    name=shared.corpse, force="neutral", position=position,
  }
  -- TODO: consider .class to pick a picture
  rendering.draw_sprite{
    sprite=shared.mod_prefix.."corpse-1",
    -- https://lua-api.factorio.com/latest/concepts.html#RenderLayer
    x_scale=1, y_scale=1, render_layer=110,
    surface=world.surface, target=ruin_info.entity,
  }
  ruin_info.entity.destructible = false
  ctrl_data.ruins[ruin_info.entity.unit_number] = ruin_info

  for _, obj in pairs(world.surface.find_entities_filtered{
    position=position, radius=6, type="cliff"
  }) do
    obj.destroy()
  end
end

function lib.spawn_ruin(surface, ruin_info)
  local world = lib.opt_new_world({surface=surface, ruin_prob_cf=0})
  local sector = lib.get_sector(world, ruin_info.position)
  -- TODO: add type/class?
  merge(ruin_info, blank_ruin_info, false)
  ruin_info.died = true
  world.deaths = (world.deaths or 0) + 1
  lib.materialise_ruin(world, ruin_info)
end

function lib.ruin_removed(unit_number)
  ruin_info = ctrl_data.ruins[unit_number]
  if ruin_info.exc_info then
    ruin_info.exc_info.ruin_entity = nil
    ruin_info.exc_info.ruin_info = nil
  end
  ruin_info.entity = nil
  ctrl_data.ruins[unit_number] = nil
end

function lib.ruin_extract(ruin_info, ruin_entity)
  if ruin_info then
    local total = #ruin_info.details + #ruin_info.ammo
    local position, name, count
    if total > 0 then
      if math.random() < #ruin_info.details / total then
        position = math.random(#ruin_info.details)
        name = ruin_info.details[position].name
        count = 1
        ruin_info.details[position].count = ruin_info.details[position].count - 1
        if ruin_info.details[position].count < 1 then
          table.remove(ruin_info.details, position)
        end
      else
        position = math.random(#ruin_info.ammo)
        name = ruin_info.ammo[position].name
        count = math.min(lib.ammo_unit, ruin_info.ammo[position].count)
        ruin_info.ammo[position].count = ruin_info.ammo[position].count - count
        if ruin_info.ammo[position].count < 1 then
          table.remove(ruin_info.ammo, position)
        end
      end
      if math.random() < 0.5 then
        return name, count
      else
        return nil, 0
      end
    else
      -- Pass
    end
  else
    -- Pass
  end

  local world = ctrl_data.by_surface[ruin_entity.surface.index]
  if world then
    world.finished_ruins = (world.finished_ruins or 0) + 1
    for i, obj in pairs(world.ruins) do
      if obj == ruin_info then
        world.ruins[i] = nil
        break
      end
    end
  end

  ruin_entity.destructible = true
  ruin_entity.destroy()
  -- return shared.frame_part, 1
  return nil, 0
end

local function handle_deleted_surface(event)
  local world = ctrl_data.by_surface[event.surface_index]
  world.surface = nil
  ctrl_data.by_surface[event.surface_index] = nil
end

local function create_random_ruin_info(position)
  local detailses = {}
  local ammo = {}
  local class
  if math.random() < 0.5 then
    class = shared.class_warhound
    table.insert(detailses, shared.titan_types[shared.titan_warhound].ingredients)
  else
    class = shared.class_reaver
    table.insert(detailses, shared.titan_types[shared.titan_reaver].ingredients)
  end
  table.insert(detailses, {{name=shared.frame_part, count=math.random(7)}})
  if math.random() < 0.5 then
    table.insert(detailses, shared.weapons[shared.weapon_plasma_blastgun].ingredients)
    table.insert(ammo, {
      name =shared.weapons[shared.weapon_plasma_blastgun].ammo,
      count=shared.weapons[shared.weapon_plasma_blastgun].inventory * (0.2 + 0.5*math.random())
    })
  end
  if math.random() < 0.5 then
    table.insert(detailses, shared.weapons[shared.weapon_inferno].ingredients)
    table.insert(ammo, {
      name =shared.weapons[shared.weapon_inferno].ammo,
      count=shared.weapons[shared.weapon_inferno].inventory * (0.2 + 0.5*math.random())
    })
  end
  if math.random() < 0.5 then
    table.insert(detailses, shared.weapons[shared.weapon_turbolaser].ingredients)
    table.insert(ammo, {
      name =shared.weapons[shared.weapon_turbolaser].ammo,
      count=shared.weapons[shared.weapon_turbolaser].inventory * (0.2 + 0.5*math.random())
    })
  end
  local ruin_info = {
    died = false,
    class = class,
    position = position,
    entity = nil,
    details = remove_ingredients_doubles(iter_chain(detailses)),
    ammo = remove_ingredients_doubles(ammo),
  }
  return ruin_info
end

local function create_sector(world, position)
  local sector = table.deepcopy(blank_sector)
  local ruin_prob = 0
  if math2d.position.distance(position, {0, 0}) > 2*sector_size then
    ruin_prob = (world.ruin_prob_cf or 1) * base_ruin_prob
  end
  if ruin_prob > 0 and math.random() < ruin_prob then
    -- Place a ghost ruin
    sector.ruin_ghosts = {
      -- TODO: maybe several?
      create_random_ruin_info(position),
    }
    world.created_ruins = (world.created_ruins or 0) + #sector.ruin_ghosts
    if heavy_debugging and not debug_many then
      game.print("Planned a titan ruin!")
    end
  end
  return sector
end

function lib.get_sector(world, position)
  local x = math.floor(position.x / (world.sector_size or sector_size))
  local y = math.floor(position.y / (world.sector_size or sector_size))
  local slice = world.sectors[x] or {}
  world.sectors[x] = slice
  local sector = slice[y]
  if not sector then
    sector = create_sector(world, position)
    slice[y] = sector
  end
  return sector
end

local function handle_created_chunk(event)
  local world = ctrl_data.by_surface[event.surface.index]
  if not world then return end

  local position = math2d.bounding_box.get_centre(event.area)
  local sector = lib.get_sector(world, position)
  for _, ruin_info in pairs(sector.ruin_ghosts) do
    if math2d.position.distance(position, ruin_info.position) < sector_size/2 then
      lib.materialise_ruin(world, ruin_info)
    end
  end
end

--[[
on corpse created: ignore, only generated corpses will be registered

TODO: on corpse removed:
  local ruin_info = ctrl_data.ruins[unit_number]
  if ruin_info then
    ruin_info.world.ruins[unit_number] = nil
    ctrl_data.ruins[unit_number] = nil
  end
--]]


--[[ Hopefully, entity destruction event will be called during this process
lib:on_event(defines.events.on_surface_cleared, __xyz__)
--]]

--[[ Registration of new surfaces must be handled by mods compatibility scripts
lib:on_event(defines.events.on_surface_created, function (event)
  opt_new_world({surface_index=event.surface_index})
end)
--]]

lib:on_event(defines.events.on_surface_deleted, handle_deleted_surface)
lib:on_event(defines.events.on_chunk_generated, handle_created_chunk)

-- TODO: add remote interface to register a surface, for integration mods

return lib