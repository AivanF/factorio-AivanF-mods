local Lib = require("script/event_lib")
local mod_gui = require("mod-gui")
lib_gen = Lib.new()

local gui_update_rate = 15
local gui_btn_name = "titan_gui"
local main_frame_name = "wh40k_titans_gui_frame"

local act_gui_toggle = shared.mod_prefix.."gui-toggle"
local act_show_object = shared.mod_prefix.."gui-show-object"
local act_toggle_ammo_count = "titan_toggle_ammo_count"

local tab_ttn = "ttn"
local tab_spl = "spl"
local tab_height = 256
local small_cell_width = 48
local longer_cell_width = 96

local tables_specs = {
  [tab_ttn] = {
    columns = {
      { name = "main", width = small_cell_width },
      { name = "driver", width = longer_cell_width },
      { name = "hp", width = small_cell_width },
      { name = "vs", width = small_cell_width },
    },
  },
  [tab_spl] = {
    columns = {
      { name = "main", width = small_cell_width },
      { name = "driver", width = longer_cell_width },
      { name = "hp", width = small_cell_width },
      { name = "weight", width = small_cell_width },
    },
  },
}

for k = 1, 6 do
  table.append(tables_specs[tab_ttn].columns, {
    name = "gun"..k, width = small_cell_width,
    caption = ""..k,
  })
end

for i, ammo_name in ipairs(shared.ammo_list) do
  table.append(tables_specs[tab_spl].columns, {
    name = "ammo_"..ammo_name, width = small_cell_width,
    caption = ""..i,
  })
end


function lib_gen.setup_gui_btn(player_index)
  local player = game.get_player(player_index)
  local button_flow = mod_gui.get_button_flow(player)
  if button_flow[gui_btn_name] == nil then
    local btn = button_flow.add{
      type="sprite-button", name=gui_btn_name, sprite=shared.mod_prefix.."gui-btn",
      style=mod_gui.button_style, tags={action=act_gui_toggle},
      tooltip = {"WH40k-Titans-gui.open-gen-ui-tooltip"},
    }
  end
end


local function set_cell_flow_style(cell, col_spec)
  -- TODO: use style prototype
  cell.style.minimal_height = 32
  cell.style.minimal_width = col_spec.width
  cell.style.maximal_width = col_spec.width
  cell.style.horizontal_align = "center"
  cell.style.vertical_align = "center"
end


local function preprocess_entity_name(entity_name)
  -- entity_name = entity_name:replace("$". "")
  -- entity_name = entity_name:replace("-0". "")
  entity_name = entity_name:gsub(string.gsub("-0-_-solid", "%p", "%%%0").."$", "")
  entity_name = entity_name:gsub(string.gsub("-0", "%p", "%%%0").."$", "")
  return entity_name
end


local function get_driver_name(entity)
  local driver = entity.get_driver()
  -- TODO: maybe show the passanger too??
  if driver then
    local dr_name, dr_desc
    if driver.object_name == "LuaPlayer" then
      -- Bodyless / God mode
    elseif driver.object_name == "LuaEntity" then
      if driver.type == "character" then
        if driver.player then
          -- A usual player with body
          dr_name = driver.player.name
          dr_desc = {"WH40k-Titans-gui.player-driver-desc"}
        else
          -- A character with no player, assuming AAI PV
          dr_name = {"WH40k-Titans-gui.aai-pv-driver"}
          dr_desc = {"WH40k-Titans-gui.aai-pv-driver-desc"}
        end
      else
        -- Unknown, probably not possible
        dr_name = {"WH40k-Titans-gui.unknown-driver"}
        dr_desc = serpent.line({
          -- Some debug info, JIC
          driver_object_name = driver.object_name,
          driver_name = driver.name,
        })
      end
    else
      -- Unknown, surely not possible
      dr_name = {"WH40k-Titans-gui.unknown-driver"}
      dr_desc = serpent.line({
        -- Some debug info, JIC
        driver_object_name = driver.object_name,
        driver_name = driver.name,
      })
    end

    return dr_name, dr_desc
  else
    return {"WH40k-Titans-gui.no-driver"}, {"WH40k-Titans-gui.no-driver"}
  end
end


local function create_object_tab(guiobj, tab_name)
  local table_spec = tables_specs[tab_name]
  local tab_info = {
    name = tab_name,
    rows = {}, -- unit_number => column_number => cell_flow_element
  }
  guiobj.object_tabs[tab_name] = tab_info

  -- https://lua-api.factorio.com/latest/concepts.html#ScrollPolicy
  -- "never" / "dont-show-but-allow-scrolling" / "always" / "auto" / "auto-and-reserve-space"

  tab_info.scr = guiobj.pane.add{
    type = "scroll-pane", name = tab_name.."scroller",
    horizontal_scroll_policy = "auto",
    vertical_scroll_policy = "always",
  }
  tab_info.scr.style.minimal_width = 512
  tab_info.scr.style.minimal_height = tab_height
  tab_info.scr.style.maximal_height = tab_height
  tab_info.table = tab_info.scr.add{type="table", name="table", column_count=#table_spec.columns, style="filter_slot_table"}

  -- Header line
  local cell
  for i, col_spec in ipairs(table_spec.columns) do
    cell = tab_info.table.add{ type = "flow", name = "caption_"..i }
    set_cell_flow_style(cell, col_spec)
    if col_spec.caption then
      cell.add{ type="label", caption={"?", {"WH40k-Titans-gui.column-"..col_spec.caption}, col_spec.caption}}
    else
      cell.add{ type="label", caption={"?", {"WH40k-Titans-gui.column-"..col_spec.name}, col_spec.name}}
    end
  end

  -- Test rows
  -- for i = 1, 2*#table_spec.columns do
  --   tab_info.table.add{type="sprite-button", name="btn_"..i, sprite=shared.mod_prefix.."gui-btn", style=mod_gui.button_style}
  -- end

  return tab_info.scr
end

local indexers = {}
indexers.ttn = function ()
  return ctrl_data.titans
end
indexers.spl = function ()
  return ctrl_data.supplier_index
end

local row_filler = {}

row_filler.ttn = function (row_info)
  local titan_info = ctrl_data.titans[row_info.unit_number]

  row_info.cells.main.add{
    type="sprite-button", sprite=("entity/"..titan_info.entity.name),
    tooltip={"entity-name."..preprocess_entity_name(titan_info.entity.name)},
    tags={action=act_show_object, tab_name=tab_ttn, unit_number=row_info.unit_number},
  }
  row_info.cells.driver.add{type="label", name="viz", caption=""}
  row_info.cells.hp.add{
    type="sprite-button", name="viz", sprite="item/"..shared.frame_part,
    tooltip=make_titled_text(
      {"WH40k-Titans-gui.health"},
      {"WH40k-Titans-gui.percent-toggle-tooltip"}
    ),
    tags={action=act_toggle_ammo_count},
  }
  row_info.cells.vs.add{
    type="sprite-button", name="viz", sprite="item/"..shared.void_shield,
    tooltip=make_titled_text(
      {"WH40k-Titans-gui.vs-value"},
      {"WH40k-Titans-gui.percent-toggle-tooltip"}
    ),
    tags={action=act_toggle_ammo_count},
  }

  for k, cannon in pairs(titan_info.guns) do
    row_info.cells["gun"..k].add{
      type="sprite-button", name="viz", sprite=("recipe/"..shared.mod_prefix..cannon.name),
      tooltip=make_titled_text(
        {"item-name."..shared.mod_prefix..cannon.name},
        shared.get_weapon_descr(shared.weapons[cannon.name])
      ),
      tags={action=act_toggle_ammo_count},
    }
  end
end

row_filler.spl = function (row_info)
  local supplier_info = ctrl_data.supplier_index[row_info.unit_number]

  row_info.cells.main.add{
    type="sprite-button", sprite=("entity/"..supplier_info.entity.name),
    tooltip={"entity-name."..preprocess_entity_name(supplier_info.entity.name)},
    tags={action=act_show_object, tab_name=tab_spl, unit_number=row_info.unit_number},
  }
  row_info.cells.driver.add{type="label", name="viz", caption=""}
  row_info.cells.hp.add{
    type="sprite-button", name="viz", sprite="item/"..shared.frame_part,
    tooltip=make_titled_text(
      {"WH40k-Titans-gui.health"},
      {"WH40k-Titans-gui.percent-toggle-tooltip"}
    ),
    tags={action=act_toggle_ammo_count},
  }
  row_info.cells.weight.add{
    type="sprite-button", name="viz", sprite=shared.mod_prefix.."weight",
    tooltip=make_titled_text(
      {"WH40k-Titans-gui.column-weight"},
      {"WH40k-Titans-gui.percent-toggle-tooltip"}
    ),
    tags={action=act_toggle_ammo_count},
  }

  for i, ammo_name in ipairs(shared.ammo_list) do
    row_info.cells["ammo_"..ammo_name].add{
      type="sprite-button", name="viz", sprite="item/"..ammo_name,
      tooltip=make_titled_text(
        {"item-name."..ammo_name},
        {"item-description."..ammo_name}
      ),
    }
  end
end


local row_updater = {}

row_updater.ttn = function (row_info, player_settings)
  local titan_info = ctrl_data.titans[row_info.unit_number]

  local dr_name, dr_desc = get_driver_name(titan_info.entity)
  row_info.cells.driver.viz.caption = dr_name
  row_info.cells.driver.viz.tooltip = dr_desc

  if player_settings.percent_ammo then
    row_info.cells.hp.viz.number = math.floor(100 * titan_info.entity.get_health_ratio())
    row_info.cells.vs.viz.number = math.floor(100 * titan_info.shield / lib_ttn.get_unit_shield_max_capacity(titan_info))
  else
    row_info.cells.hp.viz.number = math.floor(titan_info.entity.health)
    row_info.cells.vs.viz.number = math.floor(titan_info.shield)
  end
  -- TODO: show red icon if hp/vs is low

  for k, cannon in pairs(titan_info.guns) do
    if shared.weapons[cannon.name].ammo then
      if player_settings.percent_ammo then
        row_info.cells["gun"..k].viz.number = math.floor(100 *(cannon.ammo_count or 0) /shared.weapons[cannon.name].inventory)
      else
        row_info.cells["gun"..k].viz.number = cannon.ammo_count or 0
      end
    end
  end
end

row_updater.spl = function (row_info, player_settings)
  local supplier_info = ctrl_data.supplier_index[row_info.unit_number]

  local dr_name, dr_desc = get_driver_name(supplier_info.entity)
  row_info.cells.driver.viz.caption = dr_name
  row_info.cells.driver.viz.tooltip = dr_desc

  if player_settings.percent_ammo then
    row_info.cells.hp.viz.number = math.floor(100 * supplier_info.entity.get_health_ratio())
    row_info.cells.weight.viz.number = math.floor(100*lib_spl.count_weight(supplier_info)/lib_spl.get_max_weight(supplier_info))
  else
    row_info.cells.hp.viz.number = math.floor(supplier_info.entity.health)
    row_info.cells.weight.viz.number = lib_spl.count_weight(supplier_info)
  end

  for i, ammo_name in ipairs(shared.ammo_list) do
    row_info.cells["ammo_"..ammo_name].viz.number = supplier_info.inventory[ammo_name] or 0
  end
end


local function create_object_row(guiobj, tab_name, unit_number)
  local table_spec = tables_specs[tab_name]
  local tab_info = guiobj.object_tabs[tab_name]
  local row_info = {
    unit_number = unit_number,
    cells = {}, -- column_number => cell_flow_element
  }

  tab_info.rows[unit_number] = row_info

  local cell
  for i, col_spec in ipairs(table_spec.columns) do
    cell = tab_info.table.add{ type = "flow", name = "cell_"..unit_number.."_"..i }
    set_cell_flow_style(cell, col_spec)
    row_info.cells[i] = cell
    row_info.cells[col_spec.name] = cell
  end

  return row_info
end


local function update_object_tab(guiobj, tab_name)
  local tab_info = guiobj.object_tabs[tab_name]
  local object_indexer = indexers[tab_name]()
  local should_show, row_info
  local player_settings = ctrl_data.by_player[guiobj.player.index] or {}

  for unit_number, object_info in pairs(object_indexer) do
    should_show = object_info.entity.force == guiobj.player.force
    if not tab_info.rows[unit_number] then
      if should_show then
        row_info = create_object_row(guiobj, tab_name, unit_number)
        row_filler[tab_name](row_info)
      end
    end
  end

  for _, row_info in pairs(tab_info.rows) do
    object_info = object_indexer[row_info.unit_number]
    should_show = object_info and object_info.entity.valid and object_info.entity.force == guiobj.player.force
    if not should_show then
      -- TODO: remove row info and cells
    else
      row_updater[tab_name](row_info, player_settings)
    end
  end
end


function lib_gen.create_main_window(player)
  -- for tab_name, table_spec in pairs(tables_specs) do
  --   local sm = 0
  --   for i, col_spec in ipairs(table_spec.columns) do
  --     sm = sm + col_spec.width
  --   end
  --   game.print("Table "..tab_name.." width = "..sm)
  -- end

  local guiobj = {
    player = player,
    main_frame = nil,
    object_tabs = {},
  }

  ctrl_data.gen_ui[player.index] = guiobj
  if player.gui.screen[main_frame_name] then
    player.gui.screen[main_frame_name].destroy()
  end

  main_frame = player.gui.screen.add{
    type="frame", name=main_frame_name,
    -- caption={"WH40k-Titans-gui.gen-ui-title"},
    direction="vertical",
  }
  main_frame.style.minimal_width = 320
  main_frame.style.maximal_width = 548
  main_frame.style.minimal_height = tab_height + 96
  main_frame.style.maximal_height = tab_height + 96

  main_frame.auto_center = true
  player.opened = main_frame
  guiobj.main_frame = main_frame

  local flowtitle = main_frame.add{ type = "flow", name = "title" }
  local title = flowtitle.add{ type = "label", style = "frame_title", caption={"WH40k-Titans-gui.gen-ui-title"} }
  title.drag_target = main_frame
  local pusher = flowtitle.add{ type = "empty-widget", style = "draggable_space_header" }
  pusher.style.vertically_stretchable = true
  pusher.style.horizontally_stretchable = true
  pusher.drag_target = main_frame
  pusher.style.maximal_height = 24
  flowtitle.add{ type="sprite-button", style="frame_action_button", tags={action=act_gui_toggle}, sprite="utility/close_white" }

  guiobj.pane = main_frame.add{type="tabbed-pane"}

  guiobj.ttn_tab = guiobj.pane.add{type="tab", caption="Titans"}
  guiobj.pane.add_tab(guiobj.ttn_tab, create_object_tab(guiobj, tab_ttn))

  guiobj.spl_tab = guiobj.pane.add{type="tab", caption="Suppliers"}
  guiobj.pane.add_tab(guiobj.spl_tab, create_object_tab(guiobj, tab_spl))
end


local function update_genui(guiobj)
  for tab_name, table_spec in pairs(tables_specs) do
    update_object_tab(guiobj, tab_name)
  end
end


lib_gen:on_event(defines.events.on_gui_click, function(event)
  local player = game.get_player(event.player_index)
  local main_frame = player.gui.screen[main_frame_name]
  local action = event.element and event.element.valid and event.element.tags.action

  if action == act_gui_toggle then
    if main_frame then
      main_frame.destroy()
      return
    else
      lib_gen.create_main_window(player)
    end

  elseif action == act_show_object then
    -- tab_name=tab_ttn, unit_number=row_info.unit_number
    local object_info = indexers[event.element.tags.tab_name]()[event.element.tags.unit_number]
    if object_info and object_info.entity.valid then
      player.zoom_to_world(object_info.entity.position, 1 / (1 + (object_info.class or 10)/10), object_info.entity)
    end
  end
end)


local function update_guis()
  for player_index, guiobj in pairs(ctrl_data.gen_ui) do
    if not guiobj.player.valid or not guiobj.main_frame.valid then
      ctrl_data.gen_ui[player_index] = nil
    else
      update_genui(guiobj)
    end
  end
end


lib_gen:on_event(defines.events.on_player_created, function(event)
  lib_gen.setup_gui_btn(event.player_index)
end)

lib_ttn:on_nth_tick(gui_update_rate, update_guis)

return lib_gen