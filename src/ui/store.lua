-- src/ui/store.lua
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
  self.ui:drawPanel(20, 120, 440, 560, "Loja")

  local tabX = 40
  for _,tab in ipairs(tabOrder) do
    local width = 90
    self.ui:drawTab(tabX, 170, width, 28, tabLabels[tab] or tab, tab == self.activeTab)
    tabX = tabX + width + 8
  end

  local visibleItems = self:getFilteredItems()
  local y = 220
  for i,it in ipairs(visibleItems) do
    self.ui:drawCard(30, y - 6, 420, 44, i == self.selected)
    self.iconManager:drawType(it.type, 50, y + 10, 0.85)
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.print(it.displayName or it.id, 75, y)
    self.iconManager:drawCurrency(365, y + 10, 0.8)
    love.graphics.print(it.price, 385, y)
    y = y + 50
  end

  self.iconManager:drawCurrency(45, 748, 0.9)
  love.graphics.setColor(0.2, 0.2, 0.2)
  love.graphics.print(self.pet.coins, 70, 740)
  self.ui:drawFooter("Clique em uma aba para filtrar ou clique no item para comprar.", 20, 770, 440)
end

function Store:mousepressed(x,y,b)
  local tabX = 40
  for _,tab in ipairs(tabOrder) do
    local width = 90
    if x >= tabX and x <= tabX + width and y >= 170 and y <= 198 then
      self.activeTab = tab
      self.selected = 1
      return
    end
    tabX = tabX + width + 8
  end

  local visibleItems = self:getFilteredItems()
  local y0 = 220
  for i,it in ipairs(visibleItems) do
    if x >= 30 and x <= 450 and y >= y0-6 and y <= y0+38 then
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
