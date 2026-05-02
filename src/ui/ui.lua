-- src/ui/ui.lua
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
  self.buttons = {
    {id="feed", x=15, y=705, w=112.5, h=80, label="Comer", icon="apple"},
    {id="play", x=127.5, y=705, w=112.5, h=80, label="Brincar", icon="dancing-man"},
    {id="bath", x=240, y=705, w=112.5, h=80, label="Banho", icon="rain"},
    {id="sleep", x=352.5, y=705, w=112.5, h=80, label="Dormir", icon="star"},
    {id="store", x=15, y=145, w=112.5, h=80, label="Loja", icon="shop"},
    {id="inv", x=352.5, y=145, w=112.5, h=80, label="Inventário", icon="briefcase"},
  }
  self.ui = UIElements.new()
  return self
end

function UI:update(dt) end

function UI:draw()
  -- Left panel
  local panelHeight = 115
  local leftPanelWidth = 240
  love.graphics.setColor(1, 0.92, 0.96, 0.95)
  love.graphics.rectangle("fill", 15, 15, leftPanelWidth, panelHeight, 12, 12)
  
  love.graphics.setColor(1, 0.8, 0.9)
  love.graphics.setLineWidth(3)
  love.graphics.rectangle("line", 15, 15, leftPanelWidth, panelHeight, 12, 12)
  love.graphics.setLineWidth(1)
  
  -- Right panel
  local rightPanelWidth = 195
  love.graphics.setColor(1, 0.92, 0.96, 0.95)
  love.graphics.rectangle("fill", 270, 15, rightPanelWidth, panelHeight, 12, 12)
  
  love.graphics.setColor(1, 0.8, 0.9)
  love.graphics.setLineWidth(3)
  love.graphics.rectangle("line", 270, 15, rightPanelWidth, panelHeight, 12, 12)
  love.graphics.setLineWidth(1)
  
  -- Draw stat icons and values (left panel)
  local stats = {
    {icon="apple", label="Fome", value=math.floor(self.pet.hunger), x=30, y=30},
    {icon="star", label="Felicidade", value=math.floor(self.pet.happiness), x=30, y=65},
    {icon="lightning", label="Energia", value=math.floor(self.pet.energy), x=30, y=95},
    {icon="rain", label="Limpeza", value=math.floor(self.pet.cleanliness), x=150, y=30},
    {icon="heart", label="Saúde", value=math.floor(self.pet.health), x=150, y=65},
  }
  
  for _, stat in ipairs(stats) do
    self:drawStatIcon(stat.x, stat.y, stat.icon)
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.setFont(love.graphics.getFont())
    love.graphics.print(stat.value, stat.x + 20, stat.y)
  end
  
  -- Draw right panel stats
  love.graphics.setColor(0.2, 0.2, 0.2)
  love.graphics.setFont(love.graphics.getFont())
  local rightX = 285
  local stats_right = {
    {icon="arrow-up", label="Nível", value=math.floor(self.pet.level), x=rightX, y=30},
    {icon="dollar", label="Moedas", value=math.floor(self.pet.coins), x=rightX, y=65},
    {icon="dancing-man", label="Estado", value=self.pet:getStateLabel(), x=rightX, y=95},
  }
  for _, stat in ipairs(stats_right) do
    self:drawStatIcon(stat.x, stat.y, stat.icon)
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.setFont(love.graphics.getFont())
    love.graphics.print(stat.value, stat.x + 20, stat.y)
  end

  
  -- draw buttons
  for _,b in ipairs(self.buttons) do
    love.graphics.setColor(1, 0.85, 0.9)
    love.graphics.rectangle("fill", b.x, b.y, b.w, b.h, 8, 8)
    
    love.graphics.setColor(1, 0.7, 0.85)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", b.x, b.y, b.w, b.h, 8, 8)
    love.graphics.setLineWidth(1)
    
    self:drawStatIcon(b.x + b.w / 2, b.y + b.h / 2 - 20, b.icon)
    love.graphics.setColor(0.3, 0.1, 0.3)
    love.graphics.printf(b.label, b.x + 5, b.y + 45, b.w, "center")
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
      else
        return btn.id
      end
    end
  end
  return nil
end
return UI
