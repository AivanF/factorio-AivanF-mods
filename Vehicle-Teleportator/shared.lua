local shared = {}

shared.mod_name = "Vehicle-Teleportator"
shared.path_prefix = "__"..shared.mod_name.."__/"
shared.mod_prefix = "vehitel-"  -- for entities

-- Same planet with CD, no other planets
shared.device1 = shared.mod_prefix.."device-mk1"
-- Same planet w/t CD, any planet with CD
shared.device2 = shared.mod_prefix.."device-mk2"
-- Anywhere, no CD
shared.device3 = shared.mod_prefix.."device-mk3"

shared.dst_selector = shared.mod_prefix.."destination-selector"

return shared