-- src/ui/settings.lua
local cfg = require("data.config")
local Save = require("entities.save")
local UIElements = require("ui.ui_elements")
local Audio = require("audio")

local Settings = {}
Settings.__index = Settings

function Settings.new(pet)
  local self = setmetatable({}, Settings)
  self.ui = UIElements.new()
  self.pet = pet
  return self
end

local function volumeLabel(value)
  return tostring(math.floor((value or 0) * 100 + 0.5)) .. " %"
end

local function clampValue(value)
  return math.max(0, math.min(1, value or 0))
end

function Settings:draw()
  local panelX = 30
  local panelY = 40
  local panelWidth = cfg.gameWidth - 2 * panelX
  local panelHeight = cfg.gameHeight - panelY - 20
  self.ui:drawPanel(panelX, panelY, panelWidth, panelHeight, "Configurações")

  local closeX = panelX + panelWidth - 45
  local closeY = panelY + 15
  self.ui:drawButton(closeX, closeY, 30, 30, "X", false)

  local rows = {
    { id = "music", label = "Música", value = Audio.getMusicVolume() },
    { id = "ambience", label = "Ambiência", value = Audio.getAmbienceVolume() },
    { id = "effects", label = "Efeitos", value = Audio.getEffectsVolume() },
  }

  local labelX = panelX + 30
  local controlX = panelX + 240
  local rowHeight = 70
  local startY = panelY + 90
  local buttonSize = 40
  local valueBoxWidth = 120
  local spacing = 12

  for i, row in ipairs(rows) do
    local y = startY + (i - 1) * rowHeight
    self.ui:drawText(labelX, y, row.label, 16, {0.1, 0.1, 0.1, 1})
    self.ui:drawButton(controlX, y, buttonSize, buttonSize, "-", false)
    self.ui:drawCard(controlX + buttonSize + spacing, y, valueBoxWidth, buttonSize, false)
    self.ui:drawText(controlX + buttonSize + spacing + 10, y + 8, volumeLabel(row.value), 14, {0.15, 0.15, 0.15, 1})
    self.ui:drawButton(controlX + buttonSize + spacing + valueBoxWidth + spacing, y, buttonSize, buttonSize, "+", false)
  end

  self.ui:drawFooter("Ajuste os volumes de música, ambiente e efeitos.", panelX, panelY + panelHeight - 40, panelWidth)
end

function Settings:mousepressed(x, y, b)
  if b ~= 1 then
    return nil
  end

  local panelX = 30
  local panelY = 40
  local panelWidth = cfg.gameWidth - 2 * panelX
  local closeX = panelX + panelWidth - 45
  local closeY = panelY + 15
  if x >= closeX and x <= closeX + 30 and y >= closeY and y <= closeY + 30 then
    return "close"
  end

  local rows = {
    { id = "music", value = Audio.getMusicVolume() },
    { id = "ambience", value = Audio.getAmbienceVolume() },
    { id = "effects", value = Audio.getEffectsVolume() },
  }

  local controlX = panelX + 240
  local rowHeight = 70
  local startY = panelY + 90
  local buttonSize = 40
  local valueBoxWidth = 120
  local spacing = 12

  for i, row in ipairs(rows) do
    local rowY = startY + (i - 1) * rowHeight
    local minusX = controlX
    local plusX = controlX + buttonSize + spacing + valueBoxWidth + spacing
    if x >= minusX and x <= minusX + buttonSize and y >= rowY and y <= rowY + buttonSize then
      local newValue = clampValue(row.value - 0.05)
      if row.id == "music" then
        Audio.setMusicVolume(newValue)
        if self.pet then self.pet.musicVolume = newValue end
      elseif row.id == "ambience" then
        Audio.setAmbienceVolume(newValue)
        if self.pet then self.pet.ambienceVolume = newValue end
      elseif row.id == "effects" then
        Audio.setEffectsVolume(newValue)
        if self.pet then self.pet.effectsVolume = newValue end
      end
      if self.pet then Save.autoSave(self.pet) end
      return nil
    end
    if x >= plusX and x <= plusX + buttonSize and y >= rowY and y <= rowY + buttonSize then
      local newValue = clampValue(row.value + 0.05)
      if row.id == "music" then
        Audio.setMusicVolume(newValue)
        if self.pet then self.pet.musicVolume = newValue end
      elseif row.id == "ambience" then
        Audio.setAmbienceVolume(newValue)
        if self.pet then self.pet.ambienceVolume = newValue end
      elseif row.id == "effects" then
        Audio.setEffectsVolume(newValue)
        if self.pet then self.pet.effectsVolume = newValue end
      end
      if self.pet then Save.autoSave(self.pet) end
      return nil
    end
  end

  return nil
end

return Settings
