require("script/common")
local handler = require("event_handler")
handler.add_lib(require("script/titan"):export())
handler.add_lib(require("script/assemble"):export())
handler.add_lib(require("script/ruins"):export())
handler.add_lib(require("script/exc"):export())
handler.add_lib(require("script/supplier"):export())
handler.add_lib(require("script/tech"):export())
handler.add_lib(require("script/gen_ui"):export())
handler.add_lib(require("script/main"):export())
require("script/informatron")
