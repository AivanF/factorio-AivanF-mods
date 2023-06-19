require "shared"

local function fish_capsule(fish_name, cap, count)
  -- log('PBB_fish: '..serpent.block(fish_name)..', cap: '..serpent.block(cap)..', count: '..count)
  if not cap then return false end
  local src = data.raw.capsule[cap]
  make_potion(cap, src.stack_size, src.icon_size, src.icon_mipmaps, src.icon, -40, 0, 3.0, -0.2, 1.0)
  data:extend({
    {
      type = "recipe",
      name = "fried-"..fish_name,
      category = "smelting",
      subgroup = "raw-resource", order = "h[raw-fish]",
      energy_required = 2,
      ingredients = {{ cap, 1 }},
      result = "fried-fish",
      enabled = true,
    },
  })
end

if settings.startup["always-fry"].value then
  local fishes = 0
  local element
  for fish, proto in pairs(data.raw.fish) do
    element = proto.minable
    if element and proto.autoplace then
      fishes = fishes + 1
      if element.result then
        fish_capsule(fish, element.result, element.count)
      elseif element.results then
        for _, r in pairs(element.results) do
          fish_capsule(fish, r.name or r[1],r.count or r[1] or 1)
        end
      end
    end
  end
  -- log('PBB_fishes: '..fishes)
end