require("__core__.lualib.util") -- for table.deepcopy

local handler = require("event_handler")
handler.add_lib(require("script/table"):export())
handler.add_lib(require("script/main"):export())
handler.add_lib(require("script/remote_api"):export())
handler.add_lib(require("script/storage_lib"):export())
