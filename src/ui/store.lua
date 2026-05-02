-- src/ui/store.lua
local cfg = require("data.config")
local items = require("data.items")
local UIElements = require("ui.ui_elements")
local IconManager = require("ui.icon_manager")
local Store = {}
Store.__index = Store

local tabOrder = { "all", "food", "hygiene", "cosmetic" }
local tabLabels = {
  all = "Todos",
  food = "Comida",
  hygiene = "Banho",
  cosmetic = "Look"
}

function Store.new(pet)
  local self = setmetatable({}, Store)
  self.pet = pet
  self.items = items
  self.activeTab = "all"
  self.selected = 1
  self.ui = UIElements.new()
  self.iconManager = IconManager.new()
  return self
end

function Store:getFilteredItems()
  if self.activeTab == "all" then
    return self.items
  end
  local filtered = {}
  for _,it in ipairs(self.items) do
    if it.type == self.activeTab then
      table.insert(filtered, it)
    end
  end
  return filtered
end

function Store:draw()
  local panelX = 30
  local panelY = 40
  local panelWidth = cfg.gameWidth - 2 * panelX
  local panelHeight = cfg.gameHeight - panelY - 20
  self.ui:drawPanel(panelX, panelY, panelWidth, panelHeight, "Loja")

  local closeX = panelX + panelWidth - 15 - 30
  local closeY = panelY + 15
  self.ui:drawButton(closeX, closeY, 30, 30, "X", false)

  local tabX = panelX + 15
  local tabWidth = math.min(100, math.max(70, (panelWidth - 80) / #tabOrder))
  for _,tab in ipairs(tabOrder) do
    self.ui:drawTab(tabX, panelY + 50, tabWidth, 28, tabLabels[tab] or tab, tab == self.activeTab)
    tabX = tabX + tabWidth + 8
  end

  local visibleItems = self:getFilteredItems()
  local y = panelY + 100
  local cardWidth = panelWidth - 30
  for i,it in ipairs(visibleItems) do
    self.ui:drawCard(panelX + 15, y - 10, cardWidth, 35, i == self.selected)
    self.iconManager:drawType(it.type, panelX + 30, y + 10, 0.85)
    self.ui:drawText(panelX + 40, y, it.displayName or it.id, 12, {0.2, 0.2, 0.2, 1})
    self.iconManager:drawCurrency(panelX + panelWidth - 65, y + 10, 0.8)
    self.ui:drawText(panelX + panelWidth - 55, y, tostring(it.price), 12, {0.2, 0.2, 0.2, 1})
    y = y + 50
  end

  self.iconManager:drawCurrency(panelX + 15, panelY + panelHeight - 15, 0.9)
  self.ui:drawText(panelX + 25, panelY + panelHeight - 24, tostring(self.pet.coins), 12, {0.2, 0.2, 0.2, 1})
end

function Store:mousepressed(x,y,b)
  local panelX = 30
  local panelY = 40
  local panelWidth = cfg.gameWidth - 2 * panelX

  local closeX = panelX + panelWidth - 15 - 30
  local closeY = panelY + 15
  if x >= closeX and x <= closeX + 30 and y >= closeY and y <= closeY + 30 then
    return "close"
  end

  local tabX = panelX + 15
  local tabWidth = math.min(100, math.max(70, (panelWidth - 80) / #tabOrder))
  for _,tab in ipairs(tabOrder) do
    if x >= tabX and x <= tabX + tabWidth and y >= panelY + 50 and y <= panelY + 78 then
      self.activeTab = tab
      self.selected = 1
      return
    end
    tabX = tabX + tabWidth + 8
  end

  local visibleItems = self:getFilteredItems()
  local y0 = panelY + 100
  local itemLeft = panelX + 10
  local itemRight = panelX + panelWidth - 20
  for i,it in ipairs(visibleItems) do
    if x >= itemLeft and x <= itemRight and y >= y0 - 6 and y <= y0 + 38 then
      self.selected = i
      if self.pet.coins >= it.price then
        self.pet.coins = self.pet.coins - it.price
        self.pet.inventory[it.id] = (self.pet.inventory[it.id] or 0) + 1
        self.pet:addXP(2)
        print("Comprou:", it.id)
      else
        print("Moedas insuficientes")
      end
      break
    end
    y0 = y0 + 50
  end
end

return Store
