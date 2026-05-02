function love.conf(t)
  t.window.title = "Furão - Protótipo"
  local ok, cfg = pcall(require, "data.config")
  if ok and cfg.gameWidth and cfg.gameHeight then
    t.window.width = cfg.gameWidth
    t.window.height = cfg.gameHeight
  else
    t.window.width = 360
    t.window.height = 640
  end
end
