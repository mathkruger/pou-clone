-- src/ui_elements.lua
local UIElements = {}
UIElements.__index = UIElements

local styles = {
  panelBackground = {0.98, 0.98, 0.98, 0.99},
  panelBorder = {1, 0.85, 0.95, 1},
  panelRadius = 14,
  tabActive = {1, 0.75, 0.9, 1},
  tabInactive = {0.92, 0.88, 0.95, 1},
  card = {0.95, 0.92, 0.98, 1},
  cardSelected = {1, 0.77, 0.92, 1},
  cardBorder = {1, 0.82, 0.9, 1},
  buttonText = {0.2, 0.2, 0.2, 1},
  titleText = {0.8, 0.3, 0.7, 1},
  labelText = {0.28, 0.18, 0.38, 1},
  footerText = {0.45, 0.45, 0.45, 1},
}

function UIElements.new()
  return setmetatable({style = styles}, UIElements)
end

function UIElements:drawPanel(x, y, w, h, title)
  love.graphics.setColor(unpack(self.style.panelBackground))
  love.graphics.rectangle("fill", x, y, w, h, self.style.panelRadius, self.style.panelRadius)

  love.graphics.setColor(unpack(self.style.panelBorder))
  love.graphics.setLineWidth(3)
  love.graphics.rectangle("line", x, y, w, h, self.style.panelRadius, self.style.panelRadius)
  love.graphics.setLineWidth(1)

  if title then
    self:drawText(x + 20, y + 10, title, 18, self.style.titleText)
  end
end

function UIElements:drawTab(x, y, w, h, label, active)
  love.graphics.setColor(unpack(active and self.style.tabActive or self.style.tabInactive))
  love.graphics.rectangle("fill", x, y, w, h, 8, 8)
  love.graphics.setColor(unpack(self.style.labelText))
  love.graphics.printf(label, x, y + 6, w, "center")
  love.graphics.setColor(unpack(self.style.cardBorder))
  love.graphics.setLineWidth(1.5)
  love.graphics.rectangle("line", x, y, w, h, 8, 8)
  love.graphics.setLineWidth(1)
end

function UIElements:drawCard(x, y, w, h, selected)
  love.graphics.setColor(unpack(selected and self.style.cardSelected or self.style.card))
  love.graphics.rectangle("fill", x, y, w, h, 10, 10)
  love.graphics.setColor(unpack(self.style.cardBorder))
  love.graphics.setLineWidth(1.5)
  love.graphics.rectangle("line", x, y, w, h, 10, 10)
  love.graphics.setLineWidth(1)
end

function UIElements:drawButton(x, y, w, h, label, selected)
  self:drawCard(x, y, w, h, selected)
  love.graphics.setColor(unpack(self.style.buttonText))
  love.graphics.printf(label, x, y + h / 2 - 7, w, "center")
end

function UIElements:drawButtonWithIcon(x, y, w, h, label, icon, iconManager)
  self:drawCard(x, y, w, h, false)  -- assuming not selected for now
  if icon and iconManager then
    iconManager:draw(icon, x + w / 2, y + h / 2 - 20, 1.5)
  end
  love.graphics.setColor(unpack(self.style.buttonText))
  love.graphics.printf(label, x + 5, y + 45, w - 10, "center")  -- adjusted width
end

function UIElements:drawText(x, y, text, fontSize, color)
  local currentFont = love.graphics.getFont()
  local newFont = love.graphics.newFont(fontSize or currentFont:getHeight())
  love.graphics.setFont(newFont)
  love.graphics.setColor(color or self.style.labelText)
  love.graphics.print(text, x, y)
  love.graphics.setFont(currentFont)
end

function UIElements:drawFooter(text, x, y, w)
  love.graphics.setColor(unpack(self.style.footerText))
  love.graphics.printf(text, x, y, w, "center")
end

return UIElements
