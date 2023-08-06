local technologies = {
  [shared.tech_catch_energy] = true,
  [shared.tech_catch_prob] = true,
  [shared.tech_arty_range] = true,
  [shared.tech_arty_lvl] = true,
}

local review_technology = function(technology, do_recalc)
  for name, _ in pairs(technologies) do
    script_data.technologies[name] = script_data.technologies[name] or {}
    if technology.researched and technology.name:find(name, 0, true) then
      local force_index = technology.force.index
      script_data.technologies[name][force_index] = technology.level
      return 1
    end
  end
  return 0
end

local on_research_finished = function(event)
  review_technology(event.research, true)
end

function reset_technologies()
  log("TSL_tech_on_conf_changed")
  for name, _ in pairs(technologies) do
    script_data.technologies[name] = {}
  end
  local a, b = 0, 0
  for _, force in pairs(game.forces) do
    for _, technology in pairs(force.technologies) do
      a = a + 1
      b = b + review_technology(technology, false)
    end
  end
  log("TSL_tech_eview: "..b.." / "..a)
end

script.on_event(defines.events.on_research_finished, on_research_finished)
