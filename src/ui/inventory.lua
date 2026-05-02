-- src/ui/inventory.lua
local cfg = require("data.config")
local UIElements = require("ui.ui_elements")
local IconManager = require("ui.icon_manager")
local Inventory = {}
Inventory.__index = Inventory

local inventoryTabs = { "all", "food", "hygiene", "cosmetic" }
local inventoryTabLabels = {
  all = "Todos",
  food = "Comida",
  hygiene = "Banho",
  cosmetic = "Look"
}

function Inventory.new(pet)
  local self = setmetatable({}, Inventory)
  self.pet = pet
  self.activeTab = "all"
  self.inventoryFilter = nil
  self.opened = false
  self.ui = UIElements.new()
  self.iconManager = IconManager.new()
  return self
end

function Inventory:open(filter)
  self.inventoryFilter = filter
  self.activeTab = filter or "all"
  self.opened = true
end

function Inventory:close()
  self.opened = false
  self.inventoryFilter = nil
  self.activeTab = "all"
end

function Inventory:isOpen()
  return self.opened
end

function Inventory:getActiveTab()
  return self.inventoryFilter or self.activeTab
end

function Inventory:draw()
  local panelX = 30
  local panelY = 140
  local panelWidth = cfg.gameWidth - 2 * panelX
  local panelHeight = cfg.gameHeight - panelY - 20
  self.ui:drawPanel(panelX, panelY, panelWidth, panelHeight, "Inventário")

  local closeX = panelX + panelWidth - 15 - 30
  local closeY = panelY + 15
  self.ui:drawButton(closeX, closeY, 30, 30, "X", false)

  local activeTab = self:getActiveTab()
  local title = "Todos os itens"
  if activeTab == "food" then
    title = "Escolha um alimento"
  elseif activeTab == "hygiene" then
    title = "Escolha um item de banho"
  elseif activeTab == "cosmetic" then
    title = "Escolha um item de look"
  end

  self.ui:drawText(panelX + 15, panelY + 45, title, 16, {0.4, 0.4, 0.4, 1})

  local tabX = panelX + 15
  local tabWidth = math.min(90, math.max(70, (panelWidth - 80) / #inventoryTabs))
  for _,tab in ipairs(inventoryTabs) do
    self.ui:drawTab(tabX, panelY + 75, tabWidth, 30, inventoryTabLabels[tab] or tab, tab == activeTab)
    tabX = tabX + tabWidth + 5
  end

  local y = panelY + 130
  local items = require("data.items")
  local filtered = {}
  for id,qty in pairs(self.pet.inventory) do
    if qty > 0 then
      for _,it in ipairs(items) do
        if it.id == id and (activeTab == "all" or it.type == activeTab) then
          table.insert(filtered, { id = id, qty = qty, config = it })
          break
        end
      end
    end
  end

  if #filtered == 0 then
    local message = "Nenhum item disponível nesta aba."
    if activeTab == "all" then
      message = "Seu inventário está vazio."
    end
    self.ui:drawText(panelX + 15, y, message, 14, {0.6, 0.6, 0.6, 1})
  else
    local cardWidth = panelWidth - 30
    local actionX = panelX + panelWidth - 80
    for _,entry in ipairs(filtered) do
      local displayName = entry.config.displayName or entry.id
      local equipped = ""
      if entry.config.type == "cosmetic" and entry.config.slot then
        if self.pet.outfits[entry.config.slot] == entry.id then
          equipped = " (equipado)"
        end
      elseif self.pet.outfit == entry.id then
        equipped = " (equipado)"
      end

      self.ui:drawCard(panelX + 15, y - 10, cardWidth, 35, false)
      self.iconManager:drawType(entry.config.type, panelX + 30, y + 9, 0.85)
      self.ui:drawText(panelX + 40, y, displayName .. equipped .. " x" .. entry.qty, 12, {0.2, 0.2, 0.2, 1})
      self.ui:drawButton(actionX, y - 5, 55, 25, "[Usar]", false)
      y = y + 40
    end
  end
end

function Inventory:mousepressed(x,y,b)
  if not self.opened then
    return nil
  end

  local panelX = 30
  local panelY = 140
  local panelWidth = cfg.gameWidth - 2 * panelX

  local closeX = panelX + panelWidth - 15 - 30
  local closeY = panelY + 15
  if x >= closeX and x <= closeX + 30 and y >= closeY and y <= closeY + 30 then
    self:close()
    return nil
  end

  local activeTab = self:getActiveTab()
  local tabX = panelX + 20
  local tabWidth = math.min(90, math.max(70, (panelWidth - 80) / #inventoryTabs))
  for _,tab in ipairs(inventoryTabs) do
    if x >= tabX and x <= tabX + tabWidth and y >= panelY + 75 and y <= panelY + 105 then
      self.activeTab = tab
      self.inventoryFilter = nil
      return nil
    end
    tabX = tabX + tabWidth + 5
  end

  local y0 = panelY + 130
  local actionX = panelX + panelWidth - 90
  local items = require("data.items")
  local filtered = {}
  for id,qty in pairs(self.pet.inventory) do
    if qty > 0 then
      for _,it in ipairs(items) do
        if it.id == id and (activeTab == "all" or it.type == activeTab) then
          table.insert(filtered, { id = id, config = it })
          break
        end
      end
    end
  end

  for _,entry in ipairs(filtered) do
    if x >= actionX and x <= actionX + 55 and y >= y0 - 2 and y <= y0 + 23 then
      self.pet:useItemById(entry.id)
      return "inventory_used"
    end
    y0 = y0 + 40
  end

  return nil
end

return Inventory
