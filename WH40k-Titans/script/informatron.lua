shared = require("shared")
local Informatron = {}

function Informatron.menu(player_index)
  local player = game.players[player_index]
  local menu = {
    -- [shared.mod_name] = 1, -- already exists due to mod name
  }
  return menu
end

function Informatron.page_content(page_name, player_index, element)
  local player = game.players[player_index]
  if page_name == shared.mod_name then
    element.add{type="label", name="text_1", caption="Hello, world!"}
  end
end

return Informatron