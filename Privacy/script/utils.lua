S = require("shared")
require("script/hash")

function dict_from_keys_array(keys, value)
  -- Useful for quick indexing
  local result = {}
  for _, key in pairs(keys) do
    result[key] = value
  end
  return result
end

---@shape tag_info
  ---@field pws pw_info[]  Passwords in the key / bunch
  ---@field cat string?    Can override default registered keycat of the item

---@shape pw_info
  ---@field pw string
  ---@field name string?  Also can be Factorio localised string
  ---@field item string?  Name of original item prototype, used for bunches of keys

function setup_key_description(stack)
  -- TODO: translate everything here
  local tag_info = stack.tags[S.key_tag_name]
  if not tag_info or #tag_info.pws < 1 then
    stack.custom_description = "Empty key"
    return
  end

  if #tag_info.pws > 1 then
    local names = {}
    local untitled = 0
    for _, pw_info in pairs(tag_info.pws) do
      if pw_info.name then
        if pw_info.item then
          table.insert(names, "[item="..pw_info.item.."] "..pw_info.name)
        else
          table.insert(names, pw_info.name)
        end
      else
        untitled = untitled + 1
      end
    end
    if untitled > 0 then
      table.insert(names, {"", untitled, {"af-privacy.untitled"}})
    end
    stack.custom_description = {"af-privacy.bunch-keys", #tag_info.pws, table.concat(names, ", ")}
  else
    if tag_info.pws[1].name then
      stack.custom_description = tag_info.pws[1].name
    else
      stack.custom_description = {"af-privacy.untitled"}
    end
  end
end

function get_key_category(stack, tag_info)
  return tag_info and tag_info.cat or S.registered_keys[stack.name]
end

function get_ready_key_stack_info(stack, keycat_filter)
  if stack.valid_for_read then
    local tag_info = stack.type == "item-with-tags" and stack.get_tag(S.key_tag_name)
    if tag_info and keycat_filter[get_key_category(stack, tag_info)] then
      return tag_info
    end
  end
  return nil
end

function check_raw_key_stack(stack, keycat_filter)
  if stack.valid_for_read then
    local tag_info = stack.get_tag(S.key_tag_name)
    if keycat_filter[get_key_category(stack, tag_info)] then
      if tag_info == nil or #tag_info.pws == 0 then
        return true
      end
    end
  end
  return nil
end

function engrave_key_item(stack, name, pw, cat)
  stack.set_tag(S.key_tag_name, {pws={{pw=pw, name=name, item=stack.name}}, cat=cat})
  setup_key_description(stack)
end

function check_player_has_keys(player, required_pws, accepted_categories)
  local pinv = player.get_inventory(defines.inventory.character_main)
  local stack, tag_info
  local missing = {}
  for _, pw_info in pairs(required_pws) do
    missing[pw_info.pw] = true
  end
  local accepted_categories_dict = dict_from_keys_array(accepted_categories, true)

  for i = 1, #pinv do
    stack = pinv[i]
    if stack.valid_for_read then
      tag_info = get_ready_key_stack_info(stack, accepted_categories_dict)
      if tag_info then
        for _, pw_info in pairs(tag_info.pws) do
          missing[pw_info.pw or "-"] = nil
        end
      end
    end
  end

  for pw, _ in pairs(missing) do
    return false
  end
  return true
end

function get_player_pws(player, accepted_categories)
  local pinv = player.get_inventory(defines.inventory.character_main)
  local stack, tag_info
  local accepted_categories_dict = {}
  for _, cat in pairs(accepted_categories) do
    accepted_categories_dict[cat] = true
  end
  local pws = {}

  for i = 1, #pinv do
    stack = pinv[i]
    if stack.valid_for_read then
      tag_info = get_ready_key_stack_info(stack, accepted_categories_dict)
      if tag_info then
        for _, pw_info in pairs(tag_info.pws) do
          pws[#pws+1] = pw_info
          pw_info.item = pw_info.item or stack.name
        end
      end
    end
  end
  return pws
end


function show_msg(storage_info, player, text, color)
  storage_info.entity.surface.create_entity{
    position = storage_info.entity.position,
    name = "flying-text",
    text = text,
    color = color,
    render_player_index = player.index,
  }
end
