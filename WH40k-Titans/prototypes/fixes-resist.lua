local shared = require("shared")

local stomp_protected_types = {
  -- Conveyor belts and rails aren't even collidable,
  -- so can be considered as immune to impact damage by default
  "transport-belt", "underground-belt", "splitter", "loader",
  "curved-rail", "straight-rail", "rail-signal", "rail-chain-signal", "train-stop",
  "logistic-robot", "construction-robot",
  -- These ones are more arguable...
  "electric-pole", "inserter",
  "container", "logistic-container", "storage-tank",
  -- "wall", "gate",
}
stomp_protected_types = dict_from_keys_list(stomp_protected_types, true)

local function try_copy_resist(resistances, name_src, name_dst)
  if resistances == nil then return end
  local row = nil
  for _, arow in ipairs(resistances) do
    if arow.type == name_src then
      row = arow
      break
    end
  end
  if row ~= nil then
    table.insert(resistances, { type = name_dst, decrease = row.decrease, percent = row.percent })
  end
end

local function replace_resist(resistances, name, decrease, percent)
  local row = nil
  for _, arow in ipairs(resistances) do
    if arow.type == name then
      row = arow
      break
    end
  end
  if row == nil then
    row = { type = name, decrease = decrease, percent = percent }
    table.insert(resistances, row)
  else
    row.decrease = decrease
    row.percent = percent
  end
end

for type_name, data in pairs(data.raw) do
  for entity_name, proto in pairs(data) do
    if stomp_protected_types[type_name] then
      proto.resistances = proto.resistances or {}
      replace_resist(proto.resistances, shared.step_damage, 0, 100)
    else
      try_copy_resist(proto.resistances, "impact", shared.step_damage)
    end
    try_copy_resist(proto.resistances, "physical", shared.melee_damage)
    try_copy_resist(proto.resistances, "electric", shared.mepow_damage)
  end
end