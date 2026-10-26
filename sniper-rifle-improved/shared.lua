local shared = {}
shared.modName = "sniper-rifle-improved"
shared.ammoCategory = "rifle-bullet"
shared.magazine1 = "sniper-magazine-1"
shared.magazine2 = "sniper-magazine-2"
shared.magazine3 = "sniper-magazine-3"
shared.rifle1 = "carbine-rifle"
shared.rifle2 = "sniper-rifle"
shared.earlySetting = "af-sniper-early-research"

-- Data stage only. With the early research setting, recipes moved before steel/explosives research
-- get cheaper ingredients: 1 steel => 5 iron + 5 copper, explosives => coal
function shared.ingredients(list, replace)
    local early = replace and settings.startup[shared.earlySetting].value
    local result, by_name = {}, {}
    local function add(name, amount)
        if by_name[name] then
            by_name[name].amount = by_name[name].amount + amount
        else
            by_name[name] = {type="item", name=name, amount=amount}
            table.insert(result, by_name[name])
        end
    end
    for _, ingr in pairs(list) do
        if early and ingr[1] == "steel-plate" then
            add("iron-plate", ingr[2] * 5)
            add("copper-plate", ingr[2] * 5)
        elseif early and ingr[1] == "explosives" then
            add("coal", ingr[2])
        else
            add(ingr[1], ingr[2])
        end
    end
    return result
end

-- Data stage only. Unlocks the recipe one Military research earlier with the early research setting
function shared.unlock(tech, early_tech, recipe)
    if settings.startup[shared.earlySetting].value then tech = early_tech end
    table.insert(data.raw.technology[tech].effects, {type = "unlock-recipe", recipe = recipe})
end
return shared