function table.merge(t1, t2)
   for k, v in pairs(t2) do
      t1[k] = v
   end
   return t1
end

function table.get_keys(t)
  local keys = {}
  for key, _ in pairs(t) do
    table.insert(keys, key)
  end
  return keys
end

local bridge = {
  setup_tech = {},
  get = {},
}
afci_bridge = bridge

bridge.debug_all = false
-- bridge.debug_all = true


-- Constants
bridge.mod_name = "Common-Industries"
bridge.media_path = "__Common-Industries__/graphics/"
bridge.prefix = "afci-"
bridge.log_prefix = "AFCI: "
bridge.empty = ""
bridge.not_updated = "none"

-- bridge.group_name = "afci-common-industries"
bridge.group_name = "intermediate-products"
bridge.subg_early = "afci-early"
bridge.subg_mid   = "afci-midgame"
bridge.subg_late  = "afci-lategame"
bridge.subg_end   = "afci-endgame"

-- TODO: add own recipe categories & related buildings
-- TODO: resolve these for mods too?
bridge.cat_nano_crafting = "advanced-crafting"
bridge.cat_he_crafting   = "advanced-crafting"
bridge.cat_org_crafting  = "chemistry"


-- Supported mods
bridge.mods_list = {
  -- SE    https://mods.factorio.com/user/Earendel
  { short_name = "se",    name = "space-exploration" },
  { short_name = "aaind", name = "aai-industry" },
  -- K2    https://mods.factorio.com/user/raiguard
  { short_name = "k2",    name = "Krastorio2" },
  -- 248k  https://mods.factorio.com/mod/248k
  { short_name = "_248k", name = "248k" },

  -- EI    https://mods.factorio.com/user/PreLeyZero
  { short_name = "exind", name = "exotic-industries" },

  { short_name = "angelbob", name = "AngelBob" },
  -- Bob's    https://mods.factorio.com/user/Bobingabout
  { short_name = "bobelectronics", names = {
    "bobelectronics",
    "MDbobelectronics", -- SE+K2 compatibility for Bob's Electronics
  }},
  { short_name = "bobtech",   name = "bobtech" },
  { short_name = "bobplates", name = "bobplates" },
  { short_name = "bobpower",  name = "bobpower" },
  { short_name = "bobores",   name = "bobores" },
  { short_name = "bobwar",    name = "bobwarfare" },
  { short_name = "bobequip",  name = "bobequipment" },
  -- Angel's  https://mods.factorio.com/user/Arch666Angel
  -- Does anybody play angels without bobs?
  { short_name = "angels", name = "angelsindustries" },
  { short_name = "angelsbio", name = "angelsbioprocessing" },
  { short_name = "angelspetrochem", name = "angelspetrochem" },
  { short_name = "angelssmelting", name = "angelssmelting" },

  -- 5Dim  https://mods.factorio.com/user/McGuten
  -- Nothing to integrate: it add absolutely no new ingredients,
  -- just new building made from old buildings and components.
  { short_name = "5d_com", name = "5dim_compatibility" },
  { short_name = "5d_enr", name = "5dim_energy" },
  { short_name = "5d_nuk", name = "5dim_nuclear" },
  { short_name = "5d_min", name = "5dim_mining" },
  { short_name = "5d_sto", name = "5dim_storage" },
  { short_name = "5d_log", name = "5dim_logistic" },
  { short_name = "5d_aut", name = "5dim_automation" },

  -- IR    https://mods.factorio.com/user/Deadlock989
  { short_name = "ir3", name = "IndustrialRevolution3" },

  -- BZ    https://mods.factorio.com/user/brevven
  { short_name = "bzvery",     name = "bzvery" },
  { short_name = "bzbintermediates", name = "bzbintermediates" },
  { short_name = "bzbelectronics",   name = "bzbelectronics" },
  { short_name = "bzbearly",   name = "bzbearly" },
  { short_name = "bzsilicon",  name = "bzsilicon" },
  { short_name = "bzcarbon",   name = "bzcarbon" },
  { short_name = "bzgraphene", name = "bzgraphene" },
  { short_name = "bzaluminum", name = "bzaluminum" },
  { short_name = "bztungsten", name = "bztungsten" },

  -- Py    https://mods.factorio.com/user/pyanodon
  { short_name = "py_ht",  name = "pyhightech" },
  { short_name = "py_ind", name = "pyindustry" },
  { short_name = "py_pet", name = "pypetroleumhandling" },
  { short_name = "py_fus", name = "pyfusionenergy" },
  { short_name = "py_cp",  name = "pycoalprocessing" },
  { short_name = "py_alt", name = "pyalternativeenergy" },
  { short_name = "py_life",name = "pyalienlife" },
  { short_name = "py_raw", name = "pyrawores" },

  -- Omni  https://mods.factorio.com/user/OmnissiahZelos
  { short_name = "om_cry", name = "omnimatter_crystal" },
  { short_name = "om_enr", name = "omnimatter_energy" },
  { short_name = "om_mat", name = "omnimatter" },

  -- ModMash/Splinter  https://mods.factorio.com/user/btarrant
  { short_name = "spl_mash", name = "modmash" },
  { short_name = "spl_res",  name = "modmashsplinterresources" },
  { short_name = "spl_el",   name = "modmashsplinterelectronics" },
  { short_name = "spl_reg",  name = "modmashsplinterregenerative" },

  -- https://mods.factorio.com/user/YuokiTani
  { short_name = "yit", name = "Yi_Tech_Tree_ExtraVanilla" },
  { short_name = "yie", name = "yi_engines" },
  { short_name = "yi",  name = "Yuoki" },

  -- https://mods.factorio.com/user/AivanF
  { short_name = "pbb",  name = "Powered-by-Biters" },
}


----- Primary mechanic:
-- Resolve abstract prototype declarations (be it item, technology, any dictionary)
-- into specific ones considering enabled mods.

bridge.mods = {}
for _, mod_info in pairs(bridge.mods_list) do
  bridge.mods[mod_info.short_name] = mod_info
end

function bridge.is_bridge_name(name)
  return name:find(bridge.prefix, 1, true)
end

function bridge.clean_prerequisites(given)
  local already = {}
  local result = {}
  for _, name in pairs(given) do
    if given ~= bridge.empty then
      if not already[name] then
        table.insert(result, name)
        already[name] = true
      end
    end
  end
  return result
end

bridge.active_mods_cache = nil
function bridge.have_required_mod(mod_info)  
  -- Treat the argument as a list of mods
  -- for recipes with dependencies and ingredients
  -- from popular modpacks like K2+SE
  if mod_info.short_name == nil then
    for _, v in ipairs(mod_info) do
      if not bridge.have_required_mod(v) then
        return false
      end
    end
    return true
  end

  local active_mods = bridge.active_mods_cache or mods or script.active_mods
  if mod_info.name then
    return not not active_mods[mod_info.name]
  elseif mod_info.names then
    for _, name in pairs(mod_info.names) do
      if active_mods[name] then return true end
    end
  end
  return false
end

-- Updates given object declaration depending on enabled mods
bridge.preprocessed = {}
function bridge.preprocess(obj_info)
  -- Already done or nothing to do
  if bridge.preprocessed[obj_info.short_name] then
    return obj_info
  end
  -- Try to adjust
  for _, specialised in ipairs(obj_info.modded or {}) do
    if bridge.have_required_mod(specialised.mod) then
      table.merge(obj_info, specialised)
      bridge.preprocessed[obj_info.short_name] = true
      obj_info.updated = bridge.is_bridge_name(obj_info.name) and "adjusted" or "replaced"
      log(bridge.log_prefix.."fix, "..specialised.mod.short_name.." "..obj_info.updated.." "..obj_info.short_name)
      if not specialised.continue then
        return obj_info
      end
    end
  end
  if obj_info.updated == bridge.not_updated then
    -- Found nothing
    obj_info.updated = "pass"
  end
  bridge.preprocessed[obj_info.short_name] = true
  return obj_info
end

-- TODO: implement dynamic items migrations comparing cached and actual resolved names of mods and items.

return bridge