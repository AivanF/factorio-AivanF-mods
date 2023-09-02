require("__core__.lualib.util") -- for table.deepcopy
shared = require("shared")
mod_name = shared.mod_name

--[[
https://lua-api.factorio.com/latest/Concepts.html#RenderLayer
"air-object" = 145
"light-effect" = 148
"selection-box" = 187
]]--
track_render_layer = 122
foot_render_layer = 124 -- ="lower-object"
shadow_render_layer = 144
lower_render_layer = 168
arm_render_layer = 169
body_render_layer = 170
shoulder_render_layer = 171
shield_render_layer = 172


----- Script data -----

blank_ctrl_data = {
  bunkers = {},
  titans = {},
  foots = {},
}
ctrl_data = table.deepcopy(blank_ctrl_data)

local used_specials = {}


----- Utils -----

function get_keys(tbl)
  if tbl == nil then return nil end
  local result = {}
  for k, v in pairs(tbl) do
    result[#result+1] = k
  end
  return result
end

function merge(a, b, over)
  for k, v in pairs(b) do
    if a[k] == nil or over then
      a[k] = v
    end
  end
  return a
end

function points_to_orientation(a, b)
  return 0.25 +math.atan2(b.y-a.y, b.x-a.x) /math.pi /2
end

function orientation_diff(src, dst)
  if dst - src > 0.5 then src = src + 1 end
  if src - dst > 0.5 then dst = dst + 1 end
  return dst - src
end

function point_orientation_shift(ori, oris, length)
  ori = -ori + 0.25 + oris
  ori = ori * 2 * math.pi
  return {length*math.cos(ori), -length*math.sin(ori)}
end

function math.clamp(v, mn, mx)
  return math.max(math.min(v, mx), mn)
end

function die_all(list, global_storage)
  for _, special_entity in pairs(list) do
    special_entity.destroy()
    if global_storage ~= nil then
      global_storage[special_entity.unit_number] = nil
    end
  end
end

function preprocess_entities(list)
  for _, entity in pairs(list) do
    used_specials[entity.unit_number] = true
    entity.active = false -- for crafting machines
  end
end

function is_titan(name)
  return name:find(shared.titan_prefix, 1, true)
end
