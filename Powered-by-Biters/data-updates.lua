local floor,ceil,sqrt = math.floor,math.ceil,math.sqrt

local pow = math.pow

local fishyield, num, entry, flag = 0, 0

--[[
for fish,proto in pairs(data.raw.fish) do
	entry = biter_bites_fish_capsules[fish]
	log("fish,proto of "..fish)
	log(serpent.block(proto))
	if entry then
		flag = false
		if proto.minable.result == entry then
			fishyield = fishyield + proto.minable.count or 1
			flag = true
		else
			for _,e in pairs(proto.minable.results) do
				if e.type=="item" and (e.name or e[1])==entry then
					fishyield = fishyield + (e.amount or e[2] or ((e.amount_min or 0) + (e.amount_max or 1))/2)
					flag = true
				end
			end
		end
		if flag then num = num + 1 end
	end
end
--]]
for _,c in pairs(biter_bites_fish_capsules) do
	fishyield = fishyield + c
	num = num + 1
end

fishyield = fishyield/num
fishyield = fishyield*fishyield

function corpsemine(name,yield,difficulty,count)
	local corpse=data.raw.corpse[name]
	if corpse==nil then log("Biter-Bites encountered an error with "..name.."; skipping") end
	corpse.selectable_in_game=true
	corpse.time_before_removed = 60*60*5
	if not corpse.minable then
		corpse.minable=
			{mining_particle = "guts-entrails-particle-small-medium",
			 mining_time = difficulty,
			 results={{name=yield,amount_min=1,amount_max=count, probability = (count)/(count+2)}}
			 }
		corpse.mining_sound = { variations = {
								{ filename = "__core__/sound/axe-meat-1.ogg", volume = 0.4 },
								{ filename = "__core__/sound/axe-meat-2.ogg", volume = 0.4 },
								{ filename = "__core__/sound/axe-meat-3.ogg", volume = 0.4 },
								{ filename = "__core__/sound/axe-meat-4.ogg", volume = 0.4 },
								{ filename = "__core__/sound/axe-meat-5.ogg", volume = 0.4 },
								{ filename = "__core__/sound/axe-meat-6.ogg", volume = 0.4 },
							  } }

	else
		if not corpse.minable.results then corpse.minable.results = {} end
		local single,multiple = corpse.minable.result, corpse.minable.results
		if single then
			multiple[#multiple+1]={name=single.result,amount=single.result}
		end
		multiple[#multiple+1]={name=yield,amount_min=1,amount_max=count, probability = (count)/(count+2)}
	end
	--log(name..serpent.block(corpse.minable))
end

local corpsedrop = {}
for name,e in pairs(data.raw.unit) do
	if string.find(name,"biter") then
		if e.corpse then
			num = ceil((e.max_health+fishyield)^.6/6)
			if corpsedrop[e.corpse] then
				if corpsedrop[e.corpse].meat=="raw-meat" then
					if corpsedrop[e.corpse].amount > num then corpsedrop[e.corpse].amount=num end
				else corpsedrop[e.corpse].amount=0 end
			else
				corpsedrop[e.corpse]={meat="raw-meat",amount=num}
			end
		end
	elseif string.find(name,"spitter") then
		if e.corpse then
			num = ceil((e.max_health+fishyield)^.6/5)
			if corpsedrop[e.corpse] then
				if corpsedrop[e.corpse].meat=="raw-meat" then
					if corpsedrop[e.corpse].amount > num then corpsedrop[e.corpse].amount=num end
				else corpsedrop[e.corpse].amount=0 end
			else
				corpsedrop[e.corpse]={meat="raw-meat", amount=num}
			end
		end
	end
end

for name,e in pairs(corpsedrop) do
	if e.amount>0 then corpsemine(name,e.meat,.25*ceil(((e.amount^.7)-1)*2),e.amount) end
end
