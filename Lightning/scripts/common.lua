shared = require("shared")
mod_name = shared.mod_name
SE = shared.SE
global_max_power_level = 4

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


subtype_accum  = 2
subtype_simple = 1
subtype_arty   = 0
rod_protos = {
    [shared.rod3] = subtype_accum,
    [shared.rod2] = subtype_accum,
    [shared.rod1] = subtype_simple,
    [shared.arty1] = subtype_arty,
    [shared.arty2] = subtype_arty,
}
-- Strongest catchers first
rod_protos_ordered = {
  {name=shared.rod3, limit_cf=1.5, add_capture_prob=0.8,},
  {name=shared.rod2, limit_cf=1, add_capture_prob=0.1,},
  {name=shared.rod1, limit_cf=1,},
}
-- Weakest towers first to save strongest for farther attacks
arty_protos_ordered = {
  -- {name=shared.rod2,  max_dst= 96, },
  {name=shared.rod3,  max_dst=192, },
  {name=shared.arty1, max_dst=256, },
  {name=shared.arty2, max_dst=480, },
}