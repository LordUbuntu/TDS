function love.conf(t)
    t.identity = "Top Down Shooter"
    t.version = "11.3"
    t.console = false
 
    t.window.title = "TDS"
    t.window.width = 800
    t.window.height = 600
    t.window.minwidth = 100
    t.window.minheight = 100
    t.window.resizable = true
    t.window.fullscreen = false
    t.window.fullscreentype = "desktop"
    t.window.vsync = 1
    t.window.msaa = 1
 
	t.modules.touch = false
    t.modules.physics = false
	t.modules.joystick = false
end
