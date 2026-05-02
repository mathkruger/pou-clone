-- src/pet.lua
local json = require("lib.dkjson") -- se não tiver, substitua por um serializer simples
local Save = require("entities.save")
local cfg = require("data.config")

local SCALE_FACTOR = 3

local Pet = {}
Pet.__index = Pet

local function defaultPet()
  return {
    name = "Furão",
    hunger = 80,
    happiness = 70,
    energy = 80,
    cleanliness = 90,
    health = 100,
    coins = 50,
    level = 1,
    xp = 0,
    inventory = {},
    outfits = {},
    sleeping = false,
    lastUpdate = os.time()
  }
end

local function findItemConfig(id)
  local items = require("data.items")
  for _,it in ipairs(items) do
    if it.id == id then
      return it
    end
  end
  return nil
end

local spriteColor = {1,1,1}

function Pet.load()
  local s = Save.load()
  if s then
    s = setmetatable(s, Pet)
    s:applyOfflineDecay()
    if not s.outfits then
      s.outfits = {}
    end
    return s
  else
    return setmetatable(defaultPet(), Pet)
  end
end

function Pet:save()
  self.lastUpdate = os.time()
  Save.save(self)
end

function Pet:applyOfflineDecay()
  local currentTime = os.time()
  local lastTime = self.lastUpdate or currentTime
  local deltaSeconds = math.max(0, currentTime - lastTime)
  
  if deltaSeconds > 0 then
    if self.sleeping then
      self:changeStat("energy", cfg.sleep.energyPerMinute * (deltaSeconds / 60))
      if self.energy >= 100 then
        self.sleeping = false
      end
    else
      local minutes = deltaSeconds / 60
      self:hungerAdd(-cfg.decay.hunger * minutes)
      self:changeStat("cleanliness", -cfg.decay.cleanliness * minutes)
      self:changeStat("energy", -cfg.decay.energy * minutes)
      self:changeStat("happiness", -cfg.decay.happiness * minutes)
    end
  end
  
  self.lastUpdate = currentTime
end

function Pet:updateDecay(deltaSeconds)
  -- decaimento por segundo (config usa rates per minute)
  local minutes = deltaSeconds / 60
  self:hungerAdd(-cfg.decay.hunger * minutes)
  self:changeStat("cleanliness", -cfg.decay.cleanliness * minutes)
  self:changeStat("happiness", -cfg.decay.happiness * minutes)

  if self.sleeping then
    self:changeStat("energy", cfg.sleep.energyPerMinute * minutes)
    spriteColor = {0.5, 0.5, 0.5}
    if self.energy >= 100 then
      self:sleepWakeUp()
    end
  else
    self:changeStat("energy", -cfg.decay.energy * minutes)
  end

  self.lastUpdate = os.time()
end

function Pet:clampStat(v)
  if v < 0 then return 0 end
  if v > 100 then return 100 end
  return v
end

function Pet:changeStat(stat, delta)
  self[stat] = self:clampStat(self[stat] + delta)
end

function Pet:hungerAdd(delta) self:changeStat("hunger", delta) end

function Pet:startSleep()
  self.sleeping = true
  Save.autoSave(self)
end

function Pet:sleepWakeUp()
  if self.sleeping then
    self.sleeping = false
    spriteColor = {1, 1, 1}
    Save.autoSave(self)
  end
end

function Pet:addXP(amount)
  self.xp = (self.xp or 0) + amount
  while self.xp >= cfg.levelXP do
    self.xp = self.xp - cfg.levelXP
    self.level = self.level + 1
    self.coins = self.coins + cfg.levelRewardCoins
  end
end

function Pet:getVisualState()
  if self.sleeping then
    return "sleeping"
  end
  if self.cleanliness < 40 then
    return "dirty"
  end
  if self.energy < 35 then
    return "tired"
  end
  if self.energy > 70 then
    return "rested"
  end
  if self.happiness < 40 then
    return "sad"
  end
  if self.happiness > 70 then
    return "happy"
  end
  return "clean"
end

function Pet:getStateLabel()
  local labels = {
    sleeping = "Dormindo",
    dirty = "Sujo",
    clean = "Limpo",
    happy = "Feliz",
    sad = "Triste",
    tired = "Cansado",
    rested = "Descansado"
  }
  return labels[self:getVisualState()] or "Normal"
end

function Pet:drawCosmetic(x, y, itemSprites, petSprite)
  local scale = SCALE_FACTOR
  local baseX = x - petSprite:getWidth() * scale / 2
  local baseY = y - petSprite:getHeight() * scale / 2

  for slot, itemId in pairs(self.outfits) do
    local itemConfig = findItemConfig(itemId)
    if itemConfig and itemConfig.type == "cosmetic" then
      local sprite = itemSprites and itemSprites[itemId]
      if sprite then
        love.graphics.setColor(spriteColor)
        local offsetX = itemConfig.position.x * scale
        local offsetY = itemConfig.position.y * scale
        love.graphics.draw(sprite, baseX + offsetX, baseY + offsetY, 0, scale, scale)
      end
    end
  end
end

function Pet:draw(x,y, sprites, itemSprites)
  local state = self:getVisualState()
  local sprite = sprites and sprites[state]
  local scale = SCALE_FACTOR
  local drawX = x - sprite:getWidth() * scale / 2
  local drawY = y - sprite:getHeight() * scale / 2

  love.graphics.setColor(spriteColor)
  love.graphics.draw(sprite, drawX, drawY, 0, scale, scale)

  self:drawCosmetic(x, y, itemSprites, sprite)
end


function Pet:hasItem(id)
  return (self.inventory[id] or 0) > 0
end

function Pet:useItemById(id)
  local items = require("data.items")
  local itemConfig
  for _,it in ipairs(items) do if it.id == id then itemConfig = it; break end end
  if not itemConfig then return false end

  local count = self.inventory[id] or 0
  if count <= 0 then return false end
  if itemConfig.type ~= "cosmetic" then
    self.inventory[id] = count - 1
  end

  if itemConfig.type == "food" then
    self:hungerAdd(itemConfig.hungerRestore or 0)
    self:changeStat("cleanliness", -(itemConfig.cleanlinessPenalty or 0))
    self:addXP(3)
  elseif itemConfig.type == "hygiene" then
    self:changeStat("cleanliness", itemConfig.cleanRestore or 40)
    self:addXP(2)
  elseif itemConfig.type == "cosmetic" then
    if itemConfig.slot then
      if self.outfits[itemConfig.slot] == id then
        self.outfits[itemConfig.slot] = nil  -- unequip
      else
        self.outfits[itemConfig.slot] = id  -- equip
      end
    end
    self:addXP(1)
  end

  Save.autoSave(self)
  return true
end

return Pet
