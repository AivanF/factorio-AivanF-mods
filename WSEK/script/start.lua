local Lib = require("script/event_lib")
local lib = Lib.new()

local function main(event)
	if not settings.global["sekw-start-help"].value then return end

	local player = game.players[event.player_index]
	if not player.get_main_inventory() then return end

	local inventory = player.get_inventory(defines.inventory.character_armor)
	inventory.insert{name="power-armor-mk2"}

	local suit = player.get_inventory(defines.inventory.character_armor)[1].grid
	suit.put({name = "personal-roboport-mk2-equipment"})
	suit.put({name = "personal-roboport-mk2-equipment"})
	suit.put({name = "battery-mk2-equipment"})
	suit.put({name = "battery-mk2-equipment"})
	suit.put({name = "night-vision-equipment"})
	suit.put({name = "exoskeleton-equipment"})
	suit.put({name = "exoskeleton-equipment"})
	for _ = 1, 12 do
		suit.put({name = "solar-panel-equipment"})
	end

	player.get_inventory(defines.inventory.character_guns).clear()
	player.get_inventory(defines.inventory.character_ammo).clear()
	player.get_inventory(defines.inventory.character_guns).insert{name = "pistol", count = 1}
	player.get_inventory(defines.inventory.character_ammo).insert{name = "piercing-rounds-magazine", count=200}
	player.get_inventory(defines.inventory.character_guns).insert{name = "submachine-gun", count=1}
	player.get_inventory(defines.inventory.character_ammo).insert{name = "armor-piercing-rifle-magazine", count=200}

	player.force.technologies['worker-robots-speed-1'].researched = true
	player.force.technologies['worker-robots-speed-2'].researched = true
	player.force.technologies['worker-robots-speed-3'].researched = true

	player.force.technologies['worker-robots-storage-1'].researched = true
	player.force.technologies['worker-robots-storage-2'].researched = true
	player.force.technologies['worker-robots-storage-3'].researched = true

	player.insert{name="construction-robot", count=50}

	-- player.insert{name="warptorio-warpmodule", count=2}
	-- player.insert{name="effectivity-module-7", count=2}

	player.insert{name="processed-fuel", count=100}
	player.insert{name="burner-mining-drill", count=10}
	player.insert{name="steel-furnace", count=10}
	player.insert{name="gun-turret", count=40}
	player.insert{name="armor-piercing-rifle-magazine", count=200}
end

local function player_created(event)
	main(event)
end

local function cutscene_cancelled(event)
	if remote.interfaces["freeplay"] then
		main(event)
	end
end

lib:on_event(defines.events.on_player_created, player_created)
lib:on_event(defines.events.on_cutscene_cancelled, cutscene_cancelled)

return lib