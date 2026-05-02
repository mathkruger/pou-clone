-- src/minigame_catch.lua
local UIElements = require("ui.ui_elements")
local IconManager = require("ui.icon_manager")
local cfg = require("data.config")
local Minigame = {}
Minigame.__index = Minigame

function Minigame.new()
  local self = setmetatable({}, Minigame)
  self.targets = {}
  self.timer = 30 -- duration seconds
  self.elapsed = 0
  self.score = 0
  self.finished = false
  self.backgroundImage = love.graphics.newImage("assets/sprites/minigames/background-catch.jpeg")
  self.ui = UIElements.new()
  self.iconManager = IconManager.new()
  return self
end

function Minigame:reset()
  self.targets = {}
  self.timer = 30
  self.elapsed = 0
  self.score = 0
  self.finished = false
end

function Minigame:update(dt)
  if self.finished then return end
  self.elapsed = self.elapsed + dt
  self.timer = math.max(0, self.timer - dt)
  -- spawn target occasionally
  if math.random() < 0.02 then
    local minX = 40
    local maxX = math.max(minX, cfg.gameWidth - 40)
    table.insert(self.targets, {x = math.random(minX, maxX), y = -20, vy = 60 + math.random() * 80})
  end
  -- update targets
  for i=#self.targets,1,-1 do
    local t = self.targets[i]
    t.y = t.y + t.vy * dt
    if t.y > cfg.gameHeight + cfg.gameHeight * 0.4 then table.remove(self.targets, i) end
  end
  if self.timer <= 0 then
    self.finished = true
  end
end

function Minigame:draw()
  love.graphics.clear(0.9,0.95,1)
  love.graphics.draw(self.backgroundImage, 0, 0, 0, cfg.gameWidth / self.backgroundImage:getWidth(), cfg.gameHeight / self.backgroundImage:getHeight())
  love.graphics.setColor(1,1,1)
  for _,t in ipairs(self.targets) do
    self.iconManager:draw("fish", t.x, t.y, 5)
  end
  self.ui:drawPanel(15, 15, cfg.gameWidth - 30, 60, "Pegue o peixe!")
  self.ui:drawText(45, 50, "Tempo: "..math.floor(self.timer), 14, {0, 0, 0, 1})
  self.ui:drawText(cfg.gameWidth - 120, 50, "Pontos: "..self.score, 14, {0, 0, 0, 1})
  if self.finished then
    self.ui:drawText(0, cfg.gameHeight / 2, "Finished! Click to return", 14, {0, 0, 0, 1})
  end
end

function Minigame:mousepressed(x,y,b)
  if self.finished then
    -- signal main to collect rewards
    return
  end
  for i=#self.targets,1,-1 do
    local t = self.targets[i]
    local dx = x - t.x
    local dy = y - t.y
    if dx*dx+dy*dy <= 45*45 then
      table.remove(self.targets, i)
      self.score = self.score + 1
    end
  end
end

function Minigame:mousereleased(x,y,b)
  -- no-op
end

function Minigame:getResult()
  local coins = 5 + self.score * 2
  local happy = math.min(10, math.floor(self.score/2))
  return coins, happy
end

return Minigame
