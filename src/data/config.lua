-- data/config.lua
local cfg = {}

cfg.gameWidth = 480
cfg.gameHeight = 800

cfg.decay = {
  hunger = 1.0,      -- por minuto
  cleanliness = 0.5, -- por minuto
  energy = 0.66,     -- por minuto
  happiness = 0.33   -- por minuto
}

cfg.sleep = {
  energyPerMinute = 30
}

cfg.levelXP = 100
cfg.levelRewardCoins = 20

return cfg
