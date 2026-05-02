-- main.lua
local Pet = require("entities.pet")
local Save = require("entities.save")
local UI = require("ui.ui")
local MinigameSelector = require("ui.minigame_selector")
local MinigameCatch = require("minigames.catch")
local MinigameJump = require("minigames.jump")
local Store = require("ui.store")
local Settings = require("ui.settings")
local Audio = require("audio")
local cfg = require("data.config")

local pet, ui, minigame, store, minigameSelector, settings
local petSprites = {}
local itemSprites = {}
local gameState = "main" -- "main", "minigame_select", "minigame", "store"
local gameBackgroundImage = nil
local push = require("lib.push")

local _, _, windowWidth, windowHeight = love.window.getSafeArea()
push:setupScreen(cfg.gameWidth, cfg.gameHeight, windowWidth, windowHeight, {fullscreen = false, resizable = true})

function love.resize(w, h)
  return push:resize(w, h)
end

function love.load()
  love.graphics.setDefaultFilter("nearest","nearest")
  pet = Pet.load()
  ui = UI.new(pet)
  minigame = nil
  store = Store.new(pet)
  settings = Settings.new(pet)

  -- Load pet sprites
  local states = {"clean", "dirty", "happy", "sad", "tired", "rested", "sleeping"}
  for _, state in ipairs(states) do
    local path = "assets/sprites/pet/pet-" .. state .. ".png"
    if love.filesystem.getInfo(path) then
      petSprites[state] = love.graphics.newImage(path)
    else
      print("Warning: Sprite not found: " .. path)
    end
  end

  -- Load item sprites
  local itemSpriteNames = {
    scarf_red = "red-scarf.png",
    glasses_black = "black-sunglasses.png",
    hat_blue = "blue-hat.png",
    hat_red = "red-hat.png",
    suit_blue = "blue-suit.png",
  }
  for id, filename in pairs(itemSpriteNames) do
    local path = "assets/sprites/items/" .. filename
    if love.filesystem.getInfo(path) then
      itemSprites[id] = love.graphics.newImage(path)
    else
      print("Warning: Item sprite not found: " .. path)
    end
  end

  gameBackgroundImage = love.graphics.newImage("assets/sprites/background.jpeg")
  minigameSelector = MinigameSelector.new()

  local font = love.graphics.newFont(12, "mono")
  font:setFilter("nearest")
  love.graphics.setFont(font)

  Audio.load()
  Audio.setMusicVolume(pet.musicVolume or 0.65)
  Audio.setAmbienceVolume(pet.ambienceVolume or 0.45)
  Audio.setEffectsVolume(pet.effectsVolume or 0.85)
  Audio.start()
end

local accum = 0
function love.update(dt)
  accum = accum + dt
  if accum >= 1 then
    pet:updateDecay(accum)
    accum = 0
    Save.autoSave(pet)
  end

  if gameState == "main" then
    ui:update(dt)
  elseif gameState == "minigame" and minigame then
    minigame:update(dt)
    if minigame.finished then
      local rewardCoins, happyGain = minigame:getResult()
      pet.coins = pet.coins + rewardCoins
      pet:changeStat("happiness", happyGain)
      pet:addXP(math.floor(rewardCoins/2))
      gameState = "main"
      minigame = nil
    end
  end

  Audio.update(dt)
end

function love.draw()
  push:start()
  if gameState == "main" then
    love.graphics.clear(1,1,1)

    if pet.sleeping then
      love.graphics.setColor(0.5, 0.5, 0.5)
    else
      love.graphics.setColor(1, 1, 1)
    end
    love.graphics.draw(gameBackgroundImage, 0, 0, 0, cfg.gameWidth / gameBackgroundImage:getWidth(), cfg.gameHeight / gameBackgroundImage:getHeight())

    local centerX = cfg.gameWidth / 2
    local centerY = cfg.gameHeight / 2
    pet:draw(centerX, centerY, petSprites, itemSprites)
    ui:draw()
  elseif gameState == "minigame_select" then
    minigameSelector:draw()
  elseif gameState == "minigame" then
    minigame:draw()
  elseif gameState == "store" then
    love.graphics.clear(0.95,0.95,1)
    store:draw()
  elseif gameState == "settings" then
    love.graphics.clear(0.98,0.98,1)
    settings:draw()
  end
  push:finish()
end

function love.mousepressed(x,y,b)
  x, y = push:toGame(x, y)
  if x == nil or y == nil then return end

  if b == 1 then
    Audio.playClick()
  end

  if gameState == "main" then
    local action = ui:mousepressed(x,y,b)
    print("Action:", action, x, y)
    if action == "sleep" then
      pet:startSleep()
    end
    if action == "play" then
      gameState = "minigame_select"
    end
    if action == "open_store" then
      gameState = "store"
    end
    if action == "settings" then
      gameState = "settings"
    end
  elseif gameState == "minigame_select" then
    local action = minigameSelector:mousepressed(x, y, b)
    if action == "catch" then
      minigame = MinigameCatch.new()
      gameState = "minigame"
    elseif action == "jump" then
      minigame = MinigameJump.new()
      gameState = "minigame"
    elseif action == "back" then
      gameState = "main"
    end
  elseif gameState == "minigame" and minigame then
    minigame:mousepressed(x,y,b)
  elseif gameState == "store" then
    local action = store:mousepressed(x,y,b)
    if action == "close" then
      gameState = "main"
    end
  elseif gameState == "settings" then
    local action = settings:mousepressed(x,y,b)
    if action == "close" then
      gameState = "main"
    end
  end
end

function love.mousereleased(x,y,b)
  x, y = push:toGame(x, y)
  
  if gameState == "minigame" and minigame then
    minigame:mousereleased(x,y,b)
  end
end

function love.keypressed(key)
  if key == "escape" then
    if gameState == "minigame" then
      gameState = "main"
      minigame = nil
    elseif gameState == "minigame_select" then
      gameState = "main"
    else
      love.event.quit()
    end
  end
end

function love.quit()
  pet:save()
end

