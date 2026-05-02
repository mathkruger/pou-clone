-- src/minigame_catch.lua
local Minigame = {}
Minigame.__index = Minigame

function Minigame.new()
  local self = setmetatable({}, Minigame)
  self.targets = {}
  self.timer = 30 -- duration seconds
  self.elapsed = 0
  self.score = 0
  self.finished = false
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
    table.insert(self.targets, {x = math.random(40,440), y = -20, vy = 60 + math.random()*80})
  end
  -- update targets
  for i=#self.targets,1,-1 do
    local t = self.targets[i]
    t.y = t.y + t.vy * dt
    if t.y > 900 then table.remove(self.targets, i) end
  end
  if self.timer <= 0 then
    self.finished = true
  end
end

function Minigame:draw()
  love.graphics.clear(0.9,0.95,1)
  love.graphics.setColor(0,0,0)
  love.graphics.print("Catch Fish Minigame", 160, 20)
  love.graphics.print("Time: "..math.ceil(self.timer), 20, 40)
  love.graphics.print("Score: "..self.score, 360, 40)
  love.graphics.setColor(1,1,1)
  for _,t in ipairs(self.targets) do
    love.graphics.setColor(0.6,0.8,1)
    love.graphics.circle("fill", t.x, t.y, 14)
    love.graphics.setColor(0,0,0)
    love.graphics.circle("fill", t.x+4, t.y-2, 3)
  end
  if self.finished then
    love.graphics.setColor(0,0,0)
    love.graphics.printf("Finished! Click to return", 0, 380, 480, "center")
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
    if dx*dx+dy*dy <= 14*14 then
      table.remove(self.targets, i)
      self.score = self.score + 1
    end
  end
end

function Minigame:getResult()
  local coins = 5 + self.score * 2
  local happy = math.min(10, math.floor(self.score/2))
  return coins, happy
end

return Minigame
