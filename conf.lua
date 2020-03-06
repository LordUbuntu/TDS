function love.conf(t)
	t.identity = "Top Down Shooter"
	t.window.title = "TDS"
	t.window.width = 800
	t.window.height = 600
	t.window.resizable = true
	t.window.fullscreen = true 
	t.window.fullscreentype = "desktop"

	-- Disabled Modules
	t.modules.touch = false
	t.modules.joystick = false

	io.stdout:setvbuf("no")
end
