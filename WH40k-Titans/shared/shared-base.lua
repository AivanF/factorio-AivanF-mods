local shared = {}
shared.debug_mod = true
shared.mod_name = "WH40k-Titans"
shared.path_prefix = "__"..shared.mod_name.."__/"
shared.media_prefix = "__"..shared.mod_name.."-media__/"
shared.mod_prefix = "wh40k-titans-"  -- Most entities
shared.titan_prefix = "wh40k-titan-" -- To distinct titan entities
shared.part_prefix = "wh40k-" -- Can be moved out into separate mod
shared.bridge_prefix = "afci-"

afci_bridge = require("__Common-Industries__.export") -- TODO: update

--------- Titan parts
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

--------- Buildings, Groups, Categories
shared.bunker_minable = shared.mod_prefix.."assembly-bunker-minable"
shared.bunker_active = shared.mod_prefix.."assembly-bunker-active"
shared.bunker_center = shared.mod_prefix.."assembly-bunker-center"
shared.bunker_wrecipeh = shared.mod_prefix.."assembly-bunker-weapon-recipe-hor"
shared.bunker_wrecipev = shared.mod_prefix.."assembly-bunker-weapon-recipe-ver"
shared.bunker_wstoreh = shared.mod_prefix.."assembly-bunker-weapon-storage-hor"
shared.bunker_wstorev = shared.mod_prefix.."assembly-bunker-weapon-storage-ver"
shared.bunker_bstore = shared.mod_prefix.."assembly-bunker-body-storage"
shared.bunker_lamp = shared.mod_prefix.."assembly-bunker-bunker-lamp"
shared.leftovers_chest = shared.mod_prefix.."leftovers-chest"

shared.craftcat_empty = shared.mod_prefix.."empty"
shared.craftcat_titan = shared.mod_prefix.."titan-"
shared.craftcat_weapon = shared.mod_prefix.."weapon-"

shared.subg_build   = "wh40k-titan-buildings"
shared.subg_parts   = "wh40k-titan-parts"
shared.subg_titans  = "wh40k-titan-classes"
shared.subg_ammo    = "wh40k-titan-ammo"
shared.subg_weapons = "wh40k-titan-weapons-"

shared.corpse = shared.mod_prefix.."titan-corpse"
shared.excavator = shared.mod_prefix.."extractor"
shared.excavation_recipe = shared.mod_prefix.."extracting"

shared.lab = "wh40k-lab"
shared.sp = "wh40k-titan-science-pack"

shared.mock_icon = {
  icon = shared.media_prefix.."graphics/icons/titan-mock.png",
  icon_size = 64,
  icon_mipmaps = 1,
}

--------- Other Mods
shared.SE = "space-exploration"

return shared