-- src/ui/ui.lua
local cfg = require("data.config")
local InventoryScreen = require("ui.inventory")
local IconManager = require("ui.icon_manager")
local UIElements = require("ui.ui_elements")
local UI = {}
UI.__index = UI

function UI.new(pet)
  local self = setmetatable({}, UI)
  self.pet = pet
  self.inventoryScreen = InventoryScreen.new(pet)
  self.iconManager = IconManager.new()

  local margin = 15
  local bottomButtonWidth = (cfg.gameWidth - 2 * margin) / 4
  local topButtonWidth = (cfg.gameWidth - 2 * margin - 16) / 3
  local bottomY = cfg.gameHeight - margin - 80
  local topButtonY = margin + 130
  self.buttons = {
    {id="feed", x=margin, y=bottomY, w=bottomButtonWidth, h=80, label="Comer", icon="apple"},
    {id="play", x=margin + bottomButtonWidth, y=bottomY, w=bottomButtonWidth, h=80, label="Brincar", icon="dancing-man"},
    {id="bath", x=margin + 2 * bottomButtonWidth, y=bottomY, w=bottomButtonWidth, h=80, label="Banho", icon="rain"},
    {id="sleep", x=margin + 3 * bottomButtonWidth, y=bottomY, w=bottomButtonWidth, h=80, label="Dormir", icon="star"},
    {id="store", x=margin, y=topButtonY, w=topButtonWidth, h=80, label="Loja", icon="shop"},
    {id="settings", x=margin + topButtonWidth + 8, y=topButtonY, w=topButtonWidth, h=80, label="Configurações", icon="control-panel"},
    {id="inv", x=margin + 2 * (topButtonWidth + 8), y=topButtonY, w=topButtonWidth, h=80, label="Inventário", icon="briefcase"},
  }
  self.ui = UIElements.new()
  return self
end

function UI:update(dt) end

function UI:draw()
  local panelMargin = 15
  local panelHeight = 115
  local leftPanelWidth = (cfg.gameWidth - 3 * panelMargin) * 0.55
  local rightPanelWidth = (cfg.gameWidth - 3 * panelMargin) * 0.45
  local leftPanelX = panelMargin
  local rightPanelX = leftPanelX + leftPanelWidth + panelMargin

  love.graphics.setColor(1, 0.92, 0.96, 0.95)
  love.graphics.rectangle("fill", leftPanelX, 15, leftPanelWidth, panelHeight, 12, 12)

  love.graphics.setColor(1, 0.8, 0.9)
  love.graphics.setLineWidth(3)
  love.graphics.rectangle("line", leftPanelX, 15, leftPanelWidth, panelHeight, 12, 12)
  love.graphics.setLineWidth(1)

  love.graphics.setColor(1, 0.92, 0.96, 0.95)
  love.graphics.rectangle("fill", rightPanelX, 15, rightPanelWidth, panelHeight, 12, 12)

  love.graphics.setColor(1, 0.8, 0.9)
  love.graphics.setLineWidth(3)
  love.graphics.rectangle("line", rightPanelX, 15, rightPanelWidth, panelHeight, 12, 12)
  love.graphics.setLineWidth(1)

  local stats = {
    {icon="apple", value=math.floor(self.pet.hunger), x=leftPanelX + 15, y=30},
    {icon="star", value=math.floor(self.pet.happiness), x=leftPanelX + 15, y=65},
    {icon="lightning", value=math.floor(self.pet.energy), x=leftPanelX + 15, y=95},
    {icon="rain", value=math.floor(self.pet.cleanliness), x=leftPanelX + leftPanelWidth * 0.45, y=30},
    {icon="heart", value=math.floor(self.pet.health), x=leftPanelX + leftPanelWidth * 0.45, y=65},
  }

  for _, stat in ipairs(stats) do
    self:drawStatIcon(stat.x, stat.y, stat.icon)
    self.ui:drawText(stat.x + 20, stat.y, tostring(stat.value), nil, {0.2, 0.2, 0.2, 1})
  end

  love.graphics.setColor(0.2, 0.2, 0.2)
  love.graphics.setFont(love.graphics.getFont())
  local rightX = rightPanelX + 15
  local stats_right = {
    {icon="arrow-up", value=math.floor(self.pet.level), x=rightX, y=30},
    {icon="dollar", value=math.floor(self.pet.coins), x=rightX, y=65},
    {icon="dancing-man", value=self.pet:getStateLabel(), x=rightX, y=95},
  }
  for _, stat in ipairs(stats_right) do
    self:drawStatIcon(stat.x, stat.y, stat.icon)
    self.ui:drawText(stat.x + 20, stat.y, tostring(stat.value), nil, {0.2, 0.2, 0.2, 1})
  end

  for _, b in ipairs(self.buttons) do
    self.ui:drawButtonWithIcon(b.x, b.y, b.w, b.h, b.label, b.icon, self.iconManager)
  end

  -- inventory overlay
  if self.inventoryScreen:isOpen() then
    self.inventoryScreen:draw()
  end
end

function UI:drawStatIcon(x, y, iconType)
  self.iconManager:draw(iconType, x, y, 1.5)
end

function UI:mousepressed(x,y,b)
  if self.inventoryScreen:isOpen() then
    return self.inventoryScreen:mousepressed(x,y,b)
  end

  for _,btn in ipairs(self.buttons) do
    if x >= btn.x and x <= btn.x+btn.w and y >= btn.y and y <= btn.y+btn.h then
      if btn.id == "store" then
        return "open_store"
      elseif btn.id == "inv" then
        self.inventoryScreen:open("all")
        return "open_inventory"
      elseif btn.id == "feed" then
        self.pet:sleepWakeUp()
        self.inventoryScreen:open("food")
        return "open_inventory"
      elseif btn.id == "bath" then
        self.pet:sleepWakeUp()
        self.inventoryScreen:open("hygiene")
        return "open_inventory"
      elseif btn.id == "play" then
        self.pet:sleepWakeUp()
        return "play"
      elseif btn.id == "settings" then
        return "settings"
      else
        return btn.id
      end
    end
  end
  return nil
end
return UI
