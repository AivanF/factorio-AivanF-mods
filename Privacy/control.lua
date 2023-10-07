require("__core__.lualib.util") -- for table.deepcopy

local handler = require("event_handler")
handler.add_lib(require("script/table"):export())
handler.add_lib(require("script/main"):export())

local classes = require("script/classes")
for _, class_lib in pairs(classes) do
  handler.add_lib(class_lib:export())
end
