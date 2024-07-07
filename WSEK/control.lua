WSEK_DEBUG = false
-- WSEK_DEBUG = true

local handler = require("event_handler")
handler.add_lib(require("script/start"):export())
handler.add_lib(require("script/sew"):export())

-- Informatron = require("script/informatron")
-- remote.add_interface(
--   "WSEK-Informatron",
--   {
--     informatron_menu = function(data)
--       return Informatron.menu(data.player_index)
--     end,
--     informatron_page_content = function(data)
--       return Informatron.page_content(data.page_name, data.player_index, data.element)
--     end,
--   }
-- )
