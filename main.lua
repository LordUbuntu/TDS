-- LOAD --
function love.load()
	--
end

-- DRAW --
function love.draw()
	love.graphics.print("x: "..mouse_x..", y: "..mouse_y, 0, 0)
	love.graphics.print("tan: "..math.tan(mouse_y/mouse_x), 100, 0)
end

-- UPDATE --
function love.update(dt)
	mouse_x, mouse_y = love.mouse.getPosition()
end
