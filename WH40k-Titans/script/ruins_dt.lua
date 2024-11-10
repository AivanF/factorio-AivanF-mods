local function add_weapon_and_ammo(detailses, ammo, weapon_name)
    table.insert(detailses, shared.weapons[weapon_name].ingredients)
    table.insert(ammo, {
      name =shared.weapons[weapon_name].ammo,
      count=shared.weapons[weapon_name].inventory * (0.2 + 0.9*math.random())
    })
end

local function add_weapon_grade_1(detailses, ammo)
  local value = math.random()
  if value < 1/4 then
    add_weapon_and_ammo(detailses, ammo, shared.weapon_inferno)
  elseif value < 2/4 then
    add_weapon_and_ammo(detailses, ammo, shared.weapon_vulcanbolter)
  elseif value < 3/4 then
    add_weapon_and_ammo(detailses, ammo, shared.weapon_plasma_blastgun)
  else
    add_weapon_and_ammo(detailses, ammo, shared.weapon_turbolaser)
  end
end

local function add_weapon_grade_2(detailses, ammo)
  local value = math.random()
  if value < 1/4 then
    add_weapon_and_ammo(detailses, ammo, shared.weapon_gatling_blaster)
  elseif value < 2/4 then
    add_weapon_and_ammo(detailses, ammo, shared.weapon_volcano_cannon)
  elseif value < 3/4 then
    add_weapon_and_ammo(detailses, ammo, shared.weapon_laserblaster)
  else
    add_weapon_grade_1(detailses, ammo)
  end
end

local function add_weapon_grade_2_top(detailses, ammo)
  local value = math.random()
  if value < 1/3 then
    add_weapon_and_ammo(detailses, ammo, shared.weapon_missiles)
  elseif value < 2/3 then
    add_weapon_and_ammo(detailses, ammo, shared.weapon_apocalypse_missiles)
  else
    add_weapon_grade_2(detailses, ammo)
  end
end

local function add_weapon_grade_3(detailses, ammo)
  local value = math.random()
  if value < 1/3 then
    add_weapon_and_ammo(detailses, ammo, shared.weapon_plasma_sunfury)
  elseif value < 2/3 then
    add_weapon_and_ammo(detailses, ammo, shared.weapon_volkite_destructor)
  else
    add_weapon_grade_2(detailses, ammo)
  end
end



local function fill_class_1(detailses, ammo) -- WarHound
  table.insert(detailses, shared.titan_types[shared.titan_warhound].ingredients)
  add_weapon_grade_1(detailses, ammo)
  add_weapon_grade_1(detailses, ammo)
end

local function fill_class_2(detailses, ammo) -- Reaver
  table.insert(detailses, shared.titan_types[shared.titan_reaver].ingredients)
  add_weapon_grade_2(detailses, ammo)
  add_weapon_grade_2(detailses, ammo)
  add_weapon_grade_2_top(detailses, ammo)
end

local function fill_class_3(detailses, ammo) -- WarLord
  table.insert(detailses, shared.titan_types[shared.titan_reaver].ingredients)
  add_weapon_grade_2(detailses, ammo)
  add_weapon_grade_2(detailses, ammo)
  add_weapon_grade_2_top(detailses, ammo)
  add_weapon_grade_2_top(detailses, ammo)
end

local function fill_supplier(detailses, ammo) -- Supplier AirCraft
  for _, obj in pairs(prototypes.recipe[shared.aircraft_supplier].ingredients) do
    table.insert(detailses, {{obj.name, obj.amount}})
  end
  for name, weight in pairs(shared.ammo_weights) do
    if math.random() < 1 / (weight+1) then
      table.insert(ammo, {
        name=name,
        count=math.floor((3600 / weight) * (0.3 + 0.8*math.random()))
      })
    end
  end
end



local sized_fillers = {
  {weight=4, img=shared.mod_prefix.."corpse-1", act=fill_class_1},
  -- {3, __TODO__, fill_class_2},
  {weight=2, img=shared.mod_prefix.."corpse-3", act=fill_class_3},
  -- {1, __TODO__, fill_class_4},
  {weight=2, img=shared.mod_prefix.."corpse-supplier", act=fill_supplier},
}

local total_size = 0
for _, obj in pairs(sized_fillers) do
  total_size = total_size + obj.weight
end

function lib_ruins.create_random_ruin_info(position)
  local detailses = {}
  local ammo = {}
  local img

  local value = math.random() * total_size
  for _, obj in ipairs(sized_fillers) do
    if value < obj.weight then
      obj.act(detailses, ammo)
      img = obj.img
      break
    else
      value = value - obj.weight
    end
  end

  if not img then
    error(shared.mod_prefix.."create_random_ruin_info failed")
  end

  local ruin_info = {
    died = false,
    img = img,
    position = position,
    entity = nil,
    details = merge_ingredients_doubles(iter_chain(detailses)),
    ammo = merge_ingredients_doubles(ammo),
  }
  return ruin_info
end
