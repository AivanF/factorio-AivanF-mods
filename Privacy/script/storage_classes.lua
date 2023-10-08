require("script/storage_lib")

---@shape storage_info
  ---@field entity    LuaEntity     Storage game object
  ---@field subtype   string        Storage class name
  ---@field inv       LuaInventory? Main repository

---@shape keylocked_storage_info: storage_info
  -- @field keycats   string[]
  ---@field pws       pw_info[]?

---@shape safe_info
  ---@field name  string
  ---@field pws   pw_info[]
  ---@field inv   LuaInventory

---@shape bank_storage_info: storage_info
  -- @field keycats   string[]     For lockable safes
  ---@field by_player table<player_index, LuaInventory>  Personal safes
  ---@field by_key    safe_info[]  Lockable safes
  ---@field oc_safes  integer?     Number of occupied safes
  ---@field oc_stacks integer?     Number of occupied stacks among all safes
  ---@field active    boolean      Disabled bank doesn't open, active bank can't be mined

function make_inv(size)
  return game.create_inventory(size)
end

function default_init(class_spec, storage_info)
  storage_info.inv = make_inv(class_spec.size)
  storage_info.key_categories = {S.keycat_m}
end

function default_destroy(class_spec, storage_info)
  -- TODO: check and possibly output leftovers
  storage_info.inv.destroy()
end

function default_closed(class_spec, storage_info)
  storage_info.entity.minable = storage_info.inv.is_empty()
end


----------- 1. Key Locked
local class_spec = {}
storage_classes[S.sub_keylocked] = class_spec

class_spec.size = S.small_storage_size
class_spec.accepted_categories = {S.keycat_mech}

class_spec.init = default_init
class_spec.destroy = default_destroy
class_spec.closed = default_closed

function class_spec.try_open(class_spec, storage_info, player)
  if storage_info.pws and #storage_info.pws > 0 then
    if check_player_has_keys(player, storage_info.pws, class_spec.accepted_categories) then
      ctrl_data.opened[player.index] = { storage_info=storage_info }
      player.opened = storage_info.inv
      storage_info.entity.surface.play_sound{
        path="af-privacy-lock",
        position=storage_info.entity.position,
      }
    else
      show_msg(storage_info, player, {"af-privacy.no-key-error"}, color_error)
      storage_info.entity.surface.play_sound{
        path="af-privacy-locked",
        position=storage_info.entity.position,
      }
    end

  else
    ctrl_data.opened[player.index] = { storage_info=storage_info }
    make_gui_select_key(class_spec, storage_info, player)
  end
end


----------- 2. Personal
local class_spec = {}
storage_classes[S.sub_personal] = class_spec

class_spec.size = S.small_storage_size

class_spec.init = default_init
class_spec.destroy = default_destroy
class_spec.closed = default_closed

function class_spec.try_open(class_spec, storage_info, player)
  if false
    or storage_info.entity.last_user == nil
    or storage_info.entity.last_user == player
  then
    ctrl_data.opened[player.index] = { storage_info=storage_info }
    player.opened = storage_info.inv
    storage_info.entity.surface.play_sound{
      path="af-privacy-lock",
      position=storage_info.entity.position,
    }
  else
    show_msg(storage_info, player, {"af-privacy.no-access-error"}, color_error)
    storage_info.entity.surface.play_sound{
      path="af-privacy-locked",
      position=storage_info.entity.position,
    }
  end
end


----------- 3. Team
-- Seems like this storage isn't needed, Factorio doesn't allow opening chests, buildings of other forces
local class_spec = {}
-- storage_classes[S.sub_team] = class_spec

class_spec.size = S.big_storage_size

class_spec.init = default_init
class_spec.destroy = default_destroy
class_spec.closed = default_closed

function class_spec.try_open(class_spec, storage_info, player)
  if false
    or storage_info.entity.force == player.force
    or storage_info.entity.force.get_friend(player.force)
  then
    ctrl_data.opened[player.index] = { storage_info=storage_info }
    player.opened = storage_info.inv
    storage_info.entity.surface.play_sound{
      path="af-privacy-lock",
      position=storage_info.entity.position,
    }
  else
    show_msg(storage_info, player, {"af-privacy.no-access-error"}, color_error)
    storage_info.entity.surface.play_sound{
      path="af-privacy-locked",
      position=storage_info.entity.position,
    }
  end
end


----------- 4. Bank
local class_spec = {}
storage_classes[S.sub_bank] = class_spec

class_spec.size = S.big_storage_size
class_spec.accepted_categories = {S.keycat_mech, S.keycat_el}

function class_spec.init(class_spec, storage_info, player)
  default_init(class_spec, storage_info, player)
  storage_info.key_categories = {S.keycat_m, S.keycat_el}
  storage_info.by_player = {}
  storage_info.by_key = {}
  storage_info.stacks = 0
  storage_info.entity.minable = false
  storage_info.active = true
end

function class_spec.try_open(class_spec, storage_info, player)
  if false
    or storage_info.entity.force == player.force
    or storage_info.entity.force.get_friend(player.force)
  then
    if storage_info.entity.energy / storage_info.entity.electric_buffer_size > 0.9 then

      if not storage_info.by_player[player.index] then
        storage_info.by_player[player.index] = make_inv(S.small_storage_size)
      end

      -- TODO: make GUI to choose between safes!
      ctrl_data.opened[player.index] = { storage_info=storage_info }
      player.opened = storage_info.by_player[player.index]
      storage_info.entity.surface.play_sound{
        path="af-privacy-safe",
        position=storage_info.entity.position,
      }

    else
      show_msg(storage_info, player, {"af-privacy.no-energy-error"}, color_error)
      storage_info.entity.surface.play_sound{
        path="af-privacy-locked",
        position=storage_info.entity.position,
      }
    end
  end
end

function class_spec.destroy(class_spec, storage_info, player)
  default_destroy(class_spec, storage_info, player)
  for player_index, inv in pairs(storage_info.by_player) do
    inv.destroy()
  end
  for _, safe_info in pairs(storage_info.by_key) do
    safe_info.inv.destroy()
  end
end

function class_spec.closed(class_spec, storage_info, player)
  -- Pass
end

return classes