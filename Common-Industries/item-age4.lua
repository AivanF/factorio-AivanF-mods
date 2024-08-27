local bridge = require("item-utils")

local add_item = bridge.add_item
local prerequisite = bridge.tech.endgame.name
-- local subgroup = bridge.subg_end
local subgroup = bridge.subg_late

-- TODO: add high-energy factory with 30 nano_mat, 6 quantum_chip, 12 he_emitter

add_item({
  short_name = "st_operator",
  name = bridge.prefix.."space-time-operator",
  icon = bridge.media_path.."icons/spacetime-operator.png",
  icon_size = 64, icon_mipmaps = 3,
  prereq = prerequisite,
  subgroup = subgroup,
  ingredients = {
    {bridge.item.he_emitter, 3},
    {bridge.item.quantum_chip, 1},
    {bridge.item.nano_mat, 8},
  },
  energy_required = 60,
  category = bridge.cat_he_crafting,
  modded = {
    {
      mod = bridge.mods.se,
      -- name = "se-naquium-tesseract",
      -- name = "se-naquium-cube",
      prereq = "se-naquium-cube",
      ingredients = {
        {"se-naquium-cube", 1},
        {bridge.item.he_emitter, 3},
        {bridge.item.quantum_chip, 1},
        {bridge.item.nano_mat, 8},
      },
    },
    {
      mod = bridge.mods.ir3,
      -- name = "quantum-ring",
      prereq = "ir-research-2",
      ingredients = {
        {"quantum-ring", 6},
        {bridge.item.he_emitter, 3},
        {bridge.item.quantum_chip, 1},
        {bridge.item.nano_mat, 8},
      },
    },
    {
      mod = bridge.mods.exind,
      prereq = "ei_matter-stabilizer",
      -- name = "ei_matter-stabilizer",
      ingredients = {
        {"ei_matter-stabilizer", 3},
        {bridge.item.he_emitter, 3},
        {bridge.item.quantum_chip, 1},
        {bridge.item.nano_mat, 8},
      },
    },
    {
      mod = bridge.mods.k2,
      prereq = "kr-matter-processing",
      -- name = "matter-stabilizer",
      ingredients = {
        {"matter-stabilizer", 3},
        {bridge.item.he_emitter, 3},
        {bridge.item.quantum_chip, 1},
        {bridge.item.nano_mat, 8},
      },
    },
  },
})

add_item({
  short_name = "ehe_emitter",
  name = bridge.prefix.."extra-high-energy-emitter",
  icon = bridge.media_path.."icons/emitter-ehe.png",
  icon_size = 64, icon_mipmaps = 1,
  prereq = prerequisite,
  subgroup = subgroup,
  ingredients = {
    {bridge.item.st_operator, 1},
    {bridge.item.he_emitter, 3},
  },
  energy_required = 60,
  category = bridge.cat_he_crafting,
  modded = {
    {
      mod = bridge.mods.se,
      prereq = bridge.item.st_operator,
    },
    -- {
    --   mod = bridge.mods.ir3,
    --   -- prereq = "ir-transmat",
    --   -- prereq = "ir-research-2",
    -- },
  },
})

add_item({
  short_name = "inter_dim_chip",
  name = bridge.prefix.."inter-dimensional-processor",
  icon = bridge.media_path.."icons/chip-quantum.png", -- TODO: replace
  icon_size = 64, icon_mipmaps = 1,
  prereq = prerequisite,
  subgroup = subgroup,
  ingredients = {
    {bridge.item.st_operator, 1},
    {bridge.item.quantum_chip, 4},
  },
  energy_required = 60,
  category = bridge.cat_he_crafting,
  modded = {
    {
      mod = bridge.mods.se,
      name = "se-naquium-processor",
      prereq = "se-naquium-processor",
    },
    {
      mod = bridge.mods.ir3,
      prereq = "ir-research-2",
      ingredients = {
        {bridge.item.st_operator, 1},
        {bridge.item.quantum_chip, 4},
      },
    },
  },
})
