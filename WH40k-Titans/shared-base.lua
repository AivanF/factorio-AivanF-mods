local shared = {}
shared.debug_mod = true
shared.mod_name = "WH40k-Titans"
shared.path_prefix = "__"..shared.mod_name.."__/"
shared.media_prefix = "__"..shared.mod_name.."-media__/"
shared.mod_prefix = "wh40k-titans-"
shared.titan_prefix = "wh40k-titan-"

-- For other mods compatibility
shared.mod_SE = "space-exploration"


--------- Titan parts
shared.part_prefix = "afi-"  -- AivanF Medium/Bridge Industry
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
shared.emfc = shared.part_prefix.."emfc" -- electro-magnetic field controller, for energy core, plasma and hellcannon
-- Weapons
shared.barrel      = shared.part_prefix.."titanic-barrel"
shared.proj_engine = shared.part_prefix.."titanic-projectile-engine" -- mostly mechanical, for bolters, rockets
shared.he_emitter  = shared.part_prefix.."he-emitter"  -- high energy for lasers, plasma, melta
shared.ehe_emitter = shared.part_prefix.."ehe-emitter" -- extra high energy for hell cannon


shared.bunker = shared.mod_prefix.."assembly-bunker-base"
shared.bunker_center = shared.mod_prefix.."assembly-bunker-center"
shared.bunker_wrecipeh = shared.mod_prefix.."assembly-bunker-weapon-recipe-hor"
shared.bunker_wrecipev = shared.mod_prefix.."assembly-bunker-weapon-recipe-ver"
shared.bunker_wstoreh = shared.mod_prefix.."assembly-bunker-weapon-storage-hor"
shared.bunker_wstorev = shared.mod_prefix.."assembly-bunker-weapon-storage-ver"
shared.bunker_bstore = shared.mod_prefix.."assembly-bunker-body-storage"
shared.bunker_lamp = shared.mod_prefix.."assembly-bunker-bunker_lamp"

shared.craftcat_titan = shared.mod_prefix.."titan"
shared.craftcat_weapon = shared.mod_prefix.."weapon"

shared.subg_build = "wh40k-titan-buildings"
shared.subg_parts = "wh40k-titan-parts"
shared.subg_titans = "wh40k-titan-classes"
shared.subg_weapons = "wh40k-titan-weapons"

shared.lab = "wh40k-lab"
shared.sp = "wh40k-science-pack"

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

return shared