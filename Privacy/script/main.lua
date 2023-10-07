local S = require("shared")
local Lib = require("script/event_lib")
local lib = Lib.new()

local classes = require("script/classes")
-- Classes could be extendable by remote interfaces, but no need for now, so KISS YAGNI


local blank_storage_info = {
  entity = nil, -- LuaEntity
  subtype = nil, -- storage class string
  inv = nil, -- primary storage LuaInventory
  key_categories = nil, -- for key-locked and some bank safes

  -- sub_keylocked
  pws = nil, -- list of required keys as pw_info

  -- sub_personal: access by last_user
  -- sub_team: access by same force

  -- sub_bank
  by_player = nil, -- player_index => LuaEntity
  by_key = nil, -- list of {name=localised string, pws={array of required passwords}, inv=LuaInventory}
  stacks = nil, -- total number of item stacks
}

local blank_ctrl_data = {
  storages = {}, -- uid of main LuaEntity => storage_info
  opened = {}, -- player.index => their last storage_info
}
ctrl_data = nil


local function register_storage(entity, subtype, size)
  local storage_info = {
    entity = entity,
    subtype = subtype,
  }
  ctrl_data.storages[entity.unit_number] = storage_info
  classes[subtype]:init(storage_info)
end


lib:on_any_built(function(event)
  local entity = event.created_entity or event.entity or event.destination
  if not (entity and entity.valid) then return end
  local subtype = S.entity_name_to_class[entity.name]
  if subtype then
    register_storage(entity, subtype, classes[subtype].size)
  end
end)


lib:on_any_remove(function(event)
  local uid
  local entity = event.entity
  if entity and entity.valid then
    uid = entity.unit_number
  else
    entity = nil
  end
  uid = uid or event.unit_number
  if not uid then return end

  local storage_info = ctrl_data.storages[uid]
  if storage_info then
    classes[storage_info.subtype]:destroy(storage_info)
  end
end)


lib:on_event(defines.events.on_gui_opened, function(event)
  local player = game.get_player(event.player_index)
  local storage_info = event.entity and ctrl_data.storages[event.entity.unit_number]
  if storage_info then
    player.opened = nil
    classes[storage_info.subtype]:try_open(storage_info, player)
    if player.opened ~= nil then
      ctrl_data.opened[player.index] = storage_info
    end
  end
end)


lib:on_init(function()
  global.ctrl_data = table.deepcopy(blank_ctrl_data)
  ctrl_data = global.ctrl_data
end)

lib:on_load(function()
  ctrl_data = global.ctrl_data
end)

return lib