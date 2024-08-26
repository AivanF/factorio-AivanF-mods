---@diagnostic disable
-- Remote interface. replace "mymod" with your mod name
remote.add_interface("Reverse-Engineering", {
  informatron_menu = function(data)
    return mymod_menu(data.player_index)
  end,
  informatron_page_content = function(data)
    return mymod_page_content(data.page_name, data.player_index, data.element)
  end
})

function mymod_menu(player_index)
  return {
  }
end

function mymod_page_content(page_name, player_index, element)
  if page_name == "Reverse-Engineering" then
    element.add{type="label", name="text_1", caption={"Reverse-Engineering.page_1_text_1"}}
    element.add{type="button", name="image_1", style="reveng-info"}
    element.add{type="label", name="text_2", caption={"Reverse-Engineering.page_1_text_2"}}
    element.add{
      type="sprite-button", sprite="af-reverse-lab-worth",
      tooltip={"shortcut-description.af-reverse-lab-see-worth"},
      tags={action="reverse-lab-open-worth-explain"},
    }
  end
end
