local shared = {}
shared.debug_mod = false
-- shared.debug_mod = true
shared.mod_name = "WH40k-Titans"
shared.path_prefix = "__"..shared.mod_name.."__/"
shared.media_prefix = "__"..shared.mod_name.."-media__/"
shared.mod_prefix = "wh40k-titans-"  -- Most entities
shared.titan_prefix = "wh40k-titan-" -- To distinct titan entities
shared.part_prefix = "wh40k-" -- Can be moved out into separate mod
shared.bridge_prefix = "afci-"
shared.equip_cat = shared.mod_prefix
shared.step_damage = shared.mod_prefix.."stomp"
shared.melee_damage = shared.mod_prefix.."melee"
shared.mepow_damage = shared.mod_prefix.."power-melee"

afci_bridge = require("__Common-Industries__.export")

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
shared.rocket_engine = afci_bridge.item.rocket_engine
shared.bci = afci_bridge.item.bci

--------- Buildings, Groups, Categories
shared.bunker_minable = shared.mod_prefix.."assembly-bunker-minable"
shared.bunker_active = shared.mod_prefix.."assembly-bunker-active"
shared.bunker_center = shared.mod_prefix.."assembly-bunker-center"
shared.bunker_wrecipeh = shared.mod_prefix.."assembly-bunker-weapon-recipe-hor"
shared.bunker_wrecipev = shared.mod_prefix.."assembly-bunker-weapon-recipe-ver"
shared.bunker_wstoreh = shared.mod_prefix.."assembly-bunker-weapon-storage-hor"
shared.bunker_wstorev = shared.mod_prefix.."assembly-bunker-weapon-storage-ver"
shared.bunker_bstore = shared.mod_prefix.."assembly-bunker-body-storage"
shared.bunker_comb = shared.mod_prefix.."assembly-bunker-combinator"
shared.bunker_lamp = shared.mod_prefix.."assembly-bunker-bunker-lamp"
shared.leftovers_chest = shared.mod_prefix.."leftovers-chest"
shared.bunker_comb_size = 20

shared.craftcat_empty = shared.mod_prefix.."empty"
shared.craftcat_titan = shared.mod_prefix.."titan-"
shared.craftcat_weapon = shared.mod_prefix.."weapon-"
shared.craftcat_nomount = shared.mod_prefix.."nomount"
shared.craftcat_noknownweapon = shared.mod_prefix.."noknownweapon"

shared.subg_build   = "wh40k-titan-buildings"
shared.subg_parts   = "wh40k-titan-parts"
shared.subg_titans  = "wh40k-titan-classes"
shared.subg_ammo    = "wh40k-titan-ammo"
shared.subg_weapons = "wh40k-titan-weapons-"

shared.corpse = shared.mod_prefix.."titan-corpse"
shared.excavator = shared.mod_prefix.."extractor"
shared.excavation_recipe = shared.mod_prefix.."extracting"
shared.aircraft_supplier = shared.mod_prefix.."aircraft-supplier"
shared.item_proj = shared.mod_prefix.."item-projectile"

shared.lab = "wh40k-lab"
shared.sp = "wh40k-titan-science-pack"

shared.mock_icon = {
  icon = shared.media_prefix.."graphics/icons/titan-mock.png",
  icon_size = 64,
  icon_mipmaps = 1,
}

--------- Tech researches & effects
shared.exc_speed_research = shared.mod_prefix.."excavation-speed"
shared.exc_speed_by_level = {
  [0] = 0.25,
  [1] = 0.50,
  [2] = 0.75,
  [3] = 1.00,
  [4] = 1.50,
  [5] = 2.00,
  [6] = 3.00,
  [7] = 4.00,
}
shared.exc_efficiency_research = shared.mod_prefix.."excavation-efficiency"
shared.exc_efficiency_by_level = {
  [0] = 0.40,
  [1] = 0.55,
  [2] = 0.75,
  [3] = 0.90,
  [4] = 0.95,
  [5] = 0.99,
}

shared.assembly_speed_research = shared.mod_prefix.."assembly-speed"
shared.assembly_speed_by_level = {
  [0] = 0.5,
  [1] = 0.75,
  [2] = 1.0,
  [3] = 1.5,
  [4] = 2.0,
  [5] = 3.0,
  [6] = 4.0,
}

shared.void_shield_cap_research = shared.mod_prefix.."void-shield-capacity"
shared.void_shield_cap_base = settings.startup["wh40k-titans-base-shield-cap-cf"].value * 2000
shared.void_shield_spd_research = shared.mod_prefix.."void-shield-recharge"

shared.ammo_usage_research = shared.mod_prefix.."ammo-usage-efficiency"
shared.attack_range_research = shared.mod_prefix.."max-attack-range"
shared.attack_range_research_count = 10
shared.attack_range_cf_get = function(level)
  return math.lerp_map(level, 0, shared.attack_range_research_count, 0.7, 1.2)
end

shared.supplier_cap_research = shared.mod_prefix.."supplier-capacity"
shared.supplier_exch_research = shared.mod_prefix.."supplier-exchange-speed"
shared.supplier_exch_by_level = {
  [0] = 20,
  [1] = 50,
  [2] = 100,
  [3] = 200,
  [4] = 500,
  [5] = 1000,
  [6] = 2000,
  [7] = 5000,
}

shared.track_researches = {
  shared.exc_speed_research, shared.exc_efficiency_research,
  shared.assembly_speed_research,
  shared.void_shield_cap_research, shared.void_shield_spd_research,
  shared.ammo_usage_research, shared.attack_range_research,
  shared.supplier_cap_research, shared.supplier_exch_research,
}

--------- Other Mods
shared.SA   = "space-age"
shared.AIND = "aai-industry"
shared.SE   = "space-exploration"
shared.K2   = "Krastorio2"

return shared