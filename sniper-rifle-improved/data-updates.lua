local shared = require("shared")

local round_by = function(value, base)
    return math.floor(value/base + 0.5) * base
end

damage_gain = settings.startup["af-sniper-damage-gain"].value

local function addDamageEffect(technology)
    local effects = data.raw["technology"][technology].effects
    effects[#effects + 1] = {
        type = "ammo-damage",
        ammo_category = shared.ammoCategory,
        modifier = round_by(effects[#effects - (#effects - 1)].modifier * damage_gain, 0.05)
    }
end

addDamageEffect("physical-projectile-damage-1")
addDamageEffect("physical-projectile-damage-2")
addDamageEffect("physical-projectile-damage-3")
addDamageEffect("physical-projectile-damage-4")
addDamageEffect("physical-projectile-damage-5")
addDamageEffect("physical-projectile-damage-6")
addDamageEffect("physical-projectile-damage-7")

if mods["warptorio2"] then
    log(serpent.block(data.raw["technology"]))
    addDamageEffect("warptorio-physdmg-1")
    -- // Seems like they just copy effects
    -- addDamageEffect("warptorio-physdmg-2")
    -- addDamageEffect("warptorio-physdmg-3")
end

local function addSpeedEffect(technology)
    local effects = data.raw["technology"][technology].effects
    effects[#effects + 1] = {
        type = "gun-speed",
        ammo_category = shared.ammoCategory,
        modifier = effects[#effects - (#effects - 1)].modifier
    }
end

addSpeedEffect("weapon-shooting-speed-1")
addSpeedEffect("weapon-shooting-speed-2")
addSpeedEffect("weapon-shooting-speed-3")
addSpeedEffect("weapon-shooting-speed-4")
addSpeedEffect("weapon-shooting-speed-5")
addSpeedEffect("weapon-shooting-speed-6")
