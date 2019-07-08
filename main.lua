--[[
TODO:
- Express player motion as the sum of y and x velocity vectors
- take y and x input independently and simultaneously
- limit player speed, and provide friction (also limit player position within window)
- implement bullets
- implement enemies
]]--

-- LOAD --
function love.load()
	width, height = love.graphics.getDimensions()

	-- global properties
	speed = 100

	-- player properties
	player = { x = 50, y = 50 }

end

-- DRAW --
function love.draw()
	-- draw placeholder player
	love.graphics.rectangle("fill", player.x-5, player.y-5, 10, 10)
	love.graphics.line(player.x, player.y, mouse_x, mouse_y)

	-- print information
	love.graphics.print("player: "..player.x..", "..player.y, 0, 0)
	love.graphics.print("mouse: "..mouse_x..", "..mouse_y, 0, 10)
end

-- UPDATE --
function love.update(dt)
	mouse_x, mouse_y = love.mouse.getPosition()

	-- move player by velocity amount
	if love.keyboard.isDown('w') then
		player.y = player.y - speed * dt
	elseif love.keyboard.isDown('s') then
		player.y = player.y + speed * dt
	end

	if love.keyboard.isDown('a') then
		player.x = player.x - speed * dt
	elseif love.keyboard.isDown('d') then
		player.x = player.x + speed * dt
	end

	-- TODO cap speed
	-- TODO boundry collision for window

end
