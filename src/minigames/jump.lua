-- src/minigame_jump.lua
local Minigame = {}
Minigame.__index = Minigame

local function generateCloud(y)
  return {
    x = math.random(60, 420),
    y = y,
    w = 90,
    h = 16
  }
end

function Minigame.new()
  local self = setmetatable({}, Minigame)
  self:reset()
  return self
end

function Minigame:reset()
  self.clouds = {}
  self.height = 0
  self.score = 0
  self.finished = false
  self.onCloud = true
  self.jumpPower = -500
  self.gravity = 700

  local startY = 520
  for i = 1, 6 do
    table.insert(self.clouds, generateCloud(startY))
    startY = startY - math.random(80, 120)
  end

  local firstCloud = self.clouds[1]
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

  if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
    self.player.x = self.player.x - 180 * dt
  elseif love.keyboard.isDown("right") or love.keyboard.isDown("d") then
    self.player.x = self.player.x + 180 * dt
  end

  self.player.x = math.max(self.player.radius, math.min(480 - self.player.radius, self.player.x))

  self.player.vy = self.player.vy + self.gravity * dt
  self.player.y = self.player.y + self.player.vy * dt

  if self.player.y > 700 then
    self.finished = true
    return
  end

  if self.player.y < 250 then
    local dy = 250 - self.player.y
    self.player.y = 250
    self.height = self.height + dy
    self.score = math.max(self.score, math.floor(self.height / 100))
    for _,c in ipairs(self.clouds) do
      c.y = c.y + dy
    end
  end

  for i = #self.clouds, 1, -1 do
    if self.clouds[i].y > 700 then
      table.remove(self.clouds, i)
    end
  end

  while #self.clouds < 6 do
    local top = self:getHighestCloudY()
    table.insert(self.clouds, generateCloud(top - math.random(80, 120)))
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
  love.graphics.clear(0.8, 0.95, 1)
  love.graphics.setColor(0, 0, 0)
  love.graphics.print("Jump Cloud Minigame", 120, 20)
  love.graphics.print("Score: "..self.score, 360, 40)
  love.graphics.print("Altura: "..math.floor(self.height), 20, 40)
  love.graphics.print("Use setas / A D para mover e clique para pular", 20, 70)

  love.graphics.setColor(1, 1, 1)
  for _,c in ipairs(self.clouds) do
    love.graphics.setColor(0.95, 0.95, 0.85)
    love.graphics.rectangle("fill", c.x, c.y, c.w, c.h, 8, 8)
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.rectangle("line", c.x, c.y, c.w, c.h, 8, 8)
  end

  love.graphics.setColor(1, 0.9, 0.6)
  love.graphics.circle("fill", self.player.x, self.player.y, self.player.radius)
  love.graphics.setColor(0, 0, 0)
  love.graphics.circle("fill", self.player.x-6, self.player.y-4, 3)
  love.graphics.circle("fill", self.player.x+6, self.player.y-4, 3)
  love.graphics.setLineWidth(3)
  love.graphics.arc("line", self.player.x, self.player.y+6, 8, math.rad(20), math.rad(160))

  if self.finished then
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf("Game Over! Clique para voltar", 0, 380, 480, "center")
  end
end

function Minigame:mousepressed(x,y,b)
  if self.finished then
    return
  end
  if self.onCloud then
    self.player.vy = self.jumpPower
    self.onCloud = false
  end
end

function Minigame:getResult()
  local coins = 10 + math.floor(self.height / 120)
  local happy = math.min(12, math.floor(self.height / 150) + 1)
  return coins, happy
end

return Minigame
