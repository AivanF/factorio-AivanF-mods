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

-- Informatron = require("script/informatron")
-- remote.add_interface(
--   shared.titan_prefix.."info",
--   {
--     informatron_menu = function(data)
--       return Informatron.menu(data.player_index)
--     end,
--     informatron_page_content = function(data)
--       return Informatron.page_content(data.page_name, data.player_index, data.element)
--     end,
--   }
-- )
