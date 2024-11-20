local function array_contains(ar, target)
  if ar and #ar > 0 then
    for _, value in ipairs(ar) do
      if value == target then
        return true
      end
    end
  end
  return false
end


local function adds_productivity(module)
  for name, value in pairs(module.effect) do
    if name == "productivity" and value > 0 then
      return true
    end
  end
  return false
end


local function is_restricted(module, recipe_name)
  return module.limitation and #module.limitation > 0 and not array_contains(module.limitation, recipe_name)
end


local function item_has_field(item_name, field_name)
  return data.raw.item[item_name] and data.raw.item[item_name][field_name]
end


local have_SA = mods["space-age"]
local have_ER = mods["elevated-rails"]


local function should_enable_prod(item_name)
  if type(item_name) ~= "string"  then return false end
  if item_name:find("fish", 1, true) then return false end

  local placable = item_has_field(item_name, "place_result")
  local equipment = item_has_field(item_name, "place_as_equipment_result")
  local launchable = item_has_field(item_name, "rocket_launch_product") or item_has_field(item_name, "rocket_launch_products")

  local result = (false
    ----- Logistics
    or settings.startup["af-prod-enable-belts"].value and data.raw["transport-belt"][item_name]
    or settings.startup["af-prod-enable-belts"].value and data.raw["underground-belt"][item_name]
    or settings.startup["af-prod-enable-belts"].value and data.raw["splitter"][item_name]
    or settings.startup["af-prod-enable-belts"].value and data.raw["loader"][item_name]
    or settings.startup["af-prod-enable-belts"].value and data.raw["loader-1x1"][item_name]
    or settings.startup["af-prod-enable-inserters"].value and data.raw["inserter"][item_name]
    or settings.startup["af-prod-enable-containers"].value and data.raw["container"][item_name]
    or settings.startup["af-prod-enable-containers"].value and data.raw["logistic-container"][item_name]

    or settings.startup["af-prod-enable-robots"].value and data.raw["logistic-robot"][item_name]
    or settings.startup["af-prod-enable-robots"].value and data.raw["construction-robot"][item_name]

    or settings.startup["af-prod-enable-rails"].value and data.raw["rail-planner"][item_name]
    or have_ER and settings.startup["af-prod-enable-rails"].value and data.raw["rail-ramp"][item_name]
    or have_ER and settings.startup["af-prod-enable-rails"].value and data.raw["rail-support"][item_name]
    or settings.startup["af-prod-enable-rail-stops-signals"].value and data.raw["train-stop"][item_name]
    or settings.startup["af-prod-enable-rail-stops-signals"].value and data.raw["rail-signal"][item_name]
    or settings.startup["af-prod-enable-rail-stops-signals"].value and data.raw["rail-chain-signal"][item_name]

    or settings.startup["af-prod-enable-trains"].value and data.raw["locomotive"][item_name]
    or settings.startup["af-prod-enable-trains"].value and data.raw["artillery-wagon"][item_name]
    or settings.startup["af-prod-enable-trains"].value and data.raw["cargo-wagon"][item_name]
    or settings.startup["af-prod-enable-trains"].value and data.raw["fluid-wagon"][item_name]
    or settings.startup["af-prod-enable-vehicles"].value and data.raw["car"][item_name]
    or settings.startup["af-prod-enable-vehicles"].value and data.raw["spider-vehicle"][item_name]

    or settings.startup["af-prod-enable-fluid-sys"].value and data.raw["pipe"][item_name]
    or settings.startup["af-prod-enable-fluid-sys"].value and data.raw["pipe-to-ground"][item_name]
    or settings.startup["af-prod-enable-fluid-sys"].value and data.raw["pump"][item_name]
    or settings.startup["af-prod-enable-fluid-sys"].value and data.raw["offshore-pump"][item_name]
    or settings.startup["af-prod-enable-fluid-sys"].value and data.raw["storage-tank"][item_name]

    ----- Buildings
    or settings.startup["af-prod-enable-miners"].value and data.raw["mining-drill"][item_name]
    or settings.startup["af-prod-enable-assemblers"].value and data.raw["assembling-machine"][item_name]
    or settings.startup["af-prod-enable-assemblers"].value and data.raw["furnace"][item_name]
    or settings.startup["af-prod-enable-assemblers"].value and data.raw["rocket-silo"][item_name]
    or settings.startup["af-prod-enable-assemblers"].value and data.raw["lab"][item_name]
    or have_SA and settings.startup["af-prod-enable-assemblers"].value and data.raw["agricultural-tower"][item_name]
    or settings.startup["af-prod-enable-roboports"].value and data.raw["roboport"][item_name]

    or settings.startup["af-prod-enable-solar-acc"].value and data.raw["solar-panel"][item_name]
    or settings.startup["af-prod-enable-solar-acc"].value and data.raw["accumulator"][item_name]
    or settings.startup["af-prod-enable-boiler-gen"].value and data.raw["reactor"][item_name]
    or settings.startup["af-prod-enable-boiler-gen"].value and data.raw["heat-pipe"][item_name]
    or settings.startup["af-prod-enable-boiler-gen"].value and data.raw["boiler"][item_name]
    or settings.startup["af-prod-enable-boiler-gen"].value and data.raw["generator"][item_name]
    or settings.startup["af-prod-enable-boiler-gen"].value and data.raw["burner-generator"][item_name]
    or have_SA and settings.startup["af-prod-enable-boiler-gen"].value and data.raw["fusion-reactor"][item_name]
    or have_SA and settings.startup["af-prod-enable-boiler-gen"].value and data.raw["fusion-generator"][item_name]

    or settings.startup["af-prod-enable-turrets"].value and item_name:find("turret", 1, true) and placable
    or settings.startup["af-prod-enable-radar"].value and data.raw["radar"][item_name]
    or settings.startup["af-prod-enable-walls"].value and data.raw["wall"][item_name]
    or settings.startup["af-prod-enable-walls"].value and data.raw["gate"][item_name]

    or settings.startup["af-prod-enable-spaceage"].value and data.raw["cargo-landing-pad"][item_name]
    or have_SA and settings.startup["af-prod-enable-spaceage"].value and data.raw["cargo-bay"][item_name]
    or have_SA and settings.startup["af-prod-enable-spaceage"].value and data.raw["space-platform-starter-pack"][item_name]
    or have_SA and settings.startup["af-prod-enable-spaceage"].value and data.raw["thruster"][item_name]
    or have_SA and settings.startup["af-prod-enable-spaceage"].value and data.raw["asteroid-collector"][item_name]

    ----- Misc
    or settings.startup["af-prod-enable-modules"].value and data.raw["module"][item_name]
    or settings.startup["af-prod-enable-modules"].value and data.raw["beacon"][item_name]
    or settings.startup["af-prod-enable-poles"].value and data.raw["electric-pole"][item_name]
    or settings.startup["af-prod-enable-poles"].value and have_SA and data.raw["lightning-attractor"][item_name]
    or settings.startup["af-prod-enable-combinators"].value and item_name:find("combinator", 1, true) and placable
    or settings.startup["af-prod-enable-tiles"].value and data.raw["tile"][item_name]
    or settings.startup["af-prod-enable-repair"].value and data.raw["repair-tool"][item_name]
    or settings.startup["af-prod-enable-satellites"].value and item_name:find("satellite", 1, true) and launchable
    or settings.startup["af-prod-enable-satellites"].value and item_name:find("-probe", 1, true) and launchable -- SE probes

    ----- Armor & Ammo
    or settings.startup["af-prod-enable-armor"].value and data.raw["armor"][item_name]
    or settings.startup["af-prod-enable-armor"].value and equipment
    or settings.startup["af-prod-enable-guns"].value and data.raw["gun"][item_name]
    or settings.startup["af-prod-enable-ammo"].value and data.raw["ammo"][item_name]
    or settings.startup["af-prod-enable-ammo"].value and data.raw["land-mine"][item_name]
    or settings.startup["af-prod-enable-ammo"].value and data.raw["capsule"][item_name]
  )
  return not not result
end


function enable_total_productivity()
  -- log("--- TotalProductivity1 ---")

  local item_name, success, result
  for recipe_name, recipe in pairs(data.raw.recipe) do
    item_name = recipe.results and #recipe.results==1 and recipe.results[1].name

    success, call_result = pcall(should_enable_prod, item_name)
    if not success then
      error(serpent.line({
        recipe = recipe,
        error = call_result,
      }))
    end

    -- log("Adding Prod to "..recipe_name.." => "..serpent.line(item_name)..": "..serpent.line(call_result))
    -- log(serpent.line(recipe))

    if call_result then
      recipe.allow_productivity = true
      -- Hooray, it finally seems so simple now
      -- for _, module in pairs(data.raw.module) do
      --   if adds_productivity(module) and is_restricted(module, recipe_name) then
      --     table.insert(module.limitation, recipe_name)
      --   end
      -- end
    end
  end
  -- log("--- TotalProductivity2 ---")
end
