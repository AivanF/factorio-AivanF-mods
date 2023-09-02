local Lib = require("script/event_lib")
local titan = require("script/titan")
local assemble = require("script/assemble")
local main = require("script/main")

local handler = require("event_handler")
handler.add_lib(titan.content)
handler.add_lib(assemble.content)
handler.add_lib(main.content)
