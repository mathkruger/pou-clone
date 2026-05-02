-- src/ui/icon_manager.lua
local IconManager = {}
IconManager.__index = IconManager

local ICONS_PATH = "assets/sprites/icons/"
local iconNames = {
  "apple",
  "lightning",
  "star",
  "heart",
  "dollar",
  "arrow-up",
  "rain",
  "dancing-man",
  "shop",
  "briefcase",
  "fish"
}

local typeIcons = {
  food = "apple",
  hygiene = "rain",
  cosmetic = "star"
}

function IconManager.new()
  local self = setmetatable({}, IconManager)
  self.icons = {}

  for _, name in ipairs(iconNames) do
    local path = ICONS_PATH .. name .. ".png"
    if love.filesystem.getInfo(path) then
      self.icons[name] = love.graphics.newImage(path)
    else
      print("Warning: Icon not found: " .. path)
    end
  end

  return self
end

function IconManager:get(name)
  return self.icons[name]
end

function IconManager:draw(name, x, y, scale)
  local icon = self:get(name)
  if not icon then
    return
  end
  scale = scale or 1
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(icon, x - icon:getWidth() / 2, y - icon:getHeight() / 2, 0, scale, scale)
end

function IconManager:drawType(typeName, x, y, scale)
  local iconName = typeIcons[typeName]
  if iconName then
    self:draw(iconName, x, y, scale)
  end
end

function IconManager:drawCurrency(x, y, scale)
  self:draw("dollar", x, y, scale)
end

return IconManager
