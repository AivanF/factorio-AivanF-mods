local shared = require("shared")

-- TODO: move into separate reusable mod? AivanF Medium/Bridge Industry (c) :D
local parts = {
  {
    name = shared.servitor,
    icon = shared.media_prefix.."graphics/icons/details/servitor.png",
    icon_size = 64, icon_mipmaps = 4,
    ingredients = {
      {"low-density-structure", 20},
      {"iron-gear-wheel", 20},
      {"copper-cable", 40},
      {"processing-unit", 50},
      {"construction-robot", 1},
    },
    se_ingredients = {
      {"se-specimen", 20}, -- biomass
      {"se-neural-gel", 5},
      {"processing-unit", 1},
      {"copper-cable", 40},
      {"steel-plate", 10},
    },
    category = "chemistry",
    order = "a-1",
    place_result = nil,
  },
  {
    name = shared.brain,
    icon = shared.media_prefix.."graphics/icons/details/titanic-brain.png",
    icon_size = 64, icon_mipmaps = 4,
    ingredients = {
      {"radar", 1},
      {"processing-unit", 200},
    },
    se_ingredients = {
      {"se-quantum-processor", 1},
      {"low-density-structure", 10},
    },
    order = "a-2",
  },
  {
    name = shared.motor,
    icon = shared.media_prefix.."graphics/icons/details/titanic-motor.png",
    icon_size = 64, icon_mipmaps = 4,
    ingredients = {
      {"electric-engine-unit", 50},
      {"iron-gear-wheel", 20},
      {"steel-plate", 60},
    },
    se_ingredients = {
      {"se-heavy-assembly", 18},
    },
    order = "a-3",
  },
  {
    name = shared.frame_part,
    icon = shared.media_prefix.."graphics/icons/details/frame-part.png",
    icon_size = 64, icon_mipmaps = 4,
    ingredients = {
      {"low-density-structure", 100},
      {"iron-gear-wheel", 40},
      {"copper-cable", 100},
    },
    se_ingredients = {
      {"se-nanomaterial", 12},
      {"se-heavy-assembly", 1},
      {"processing-unit", 1},
    },
    order = "a-4",
  },
  {
    name = shared.energy_core,
    icon = shared.media_prefix.."graphics/icons/details/energy-core.png",
    icon_size = 64, icon_mipmaps = 4,
    ingredients = {
      {"fusion-reactor-equipment", 21},
      {shared.emfc, 1},
      {"steel-plate", 100},
    },
    se_ingredients = {
      {"fusion-reactor-equipment", 7},
      {shared.emfc, 1},
      {"se-heavy-girder", 50},
    },
    order = "a-5",
    place_result = nil,
  },
  {
    name = shared.void_shield,
    icon = shared.media_prefix.."graphics/icons/details/void-shield-gen.png",
    icon_size = 64, icon_mipmaps = 3,
    ingredients = {
      {shared.realityctrl, 1},
      {"steel-plate", 24},
    },
    order = "a-6",
  },


  -- Common details
  {
    name = shared.antigraveng,
    icon = shared.media_prefix.."graphics/icons/details/antigraveng.png",
    icon_size = 64, icon_mipmaps = 3,
    ingredients = {
      {"fusion-reactor-equipment", 7},
      {"processing-unit", 23},
      {"energy-shield-mk2-equipment", 16},
    },
    se_ingredients = {
      {"se-naquium-cube", 1},
      {"processing-unit", 23},
      {"steel-plate", 47},
    },
    order = "b-1",
  },
  {
    name = shared.realityctrl,
    icon = shared.media_prefix.."graphics/icons/details/reality-ctrl.png",
    icon_size = 64, icon_mipmaps = 3,
    ingredients = {
      {shared.antigraveng, 13},
      {"low-density-structure", 47},
    },
    se_ingredients = {
      {shared.antigraveng, 13},
      {"se-naquium-tesseract", 3},
      {"se-nanomaterial", 41},
    },
    order = "b-2",
  },
  {
    name = shared.emfc,
    icon = shared.media_prefix.."graphics/icons/details/emfc.png",
    icon_size = 64, icon_mipmaps = 4,
    ingredients = {
      {"energy-shield-mk2-equipment", 5},
      {"low-density-structure", 20},
    },
    se_ingredients = {
      {"se-holmium-solenoid", 6},
      {"se-superconductive-cable", 24},
      {"processing-unit", 5},
      {"low-density-structure", 10},
    },
    order = "b-3",
    place_result = nil,
  },


  -- Weapon details
  {
    name = shared.barrel,
    icon = shared.media_prefix.."graphics/icons/details/barrel.png",
    icon_size = 64, icon_mipmaps = 4,
    ingredients = {
      {"sulfur", 100},
      {"steel-plate", 200},
    },
    se_ingredients = {
      {"se-heavy-girder", 12},
    },
    order = "c-1",
    place_result = nil,
  },
  {
    name = shared.proj_engine,
    icon = shared.media_prefix.."graphics/icons/details/projectile-engine.png",
    icon_size = 64, icon_mipmaps = 4,
    ingredients = {
      {"low-density-structure", 50},
      {"iron-gear-wheel", 40},
      {"electric-engine-unit", 20},
      {"engine-unit", 10},
    },
    se_ingredients = {
      {"se-heavy-assembly", 4},
      {"engine-unit", 6},
    },
    order = "c-2",
    place_result = nil,
  },
  {
    name = shared.he_emitter,
    icon = shared.media_prefix.."graphics/icons/details/emitter-he.png",
    icon_size = 64, icon_mipmaps = 3,
    ingredients = {
      {"energy-shield-mk2-equipment", 10},
      {"copper-cable", 200},
      {"processing-unit", 20},
    },
    se_ingredients = {
      {shared.emfc, 1},
      {"se-dynamic-emitter", 1},
      {"glass", 7},
      {"processing-unit", 3},
    },
    order = "c-3",
    place_result = nil,
  },
  {
    name = shared.ehe_emitter,
    icon = shared.media_prefix.."graphics/icons/details/emitter-ehe.png",
    icon_size = 64, icon_mipmaps = 4,
    ingredients = {
      {"energy-shield-mk2-equipment", 20},
      {"processing-unit", 100},
      {"copper-cable", 100},
    },
    se_ingredients = {
      {"se-dynamic-emitter", 5},
      {"se-naquium-cube", 1},
      {"processing-unit", 5},
      {"se-superconductive-cable", 10},
    },
    order = "c-4",
    place_result = nil,
  },


  -- Ammo
  {
    name = shared.plasma_ammo,
    icon = shared.media_prefix.."graphics/icons/weapons/plasma-fuel.png",
    icon_size = 64, icon_mipmaps = 4,
    energy_required = 5,
    ingredients = {
      {type="fluid", name="water", amount=50},
      {"battery", 5},
      {"steel-plate", 2},
    },
    -- se_ingredients = {
    -- TODO: make smth here?
    -- },
    results = {
      {"iron-ore", 1},
      {"copper-ore", 1},
    },
    se_results = {
      {"se-scrap", 4},
    },
    stack_size = 10,
    category = "chemistry",
    order = "d-1",
    place_result = nil,
  },
}


local ingredients, results
local has_SE = not not mods[shared.mod_SE]

for _, info in pairs(parts) do

  ingredients = info.ingredients
  if has_SE and info.se_ingredients and #info.se_ingredients > 0 then
    ingredients = info.se_ingredients
  end

  results = info.results
  -- TODO: add use_recylcing startup setting, remove ores if false
  if has_SE and info.se_results and #info.se_results > 0 then
    results = info.se_results
  end
  if results then
    table.insert(results, 1, {info.name, 1})
  end

  data:extend({
    {
      type = "item",
      name = info.name,
      icon = info.icon,
      icon_size = info.icon_size, icon_mipmaps = info.icon_mipmaps,
      subgroup = shared.subg_parts,
      order = info.order,
      place_result = info.place_result,
      stack_size = info.stack_size or 1,
    },
    {
      type = "recipe",
      name = info.name,
      enabled = false,
      energy_required = info.energy_required or 10,
      ingredients = ingredients,
      result = info.name,
      results = results,
      main_product = info.name,
      category = info.category or "crafting",
    },
  })
end
