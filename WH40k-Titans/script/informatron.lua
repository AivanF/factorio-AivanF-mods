shared = require("shared")

remote.add_interface(shared.mod_name, {
  informatron_menu = function(data)
    return mymod_menu(data.player_index)
  end,
  informatron_page_content = function(data)
    return mymod_page_content(data.page_name, data.player_index, data.element)
  end
})

function mymod_menu(player_index)
  return {
    lore = 1,
    exploration = 1,
    assembling = 1,
    weapon_rules = 1,
    titan_usage = 1,
    supplier_usage = 1,
    ai = 1,
    other = 1,
  }
end

local ntt = " " -- No ToolTip!!! Why nil doesn't f*ing work??

function mymod_page_content(page_name, player_index, element)
  if page_name == shared.mod_name then
    element.add{type="button", name="image_1", style=shared.mod_prefix.."inf-AT-logo"}
    element.add{type="label", name="text_1", tooltip=ntt, caption={"WH40k-Titans-informatron.Intro"}}

  elseif page_name == "lore" then
    element.add{type="label", name="text_1", tooltip=ntt, caption={"WH40k-Titans-informatron.Lore1"}}
    element.add{type="label", name="empty_1", caption=" "}
    element.add{type="button", name="image_1", style=shared.mod_prefix.."inf-lore-art"}
    element.add{type="label", name="empty_2", caption=" "}
    element.add{type="label", name="text_2", tooltip=ntt, caption={"WH40k-Titans-informatron.Lore2"}}
    element.add{type="label", name="empty_3", caption=" "}

  elseif page_name == "exploration" then
    element.add{type="label", name="text_0", tooltip=ntt, caption={"WH40k-Titans-informatron.Exploration"}}
    element.add{type="label", name="empty_0", caption=" "}

    element.add{type="label", name="text_extract", tooltip=ntt, caption={"WH40k-Titans-informatron.Exploration-Extract"}}
    element.add{type="label", name="empty_extract1", caption=" "}
    element.add{type="button", name="image_extract", style=shared.mod_prefix.."inf-extractor"}
    element.add{type="label", name="empty_extract2", caption=" "}

    element.add{type="label", name="text_revlab", tooltip=ntt, caption={"WH40k-Titans-informatron.Exploration-RevLab"}}
    local flow = element.add{ type = "flow", name = "reveng_btn_placeholder" }
    -- flow.style.minimal_height = 64
    flow.style.minimal_width = 512
    flow.style.horizontal_align = "center"
    flow.style.vertical_align = "center"
    flow.add{
      type="sprite-button", sprite="af-reverse-lab-worth",
      tooltip={"shortcut-description.af-reverse-lab-see-worth"},
      tags={action="reverse-lab-open-worth-explain"},
    }
    element.add{type="label", name="empty_revlab", caption=" "}

    element.add{type="label", name="text_research", tooltip=ntt, caption={"WH40k-Titans-informatron.Exploration-Research"}}
    element.add{type="label", name="empty_research", caption=" "}

  elseif page_name == "titan_usage" then
    element.add{type="label", name="text_0", tooltip=ntt, caption={"WH40k-Titans-informatron.Titan-usage"}}
    element.add{type="label", name="empty_0", caption=" "}

    local flow = element.add{ type = "flow", name = "ttn_db_placeholder" }
    flow.style.minimal_width = 512
    flow.style.horizontal_align = "center"
    flow.style.vertical_align = "center"
    flow.add{type="button", name="image_extract", style=shared.mod_prefix.."inf-titan-dashboard"}

    element.add{type="label", name="empty_1", caption=" "}
    element.add{type="label", name="text_1", tooltip=ntt, caption={"WH40k-Titans-informatron.Titan-usage-db"}}

  else
    element.add{type="label", name="text_1", caption={"WH40k-Titans-informatron.ToDo"}}
  end
end
