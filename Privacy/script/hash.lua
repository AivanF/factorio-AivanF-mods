--[[
Simple hence quickly performant hash function for Lua.
Author: AivanF

LICENSE: do whatever you want, just:
1. State changes if any.
   Excepting values of char_dict, default length, salt, or changing XOR style.
2. Keep this license and comment block.
3. Notify me, I'd like to know where my code is used.

Contacts:
- Discussion pages of my mods: https://mods.factorio.com/user/AivanF
- Issues at my gh repo: https://github.com/AivanF/factorio-AivanF-mods
- My Discord server: https://discord.gg/7QCXn35mU5
]]

local char_dict = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-+=$%#@!?.,:;"
local default_len = 16
local default_salt = 16180

function af_simple_hash(pw, length, salt)
  length = length or default_len
  local cumulative = (salt or default_salt) + #pw
  local b
  local pos = 1
  local generated = {}

  for i = 0, math.max(#pw, length)-1 do
    pos = i % #pw
    b = string.byte(string.sub(pw, pos+1, pos+1))
    cumulative = (cumulative + b) % 256
    -- generated[i % length] = (generated[i % length] or 0) ~ cumulative -- Lua 5.4
    generated[i % length] = bit32.bxor((generated[i % length] or 0), cumulative) -- Lua 5.2
  end

  local result = ""
  for i = 0, length-1 do
    b = generated[i] % #char_dict + 1
    result = result .. string.sub(char_dict, b, b)
  end
  return result
end

-- Try: print("'"..af_simple_hash("Hello, worldishe!", 16).."'")
