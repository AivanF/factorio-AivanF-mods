local Lib = require("script/event_lib")
local titan = require("script/titan")
local assemble = require("script/assemble")
local main = require("script/main")

local handler = require("event_handler")
handler.add_lib(titan.export())
handler.add_lib(assemble.export())
handler.add_lib(main.export())
