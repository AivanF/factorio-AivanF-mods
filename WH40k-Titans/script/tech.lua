require("script/common")
local Lib = require("script/event_lib")
local lib = Lib.new()

local review_technology = function(technology)
  for _, name in pairs(shared.track_researches) do
    if technology.researched and technology.name:find(name, 0, true) then
      local force_index = technology.force.index
      ctrl_data.researches[force_index] = ctrl_data.researches[force_index] or {}
      ctrl_data.researches[force_index][name] = technology.level
      -- game.print("WH40k_Titans_review_technology: "..technology.name.." of level "..technology.level)
      return 1
    end
  end
  return 0
end

lib:on_event(defines.events.on_research_finished, function(event)
  -- game.print("WH40k_Titans_on_research_finished: "..event.research.name.." of level "..event.research.level)
  review_technology(event.research)
end)

function lib.get_research_level(force_index, name)
  if ctrl_data.researches[force_index] and ctrl_data.researches[force_index][name] then
    return ctrl_data.researches[force_index][name]
  end
  return 0
end

function lib.update_configuration()
  local a, b = 0, 0
  for _, force in pairs(game.forces) do
    for _, technology in pairs(force.technologies) do
      a = a + 1
      b = b + review_technology(technology)
    end
  end
  -- game.print("WH40k_Titans_tech_reload: "..b.." / "..a)
end

return lib