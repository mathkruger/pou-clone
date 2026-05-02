-- src/ui/inventory.lua
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
  self.ui:drawPanel(30, 140, 420, 520, "Inventário")

  local activeTab = self:getActiveTab()
  local title = "Todos os itens"
  if activeTab == "food" then
    title = "Escolha um alimento"
  elseif activeTab == "hygiene" then
    title = "Escolha um item de banho"
  elseif activeTab == "cosmetic" then
    title = "Escolha um item de look"
  end

  love.graphics.setColor(0.4, 0.4, 0.4)
  love.graphics.print(title, 50, 185)

  local tabX = 50
  for _,tab in ipairs(inventoryTabs) do
    local width = 85
    self.ui:drawTab(tabX, 215, width, 30, inventoryTabLabels[tab] or tab, tab == activeTab)
    tabX = tabX + width + 5
  end

  local y = 270
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
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.print(message, 50, y)
  else
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

      self.ui:drawCard(40, y - 5, 400, 35, false)
      self.iconManager:drawType(entry.config.type, 57, y + 9, 0.85)
      love.graphics.setColor(0.2, 0.2, 0.2)
      love.graphics.print(displayName .. equipped .. " x" .. entry.qty, 75, y)
      self.ui:drawButton(370, y - 2, 55, 25, "[Usar]", false)
      y = y + 40
    end
  end
end

function Inventory:mousepressed(x,y,b)
  if not self.opened then
    return nil
  end

  local activeTab = self:getActiveTab()
  local tabX = 50
  for _,tab in ipairs(inventoryTabs) do
    local width = 85
    if x >= tabX and x <= tabX + width and y >= 215 and y <= 245 then
      self.activeTab = tab
      self.inventoryFilter = nil
      return nil
    end
    tabX = tabX + width + 5
  end

  local y0 = 270
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
    if x >= 370 and x <= 425 and y >= y0 - 2 and y <= y0 + 23 then
      self.pet:useItemById(entry.id)
      self:close()
      return "inventory_used"
    end
    y0 = y0 + 40
  end

  if not (x >= 30 and x <= 450 and y >= 140 and y <= 660) then
    self:close()
  end
  return nil
end

return Inventory
