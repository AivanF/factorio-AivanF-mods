require("script/common")
local Lib = require("script/event_lib")
local lib = Lib.new()

building_update_rate = 60

local b1, b2 = 4, 2.5
local bunker_lamps = {
  {-b1, -b2}, {-b1, -b1}, {-b2, -b1},
  { b1, -b2}, { b1, -b1}, { b2, -b1},
  {-b1,  b2}, {-b1,  b1}, {-b2,  b1},
  { b1,  b2}, { b1,  b1}, { b2,  b1},
}


function lib.register_bunker(entity)
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


local function process_bunkers()
  -- print(serpent.block(ctrl_data))
  -- TODO: check process status

  -- TODO: if is assembly process...

  -- TODO: if not in assembly process
  -- TODO: find class by recipe
  -- TODO: determine appropriate weapons recipes and storages content
  -- TODO: set lamp colors by prev values
end

lib:on_nth_tick(building_update_rate, process_bunkers)


return lib