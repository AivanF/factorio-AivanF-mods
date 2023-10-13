local S = require("shared")
local storage_classes = require("script/storage_classes")
local lib_main = require("script/main")
local Lib = require("script/event_lib")
local lib = Lib.new()

remote.add_interface(S.mod_name, {

  ----------- Control time

  -- Registers storage entity using specified storage class.
  -- Entity's prototype can be unregistered.
  -- Entity's prototype can be of any type, but I suggest smth not operable,
  -- like I made assembling-machine with empty recipe category.
  ---@param args.entity      LuaEntity
  ---@param args.class_name  string
  ---@param args.data        table?    Any attributes for new storage_info
  register_storage = function(args)
    lib_main.register_storage(args.entity, args.class_name, args.data)
  end,

  -- Returns inventory of a lockable chest or team storage of a bank. Can be nil if storage is a personalised lootbox.
  ---@param args.entity      LuaEntity
  ---@param args.error       boolean?  Raise error if entity is not a registered storage, true by default
  ---@return LuaInventory?
  get_main_inv = function(args)
    local storage_info = ctrl_data.storages[entity.unit_number]
    if storage_info then
      return ctrl_data.storages[entity.unit_number].inv
    else
      if args.error==true or args.error==nil then
        error("Entity is not a registered storage")
      else
        return nil
      end
    end
  end,

  -- Returns personal inventory of a storage. Can be used for fulfilling lootboxes.
  ---@param args.entity      LuaEntity
  ---@param args.owner       LuaPlayer
  ---@param args.create      boolean?  Should inventory be created if there is no one, false by default
  ---@param args.error       boolean?  Raise error if entity is not a registered storage, true by default
  ---@return LuaInventory?
  get_personal_inv = function(args)
    local storage_info = ctrl_data.storages[entity.unit_number]
    if storage_info then
      local class_spec = storage_classes[storage_info.subtype]
      if not storage_info.by_player[player.name] and args.create then
        storage_info.by_player[player.name] = make_inv(class_spec.new_size)
      end
      return storage_info.by_player[player.name]
    else
      if args.error==true or args.error==nil then
        error("Entity is not a registered storage")
      else
        return nil
      end
    end
  end,

  -- TODO: get_lockable_inv; validate bounds even if create=true, but skip if lockables_number<0


  ----------- Load time

  -- Registers a storage entity prototype.
  -- This will automatically call register_storage when entity get placed.
  -- Entity's prototype can be of any type, but I suggest smth not operable,
  -- like I made assembling-machine with empty recipe category.
  ---@param args.entity_name  string
  ---@param args.class_name   string
  register_storage_entity =  function(args)
    S.entity_name_to_class[args.entity_name] = args.class_name
  end,

  -- Registers new storage class importing it from given file path and variable name.
  -- You can easily create new class reusing code of existing ones, see storage_classes.lua.
  ---@param args.class_name  string
  ---@param args.path        string
  ---@param args.attribute   string
  register_storage_class = function(args)
    if storage_classes[args.class_name] then
      error("Class "..args.class_name.." is already registered")
    end
    storage_classes[args.class_name] = require(args.path)[args.attribute]
  end,

  -- Registers a key item prototype, it needs to be item-with-tags.
  -- Registration is only used as a source of default category, e.g when crafting keys,
  -- so it's not required for ready-to-use keys from scripts/quests,
  -- you can simply assign a compatible tag, see tag_info in utils.lua.
  -- Key category can be any string, it don't have to be builtin or registered.
  ---@param args.item_name  string
  ---@param args.keycat     string
  register_key_item = function(args)
    S.registered_keys[args.item_name] = args.keycat
  end,

  -- Registers an engraving worktable entity prototype.
  -- This will add engraving UI when a player opens an instance of this entity.
  -- Note that it should be of container type.
  -- If you wanna smth different – feel free to design and code a brand new engraving station,
  -- it simply should deal with keys in a similar way.
  ---@param args.entity_name  LuaEntity
  ---@param args.keycats      string[]
  register_engraving_entity = function(args)
    S.registered_tables[args.entity_name] = {keycats = args.keycats}
  end,
})

return lib