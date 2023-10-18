require("script/storage_lib")

---@shape storage_info
  ---@field entity    LuaEntity     Storage game object
  ---@field subtype   string        Storage class name
  ---@field inv       LuaInventory? Main repository
  ---@field oc_safes  integer?      Number of occupied inventories or safes
  ---@field oc_stacks integer?      Number of occupied stacks among all strongboxes

---@shape keylocked_storage_info: storage_info
  -- @field keycats   string[]
  ---@field pws       pw_info[]?

---@shape safe_info
  ---@field inv   LuaInventory
  ---@field pws   pw_info[]
  ---@field name  string?
  ---@field index integer

---@shape bank_storage_info: storage_info
  -- @field keycats   string[]     For lockable safes
  ---@field by_player table<player.name, LuaInventory>  Personal safes
  ---@field by_key    safe_info[]  Lockable safes
  ---@field active    boolean      Disabled bank doesn't open, active bank can't be mined

-- TODO: make storage_info inherite class_spec, to allow simple attributes overriding

function default_init(class_spec, storage_info)
  storage_info.inv = game.create_inventory(class_spec.main_size)
  storage_info.key_categories = {S.keycat_m}
end

function default_destroy(class_spec, storage_info, buffer)
  -- TODO: move content to buffer if it exists
  storage_info.inv.destroy()
end

function default_closed(class_spec, storage_info)
  storage_info.entity.minable = storage_info.inv.is_empty()
  -- game.print("Minable: "..serpent.line(storage_info.entity.minable))
end

function default_inventory_audit(class_spec, storage_info)
  storage_info.oc_safes = 1
  storage_info.oc_stacks = #storage_info.inv - storage_info.inv.count_empty_stacks()
end


----------- 1. Key Locked
local class_spec = {}
storage_classes[S.sub_keylocked] = class_spec

class_spec.main_size = S.small_storage_size
class_spec.accepted_categories = {S.keycat_mech}

class_spec.init = default_init
class_spec.destroy = default_destroy
class_spec.closed = default_closed
class_spec.inventory_audit = default_inventory_audit

function class_spec.try_open(class_spec, storage_info, player)
  if storage_info.pws and #storage_info.pws > 0 then
    if check_player_has_keys(player, storage_info.pws, class_spec.accepted_categories) then
      ctrl_data.opened[player.name] = { storage_info=storage_info, inv_type=inv_type_main }
      open_inv(player, storage_info, {"entity-name."..storage_info.entity.name}, "af-privacy-lock", storage_info.inv, inv_type_main)
      add_locked_side(player, storage_info)
    else
      show_msg(storage_info, player, {"af-privacy.no-key-error"}, color_error)
      storage_info.entity.surface.play_sound{
        path="af-privacy-cannot-open",
        position=storage_info.entity.position,
      }
    end

  else
    open_inv(player, storage_info, {"entity-name."..storage_info.entity.name}, "af-open-unlocked", storage_info.inv, inv_type_main)
    add_locking_button(player)
  end
end


----------- 2. Personal
local class_spec = {}
storage_classes[S.sub_personal] = class_spec

class_spec.main_size = S.small_storage_size

class_spec.init = default_init
class_spec.destroy = default_destroy
class_spec.closed = default_closed
class_spec.inventory_audit = default_inventory_audit

function class_spec.try_open(class_spec, storage_info, player)
  if false
    or storage_info.entity.last_user == nil
    or storage_info.entity.last_user == player
  then
    open_inv(player, storage_info, {"entity-name."..storage_info.entity.name}, "af-open-personal", storage_info.inv, inv_type_main)
  else
    show_msg(storage_info, player, {"af-privacy.no-access-error"}, color_error)
    storage_info.entity.surface.play_sound{
      path="af-privacy-cannot-open",
      position=storage_info.entity.position,
    }
  end
end


----------- 3. Bank
local class_spec = {}
storage_classes[S.sub_bank] = class_spec

class_spec.has_main_menu = true -- If true, try_open will be called again after an inventory gets closed
class_spec.deactivetable = true
class_spec.auto_create_personal = true
class_spec.collapsing = false -- If true, will decrease size of inventories, then delete them
class_spec.lockables_number = 16
class_spec.main_size = S.big_storage_size
class_spec.new_size = S.small_storage_size
class_spec.accepted_categories = {S.keycat_mech, S.keycat_el}

function class_spec.init(class_spec, storage_info, player)
  default_init(class_spec, storage_info, player)
  storage_info.key_categories = {S.keycat_m, S.keycat_el}
  storage_info.by_player = {}
  storage_info.by_key = {}
  storage_info.stacks = 0
  storage_info.active = not class_spec.deactivetable
end

function class_spec.try_open(class_spec, storage_info, player)
  if false
    or storage_info.entity.force == player.force
    or storage_info.entity.force.get_friend(player.force)
  then
    if storage_info.entity.energy / storage_info.entity.electric_buffer_size > 0.9 then

      if class_spec.auto_create_personal and not storage_info.by_player[player.name] then
        storage_info.by_player[player.name] = game.create_inventory(class_spec.new_size)
      end

      ctrl_data.opened[player.name] = { storage_info=storage_info, type=nil }
      make_gui_bank_main(class_spec, storage_info, player)

    else
      show_msg(storage_info, player, {"af-privacy.no-energy-error"}, color_error)
      storage_info.entity.surface.play_sound{
        path="af-privacy-cannot-open",
        position=storage_info.entity.position,
      }
    end
  end
end

function class_spec.destroy(class_spec, storage_info, player, buffer)
  default_destroy(class_spec, storage_info, player, buffer)
  -- TODO: move content to buffer if it exists
  for player_name, inv in pairs(storage_info.by_player) do
    inv.destroy()
  end
  for _, safe_info in pairs(storage_info.by_key) do
    safe_info.inv.destroy()
  end
end

function class_spec.inventory_audit(class_spec, storage_info)
  storage_info.oc_safes = 0
  storage_info.oc_stacks = 0
  local count
  -- Common space
  count = #storage_info.inv - storage_info.inv.count_empty_stacks()
  if count > 0 then
    storage_info.oc_safes = storage_info.oc_safes + count
    storage_info.oc_stacks = storage_info.oc_stacks + 1
  end
  -- Personal strongboxes
  for player_name, pinv in pairs(storage_info.by_player) do
    if game.get_player(player_name) then
      count = #pinv - pinv.count_empty_stacks()
      if count > 0 then
        storage_info.oc_safes = storage_info.oc_safes + count
        storage_info.oc_stacks = storage_info.oc_stacks + 1
      end
    else
      -- TODO: move to common storage?
    end
  end
  -- Lockable safes
  for _, safe_info in pairs(storage_info.by_key) do
    count = #safe_info.inv - safe_info.inv.count_empty_stacks()
    if count > 0 then
      storage_info.oc_safes = storage_info.oc_safes + count
      storage_info.oc_stacks = storage_info.oc_stacks + 1
    end
  end
end

function class_spec.closed(class_spec, storage_info, player)
  -- game.print("Minable: "..serpent.line(storage_info.entity.minable))
  if class_spec.collapsing then
    -- TODO: find inventory from ctrl_data.opened, .sort_and_merge() then .resize() or destroy() and set to nil
  end
end

return classes