script.on_nth_tick(60 * settings.startup["af-md2r-rescan-period"].value, function()
  if remote.interfaces["mining_drones"] then
    if settings.global["af-md2r-rescan-print"].value then
      game.print("Calling MD2R Rescan")
    end
    remote.call("mining_drones", "rescan_all_depots")
  end
end)