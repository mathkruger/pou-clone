local Audio = {}
Audio.__index = Audio

Audio.bgmSources = {}
Audio.currentBgm = 1
Audio.ambience = nil
Audio.click = nil
Audio.eat = nil
Audio.bath = nil
Audio.musicVolume = 0.65
Audio.ambienceVolume = 0.45
Audio.effectsVolume = 0.85
Audio.started = false

local function clampVolume(value)
  return math.max(0, math.min(1, value or 0))
end

local function safePlay(source)
  if not source then
    return
  end

  if source.stop then
    source:stop()
  end
  if source.play then
    source:play()
  end
end

function Audio.load()
  Audio.bgmSources[1] = love.audio.newSource("assets/audio/bgm-1.mp3", "stream")
  Audio.bgmSources[2] = love.audio.newSource("assets/audio/bgm-2.mp3", "stream")
  for _, source in ipairs(Audio.bgmSources) do
    source:setLooping(false)
    source:setVolume(Audio.musicVolume)
  end

  Audio.ambience = love.audio.newSource("assets/audio/ambiance.wav", "stream")
  Audio.ambience:setLooping(true)
  Audio.ambience:setVolume(Audio.ambienceVolume)

  Audio.click = love.audio.newSource("assets/audio/click.wav", "static")
  Audio.eat = love.audio.newSource("assets/audio/eat.wav", "static")
  Audio.bath = love.audio.newSource("assets/audio/bath.wav", "static")

  if Audio.click then
    Audio.click:setVolume(Audio.effectsVolume)
  end
  if Audio.eat then
    Audio.eat:setVolume(Audio.effectsVolume)
  end
  if Audio.bath then
    Audio.bath:setVolume(Audio.effectsVolume)
  end

  Audio.started = false
end

function Audio.setMusicVolume(value)
  Audio.musicVolume = clampVolume(value)
  for _, source in ipairs(Audio.bgmSources) do
    source:setVolume(Audio.musicVolume)
  end
end

function Audio.setAmbienceVolume(value)
  Audio.ambienceVolume = clampVolume(value)
  if Audio.ambience then
    Audio.ambience:setVolume(Audio.ambienceVolume)
  end
end

function Audio.setEffectsVolume(value)
  Audio.effectsVolume = clampVolume(value)
  if Audio.click then
    Audio.click:setVolume(Audio.effectsVolume)
  end
  if Audio.eat then
    Audio.eat:setVolume(Audio.effectsVolume)
  end
  if Audio.bath then
    Audio.bath:setVolume(Audio.effectsVolume)
  end
end

function Audio.getMusicVolume()
  return Audio.musicVolume
end

function Audio.getAmbienceVolume()
  return Audio.ambienceVolume
end

function Audio.getEffectsVolume()
  return Audio.effectsVolume
end

function Audio.start()
  if not Audio.started then
    if Audio.ambience then
      Audio.ambience:play()
    end
    if Audio.bgmSources[Audio.currentBgm] then
      Audio.bgmSources[Audio.currentBgm]:play()
    end
    Audio.started = true
  end
end

function Audio.update(dt)
  if not Audio.started or not Audio.bgmSources[Audio.currentBgm] then
    return
  end

  local current = Audio.bgmSources[Audio.currentBgm]
  if current and not current:isPlaying() then
    Audio.currentBgm = Audio.currentBgm % #Audio.bgmSources + 1
    safePlay(Audio.bgmSources[Audio.currentBgm])
  end
end

function Audio.playClick()
  safePlay(Audio.click)
end

function Audio.playEat()
  safePlay(Audio.eat)
end

function Audio.playBath()
  safePlay(Audio.bath)
end

return Audio
