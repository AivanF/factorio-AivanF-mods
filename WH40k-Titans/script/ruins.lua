local Lib = require("script/event_lib")
local lib_tech = require("script/tech")
lib_ruins = Lib.new()

local debug_many = false
-- debug_many = true
local base_ruin_prob = heavy_debugging and debug_many and 0.8 or settings.startup["wh40k-titans-ruin-prob"].value
local sector_size = (heavy_debugging and debug_many and 2 or 10) * 32
local free_area = 1.5 * sector_size

local blank_world = {
  surface = nil,
  mod = nil,   -- name
  zone = nil,  -- mod's zone index
  ruins = {},  -- unit_number => ruin_info
  free_area = nil, -- start area radius, free of corpses
  sector_size = nil,
  sectors = {}, -- x//sector_size => y//sector_size => sector
  ruin_prob_cf = 1,
  deaths = 0,
  created_ruins = 0,
  finished_ruins = 0,
}

local blank_ruin_info = {
  -- world = nil,
  -- sector = nil,
  img = nil,
  died = nil,
  entity = nil,
  details = {}, -- [{name=, count=}]
  ammo = {}, -- [{name=, count=}]
  exc_info = nil,
}

local blank_sector = {
  ruin_ghosts = {},
}

lib_ruins.ammo_unit = 300 -- devided by weight

--[[
INFO: To reduce memory usage on large maps, surfaces are split into sectors (10*10 chunks by default).
      A sector can have multiple ruins, and ruins can be ghosts, not materialised,
      if a corpse was spawned on a chunk which is not discovered yet,
      which happens when another, revealed chunk of the same secotor creates the sector.

TODO:
- Add migration code to apply when sector size get changed.
- Add remote interface to register a surface, for integration mods
]]


function lib_ruins.initial_index()
  ctrl_data.by_surface = {}
  ctrl_data.by_zones = {}
  if game.surfaces["nauvis"] then
    lib_ruins.opt_new_world({surface = game.surfaces["nauvis"]})
  end
end

-- Tries to find existing world for new surface
function lib_ruins.opt_new_world(data)
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
    -- TODO: adjust ruin_prob_cf considering world.surface.map_gen_settings.width&height?
    -- Adjust wrecks number considering amount of water
    world.ruin_prob_cf = world.ruin_prob_cf * (1 + world.surface.map_gen_settings.water)
  end
  ctrl_data.by_surface[world.surface.index] = world

  -- Save persistent world
  if data.mod and data.zone then
    ctrl_data.by_zones[data.mod] = ctrl_data.by_zones[data.mod] or {}
    ctrl_data.by_zones[data.mod][data.zone] = world
  end

  return world
end

function lib_ruins.materialise_ruin(world, ruin_info)
  if ruin_info.entity then return end
  local position = ruin_info.position
  -- TODO: try adjust position, check there are no player buildings
  -- TODO: add enemies if a new chunk
  ruin_info.entity = world.surface.create_entity{
    name=shared.corpse, force="neutral", position=position,
  }
  rendering.draw_sprite{
    sprite=ruin_info.img or shared.mod_prefix.."corpse-1",
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

function lib_ruins.spawn_ruin(surface, ruin_info)
  local world = lib_ruins.opt_new_world({surface=surface, ruin_prob_cf=0})
  local sector = lib_ruins.get_create_sector(world, ruin_info.position)
  merge(ruin_info, blank_ruin_info, false)
  ruin_info.died = true
  world.deaths = (world.deaths or 0) + 1
  lib_ruins.materialise_ruin(world, ruin_info)
end

function lib_ruins.ruin_removed(unit_number)
  ruin_info = ctrl_data.ruins[unit_number]
  if ruin_info.exc_info then
    ruin_info.exc_info.ruin_entity = nil
    ruin_info.exc_info.ruin_info = nil
  end
  ruin_info.entity = nil
  ctrl_data.ruins[unit_number] = nil
end

function lib_ruins.calc_extract_success_prob(force)
  local cf = shared.exc_efficiency_by_level[0]
  if force then
    local level = lib_tech.get_research_level(force.index, shared.exc_efficiency_research)
    cf = shared.exc_efficiency_by_level[level]
  end
  return cf
end

function lib_ruins.ruin_extract(ruin_info, ruin_entity)
  if ruin_info then
    local total = #ruin_info.details + #ruin_info.ammo
    local position, name, count, weight
    if total > 0 then
      -- Detail or ammo?
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
        weight = shared.ammo_weights[name] or 1
        count = math.min(lib_ruins.ammo_unit / weight, ruin_info.ammo[position].count)
        ruin_info.ammo[position].count = ruin_info.ammo[position].count - count
        if ruin_info.ammo[position].count < 1 then
          table.remove(ruin_info.ammo, position)
        end
      end
      -- Success or failed extraction?
      if math.random() < lib_ruins.calc_extract_success_prob(ruin_info.exc_info.entity.force) then
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
  if world then
    world.surface = nil
    ctrl_data.by_surface[event.surface_index] = nil
  end
end

local function count_water(surface, position, radius)
  local only_water_layer = collision_mask_util_extended.get_named_collision_mask("only-water-layer")
  local total = surface.count_tiles_filtered{position=position, radius=radius}
  local water = surface.count_tiles_filtered{position=position, radius=radius, collision_mask={only_water_layer}}
  local shallow = surface.count_tiles_filtered{position=position, radius=radius, name="water-shallow"}
  return (water + 0.5*shallow) / (total + 0.1)
end

local function fulfill_sector(world, sector, any_position, add_prob)
  local position = math2d.bounding_box.random_point(lib_ruins.get_sector_box(world, any_position))
  local ruin_prob = 0
  if math2d.position.distance(position, {0, 0}) > (world.free_area or free_area) then
    ruin_prob = (world.ruin_prob_cf or 1) * base_ruin_prob * (add_prob or 1)
  end
  local water_amount = count_water(world.surface, position, 5)
  if false and ruin_prob > 0 then
    game.print("info: "..serpent.line({
      ruin_prob=ruin_prob,
      water_amount=water_amount,
      position=position,
      -- free_area=free_area,
      -- box=lib_ruins.get_sector_box(world, any_position),
      -- any_position=any_position,
    }))
  end

  if true
    and ruin_prob > 0
    and math.random() < ruin_prob
    and water_amount < 0.35
  then
    -- Place a ghost ruin
    if #sector.ruin_ghosts < 1 then
      sector.ruin_ghosts = {
        -- TODO: maybe several?
        lib_ruins.create_random_ruin_info(position),
      }
    end
    world.created_ruins = (world.created_ruins or 0) + #sector.ruin_ghosts
    if heavy_debugging and not debug_many then
      game.print("Planned a titan ruin!")
    end
    return #sector.ruin_ghosts
  end
  return 0
end

local function create_sector_info(world, position)
  local sector = table.deepcopy(blank_sector)
  fulfill_sector(world, sector, position)
  return sector
end

function lib_ruins.get_sector_box(world, position)
  local sector_size = world.sector_size or sector_size
  local x = math.floor(position.x / sector_size) * sector_size
  local y = math.floor(position.y / sector_size) * sector_size
  return {
    left_top = {x=x, y=y},
    right_bottom = {x=x+sector_size, y=y+sector_size},
  }
end

function lib_ruins.get_create_sector(world, position)
  local x = math.floor(position.x / (world.sector_size or sector_size))
  local y = math.floor(position.y / (world.sector_size or sector_size))
  local slice = world.sectors[x] or {}
  world.sectors[x] = slice
  local sector = slice[y]
  if not sector then
    sector = create_sector_info(world, position)
    slice[y] = sector
  end
  return sector
end

local function reveal_sector_point(world, position)
  local sector = lib_ruins.get_create_sector(world, position)
  for i, ruin_info in pairs(sector.ruin_ghosts) do
    if math2d.position.distance(position, ruin_info.position) < sector_size/2 then
      lib_ruins.materialise_ruin(world, ruin_info)
      sector.ruin_ghosts[i] = nil
    end
  end
end

local function handle_created_chunk(event)
  local world = ctrl_data.by_surface[event.surface.index]
  if not world then return end

  local position = math2d.bounding_box.get_centre(event.area)
  reveal_sector_point(world, position)
end

--[[
on corpse created: ignore, only generated corpses will be registered

TODO: on corpse removed:
  local ruin_info = ctrl_data.ruins[unit_number]
  if ruin_info then
    ruin_info.world.ruins[unit_number] = nil
    ctrl_data.ruins[unit_number] = nil
    -- And validate any linked excavator!
  end
--]]


--[[ Hopefully, entity destruction event will be called during this process
lib_ruins:on_event(defines.events.on_surface_cleared, __xyz__)
--]]

--[[ Registration of new surfaces must be handled by mods compatibility scripts
lib_ruins:on_event(defines.events.on_surface_created, function (event)
  opt_new_world({surface_index=event.surface_index})
end)
--]]

lib_ruins:on_event(defines.events.on_surface_deleted, handle_deleted_surface)
lib_ruins:on_event(defines.events.on_chunk_generated, handle_created_chunk)


local function spawn_more_ruins_cmd(cmd)
  local player = game.players[cmd.player_index]
  if not player.admin then
    player.print({"cant-run-command-not-admin", "Spawn more Titan wrecks"})
    return
  end

  local surface = player.surface
  local world = ctrl_data.by_surface[surface.index]
  if not world then
    player.print("Creating new Tians world info...")
    world = lib_ruins.opt_new_world({surface = surface})
  else
    player.print("Fulfilling Titans wrecks with existing world info...")
  end
  local sector, chunk_pos
  local cnt = 0
  for chunk in surface.get_chunks() do
    chunk_pos = chunk.area.left_top
    sector = lib_ruins.get_create_sector(world, chunk_pos)
    cnt = cnt + fulfill_sector(world, sector, chunk_pos, 0.02)
    reveal_sector_point(world, chunk_pos)
  end

  player.print("Added Titans: "..cnt)
end


commands.add_command(
  "titans-spawn-more-corpses",
  "Spawns more Titans wrecks on a current surface",
  spawn_more_ruins_cmd
)


require("script/ruins_dt")
return lib_ruins