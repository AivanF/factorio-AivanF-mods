-- Adjust default settings to make the game more simple and interesting

-- AAI Industry
data.raw["int-setting"]["aai-burner-turbine-efficiency"].default_value = 75  -- was 85
data.raw["int-setting"]["aai-fuel-processor-efficiency"].default_value = 35  -- was 10

-- Warptorio
data.raw["bool-setting"]["warptorio_adjust_map_settings"].default_value = false
data.raw["int-setting"]["warptorio_pollution_tickrate"].default_value = 5
data.raw["double-setting"]["warptorio_pollution_exponent"].default_value = 0.1  -- was 0.225
data.raw["double-setting"]["warptorio_pollution_multiplier"].default_value = 0.2  -- was 0.75
