require("script/common")
local Lib = require("script/event_lib")
local lib = Lib.new()

local sector_size = heavy_debugging and 20 or 1000
local blank_world = {
  surface = nil,
  mod = nil, -- name
  zone = nil, -- mod's zone index
  ruins = {},  -- array of ruin_info
  sectors = {}, -- contains: ghosts = {}, -- array of ruin_info
  sector_size = nil,
  ruin_prob = heavy_debugging and 0.1 or 0.35,
}
local blank_ruin_info = {
  -- world = nil,
  -- sector = nil,
  entity = nil,
  details = {}, -- [{name=, count=}]
  ammo = {}, -- [{name=, count=}]
  exc_info = nil,
}
local blank_sector = {
  ruins = {}, -- 
  ruin_ghosts = {},
}

function lib.initial_index()
  ctrl_data.by_surface = {}
  ctrl_data.by_zones = {}
  if game.surfaces["nauvis"] then
    lib.opt_new_world({surface = game.surfaces["nauvis"]})
  end
end

function lib.spawn_ruin(world, ruin_info)
  local position = ruin_info.position
  -- TODO: try adjust position, check there are no player buildings
  -- TODO: add enemies?
  ruin_info.entity = world.surface.create_entity{
    name=shared.mod_prefix.."titan-corpse", force="neutral", position=position,
  }
  ruin_info.entity.destructible = false
  ctrl_data.ruins[ruin_info.entity.unit_number] = ruin_info
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
        count = math.min(50, ruin_info.ammo[position].count)
        ruin_info.ammo[position].count = ruin_info.ammo[position].count - count
        if ruin_info.ammo[position].count < 1 then
          table.remove(ruin_info.ammo, position)
        end
      end
      return name, count
    else
      -- Pass
    end
  else
    -- Pass
  end
  ruin_entity.destroy()
  return shared.frame_part, 1
end

-- Tries to find existing world for new surface
function lib.opt_new_world(data)
  if not data.surface then
    error("Missing surface")
  end
  game.print("WH40k_Titans-opt_new_world: "..serpent.line(data.surface.name))

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
  end
  ctrl_data.by_surface[world.surface.index] = world

  -- Save persistent world
  if data.mod and data.zone then
    ctrl_data.by_zones[data.mod] = ctrl_data.by_zones[data.mod] or {}
    ctrl_data.by_zones[data.mod][data.zone] = world
  end

  return world
end

local function handle_deleted_surface(event)
  local world = ctrl_data.by_surface[event.surface_index]
  world.surface = nil
  ctrl_data.by_surface[event.surface_index] = nil
end

function lib.create_ruin_info(position)
  local ruin_info = {
    -- TODO: add class/picture/variant opt argument?
    -- TODO: make random values
    position = position,
    entity = nil,
    details = remove_ingredients_doubles(iter_chain{
      shared.titan_types[shared.titan_warhound].ingredients,
      shared.weapons[shared.weapon_plasma_blastgun].ingredients,
      shared.weapons[shared.weapon_inferno].ingredients,
    }),
    ammo = {
      {
        name =shared.weapons[shared.weapon_plasma_blastgun].ammo,
        count=shared.weapons[shared.weapon_plasma_blastgun].inventory/4
      },
      {
        name =shared.weapons[shared.weapon_inferno].ammo,
        count=shared.weapons[shared.weapon_inferno].inventory/3
      },
    },
  }
  return ruin_info
end

local function create_sector(world, position)
  local sector = table.deepcopy(blank_sector)
  if math.random() < world.ruin_prob then
    sector.ruin_ghosts = {
      -- TODO: make random ruins count, their type & position
      lib.create_ruin_info(position),
    }
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
      lib.spawn_ruin(world, ruin_info)
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