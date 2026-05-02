-- src/minigame_jump.lua
local UIElements = require("ui.ui_elements")
local cfg = require("data.config")
local Minigame = {}
Minigame.__index = Minigame

local function generateCloud(y)
  local minX = 60
  local maxX = math.max(minX, cfg.gameWidth - 60)
  return {
    x = math.random(minX, maxX),
    y = y,
    w = 90,
    h = 16,
    timeOnCloud = 0,
    maxTimeOnCloud = 0.5
  }
end

function Minigame.new()
  local self = setmetatable({}, Minigame)
  self.ui = UIElements.new()
  self.backgroundImage = love.graphics.newImage("assets/sprites/minigames/background-jump.jpeg")
  self.playerSprite = love.graphics.newImage("assets/sprites/pet/pet-clean.png")
  self:reset()
  return self
end

function Minigame:reset()
  self.clouds = {}
  self.height = 0
  self.score = 0
  self.finished = false
  self.onCloud = true
  self.jumpPower = -470
  self.gravity = 700
  self.moveDirection = 0

  local startY = cfg.gameHeight * 0.8125
  for i = 1, 6 do
    table.insert(self.clouds, generateCloud(startY))
    startY = startY - math.random(80, 120)
  end

  local firstCloud = self.clouds[1]
  firstCloud.isStartingCloud = true
  self.firstActionDone = false
  self.player = { x = firstCloud.x + firstCloud.w / 2, y = firstCloud.y - 16, vy = 0, radius = 16 }
end

function Minigame:getHighestCloudY()
  local top = math.huge
  for _,c in ipairs(self.clouds) do
    if c.y < top then top = c.y end
  end
  return top
end

function Minigame:update(dt)
  if self.finished then return end

  if not self.firstActionDone then
    if self.moveDirection ~= 0 or love.keyboard.isDown("left") or love.keyboard.isDown("a") or love.keyboard.isDown("right") or love.keyboard.isDown("d") then
      self.firstActionDone = true
    end
  end

  -- Move player based on input (touch/mouse or keyboard)
  if self.moveDirection == -1 then
    self.player.x = self.player.x - 180 * dt
  elseif self.moveDirection == 1 then
    self.player.x = self.player.x + 180 * dt
  end
  
  -- Fallback to keyboard for dev
  if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
    self.player.x = self.player.x - 180 * dt
  elseif love.keyboard.isDown("right") or love.keyboard.isDown("d") then
    self.player.x = self.player.x + 180 * dt
  end

  self.player.x = math.max(self.player.radius, math.min(cfg.gameWidth - self.player.radius, self.player.x))

  self.player.vy = self.player.vy + self.gravity * dt
  self.player.y = self.player.y + self.player.vy * dt

  if self.player.y > cfg.gameHeight + 60 then
    self.finished = true
    return
  end

  local ceilingY = cfg.gameHeight * 0.39
  if self.player.y < ceilingY then
    local dy = ceilingY - self.player.y
    self.player.y = ceilingY
    self.height = self.height + dy
    self.score = math.max(self.score, math.floor(self.height / 100))
    for _,c in ipairs(self.clouds) do
      c.y = c.y + dy
    end
  end

  for i = #self.clouds, 1, -1 do
    local cloud = self.clouds[i]
    if cloud.y > cfg.gameHeight + 220 then
      table.remove(self.clouds, i)
    else
      -- Update time on cloud
      local footY = self.player.y + self.player.radius
      local onThisCloud = (footY >= cloud.y and footY <= cloud.y + 10 and 
                          self.player.x > cloud.x and self.player.x < cloud.x + cloud.w and
                          self.player.vy >= 0)
      
      if onThisCloud then
        if cloud.isStartingCloud and not self.firstActionDone then
          cloud.timeOnCloud = 0
        else
          cloud.timeOnCloud = cloud.timeOnCloud + dt
          -- Remove cloud if player stayed too long
          if cloud.timeOnCloud > cloud.maxTimeOnCloud then
            table.remove(self.clouds, i)
          end
        end
      else
        cloud.timeOnCloud = 0
      end
    end
  end

  while #self.clouds < 6 do
    local top = self:getHighestCloudY()
    if top == math.huge then
      top = cfg.gameHeight * 0.8
    end
    table.insert(self.clouds, generateCloud(top - math.random(80, 120)))
  end

  local top = self:getHighestCloudY()
  local spawnThreshold = cfg.gameHeight * 0.3
  while top > spawnThreshold do
    top = top - math.random(80, 120)
    table.insert(self.clouds, generateCloud(top))
  end

  if self.player.vy > 0 then
    for _,c in ipairs(self.clouds) do
      local footY = self.player.y + self.player.radius
      if footY >= c.y and footY <= c.y + 10 and self.player.x > c.x and self.player.x < c.x + c.w then
        self.player.y = c.y - self.player.radius
        self.player.vy = 0
        self.onCloud = true
        break
      end
    end
  end
end

function Minigame:draw()
  love.graphics.clear(0, 0, 0)
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(self.backgroundImage, 0, 0, 0, cfg.gameWidth / self.backgroundImage:getWidth(), cfg.gameHeight / self.backgroundImage:getHeight())

  love.graphics.setColor(1, 1, 1)
  for _,c in ipairs(self.clouds) do
    love.graphics.setColor(0.95, 0.95, 0.85)
    love.graphics.rectangle("fill", c.x, c.y, c.w, c.h, 8, 8)
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.rectangle("line", c.x, c.y, c.w, c.h, 8, 8)
  end

  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(
    self.playerSprite,
    self.player.x,
    self.player.y,
    0,
    0.7,
    0.7,
    self.playerSprite:getWidth() / 2,
    self.playerSprite:getHeight() / 2
  )

  self.ui:drawPanel(15, 15, cfg.gameWidth - 30, 60, "Nuvens")
  self.ui:drawText(45, 50, "Altura: "..math.floor(self.height), 14, {0, 0, 0, 1})
  self.ui:drawText(cfg.gameWidth - 120, 50, "Score: "..self.score, 14, {0, 0, 0, 1})
  if self.finished then
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf("Game Over! Clique para voltar", 0, cfg.gameHeight / 2, cfg.gameWidth, "center")
  end
end

function Minigame:mousepressed(x,y,b)
  if self.finished then
    return
  end

  local midX = cfg.gameWidth / 2
  if x < midX then
    self.moveDirection = -1
  else
    self.moveDirection = 1
  end

  if self.onCloud then
    self.player.vy = self.jumpPower
    self.onCloud = false
  end
end

function Minigame:mousereleased(x,y,b)
  -- Stop moving when mouse is released
  self.moveDirection = 0
end

function Minigame:getResult()
  local coins = 10 + math.floor(self.height / 120)
  local happy = math.min(12, math.floor(self.height / 150) + 1)
  return coins, happy
end

return Minigame
