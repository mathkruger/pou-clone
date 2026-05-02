-- src/save.lua
local json = require("lib.dkjson") -- optional; if absent, use simple serializer
local Save = {}

local SAVE_FILE = "save.json"

function Save.save(state)
  local ok, data = pcall(function() return json.encode(state) end)
  if ok then
    love.filesystem.write(SAVE_FILE, data)
    return true
  end
  return false
end

function Save.load()
  if not love.filesystem.getInfo(SAVE_FILE) then return nil end
  local contents = love.filesystem.read(SAVE_FILE)
  local obj, pos, err = json.decode(contents)
  if err then return nil end
  return obj
end

function Save.autoSave(state)
  -- call periodically; small wrapper
  if state and state.lastUpdate then
    state.lastUpdate = os.time()
  end
  Save.save(state)
end

return Save
