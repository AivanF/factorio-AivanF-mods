local Lib = require("script/event_lib")
lib_tech = Lib.new()

local function reset_weapon_max_dst_cache(force)
  local titan_type, cannon
  for unit_number, titan_info in pairs(ctrl_data.titans) do
    if force == nil or titan_info.force == force then
      titan_type = shared.titan_types[titan_info.class]
      for k, _ in ipairs(titan_type.guns) do
        cannon = titan_info.guns[k]
        cannon.cached_dst = nil
      end
    end
  end
end

local function reset_titan_max_shield_cache(force)
  for unit_number, titan_info in pairs(ctrl_data.titans) do
    if force == nil or titan_info.force == force then
      titan_info.cached_max_shield = nil
    end
  end
end

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

lib_tech:on_event(defines.events.on_research_finished, function(event)
  -- game.print("WH40k_Titans_on_research_finished: "..event.research.name.." of level "..event.research.level)
  review_technology(event.research)

  -- Invalidate specific cache
  if event.research.name:find(shared.attack_range_research, 0, true) then
    reset_weapon_max_dst_cache(event.research.force)
  end
  if event.research.name:find(shared.void_shield_cap_research, 0, true) then
    reset_titan_max_shield_cache(event.research.force)
  end
end)

function lib_tech.get_research_level(force_index, name)
  if ctrl_data.researches[force_index] and ctrl_data.researches[force_index][name] then
    return ctrl_data.researches[force_index][name]
  end
  return 0
end

function lib_tech.update_configuration()
  local a, b = 0, 0
  for _, force in pairs(game.forces) do
    for _, technology in pairs(force.technologies) do
      a = a + 1
      b = b + review_technology(technology)
    end
  end
  reset_weapon_max_dst_cache(nil)
  reset_titan_max_shield_cache(nil)
  -- game.print("WH40k_Titans_tech_reload: "..b.." / "..a)
end

local function tech_debug_cmd(cmd)
  local player = game.players[cmd.player_index]
  if not player.admin then
    player.print({"cant-run-command-not-admin", "Researches debug"})
    return
  end
  player.print(serpent.line(ctrl_data.researches))
end

commands.add_command(
  "titans-tech-debug",
  "Prints some debug info",
  tech_debug_cmd
)

return lib_tech