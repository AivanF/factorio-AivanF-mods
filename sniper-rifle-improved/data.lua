local Constants = require("constants")

-- Category --
data:extend({{type = "ammo-category", name = Constants.ammoCategory}})

-- Entities --
require("prototypes.magazine")
require("prototypes.rifle")
