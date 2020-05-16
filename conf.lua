function love.conf(t)
    t.version = "11.3"
	t.identity = "Top Down Shooter"
	t.window.title = "TDS"
	t.window.width = 800
	t.window.height = 600
	t.window.resizable = true

	-- Disabled Modules
	t.modules.touch = false
    t.modules.physics = false
	t.modules.joystick = false

	io.stdout:setvbuf("no")
end
