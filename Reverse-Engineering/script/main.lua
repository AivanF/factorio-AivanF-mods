require("shared")
require("utils")
require("script.worth")

local Lib = require("event_lib")
local lib = Lib.new()


function correct_global()
  if not storage.reverse_labs then storage.reverse_labs = {} end
  if not storage.reverse_items and game then
    storage.reverse_items = {}
    cache_data()
  end
end

-- lib:on_init(function()
-- end)

lib:on_configuration_changed(function()
  -- Clean storage. This will cause recache when game get initialised
  storage.scipacks = nil
  storage.reverse_items = nil
end)

-- TODO: add re-register function to reset storage.reverse_labs?


local interface = {
  add_ignore_items = function(names)
    deep_merge(storage.add_ignore_items, from_key_list(names, true))
  end,

  add_ignore_techs = function(names)
    deep_merge(storage.add_ignore_techs, from_key_list(names, true))
  end,

  -- Given `item_info` must contain at least `ingredients`. Maybe better to override from `get_item`
  add_override_item = function(item_name, item_info)
    if not item_info.ingredients then
      error("add_override_item got bad values for "..serpent.line(item_name)..", item_info: "..serpent.line(item_info))
    end
    item_info.prob = item_info.prob or 1
    item_info.need = item_info.need or 1
    item_info.price = item_info.price or 1
    storage.add_override_items[item_name] = item_info
  end,

  get_item = function(item_name)
    -- local item_info = storage.add_override_items[item_name] or storage.reverse_items[item_name]
    -- game.print("get_item: "..serpent.line(item_name).." => "..serpent.line(storage.reverse_items[item_name]))
    return storage.reverse_items[item_name]
  end,

  -- Use the above API in your own remote functions:
  -- `reverse_engineering_pre_calc` to add ignoring
  -- `reverse_engineering_post_calc` to override items
}


if not remote.interfaces["reverse_labs"] then
  remote.add_interface("reverse_labs", interface)
end


commands.add_command(
  "reveng-recache",
  "Recalculate cache of items costs",
  function ()
    cache_data()
    game.print("Reverse Engineering cache reloaded")
  end
)

return lib