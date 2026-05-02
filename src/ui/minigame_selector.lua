-- src/ui/minigame_selector.lua
local UIElements = require("ui.ui_elements")
local MinigameSelector = {}
MinigameSelector.__index = MinigameSelector

local options = {
  { id = "catch", label = "Pegar Peixes", x = 60, y = 110, w = 170, h = 90 },
  { id = "jump", label = "Nuvens", x = 250, y = 110, w = 170, h = 90 },
  { id = "back", label = "Voltar", x = 150, y = 700, w = 180, h = 60 },
}

function MinigameSelector.new()
  local self = setmetatable({}, MinigameSelector)
  self.ui = UIElements.new()
  self.options = options
  return self
end

function MinigameSelector:draw()
  love.graphics.clear(0.93, 0.96, 1)
  self.ui:drawPanel(15, 15, 450, 755, "Selecione o Minigame")

  love.graphics.setColor(0.35, 0.25, 0.45)
  love.graphics.print("Escolha uma atividade para ganhar moedas e felicidade.", 35, 50)

  for _, option in ipairs(self.options) do
    self.ui:drawButton(option.x, option.y, option.w, option.h, option.label, false)
  end
end

function MinigameSelector:mousepressed(x, y, b)
  for _, option in ipairs(self.options) do
    if x >= option.x and x <= option.x + option.w and y >= option.y and y <= option.y + option.h then
      return option.id
    end
  end
  return nil
end

return MinigameSelector
