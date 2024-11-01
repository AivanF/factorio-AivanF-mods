function reload_recipes(event)
  -- Enable researched recipes
  for i, force in pairs(game.forces) do
    for _, tech in pairs(force.technologies) do
      if tech.researched then
        local success, effects = pcall(function() return tech.effects end)
        if success and effects then -- Checking for successful access to effects
          for _, effect in pairs(effects) do
            if effect.type == "unlock-recipe" then
              force.recipes[effect.recipe].enabled = true
            end
          end
        end
      end
    end
  end
end

script.on_init(reload_recipes)
script.on_configuration_changed(reload_recipes)

commands.add_command(
  "recipes-reload",
  "Reload all recipes from researched technologies",
  reload_recipes
)
