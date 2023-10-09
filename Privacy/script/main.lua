local S = require("shared")
require("script/storage_classes")
local Lib = require("script/event_lib")
local lib = Lib.new()

---@shape player_opened_info
  -- @field storage_info storage_info
  ---@field inv_type     string?      Nil if bank main menu is opened
  ---@field index        integer?     For lockable safes

local blank_ctrl_data = {
  storages = {}, -- LuaEntity.unit_number => storage_info
  opened = {}, -- player.name => player_opened_info
}
ctrl_data = nil

function lib.register_storage(entity, subtype, data)
  if ctrl_data.storages[entity.unit_number] then
    error("Entity "..tostring(entity.unit_number).." is an already registered storage")
  end
  local storage_info = {
    entity = entity,
    subtype = subtype,
  }
  if data then
    for k, v in pairs(data) do
      storage_info[k] = v
    end
  end
  storage_classes[subtype]:init(storage_info)
  ctrl_data.storages[entity.unit_number] = storage_info
end

lib:on_any_built(function(event)
  local entity = event.created_entity or event.entity or event.destination
  if not (entity and entity.valid) then return end
  local subtype = S.entity_name_to_class[entity.name]
  if subtype then
    lib.register_storage(entity, subtype)
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
    storage_classes[storage_info.subtype]:destroy(storage_info)
  end
end)

lib:on_event(defines.events.on_gui_opened, function(event)
  local player = game.get_player(event.player_index)
  local storage_info = event.entity and ctrl_data.storages[event.entity.unit_number]
  if storage_info then
    player.opened = nil
    storage_classes[storage_info.subtype]:try_open(storage_info, player)
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