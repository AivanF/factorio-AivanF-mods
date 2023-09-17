local shared = {}
shared.debug_mod = true
shared.mod_name = "WH40k-Titans"
shared.path_prefix = "__"..shared.mod_name.."__/"
shared.media_prefix = "__"..shared.mod_name.."-media__/"
shared.mod_prefix = "wh40k-titans-"  -- Most entities
shared.titan_prefix = "wh40k-titan-" -- To distinct titan entities
shared.part_prefix = "wh40k-" -- Can be moved out into separate mod
shared.bridge_prefix = "afci-"


--------- Titan parts
afci_bridge = require("__Common-Industries__.bridge3-item")
-- Body
shared.servitor    = shared.part_prefix.."servitor"
shared.brain       = shared.part_prefix.."titanic-brain"
shared.energy_core = shared.part_prefix.."energy-core"     -- could be placed
shared.void_shield = shared.part_prefix.."void-shield-gen" -- could be placed?
shared.motor       = shared.part_prefix.."titanic-motor"
shared.frame_part  = shared.part_prefix.."titanic-frame-part"
-- Common
shared.antigraveng = shared.part_prefix.."anti-grav-engine"   -- for titan bodies, titan graviton ruinator
shared.realityctrl = shared.part_prefix.."reality-controller" -- for void shields, warp missiles
-- Weapons
shared.barrel      = shared.part_prefix.."titanic-barrel"
shared.proj_engine = shared.part_prefix.."titanic-projectile-engine" -- mostly mechanical, for bolters, rockets
shared.melta_pump  = shared.part_prefix.."titanic-melta-pump" -- mostly mechanical pump, for plasma, melta

-- From the Bridge
shared.emfc = afci_bridge.item.emfc
shared.he_emitter  = afci_bridge.item.he_emitter
shared.ehe_emitter = afci_bridge.item.ehe_emitter


shared.bunker_minable = shared.mod_prefix.."assembly-bunker-minable"
shared.bunker_active = shared.mod_prefix.."assembly-bunker-active"
shared.bunker_center = shared.mod_prefix.."assembly-bunker-center"
shared.bunker_wrecipeh = shared.mod_prefix.."assembly-bunker-weapon-recipe-hor"
shared.bunker_wrecipev = shared.mod_prefix.."assembly-bunker-weapon-recipe-ver"
shared.bunker_wstoreh = shared.mod_prefix.."assembly-bunker-weapon-storage-hor"
shared.bunker_wstorev = shared.mod_prefix.."assembly-bunker-weapon-storage-ver"
shared.bunker_bstore = shared.mod_prefix.."assembly-bunker-body-storage"
shared.bunker_lamp = shared.mod_prefix.."assembly-bunker-bunker_lamp"

shared.craftcat_titan = shared.mod_prefix.."titan"
shared.craftcat_weapon = shared.mod_prefix.."weapon"
shared.craftcat_empty = shared.mod_prefix.."empty"

shared.subg_build = "wh40k-titan-buildings"
shared.subg_parts = "wh40k-titan-parts"
shared.subg_titans = "wh40k-titan-classes"
shared.subg_weapons = "wh40k-titan-weapons"

shared.lab = "wh40k-lab"
shared.sp = "wh40k-titan-science-pack"

function shared.preprocess_recipe(ingredients)
  -- Materialize Bridge items
  result = {}
  for _, couple in pairs(ingredients) do
    if couple[1].short_name then
      afci_bridge.preprocess(couple[1])
      couple[1] = couple[1].name
    end
    result[#result+1] = couple
  end
  return result
end

function shared.shuffle(t)
  for i = #t, 2, -1 do
    local j = math.random(i)
    t[i], t[j] = t[j], t[i]
  end
end

function table.shallow_copy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

function table.slice(tbl, first, last, step)
  local sliced = {}
  for i = first or 1, last or #tbl, step or 1 do
    sliced[#sliced+1] = tbl[i]
  end
  return sliced
end

color_default_dst = {1,1,1}
color_gold    = {255, 220,  50}
color_orange  = {255, 160,  50}
color_red     = {200,  20,  20}
color_blue    = { 70, 120, 230}
color_purple  = {200,  20, 200}
color_green   = {20,  120,  20}
color_cyan    = {20,  200, 200}
color_ltgrey  = {160, 160, 160}
color_dkgrey  = { 60,  60,  60}

return shared