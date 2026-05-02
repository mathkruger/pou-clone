-- src/ui/minigame_selector.lua
local cfg = require("data.config")
local UIElements = require("ui.ui_elements")
local MinigameSelector = {}
MinigameSelector.__index = MinigameSelector

function MinigameSelector.new()
  local self = setmetatable({}, MinigameSelector)
  self.ui = UIElements.new()

  local margin = 15
  local buttonWidth = (cfg.gameWidth - 3 * margin) / 2
  local backWidth = math.min(180, cfg.gameWidth - 2 * margin)

  self.options = {
    { id = "catch", label = "Pegar Peixes", x = margin, y = 120, w = buttonWidth, h = 90 },
    { id = "jump", label = "Nuvens", x = margin * 2 + buttonWidth, y = 120, w = buttonWidth, h = 90 },
    { id = "back", label = "Voltar", x = (cfg.gameWidth - backWidth) / 2, y = cfg.gameHeight - 80, w = backWidth, h = 60 },
  }

  return self
end

function MinigameSelector:draw()
  local margin = 15
  local panelWidth = cfg.gameWidth - 2 * margin
  local panelHeight = cfg.gameHeight - 2 * margin

  love.graphics.clear(0.93, 0.96, 1)
  self.ui:drawPanel(margin, margin, panelWidth, panelHeight, "Selecione o Minigame")

  self.ui:drawText(margin * 2, 50, "Escolha uma atividade para ganhar moedas e felicidade.", 14, {0.35, 0.25, 0.45, 1})

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
