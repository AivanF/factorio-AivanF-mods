shared = require("shared")
mod_name = shared.mod_name
SE = shared.SE
max_natural_power_level = 4

set_main_debug = false --settings.global["af-tsl-debug-main"].value
set_perf_debug = false --settings.global["af-tsl-debug-perf"].value

function perf_print(txt)
  if set_perf_debug then
    log(txt)
    game.print(txt)
  end
end

function debug_print(txt)
  log(txt)
  if set_main_debug then
    game.print(txt)
  end
end

---- Helpful Factorio constants
MJ = 1000 * 1000
chunk_size = 32
second_ticks = 60
minute_ticks = second_ticks * 60

---- TSL buildings constants
subtype_accum  = 2
subtype_simple = 1
subtype_arty   = 0
rod_protos = {
    [shared.rod1] = subtype_simple,
    [shared.rod2] = subtype_simple,
    [shared.han1] = subtype_accum,
    [shared.han2] = subtype_accum,
    [shared.art1] = subtype_arty,
    [shared.art2] = subtype_arty,
}
-- Strongest catchers first
rod_protos_ordered = {
  {name=shared.han2, limit_cf=1.5, add_capture_prob=0.9,},
  {name=shared.han1, limit_cf=1.0, add_capture_prob=0.2,},
  {name=shared.rod2, limit_cf=1.5, add_capture_prob=0.4,},
  {name=shared.rod1, limit_cf=1.0, add_capture_prob=0.1,},
}
-- Weakest towers first to save strongest for farther attacks
arty_protos_ordered = {
  {name=shared.han2, max_dst=256, },
  {name=shared.art1, max_dst=480, },
  {name=shared.art2, max_dst=960, },
}
if settings.startup["af-tsl-early-arty"].value then
  table.insert(arty_protos_ordered, 1, {name=shared.han1, max_dst=128, })
end