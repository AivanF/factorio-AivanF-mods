local shared = require("shared.shared-base")
require("shared.utils")
require("shared.shared-titans")
require("shared.shared-weapons")

shared.special_entities = {
  shared.bunker_center,
  -- shared.bunker_wrecipeh,
  -- shared.bunker_wrecipev,
  shared.bunker_wstoreh,
  shared.bunker_wstorev,
  shared.bunker_bstore,
  shared.bunker_lamp,

  shared.titan_foot_small,
  shared.titan_foot_big,
}
return shared