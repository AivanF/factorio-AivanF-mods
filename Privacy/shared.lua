local S = {}

S.mod_name = "Privacy"
S.mod_path = "__"..S.mod_name.."__"
S.small_storage_size = 48
S.big_storage_size = 160
S.key_tag_name = "af-privacy-key"

S.lock_item = "af-privacy-lock-mechanism"
S.table_item = "af-privacy-engraving-table"
S.el_table_item = "af-privacy-engraving-table-el"

-- Key categories
S.keycat_mech = "mechanical"
S.keycat_el   = "electronical"
S.keycat_q    = "quantum"
S.keycat_mag  = "magic"
S.keycat_mag  = S.keycat_q -- Clarke's 3rd law -- kinda easter egg

-- Key items
S.iron_key_item   = "af-privacy-key-iron"
S.bronze_key_item = "af-privacy-key-bronze"
S.steel_key_item  = "af-privacy-key-steel"
S.noble_key_item  = "af-privacy-key-noble" -- for quests
S.car_key_item    = "af-privacy-key-car"
S.nfc_key_item    = "af-privacy-key-nfc"

-- Category can be overriden inside the tag
S.registered_keys = {
  [S.iron_key_item]   = S.keycat_mech,
  [S.bronze_key_item] = S.keycat_mech,
  [S.steel_key_item]  = S.keycat_mech,
  [S.car_key_item]    = S.keycat_mech,
  [S.nfc_key_item]    = S.keycat_el,
}

S.registered_keycats = {
  [S.keycat_mech] = {max_merge= 10},
  [S.keycat_el]   = {max_merge=128},
}

S.registered_tables = {
  [S.table_item] = {keycats = {S.keycat_mech}},
  [S.el_table_item] = {keycats = {S.keycat_mech, S.keycat_el}},
}

-- Storages subtypes
S.entity_name_to_class = {}
S.storage_base_type = "assembling-machine"

S.sub_keylocked = "key-locked"
S.keylocked_chest_name = "af-privacy-key-locked-chest"
S.entity_name_to_class[S.keylocked_chest_name] = S.sub_keylocked

S.sub_personal = "personal"
S.personal_chest_name = "af-privacy-personal-chest"
S.entity_name_to_class[S.personal_chest_name] = S.sub_personal

S.sub_team = "team"
S.team_storage_name = "af-privacy-team-storage"
S.entity_name_to_class[S.team_storage_name] = S.sub_team

S.sub_bank = "bank"
S.bank_name = "af-privacy-bank"
S.entity_name_to_class[S.bank_name] = S.sub_bank

return S